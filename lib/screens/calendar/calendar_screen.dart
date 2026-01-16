import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:add_2_calendar/add_2_calendar.dart' as a2c;
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/notification_service.dart';

/// Categorías del calendario PUCE (según tu captura).
/// - all: solo para el filtro "Todos" (muestra todo)
/// - los demás: categorías reales del calendario
enum CalendarCategory {
  all,
  todos,
  grado,
  posgrado,
  pucetecGrado,
}

class CalendarEvent {
  final CalendarCategory category;
  final String title;
  final DateTime start;
  final DateTime? end; // si es null, es evento de 1 día

  const CalendarEvent({
    required this.category,
    required this.title,
    required this.start,
    this.end,
  });

  bool get isRange => end != null && !isSameDay(start, end!);
}

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
DateTime _firstDayOfMonth(DateTime d) => DateTime(d.year, d.month, 1);

/// Devuelve los primeros días de cada mes que intersecta el rango [start..end]
Iterable<DateTime> _monthsTouched(DateTime start, DateTime end) sync* {
  var cursor = _firstDayOfMonth(start);
  final last = _firstDayOfMonth(end);
  while (!cursor.isAfter(last)) {
    yield cursor;
    cursor = DateTime(cursor.year, cursor.month + 1, 1);
  }
}

