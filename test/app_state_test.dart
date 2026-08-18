import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pucesm_app/app/app_state.dart';
import 'package:pucesm_app/app/preference_keys.dart';
import 'package:pucesm_app/models/user_profile.dart';

void main() {
  test('migra preferencias heredadas sin perder el perfil', () async {
    SharedPreferences.setMockInitialValues({
      PreferenceKeys.legacyDarkMode: true,
      PreferenceKeys.legacyTextScale: 1.2,
      PreferenceKeys.legacyFullName: 'Joao Dueñas',
      PreferenceKeys.legacyEmail: 'joao@example.com',
      PreferenceKeys.legacyCareer: 'Software',
    });

    final state = AppState();
    await state.load();

    expect(state.darkMode, isTrue);
    expect(state.textScale, 1.2);
    expect(state.profileName, 'Joao Dueñas');
    expect(state.profileProgram, 'Software');

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(PreferenceKeys.profileName), 'Joao Dueñas');
    expect(prefs.containsKey(PreferenceKeys.legacyFullName), isFalse);
  });

  test('actualiza y persiste un perfil canónico', () async {
    SharedPreferences.setMockInitialValues({});
    final state = AppState();
    await state.load();

    await state.updateProfile(
      fullName: '  Estudiante PUCE  ',
      email: '  estudiante@puce.edu.ec  ',
      level: StudyLevel.posgrado,
      program: 'Maestría en Derecho Penal',
    );

    expect(state.profileName, 'Estudiante PUCE');
    expect(state.profileEmail, 'estudiante@puce.edu.ec');
    expect(state.studyLevel, StudyLevel.posgrado);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(PreferenceKeys.profileLevel), 'posgrado');
    expect(
      prefs.getString(PreferenceKeys.profileProgram),
      'Maestría en Derecho Penal',
    );
  });

  test('persiste PUCE TEC como un nivel académico independiente', () async {
    SharedPreferences.setMockInitialValues({});
    final state = AppState();
    await state.load();

    await state.updateProfile(
      fullName: 'Estudiante Tecnológico',
      email: 'tecnologia@puce.edu.ec',
      level: StudyLevel.pucetec,
      program: 'Tecnología Superior en Marketing Digital',
    );

    expect(state.studyLevel, StudyLevel.pucetec);
    expect(state.userProfile.studyLevel.label, 'PUCE TEC');

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(PreferenceKeys.profileLevel), 'pucetec');
    expect(
      prefs.getString(PreferenceKeys.profileProgram),
      'Tecnología Superior en Marketing Digital',
    );
  });
}
