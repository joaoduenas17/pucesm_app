import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../app/preference_keys.dart';
import '../models/calendar_event.dart';

abstract final class PersonalCalendarStore {
  static Future<List<CalendarEvent>> load() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(PreferenceKeys.personalCalendarEvents);
    if (raw == null || raw.trim().isEmpty) return [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];

      return decoded
          .map(CalendarEvent.tryParsePersonal)
          .whereType<CalendarEvent>()
          .toList()
        ..sort((a, b) => a.start.compareTo(b.start));
    } on FormatException {
      return [];
    }
  }

  static Future<void> save(List<CalendarEvent> events) async {
    final personalEvents = events.where((event) => event.isPersonal).toList()
      ..sort((a, b) => a.start.compareTo(b.start));
    final encoded = jsonEncode(
      personalEvents.map((event) => event.toPersonalJson()).toList(),
    );

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(PreferenceKeys.personalCalendarEvents, encoded);
  }
}
