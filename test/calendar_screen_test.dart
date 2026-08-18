import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pucesm_app/app/app_state.dart';
import 'package:pucesm_app/screens/calendar/calendar_screen.dart';
import 'package:pucesm_app/services/personal_calendar_store.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es_EC', null);
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('agenda y mes se adaptan a una pantalla pequeña', (tester) async {
    _setSmallScreen(tester);
    await _pumpCalendar(tester, textScale: 1.3);

    expect(find.text('Agenda'), findsOneWidget);
    expect(find.text('Mes'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.ensureVisible(find.text('Mes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mes').hitTestable());
    await tester.pumpAndSettle();

    expect(find.text('Hoy'), findsOneWidget);
    expect(find.byType(GridView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('permite crear y conservar un evento personal', (tester) async {
    _setSmallScreen(tester);
    await _pumpCalendar(tester);

    await tester.tap(find.text('Crear'));
    await tester.pumpAndSettle();

    expect(find.text('Nuevo evento personal'), findsOneWidget);
    await tester.enterText(
      find.byType(TextFormField).first,
      'Ensayo de sustentación',
    );
    await tester.ensureVisible(find.text('Crear evento'));
    await tester.tap(find.text('Crear evento'));
    await tester.pumpAndSettle();

    final restored = await PersonalCalendarStore.load();
    expect(restored, hasLength(1));
    expect(restored.single.title, 'Ensayo de sustentación');
    expect(find.text('Evento personal creado.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpCalendar(WidgetTester tester, {double textScale = 1}) async {
  final state = AppState();
  await state.load();

  await tester.pumpWidget(
    ChangeNotifierProvider<AppState>.value(
      value: state,
      child: MaterialApp(
        locale: const Locale('es', 'EC'),
        supportedLocales: const [Locale('es', 'EC'), Locale('es')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        builder: (context, child) {
          final media = MediaQuery.of(context);
          return MediaQuery(
            data: media.copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          );
        },
        home: const CalendarScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void _setSmallScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(320, 568);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}