/// ✅ Recorta rangos demasiado largos a solo un día (solo fecha de inicio)
/// Esto aplica a eventos como "Evaluación docente (oct -> mar)".
CalendarEvent _trimExcessiveRange(CalendarEvent e, {int maxDays = 45}) {
  if (e.end == null) return e;

  final start = _dateOnly(e.start);
  final end = _dateOnly(e.end!);
  final days = end.difference(start).inDays;

  // Si dura demasiado, se queda solo con el inicio.
  if (days > maxDays) {
    return CalendarEvent(
      category: e.category,
      title: e.title,
      start: e.start,
      end: null,
    );
  }

  return e;
}

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarCategory _filter = CalendarCategory.all;
  String _query = '';

  // ✅ EVENTOS REALES (solo los de tu captura OCT–ENE'26)
  final List<CalendarEvent> _allEvents = [
    // OCT 2025
    CalendarEvent(
      category: CalendarCategory.posgrado,
      title: 'Matrícula ordinaria',
      start: DateTime(2025, 9, 22),
      end: DateTime(2025, 10, 9),
    ),
    CalendarEvent(
      category: CalendarCategory.grado,
      title: 'Sexto examen de admisión general PAO 2025-2 (excepto Medicina)',
      start: DateTime(2025, 10, 8),
    ),
    CalendarEvent(
      category: CalendarCategory.pucetecGrado,
      title: 'Inicio de clases (todas las carreras, excepto Medicina)',
      start: DateTime(2025, 10, 13),
    ),
    CalendarEvent(
      category: CalendarCategory.posgrado,
      title: 'Inicio de clases Programas Híbridas Intersedes - Paralelo Nacional',
      start: DateTime(2025, 10, 13),
    ),
    CalendarEvent(
      category: CalendarCategory.posgrado,
      title: 'Inicio de clases Programas Sede Manabí',
      start: DateTime(2025, 10, 13),
    ),
    CalendarEvent(
      category: CalendarCategory.pucetecGrado,
      title: 'Borrado (todas las carreras, excluido Medicina)',
      start: DateTime(2025, 10, 13),
      end: DateTime(2025, 10, 15),
    ),
    CalendarEvent(
      category: CalendarCategory.pucetecGrado,
      title: 'Matrícula extraordinaria (todas las carreras, excepto Medicina)',
      start: DateTime(2025, 10, 13),
      end: DateTime(2025, 10, 24),
    ),
    CalendarEvent(
      category: CalendarCategory.posgrado,
      title: 'Matrícula extraordinaria',
      start: DateTime(2025, 10, 13),
      end: DateTime(2025, 10, 24),
    ),
    CalendarEvent(
      category: CalendarCategory.posgrado,
      title: 'Evaluación docente',
      start: DateTime(2025, 10, 20),
      end: DateTime(2026, 3, 20), // ⬅️ se recorta a 1 día por lógica
    ),
    CalendarEvent(
      category: CalendarCategory.posgrado,
      title: 'Registro de notas',
      start: DateTime(2025, 10, 20),
      end: DateTime(2026, 3, 20), // ⬅️ se recorta a 1 día por lógica
    ),
    CalendarEvent(
      category: CalendarCategory.pucetecGrado,
      title: 'Matrícula especial (Medicina)',
      start: DateTime(2025, 10, 13),
      end: DateTime(2025, 10, 24),
    ),
    CalendarEvent(
      category: CalendarCategory.pucetecGrado,
      title: 'Matrícula especial (todas las carreras, excepto Medicina)',
      start: DateTime(2025, 10, 27),
      end: DateTime(2025, 11, 7),
    ),
    CalendarEvent(
      category: CalendarCategory.grado,
      title: 'Borrado (Medicina)',
      start: DateTime(2025, 10, 27),
      end: DateTime(2025, 10, 31),
    ),

    // NOV 2025
    CalendarEvent(
      category: CalendarCategory.todos,
      title: 'Semana Interdisciplinar',
      start: DateTime(2025, 11, 5),
      end: DateTime(2025, 11, 7),
    ),
    CalendarEvent(
      category: CalendarCategory.pucetecGrado,
      title: 'Borrado (todas las carreras, excluido Medicina)',
      start: DateTime(2025, 11, 10),
      end: DateTime(2025, 11, 14),
    ),

    // DIC 2025
    CalendarEvent(
      category: CalendarCategory.todos,
      title: 'Ceremonias de incorporación',
      start: DateTime(2025, 11, 29),
      end: DateTime(2025, 12, 14),
    ),
    CalendarEvent(
      category: CalendarCategory.pucetecGrado,
      title: 'Evaluación docente 2025-2',
      start: DateTime(2025, 12, 1),
      end: DateTime(2026, 2, 20), // ⬅️ se recorta a 1 día por lógica
    ),
    CalendarEvent(
      category: CalendarCategory.grado,
      title: 'Examen final Octavo Semestre Enfermería',
      start: DateTime(2025, 12, 19),
    ),
    CalendarEvent(
      category: CalendarCategory.todos,
      title: 'Cierre de actividades académicas 2024',
      start: DateTime(2025, 12, 19),
    ),

    // ENE 2026
    CalendarEvent(
      category: CalendarCategory.todos,
      title: 'Vacaciones',
      start: DateTime(2025, 12, 22),
      end: DateTime(2026, 1, 1),
    ),
    CalendarEvent(
      category: CalendarCategory.todos,
      title: 'Inicio de actividades académicas y administrativas',
      start: DateTime(2026, 1, 2),
    ),
    CalendarEvent(
      category: CalendarCategory.grado,
      title: 'Registro de notas Octavo Semestre Enfermería',
      start: DateTime(2026, 1, 5),
      end: DateTime(2026, 1, 9),
    ),
    CalendarEvent(
      category: CalendarCategory.grado,
      title: 'Examen final Décimo Semestre Medicina',
      start: DateTime(2026, 1, 12),
      end: DateTime(2026, 1, 16),
    ),
    CalendarEvent(
      category: CalendarCategory.pucetecGrado,
      title:
          'Registro de aspirantes PAO 2026-1 (todas las carreras incluida Medicina)',
      start: DateTime(2026, 1, 13),
      end: DateTime(2026, 3, 28), // ⬅️ se recorta a 1 día por lógica
    ),
    CalendarEvent(
      category: CalendarCategory.posgrado,
      title: 'Registro de aspirantes PAO 2026-1',
      start: DateTime(2026, 1, 13),
      end: DateTime(2026, 4, 4), // ⬅️ se recorta a 1 día por lógica
    ),
    CalendarEvent(
      category: CalendarCategory.grado,
      title: 'Registro de notas Décimo Semestre Medicina',
      start: DateTime(2026, 1, 19),
      end: DateTime(2026, 1, 23),
    ),
    CalendarEvent(
      category: CalendarCategory.pucetecGrado,
      title:
          'Primer examen de admisión general PAO 2026-1 (Beca Igualdad de Oportunidades)',
      start: DateTime(2026, 1, 31),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    // ✅ Aplica recorte de rangos excesivos antes de filtrar/mostrar
    final normalized = _allEvents.map(_trimExcessiveRange).toList();

    final filtered = normalized.where((e) {
      final matchFilter =
          _filter == CalendarCategory.all || e.category == _filter;
      final q = _query.trim().toLowerCase();
      final matchQuery = q.isEmpty || e.title.toLowerCase().contains(q);
      return matchFilter && matchQuery;
    }).toList()
      ..sort((a, b) => a.start.compareTo(b.start));

    final grouped = _groupByMonthWithRanges(filtered);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario académico'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _SearchBox(
            onChanged: (v) => setState(() => _query = v),
          ),
          const SizedBox(height: 12),
          _FilterChips(
            selected: _filter,
            onChanged: (v) => setState(() => _filter = v),
            primary: primary,
          ),
          const SizedBox(height: 14),
          if (filtered.isEmpty)
            const _EmptyState()
          else
            ...grouped.entries.map((entry) {
              final monthKey = entry.key;
              final events = entry.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _MonthHeader(monthKey: monthKey),
                  const SizedBox(height: 10),
                  ...events.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _EventCard(
                        event: e,
                        primary: primary,
                        onTap: () => _openEventBottomSheet(e),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
              );
            }),
        ],
      ),
    );
  }

  /// ✅ Si un evento cruza meses, aparece en cada mes tocado.
  /// (OJO: ya recortamos rangos excesivos, así que no saturan la lista.)
  Map<String, List<CalendarEvent>> _groupByMonthWithRanges(
      List<CalendarEvent> events) {
    final map = <String, List<CalendarEvent>>{};

    for (final e in events) {
      final start = _dateOnly(e.start);
      final end = _dateOnly(e.end ?? e.start);

      for (final m in _monthsTouched(start, end)) {
        final key = _monthKey(m);
        map.putIfAbsent(key, () => []);
        map[key]!.add(e);
      }
    }

    for (final k in map.keys) {
      map[k]!.sort((a, b) => a.start.compareTo(b.start));
    }

    return map;
  }

  String _monthKey(DateTime d) {
    const months = {
      1: 'ENE',
      2: 'FEB',
      3: 'MAR',
      4: 'ABR',
      5: 'MAY',
      6: 'JUN',
      7: 'JUL',
      8: 'AGO',
      9: 'SEPT',
      10: 'OCT',
      11: 'NOV',
      12: 'DIC',
    };
    return '${months[d.month]} ${d.year}';
  }

  void _openEventBottomSheet(CalendarEvent e) {
    final df = DateFormat('dd MMM yyyy', 'es');
    final dateText = df.format(e.start); // ✅ solo una fecha

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final primary = Theme.of(context).colorScheme.primary;
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _categoryLabel(e.category),
                style: TextStyle(
                  color: primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                e.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.event, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(dateText)),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        Navigator.pop(context);
                        await _scheduleReminderForEvent(e);
                      },
                      icon: const Icon(Icons.notifications_active_outlined),
                      label: const Text('Recordarme'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.pop(context);
                        await _addEventToDeviceCalendar(e);
                      },
                      icon: const Icon(Icons.calendar_month),
                      label: const Text('Agregar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _addEventToDeviceCalendar(CalendarEvent e) async {
    // ✅ Ya que en UI dejamos solo una fecha para todo,
    // lo agregamos como evento de día completo.
    final start = DateTime(e.start.year, e.start.month, e.start.day, 0);
    final end = DateTime(e.start.year, e.start.month, e.start.day, 23, 59);

    final event = a2c.Event(
      title: e.title,
      description: _categoryLabel(e.category),
      startDate: start,
      endDate: end,
      allDay: true,
    );

    try {
      final ok = await a2c.Add2Calendar.addEvent2Cal(event);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ok ? 'Evento agregado al calendario.' : 'No se pudo agregar el evento.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al intentar agregar al calendario.')),
      );
    }
  }

  // =========================
  // ✅ NOTIFICACIONES (solo mi nivel)
  // =========================
  Future<bool> _canNotifyForEvent(CalendarEvent e) async {
    final prefs = await SharedPreferences.getInstance();

    // Switch maestro (tu pantalla actual lo usa)
    final masterOn = prefs.getBool('privacy_notifications') ?? true;

    // Switch específico del calendario (lo crearemos en PrivacySecurityScreen)
    final calendarOn = prefs.getBool('notif_calendar_enabled') ?? masterOn;

    if (!masterOn || !calendarOn) return false;

    // Nivel del usuario (lo guardaremos desde EditProfileScreen)
    // valores esperados: 'grado' o 'posgrado'
    final level = (prefs.getString('profile_level') ?? 'grado').toLowerCase();

    // Solo mi nivel
    final onlyMyLevel = prefs.getBool('notif_calendar_only_my_level') ?? true;

    // Incluir institucional/todos (por defecto sí)
    final includeInstitutional =
        prefs.getBool('notif_calendar_include_institutional') ?? true;

    if (!onlyMyLevel) return true;

    // Si es institucional y el usuario permite incluirlo
    if (includeInstitutional && e.category == CalendarCategory.todos) {
      return true;
    }

    if (level == 'grado') {
      return e.category == CalendarCategory.grado ||
          e.category == CalendarCategory.pucetecGrado;
    } else if (level == 'posgrado') {
      return e.category == CalendarCategory.posgrado;
    }

    // Si el valor está raro, no bloqueamos
    return true;
  }

  Future<void> _scheduleReminderForEvent(CalendarEvent e) async {
    final allowed = await _canNotifyForEvent(e);

    if (!allowed) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Este recordatorio está desactivado por tus preferencias (nivel o notificaciones).',
          ),
        ),
      );
      return;
    }

    final now = DateTime.now();

    // ✅ Evento base (9am del día del evento)
    final eventTime = DateTime(e.start.year, e.start.month, e.start.day, 9);

    // Preferencia: 1 día antes a las 09:00.
    final oneDayBefore = DateTime(e.start.year, e.start.month, e.start.day)
        .subtract(const Duration(days: 1))
        .add(const Duration(hours: 9));

    DateTime when;
    if (oneDayBefore.isAfter(now)) {
      when = oneDayBefore;
    } else {
      // Si ya no se puede 1 día antes, intenta 1 hora antes.
      final oneHourBefore = eventTime.subtract(const Duration(hours: 1));
      when = oneHourBefore.isAfter(now)
          ? oneHourBefore
          : now.add(const Duration(seconds: 10)); // fallback
    }

    final tzWhen = tz.TZDateTime.from(when, tz.local);

    // id estable por evento
    final id = e.title.hashCode & 0x7FFFFFFF;

    await NotificationService.scheduleReminder(
      id: id,
      title: 'Recordatorio PUCE',
      body: e.title,
      when: tzWhen,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Recordatorio programado para ${DateFormat('dd/MM/yyyy HH:mm').format(when)}',
        ),
      ),
    );
  }

  String _categoryLabel(CalendarCategory c) {
    switch (c) {
      case CalendarCategory.grado:
        return 'GRADO';
      case CalendarCategory.posgrado:
        return 'POSGRADO';
      case CalendarCategory.pucetecGrado:
        return 'PUCETEC/GRADO';
      case CalendarCategory.todos:
        return 'TODOS';
      case CalendarCategory.all:
        return 'TODOS';
    }
  }
}

