import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pucesm_app/app/app_state.dart';
import 'package:pucesm_app/screens/onboarding/onboarding_screen.dart';

void main() {
  testWidgets('onboarding permite cambiar entre grado y posgrado', (
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
    expect(find.text('Carrera (Grado)'), findsOneWidget);

    await tester.tap(find.text('Posgrado'));
    await tester.pump();

    expect(find.text('Programa (Posgrado)'), findsOneWidget);
  });
}
