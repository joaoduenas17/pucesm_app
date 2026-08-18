import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pucesm_app/app/app_state.dart';
import 'package:pucesm_app/screens/onboarding/onboarding_screen.dart';

void main() {
  testWidgets('onboarding muestra el logo y permite elegir los tres niveles', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final state = AppState();
    await state.load();

    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: state,
        child: const MaterialApp(home: OnboardingScreen()),
      ),
    );

    expect(find.text('Bienvenido a PUCE Manabí App 👋'), findsOneWidget);
    expect(find.bySemanticsLabel('Logo de PUCE Manabí'), findsOneWidget);
    expect(find.text('Carrera (Grado)'), findsOneWidget);

    await tester.tap(find.text('Posgrado'));
    await tester.pump();

    expect(find.text('Programa (Posgrado)'), findsOneWidget);

    await tester.ensureVisible(find.text('PUCE TEC'));
    await tester.tap(find.text('PUCE TEC'));
    await tester.pump();

    expect(find.text('Carrera tecnológica (PUCE TEC)'), findsOneWidget);
    expect(find.text('Tecnología Superior en Acuicultura'), findsOneWidget);
  });
}
