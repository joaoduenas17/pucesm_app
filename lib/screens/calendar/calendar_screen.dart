import 'package:add_2_calendar/add_2_calendar.dart' as a2c;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../app/app_state.dart';
import '../../app/preference_keys.dart';
import '../../data/academic_calendar_events.dart';
import '../../models/calendar_event.dart';
import '../../models/user_profile.dart';
import '../../services/notification_service.dart';
import '../../services/personal_calendar_store.dart';
import 'widgets/calendar_event_card.dart';
import 'widgets/event_visual.dart';
import 'widgets/month_calendar.dart';
import 'widgets/personal_event_editor.dart';

enum CalendarDisplay { agenda, month }

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarDisplay _display = CalendarDisplay.agenda;
  CalendarCategory _filter = CalendarCategory.all;
  String _query = '';
  bool _showPastEvents = false;
  bool _loadingPersonalEvents = true;
  List<CalendarEvent> _personalEvents = [];

  late DateTime _focusedMonth;
  late DateTime _selectedDay;

  final GlobalKey<ScaffoldMessengerState> _messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    final initialDate = _initialFocusDate();
    _focusedMonth = firstDayOfMonth(initialDate);
    _selectedDay = initialDate;
    _loadPersonalEvents();
  }

  Future<void> _loadPersonalEvents() async {
    final events = await PersonalCalendarStore.load();
    if (!mounted) return;
    setState(() {
      _personalEvents = events;
      _loadingPersonalEvents = false;
    });
  }

  DateTime _initialFocusDate() {
    final today = dateOnly(DateTime.now());
    final upcoming =
        academicCalendarEvents
            .where(
              (event) => !dateOnly(event.end ?? event.start).isBefore(today),
            )
            .toList()
          ..sort((a, b) => a.start.compareTo(b.start));
    return upcoming.isEmpty ? today : dateOnly(upcoming.first.start);
  }

  List<CalendarEvent> get _allEvents {
    return [...academicCalendarEvents, ..._personalEvents]
      ..sort((a, b) => a.start.compareTo(b.start));
  }

  bool _matchesCategory(CalendarEvent event) {
    return _filter == CalendarCategory.all || event.category == _filter;
  }

  List<CalendarEvent> get _agendaEvents {
    final query = _query.trim().toLowerCase();
    final today = dateOnly(DateTime.now());
    return _allEvents.where((event) {
      final searchable =
          '${event.title.toLowerCase()} ${event.description?.toLowerCase() ?? ''}';
      final lastDay = dateOnly(event.end ?? event.start);
      return _matchesCategory(event) &&
          (query.isEmpty || searchable.contains(query)) &&
          (_showPastEvents || !lastDay.isBefore(today));
    }).toList();
  }

  List<CalendarEvent> get _monthEvents {
    return _allEvents.where(_matchesCategory).toList();
  }

  List<CalendarEvent> get _selectedDayEvents {
    return _monthEvents.where((event) => event.occursOn(_selectedDay)).toList()
      ..sort((a, b) => a.start.compareTo(b.start));
  }

  void _toast(String message) {
    _messengerKey.currentState
      ?..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final agendaGroups = _groupByMonth(_agendaEvents);

    return ScaffoldMessenger(
      key: _messengerKey,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Calendario académico'),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton.extended(
          tooltip: 'Crear evento personal',
          onPressed: () => _openPersonalEventEditor(
            initialDate: _display == CalendarDisplay.month
                ? _selectedDay
                : DateTime.now(),
          ),
          icon: const Icon(Icons.add),
          label: const Text('Crear'),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
          children: [
            _CalendarHero(
              onAdd: () => _openPersonalEventEditor(
                initialDate: _display == CalendarDisplay.month
                    ? _selectedDay
                    : DateTime.now(),
              ),
            ),
            const SizedBox(height: 14),
            _ViewSelector(
              selected: _display,
              onChanged: (value) => setState(() => _display = value),
            ),
            const SizedBox(height: 14),
            _FilterChips(
              selected: _filter,
              onChanged: (value) => setState(() => _filter = value),
            ),
            if (_loadingPersonalEvents) ...[
              const SizedBox(height: 10),
              const LinearProgressIndicator(),
            ],
            const SizedBox(height: 14),
            if (_display == CalendarDisplay.agenda) ...[
              _SearchBox(onChanged: (value) => setState(() => _query = value)),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: FilterChip(
                  selected: _showPastEvents,
                  avatar: const Icon(Icons.history, size: 18),
                  label: const Text('Mostrar eventos anteriores'),
                  onSelected: (value) {
                    setState(() => _showPastEvents = value);
                  },
                ),
              ),
              const SizedBox(height: 10),
              const _CalendarSourceNote(),
              const SizedBox(height: 14),
              if (_agendaEvents.isEmpty)
                _EmptyState(
                  icon: Icons.event_busy_outlined,
                  title: 'No hay eventos con esos filtros',
                  subtitle:
                      'Prueba cambiando la categoría, la búsqueda o mostrando eventos anteriores.',
                  actionLabel: 'Crear evento personal',
                  onAction: () =>
                      _openPersonalEventEditor(initialDate: DateTime.now()),
                )
              else
                ...agendaGroups.map((group) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _AgendaMonthHeader(month: group.month),
                      const SizedBox(height: 10),
                      ...group.events.map(
                        (event) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: CalendarEventCard(
                            event: event,
                            onTap: () => _openEventBottomSheet(event),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                  );
                }),
            ] else ...[
              const _CalendarSourceNote(),
              const SizedBox(height: 14),
              AcademicMonthCalendar(
                focusedMonth: _focusedMonth,
                selectedDay: _selectedDay,
                events: _monthEvents,
                onMonthChanged: _changeMonth,
                onDaySelected: _selectDay,
                onToday: _goToToday,
              ),
              const SizedBox(height: 16),
              _SelectedDayHeader(
                date: _selectedDay,
                eventCount: _selectedDayEvents.length,
                onAdd: () =>
                    _openPersonalEventEditor(initialDate: _selectedDay),
              ),
              const SizedBox(height: 12),
              if (_selectedDayEvents.isEmpty)
                _EmptyState(
                  icon: Icons.event_available_outlined,
                  title: 'Este día está libre',
                  subtitle:
                      'Puedes añadir una actividad, entrega o recordatorio personal.',
                  actionLabel: 'Añadir en esta fecha',
                  onAction: () =>
                      _openPersonalEventEditor(initialDate: _selectedDay),
                )
              else
                ..._selectedDayEvents.map(
                  (event) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: CalendarEventCard(
                      event: event,
                      onTap: () => _openEventBottomSheet(event),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  void _changeMonth(DateTime month) {
    setState(() {
      _focusedMonth = firstDayOfMonth(month);
      final today = dateOnly(DateTime.now());
      _selectedDay = today.year == month.year && today.month == month.month
          ? today
          : firstDayOfMonth(month);
    });
  }

  void _selectDay(DateTime day) {
    setState(() {
      _selectedDay = dateOnly(day);
      if (day.year != _focusedMonth.year || day.month != _focusedMonth.month) {
        _focusedMonth = firstDayOfMonth(day);
      }
    });
  }

  void _goToToday() {
    final today = dateOnly(DateTime.now());
    setState(() {
      _focusedMonth = firstDayOfMonth(today);
      _selectedDay = today;
    });
  }

  List<_MonthGroup> _groupByMonth(List<CalendarEvent> events) {
    final groups = <DateTime, List<CalendarEvent>>{};
    for (final event in events) {
      final first = dateOnly(event.start);
      final last = dateOnly(event.end ?? event.start);
      for (final month in monthsTouched(first, last)) {
        groups.putIfAbsent(month, () => []).add(event);
      }
    }

    final entries = groups.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return entries.map((entry) {
      entry.value.sort((a, b) => a.start.compareTo(b.start));
      return _MonthGroup(month: entry.key, events: entry.value);
    }).toList();
  }

  Future<void> _openPersonalEventEditor({
    CalendarEvent? existing,
    required DateTime initialDate,
  }) async {
    final draft = await showModalBottomSheet<PersonalEventDraft>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) =>
          PersonalEventEditor(existing: existing, initialDate: initialDate),
    );
    if (draft == null || !mounted) return;

    final event = CalendarEvent.personal(
      id: existing?.id ?? 'personal-${DateTime.now().microsecondsSinceEpoch}',
      title: draft.title,
      description: draft.description,
      start: draft.start,
      end: draft.end,
    );
    final updated = [..._personalEvents];
    final index = updated.indexWhere((item) => item.id == event.id);
    if (index == -1) {
      updated.add(event);
    } else {
      updated[index] = event;
    }

    await PersonalCalendarStore.save(updated);
    if (!mounted) return;
    setState(() {
      _personalEvents = updated..sort((a, b) => a.start.compareTo(b.start));
      _filter = CalendarCategory.all;
      _focusedMonth = firstDayOfMonth(event.start);
      _selectedDay = event.start;
    });
    _toast(
      existing == null ? 'Evento personal creado.' : 'Evento actualizado.',
    );
  }

  Future<void> _deletePersonalEvent(CalendarEvent event) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar evento'),
          content: Text('¿Deseas eliminar “${event.title}” de tu calendario?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;

    final updated = _personalEvents
        .where((item) => item.id != event.id)
        .toList();
    await PersonalCalendarStore.save(updated);
    try {
      await NotificationService.cancel(_notificationId(event));
    } catch (_) {
      // El evento se elimina aunque el servicio nativo no esté disponible.
    }
    if (!mounted) return;
    setState(() => _personalEvents = updated);
    _toast('Evento personal eliminado.');
  }

  Future<void> _openEventBottomSheet(CalendarEvent event) async {
    final dateText = _fullDateText(event);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        final colors = Theme.of(sheetContext).colorScheme;
        return SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CalendarEventArtwork(event: event, height: 142),
                ),
                const SizedBox(height: 16),
                Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                _DetailInfoRow(
                  icon: Icons.calendar_today_outlined,
                  text: dateText,
                ),
                if (event.description != null) ...[
                  const SizedBox(height: 12),
                  _DetailInfoRow(
                    icon: Icons.notes_outlined,
                    text: event.description!,
                  ),
                ],
                const SizedBox(height: 18),
                _DetailActions(
                  onReminder: () {
                    Navigator.pop(sheetContext);
                    _scheduleReminderForEvent(event);
                  },
                  onAddToDevice: () {
                    Navigator.pop(sheetContext);
                    _addEventToDeviceCalendar(event);
                  },
                ),
                if (event.isPersonal) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton.icon(
                          onPressed: () {
                            Navigator.pop(sheetContext);
                            _openPersonalEventEditor(
                              existing: event,
                              initialDate: event.start,
                            );
                          },
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Editar'),
                        ),
                      ),
                      Expanded(
                        child: TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: colors.error,
                          ),
                          onPressed: () {
                            Navigator.pop(sheetContext);
                            _deletePersonalEvent(event);
                          },
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Eliminar'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  String _fullDateText(CalendarEvent event) {
    final format = DateFormat('EEEE, d MMMM yyyy', 'es_EC');
    if (event.end == null) return format.format(event.start);
    return '${format.format(event.start)} – ${format.format(event.end!)}';
  }

  Future<void> _addEventToDeviceCalendar(CalendarEvent event) async {
    final start = DateTime(
      event.start.year,
      event.start.month,
      event.start.day,
    );
    final lastDay = event.end ?? event.start;
    final end = DateTime(lastDay.year, lastDay.month, lastDay.day, 23, 59);
    final description = event.isPersonal
        ? event.description ?? 'Evento personal de PUCE Manabí App'
        : 'Evento del calendario académico de PUCE Manabí · ${event.category.label}';

    final deviceEvent = a2c.Event(
      title: event.title,
      description: description,
      location: event.isPersonal ? null : 'PUCE Manabí',
      startDate: start,
      endDate: end,
      allDay: true,
    );

    try {
      final added = await a2c.Add2Calendar.addEvent2Cal(deviceEvent);
      _toast(
        added
            ? 'Evento enviado al calendario del dispositivo.'
            : 'No se encontró una app de calendario disponible.',
      );
    } catch (_) {
      _toast('No se pudo abrir el calendario del dispositivo.');
    }
  }

  Future<bool> _canNotifyForEvent(CalendarEvent event) async {
    final level = context.read<AppState>().studyLevel;
    final preferences = await SharedPreferences.getInstance();
    final masterOn =
        preferences.getBool(PreferenceKeys.masterNotifications) ?? false;
    final calendarOn =
        preferences.getBool(PreferenceKeys.calendarNotifications) ?? true;
    if (!masterOn || !calendarOn) return false;
    if (event.isPersonal) return true;

    final onlyMyLevel =
        preferences.getBool(PreferenceKeys.calendarOnlyMyLevel) ?? true;
    if (!onlyMyLevel) return true;

    final includeInstitutional =
        preferences.getBool(PreferenceKeys.calendarIncludeInstitutional) ??
        true;
    if (includeInstitutional &&
        event.category == CalendarCategory.institucional) {
      return true;
    }

    switch (level) {
      case StudyLevel.grado:
        return event.category == CalendarCategory.grado ||
            event.category == CalendarCategory.pucetecGrado;
      case StudyLevel.posgrado:
        return event.category == CalendarCategory.posgrado;
      case StudyLevel.pucetec:
        return event.category == CalendarCategory.pucetecGrado;
    }
  }

  Future<void> _scheduleReminderForEvent(CalendarEvent event) async {
    final allowed = await _canNotifyForEvent(event);
    if (!allowed) {
      _toast(
        'Recordatorio desactivado por tus preferencias de notificaciones.',
      );
      return;
    }

    final now = DateTime.now();
    if (dateOnly(event.start).isBefore(dateOnly(now))) {
      _toast('Este evento ya comenzó y no admite nuevos recordatorios.');
      return;
    }

    final eventTime = DateTime(
      event.start.year,
      event.start.month,
      event.start.day,
      9,
    );
    final dayBefore = eventTime.subtract(const Duration(days: 1));
    final hourBefore = eventTime.subtract(const Duration(hours: 1));
    final when = dayBefore.isAfter(now)
        ? dayBefore
        : hourBefore.isAfter(now)
        ? hourBefore
        : now.add(const Duration(seconds: 10));

    try {
      await NotificationService.scheduleReminder(
        id: _notificationId(event),
        title: event.isPersonal ? 'Recordatorio personal' : 'Recordatorio PUCE',
        body: event.title,
        when: tz.TZDateTime.from(when, tz.local),
      );
      _toast(
        'Listo. Te recordaré el ${DateFormat('dd/MM/yyyy').format(when)} '
        'a las ${DateFormat('HH:mm').format(when)}.',
      );
    } catch (error) {
      _toast('No se pudo programar el recordatorio: $error');
    }
  }

  int _notificationId(CalendarEvent event) {
    var hash = 17;
    for (final codeUnit in event.id.codeUnits) {
      hash = ((hash * 31) + codeUnit) & 0x7FFFFFFF;
    }
    return hash;
  }
}

