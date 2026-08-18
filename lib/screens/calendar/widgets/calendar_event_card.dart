import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/calendar_event.dart';
import 'event_visual.dart';

class CalendarEventCard extends StatelessWidget {
  final CalendarEvent event;
  final VoidCallback onTap;

  const CalendarEventCard({
    super.key,
    required this.event,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final dateFormat = DateFormat('dd MMM', 'es_EC');
    final dateText = event.end == null
        ? dateFormat.format(event.start)
        : '${dateFormat.format(event.start)} – ${dateFormat.format(event.end!)}';

    return Material(
      color: colors.surface,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CalendarEventArtwork(event: event),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 13, 12, 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 16,
                                color: calendarCategoryColor(event.category),
                              ),
                              const SizedBox(width: 7),
                              Expanded(
                                child: Text(
                                  dateText.toUpperCase(),
                                  style: TextStyle(
                                    color: calendarCategoryColor(
                                      event.category,
                                    ),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                    letterSpacing: 0.35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            event.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              height: 1.25,
                            ),
                          ),
                          if (event.description != null) ...[
                            const SizedBox(height: 7),
                            Text(
                              event.description!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: colors.onSurfaceVariant,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(top: 25),
                      child: Icon(
                        Icons.chevron_right,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
