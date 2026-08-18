enum CalendarCategory {
  all,
  institucional,
  grado,
  posgrado,
  pucetecGrado,
  personal,
}

extension CalendarCategoryX on CalendarCategory {
  String get label {
    switch (this) {
      case CalendarCategory.all:
        return 'Todos';
      case CalendarCategory.institucional:
        return 'Institucional';
      case CalendarCategory.grado:
        return 'Grado';
      case CalendarCategory.posgrado:
        return 'Posgrado';
      case CalendarCategory.pucetecGrado:
        return 'PUCE TEC / Grado';
      case CalendarCategory.personal:
        return 'Personal';
    }
  }

  String get badgeLabel => label.toUpperCase();
}

class CalendarEvent {
  final String id;
  final CalendarCategory category;
  final String title;
  final String? description;
  final DateTime start;
  final DateTime? end;
  final bool isPersonal;

  const CalendarEvent({
    required this.id,
    required this.category,
    required this.title,
    required this.start,
    required this.isPersonal,
    this.description,
    this.end,
  });

  factory CalendarEvent.academic({
    required CalendarCategory category,
    required String title,
    required DateTime start,
    String? description,
    DateTime? end,
  }) {
    return CalendarEvent(
      id: 'academic-${start.toIso8601String()}-$title',
      category: category,
      title: title,
      description: description,
      start: dateOnly(start),
      end: end == null ? null : dateOnly(end),
      isPersonal: false,
    );
  }

  factory CalendarEvent.personal({
    required String id,
    required String title,
    required DateTime start,
    String? description,
    DateTime? end,
  }) {
    return CalendarEvent(
      id: id,
      category: CalendarCategory.personal,
      title: title.trim(),
      description: _cleanOptionalText(description),
      start: dateOnly(start),
      end: end == null ? null : dateOnly(end),
      isPersonal: true,
    );
  }

  bool get isRange => end != null && !isSameCalendarDay(start, end!);

  bool occursOn(DateTime day) {
    final target = dateOnly(day);
    final first = dateOnly(start);
    final last = dateOnly(end ?? start);
    return !target.isBefore(first) && !target.isAfter(last);
  }

  CalendarEvent copyWith({
    String? title,
    String? description,
    DateTime? start,
    DateTime? end,
    bool clearEnd = false,
  }) {
    return CalendarEvent(
      id: id,
      category: category,
      title: (title ?? this.title).trim(),
      description: _cleanOptionalText(description ?? this.description),
      start: dateOnly(start ?? this.start),
      end: clearEnd ? null : (end == null ? this.end : dateOnly(end)),
      isPersonal: isPersonal,
    );
  }

  Map<String, dynamic> toPersonalJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'start': start.toIso8601String(),
      'end': end?.toIso8601String(),
    };
  }

  static CalendarEvent? tryParsePersonal(Object? value) {
    if (value is! Map) return null;

    final id = value['id']?.toString().trim() ?? '';
    final title = value['title']?.toString().trim() ?? '';
    final start = DateTime.tryParse(value['start']?.toString() ?? '');
    final parsedEnd = DateTime.tryParse(value['end']?.toString() ?? '');

    if (id.isEmpty || title.isEmpty || start == null) return null;
    if (parsedEnd != null && dateOnly(parsedEnd).isBefore(dateOnly(start))) {
      return null;
    }

    return CalendarEvent.personal(
      id: id,
      title: title,
      description: value['description']?.toString(),
      start: start,
      end: parsedEnd,
    );
  }
}

bool isSameCalendarDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

DateTime dateOnly(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

DateTime firstDayOfMonth(DateTime date) {
  return DateTime(date.year, date.month);
}

Iterable<DateTime> monthsTouched(DateTime start, DateTime end) sync* {
  var cursor = firstDayOfMonth(start);
  final last = firstDayOfMonth(end);
  while (!cursor.isAfter(last)) {
    yield cursor;
    cursor = DateTime(cursor.year, cursor.month + 1);
  }
}

String? _cleanOptionalText(String? value) {
  final cleaned = value?.trim() ?? '';
  return cleaned.isEmpty ? null : cleaned;
}
