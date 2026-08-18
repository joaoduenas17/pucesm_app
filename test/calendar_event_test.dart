import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pucesm_app/app/preference_keys.dart';
import 'package:pucesm_app/models/calendar_event.dart';
import 'package:pucesm_app/services/personal_calendar_store.dart';

void main() {
  group('CalendarEvent', () {
    test('incluye ambos extremos de un evento de varios días', () {
      final event = CalendarEvent.personal(
        id: 'entrega-1',
        title: 'Entrega de tesis',
        start: DateTime(2026, 8, 18),
        end: DateTime(2026, 8, 20),
      );

      expect(event.occursOn(DateTime(2026, 8, 17)), isFalse);
      expect(event.occursOn(DateTime(2026, 8, 18, 23, 59)), isTrue);
      expect(event.occursOn(DateTime(2026, 8, 20)), isTrue);
      expect(event.occursOn(DateTime(2026, 8, 21)), isFalse);
    });

    test('descarta datos personales incompletos o fechas invertidas', () {
      expect(CalendarEvent.tryParsePersonal({'title': 'Sin id'}), isNull);
      expect(
        CalendarEvent.tryParsePersonal({
          'id': 'invalido',
          'title': 'Fecha invertida',
          'start': '2026-08-20T00:00:00.000',
          'end': '2026-08-19T00:00:00.000',
        }),
        isNull,
      );
    });
  });

  group('PersonalCalendarStore', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('guarda y recupera solo eventos personales en orden', () async {
      final later = CalendarEvent.personal(
        id: 'personal-2',
        title: 'Exposición final',
        start: DateTime(2026, 9, 10),
      );
      final earlier = CalendarEvent.personal(
        id: 'personal-1',
        title: 'Ensayo de sustentación',
        description: 'Aula 3',
        start: DateTime(2026, 8, 25),
      );
      final academic = CalendarEvent.academic(
        category: CalendarCategory.institucional,
        title: 'Evento institucional',
        start: DateTime(2026, 8, 1),
      );

      await PersonalCalendarStore.save([later, academic, earlier]);
      final restored = await PersonalCalendarStore.load();

      expect(restored.map((event) => event.id), ['personal-1', 'personal-2']);
      expect(restored.first.description, 'Aula 3');
      expect(restored.every((event) => event.isPersonal), isTrue);
    });

    test('tolera almacenamiento dañado sin bloquear el calendario', () async {
      SharedPreferences.setMockInitialValues({
        PreferenceKeys.personalCalendarEvents: '{no-es-json',
      });

      expect(await PersonalCalendarStore.load(), isEmpty);
    });
  });
}
