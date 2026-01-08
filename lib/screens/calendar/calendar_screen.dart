import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  static const _storageKey = 'pucesm_calendar_events_v3';

  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;

  final Map<String, List<_CalendarEvent>> eventsByDate = {};

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  String _keyFromDate(DateTime d) {
    final local = DateTime(d.year, d.month, d.day);
    final mm = local.month.toString().padLeft(2, '0');
    final dd = local.day.toString().padLeft(2, '0');
    return '${local.year}-$mm-$dd';
  }

  List<_CalendarEvent> _getEventsForDay(DateTime day) {
    final key = _keyFromDate(day);
    return eventsByDate[key] ?? [];
  }

  Future<void> _loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);

    if (raw == null || raw.isEmpty) {
      _seedDefaultAcademicCalendar();
      await _saveEvents();
      if (mounted) setState(() {});
      return;
    }

    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    eventsByDate.clear();
    decoded.forEach((key, value) {
      final list = (value as List)
          .map((e) => _CalendarEvent.fromJson(e as Map<String, dynamic>))
          .toList();
      eventsByDate[key] = list;
    });

    if (mounted) setState(() {});
  }

  Future<void> _saveEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final toSave = <String, dynamic>{};
    eventsByDate.forEach((key, list) {
      toSave[key] = list.map((e) => e.toJson()).toList();
    });
    await prefs.setString(_storageKey, jsonEncode(toSave));
  }

  void _seedDefaultAcademicCalendar() {
    void add(DateTime date, String title, String details) {
      final k = _keyFromDate(date);
      eventsByDate.putIfAbsent(k, () => []);
      eventsByDate[k]!.add(_CalendarEvent(title: title, details: details));
    }

    add(DateTime(2025, 10, 13), 'Inicio de clases',
        'Grado / Posgrado (según calendario académico).');
    add(DateTime(2025, 10, 13), 'Matrícula extraordinaria',
        'Del 13 al 24 Oct 2025.');
    add(DateTime(2025, 10, 27), 'Matrícula especial',
        'Del 27 Oct al 7 Nov 2025.');

    add(DateTime(2025, 11, 10), 'Borrado', 'Del 10 al 14 Nov 2025.');
    add(DateTime(2025, 11, 29), 'Ceremonias de incorporación',
        'Del 29 Nov al 14 Dic 2025.');

    add(DateTime(2025, 12, 1), 'Evaluación docente',
        'Del 1 Dic 2025 al 20 Feb 2026.');
    add(DateTime(2025, 12, 19), 'Cierre de actividades académicas',
        'Según calendario académico.');
    add(DateTime(2025, 12, 22), 'Vacaciones', 'Del 22 Dic 2025 al 1 Ene 2026.');

    add(DateTime(2026, 1, 2), 'Inicio de actividades',
        'Inicio de actividades académicas y administrativas.');
    add(DateTime(2026, 1, 5), 'Registro de notas', 'Del 5 al 9 Ene 2026.');
    add(DateTime(2026, 1, 12), 'Exámenes', 'Del 12 al 16 Ene 2026.');
    add(DateTime(2026, 1, 31), 'Examen de admisión',
        '31 Ene 2026 (según calendario).');
  }

  Future<void> _addEventFlow() async {
    final day = selectedDay ?? focusedDay;
    await _upsertEventDialog(day: day);
  }

  Future<void> _editEventFlow(DateTime day, int index) async {
    final list = _getEventsForDay(day);
    if (index < 0 || index >= list.length) return;
    await _upsertEventDialog(day: day, editIndex: index, existing: list[index]);
  }

  Future<void> _upsertEventDialog({
    required DateTime day,
    int? editIndex,
    _CalendarEvent? existing,
  }) async {
    DateTime chosenDay = day;
    final titleController = TextEditingController(text: existing?.title ?? '');
    final detailsController =
        TextEditingController(text: existing?.details ?? '');

    Future<void> pickDate(StateSetter setModalState) async {
      final picked = await showDatePicker(
        context: context,
        initialDate: chosenDay,
        firstDate: DateTime(2020, 1, 1),
        lastDate: DateTime(2030, 12, 31),
      );
      if (picked != null) {
        setModalState(() => chosenDay = picked);
      }
    }

    final result = await showDialog<_EventDraft>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: Text(editIndex == null ? 'Agregar evento' : 'Editar evento'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Fecha + botón cambiar
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Fecha: ${_keyFromDate(chosenDay)}',
                            style: const TextStyle(
                              color: Color(0xFF5B6472),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => pickDate(setModalState),
                          icon: const Icon(Icons.date_range),
                          label: const Text('Cambiar'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Título',
                        hintText: 'Ej: Entrega de proyecto',
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: detailsController,
                      decoration: const InputDecoration(
                        labelText: 'Detalles (opcional)',
                        hintText: 'Aula, indicaciones, link, etc.',
                        border: OutlineInputBorder(),
                      ),
                      minLines: 3,
                      maxLines: 6,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final t = titleController.text.trim();
                    final d = detailsController.text.trim();
                    if (t.isEmpty) return;
                    Navigator.pop(
                      context,
                      _EventDraft(
                        date: chosenDay,
                        event: _CalendarEvent(title: t, details: d),
                      ),
                    );
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == null) return;

    final oldKey = _keyFromDate(day);
    final newKey = _keyFromDate(result.date);

    // Si es edición, borramos el anterior del día viejo
    if (editIndex != null) {
      final oldList = eventsByDate[oldKey];
      if (oldList != null && editIndex >= 0 && editIndex < oldList.length) {
        oldList.removeAt(editIndex);
        if (oldList.isEmpty) eventsByDate.remove(oldKey);
      }
    }

    // Insertamos en el día nuevo
    eventsByDate.putIfAbsent(newKey, () => []);
    eventsByDate[newKey]!.add(result.event);

    // Ajustamos selección/foco si movió la fecha
    selectedDay = result.date;
    focusedDay = result.date;

    await _saveEvents();
    if (mounted) setState(() {});
  }

  Future<void> _removeEvent(DateTime day, int index) async {
    final key = _keyFromDate(day);
    final list = eventsByDate[key];
    if (list == null || index < 0 || index >= list.length) return;

    list.removeAt(index);
    if (list.isEmpty) eventsByDate.remove(key);

    await _saveEvents();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final day = selectedDay ?? focusedDay;
    final dayEvents = _getEventsForDay(day);

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
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
                child: TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: focusedDay,
                  selectedDayPredicate: (d) =>
                      selectedDay != null &&
                      d.year == selectedDay!.year &&
                      d.month == selectedDay!.month &&
                      d.day == selectedDay!.day,
                  eventLoader: (d) =>
                      _getEventsForDay(d).map((e) => e.title).toList(),
                  onDaySelected: (sel, foc) {
                    setState(() {
                      selectedDay = sel;
                      focusedDay = foc;
                    });
                  },
                  onPageChanged: (foc) => focusedDay = foc,
                  calendarStyle: CalendarStyle(
                    markerDecoration: const BoxDecoration(
                      color: Color(0xFF1E63FF),
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: const Color(0xFF1E63FF).withOpacity(0.25),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: const BoxDecoration(
                      color: Color(0xFF1E63FF),
                      shape: BoxShape.circle,
                    ),
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Eventos del día',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                  ),
                  Text(
                    _keyFromDate(day),
                    style: const TextStyle(
                      color: Color(0xFF5B6472),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: dayEvents.isEmpty
                    ? const Center(
                        child: Text(
                          'No hay eventos registrados para este día.',
                          style: TextStyle(color: Color(0xFF5B6472)),
                        ),
                      )
                    : ListView.separated(
                        itemCount: dayEvents.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final ev = dayEvents[i];
                          return Dismissible(
                            key: ValueKey(
                                '${_keyFromDate(day)}-$i-${ev.title}-${ev.details}'),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 16),
                              decoration: BoxDecoration(
                                color: Colors.red.shade400,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child:
                                  const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (_) => _removeEvent(day, i),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => _editEventFlow(day, i),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: const [
                                    BoxShadow(
                                      blurRadius: 14,
                                      offset: Offset(0, 6),
                                      color: Color(0x12000000),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 38,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEAF2FF),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(Icons.event,
                                          color: Color(0xFF1E63FF)),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            ev.title,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          if (ev.details.trim().isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              ev.details,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                height: 1.2,
                                                color: Color(0xFF5B6472),
                                              ),
                                            ),
                                          ]
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.edit,
                                        size: 18, color: Color(0xFF9AA3AF)),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),

        Positioned(
          right: 18,
          bottom: 18,
          child: FloatingActionButton(
            onPressed: _addEventFlow,
            backgroundColor: const Color(0xFF1E63FF),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _CalendarEvent {
  final String title;
  final String details;

  const _CalendarEvent({required this.title, required this.details});

  Map<String, dynamic> toJson() => {'title': title, 'details': details};

  factory _CalendarEvent.fromJson(Map<String, dynamic> json) {
    return _CalendarEvent(
      title: (json['title'] ?? '').toString(),
      details: (json['details'] ?? '').toString(),
    );
  }
}

class _EventDraft {
  final DateTime date;
  final _CalendarEvent event;

  _EventDraft({required this.date, required this.event});
}