class _SearchBox extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const _SearchBox({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Buscar evento...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: const Color(0xFFF1F4FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  final CalendarCategory selected;
  final ValueChanged<CalendarCategory> onChanged;
  final Color primary;

  const _FilterChips({
    required this.selected,
    required this.onChanged,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    Widget chip(CalendarCategory c, String label) {
      final active = selected == c;
      return ChoiceChip(
        selected: active,
        label: Text(label),
        onSelected: (_) => onChanged(c),
        selectedColor: primary.withOpacity(0.15),
        labelStyle: TextStyle(
          fontWeight: FontWeight.w700,
          color: active ? primary : const Color(0xFF5B6472),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        chip(CalendarCategory.all, 'Todos'),
        chip(CalendarCategory.todos, 'Institucional'),
        chip(CalendarCategory.grado, 'Grado'),
        chip(CalendarCategory.posgrado, 'Posgrado'),
        chip(CalendarCategory.pucetecGrado, 'PUCETEC/Grado'),
      ],
    );
  }
}

class _MonthHeader extends StatelessWidget {
  final String monthKey;
  const _MonthHeader({required this.monthKey});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_month),
          const SizedBox(width: 10),
          Text(
            monthKey,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: primary,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final CalendarEvent event;
  final Color primary;
  final VoidCallback onTap;

  const _EventCard({
    required this.event,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd MMM', 'es');

    // ✅ Para la vista: solo mostrar un día (inicio)
    final dateText = df.format(event.start);
    final cat = _label(event.category);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              blurRadius: 16,
              offset: Offset(0, 6),
              color: Color(0x14000000),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.event_note,
                color: primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _MiniPill(text: cat, color: primary),
                      _MiniPill(
                        text: dateText,
                        color: const Color(0xFF5B6472),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  String _label(CalendarCategory c) {
    switch (c) {
      case CalendarCategory.grado:
        return 'GRADO';
      case CalendarCategory.posgrado:
        return 'POSGRADO';
      case CalendarCategory.pucetecGrado:
        return 'PUCETEC/GRADO';
      case CalendarCategory.todos:
        return 'TODOS';
      case CalendarCategory.all:
        return 'TODOS';
    }
  }
}

class _MiniPill extends StatelessWidget {
  final String text;
  final Color color;

  const _MiniPill({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4FA),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        children: [
          Icon(Icons.event_busy, size: 40),
          SizedBox(height: 10),
          Text(
            'No hay eventos con esos filtros.',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 6),
          Text(
            'Prueba cambiando la categoría o el texto de búsqueda.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

