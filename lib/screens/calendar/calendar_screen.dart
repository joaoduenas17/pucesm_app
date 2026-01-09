import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Categorías típicas del calendario PUCE (ajústalas a lo que tengas real).
enum CalendarCategory {
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
  final String? note;

  const CalendarEvent({
    required this.category,
    required this.title,
    required this.start,
    this.end,
    this.note,
  });

  bool get isRange => end != null && !isSameDay(start, end!);
}

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarCategory _filter = CalendarCategory.todos;
  String _query = '';

  // ✅ DATA MOCK (pon aquí tus eventos reales)
  // Luego lo conectamos a API/JSON. Por ahora te lo dejo armado con ejemplos.
  final List<CalendarEvent> _allEvents = [
    CalendarEvent(
      category: CalendarCategory.grado,
      title: 'Registro de notas (Décimo Semestre Medicina y Séptimo Semestre Enfermería)',
      start: DateTime(2025, 8, 4),
      end: DateTime(2025, 8, 8),
    ),
    CalendarEvent(
      category: CalendarCategory.pucetecGrado,
      title: 'Matrícula del periodo académico extraordinario 2025-1 (excepto Medicina)',
      start: DateTime(2025, 8, 12),
      end: DateTime(2025, 9, 5),
    ),
    CalendarEvent(
      category: CalendarCategory.grado,
      title: 'Examen final (excepto Medicina) - Última semana de clases',
      start: DateTime(2025, 8, 12),
      end: DateTime(2025, 8, 15),
    ),
    CalendarEvent(
      category: CalendarCategory.posgrado,
      title: 'Cierre del primer periodo académico Programas Sede Manabí',
      start: DateTime(2025, 9, 15),
      end: DateTime(2025, 9, 19),
    ),
    CalendarEvent(
      category: CalendarCategory.grado,
      title: 'Inicio de clases (todas las carreras, excepto Medicina)',
      start: DateTime(2025, 10, 13),
    ),
    CalendarEvent(
      category: CalendarCategory.posgrado,
      title: 'Evaluación docente',
      start: DateTime(2025, 10, 20),
      end: DateTime(2026, 3, 20),
      note: 'Rango largo (se muestra como período).',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    final filtered = _allEvents.where((e) {
      final matchFilter = _filter == CalendarCategory.todos || e.category == _filter;
      final matchQuery = _query.trim().isEmpty ||
          e.title.toLowerCase().contains(_query.trim().toLowerCase());
      return matchFilter && matchQuery;
    }).toList()
      ..sort((a, b) => a.start.compareTo(b.start));

    final grouped = _groupByMonth(filtered);

    return Scaffold(
      // 👇 Ya quitamos la AppBar del shell; aquí solo ponemos si quieres.
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

  Map<String, List<CalendarEvent>> _groupByMonth(List<CalendarEvent> events) {
    // key: "AGO 2025", "SEPT 2025", etc
    final map = <String, List<CalendarEvent>>{};
    for (final e in events) {
      final key = _monthKey(e.start);
      map.putIfAbsent(key, () => []);
      map[key]!.add(e);
    }
    return map;
  }

  String _monthKey(DateTime d) {
    // meses en español abreviados estilo tu captura (AGO, SEPT, OCT...)
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
    final dateText = e.end == null
        ? df.format(e.start)
        : '${df.format(e.start)} — ${df.format(e.end!)}';

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
              if (e.note != null && e.note!.trim().isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  e.note!,
                  style: const TextStyle(color: Color(0xFF5B6472)),
                ),
              ],
              const SizedBox(height: 14),

              // 🔔 Aquí luego conectamos notificaciones / agregar a calendario
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Luego: agregar recordatorio / notificación'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.notifications_active_outlined),
                      label: const Text('Recordarme'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Luego: exportar a calendario del dispositivo'),
                          ),
                        );
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
        chip(CalendarCategory.todos, 'Todos'),
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
    final dateText = event.end == null
        ? df.format(event.start)
        : '${df.format(event.start)} — ${df.format(event.end!)}';

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
                      _MiniPill(text: dateText, color: const Color(0xFF5B6472)),
                      if (event.isRange)
                        _MiniPill(text: 'Período', color: const Color(0xFF5B6472)),
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