class _MonthGroup {
  final DateTime month;
  final List<CalendarEvent> events;

  const _MonthGroup({required this.month, required this.events});
}

class _CalendarHero extends StatelessWidget {
  final VoidCallback onAdd;

  const _CalendarHero({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F3796), Color(0xFF1EA7D7)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -38,
            top: -42,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.09),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 18,
            bottom: -28,
            child: Icon(
              Icons.calendar_month_outlined,
              size: 112,
              color: Colors.white.withValues(alpha: 0.16),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Organiza tu semestre',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'Consulta las fechas académicas y añade tus propias actividades.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.88),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF0F3796),
                  ),
                  onPressed: onAdd,
                  icon: const Icon(Icons.add),
                  label: const Text('Añadir'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewSelector extends StatelessWidget {
  final CalendarDisplay selected;
  final ValueChanged<CalendarDisplay> onChanged;

  const _ViewSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ViewButton(
              label: 'Agenda',
              icon: Icons.view_agenda_outlined,
              selected: selected == CalendarDisplay.agenda,
              onTap: () => onChanged(CalendarDisplay.agenda),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _ViewButton(
              label: 'Mes',
              icon: Icons.calendar_view_month_outlined,
              selected: selected == CalendarDisplay.month,
              onTap: () => onChanged(CalendarDisplay.month),
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ViewButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: selected ? colors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 19,
              color: selected ? colors.onPrimary : colors.primary,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? colors.onPrimary : colors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  final CalendarCategory selected;
  final ValueChanged<CalendarCategory> onChanged;

  const _FilterChips({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: CalendarCategory.values.indexed.map((entry) {
          final index = entry.$1;
          final category = entry.$2;
          final active = category == selected;
          final color = calendarCategoryColor(category);
          return Padding(
            padding: EdgeInsets.only(
              right: index == CalendarCategory.values.length - 1 ? 0 : 8,
            ),
            child: ChoiceChip(
              selected: active,
              avatar: Icon(
                calendarCategoryVisual(category).icon,
                size: 17,
                color: active ? color : colors.onSurfaceVariant,
              ),
              label: Text(category.label),
              onSelected: (_) => onChanged(category),
              selectedColor: color.withValues(alpha: 0.15),
              labelStyle: TextStyle(
                color: active ? color : colors.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
              side: BorderSide(
                color: active
                    ? color.withValues(alpha: 0.45)
                    : colors.outlineVariant,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SearchBox extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const _SearchBox({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Buscar evento...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: colors.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _AgendaMonthHeader extends StatelessWidget {
  final DateTime month;

  const _AgendaMonthHeader({required this.month});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final label = DateFormat('MMM yyyy', 'es_EC').format(month).toUpperCase();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_month_outlined, color: colors.primary),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: colors.primary,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedDayHeader extends StatelessWidget {
  final DateTime date;
  final int eventCount;
  final VoidCallback onAdd;

  const _SelectedDayHeader({
    required this.date,
    required this.eventCount,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final dateLabel = DateFormat('EEEE, d MMMM', 'es_EC').format(date);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${dateLabel[0].toUpperCase()}${dateLabel.substring(1)}',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                eventCount == 1 ? '1 evento' : '$eventCount eventos',
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          tooltip: 'Añadir evento en esta fecha',
          onPressed: onAdd,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}

class _DetailInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _DetailInfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, size: 19, color: colors.primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(text, style: const TextStyle(height: 1.35)),
          ),
        ),
      ],
    );
  }
}

class _DetailActions extends StatelessWidget {
  final VoidCallback onReminder;
  final VoidCallback onAddToDevice;

  const _DetailActions({required this.onReminder, required this.onAddToDevice});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final reminder = OutlinedButton.icon(
          onPressed: onReminder,
          icon: const Icon(Icons.notifications_active_outlined),
          label: const Text('Recordarme'),
        );
        final calendar = ElevatedButton.icon(
          onPressed: onAddToDevice,
          icon: const Icon(Icons.calendar_month_outlined),
          label: const Text('Agregar al dispositivo'),
        );
        if (constraints.maxWidth < 390) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [reminder, const SizedBox(height: 10), calendar],
          );
        }
        return Row(
          children: [
            Expanded(child: reminder),
            const SizedBox(width: 12),
            Expanded(child: calendar),
          ],
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(icon, size: 42, color: colors.primary),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.onSurfaceVariant, height: 1.35),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onAction,
            icon: const Icon(Icons.add),
            label: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}

class _CalendarSourceNote extends StatelessWidget {
  const _CalendarSourceNote();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.verified_outlined, size: 18, color: colors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Las fechas académicas provienen de publicaciones institucionales '
            'vigentes. Tus eventos personales se guardan solo en este dispositivo.',
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}
