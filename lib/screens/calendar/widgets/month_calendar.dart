import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/calendar_event.dart';
import 'event_visual.dart';

class AcademicMonthCalendar extends StatelessWidget {
  final DateTime focusedMonth;
  final DateTime selectedDay;
  final List<CalendarEvent> events;
  final ValueChanged<DateTime> onMonthChanged;
  final ValueChanged<DateTime> onDaySelected;
  final VoidCallback onToday;

  const AcademicMonthCalendar({
    super.key,
    required this.focusedMonth,
    required this.selectedDay,
    required this.events,
    required this.onMonthChanged,
    required this.onDaySelected,
    required this.onToday,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final first = firstDayOfMonth(focusedMonth);
    final gridStart = first.subtract(Duration(days: first.weekday - 1));
    final monthLabel = _capitalize(
      DateFormat('MMMM yyyy', 'es_EC').format(focusedMonth),
    );

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 14),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: 'Mes anterior',
                  onPressed: () => onMonthChanged(
                    DateTime(focusedMonth.year, focusedMonth.month - 1),
                  ),
                  icon: const Icon(Icons.chevron_left),
                ),
                Expanded(
                  child: Text(
                    monthLabel,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Mes siguiente',
                  onPressed: () => onMonthChanged(
                    DateTime(focusedMonth.year, focusedMonth.month + 1),
                  ),
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onToday,
                icon: const Icon(Icons.today_outlined, size: 17),
                label: const Text('Hoy'),
              ),
            ),
            const _WeekHeader(),
            const SizedBox(height: 4),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 42,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 0.82,
              ),
              itemBuilder: (context, index) {
                final day = gridStart.add(Duration(days: index));
                final dayEvents = events
                    .where((event) => event.occursOn(day))
                    .toList();
                return _CalendarDay(
                  day: day,
                  events: dayEvents,
                  inFocusedMonth: day.month == focusedMonth.month,
                  selected: isSameCalendarDay(day, selectedDay),
                  today: isSameCalendarDay(day, DateTime.now()),
                  onTap: () => onDaySelected(day),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekHeader extends StatelessWidget {
  const _WeekHeader();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      children: const ['L', 'M', 'X', 'J', 'V', 'S', 'D'].map((day) {
        return Expanded(
          child: Text(
            day,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _CalendarDay extends StatelessWidget {
  final DateTime day;
  final List<CalendarEvent> events;
  final bool inFocusedMonth;
  final bool selected;
  final bool today;
  final VoidCallback onTap;

  const _CalendarDay({
    required this.day,
    required this.events,
    required this.inFocusedMonth,
    required this.selected,
    required this.today,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final uniqueCategories = events.map((event) => event.category).toSet();
    final eventLabel = events.isEmpty
        ? 'sin eventos'
        : '${events.length} ${events.length == 1 ? 'evento' : 'eventos'}';

    return Semantics(
      button: true,
      selected: selected,
      label: '${DateFormat('d MMMM yyyy', 'es_EC').format(day)}, $eventLabel',
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            decoration: BoxDecoration(
              color: selected ? colors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: today && !selected
                  ? Border.all(color: colors.primary, width: 1.4)
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${day.day}',
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  style: TextStyle(
                    color: selected
                        ? colors.onPrimary
                        : inFocusedMonth
                        ? colors.onSurface
                        : colors.onSurfaceVariant.withValues(alpha: 0.46),
                    fontWeight: today || selected
                        ? FontWeight.w900
                        : FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                SizedBox(
                  height: 5,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: uniqueCategories.take(3).map((category) {
                      return Container(
                        width: 4,
                        height: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(
                          color: selected
                              ? colors.onPrimary.withValues(alpha: 0.9)
                              : calendarCategoryColor(category),
                          shape: BoxShape.circle,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _capitalize(String value) {
  if (value.isEmpty) return value;
  return '${value[0].toUpperCase()}${value.substring(1)}';
}
