import 'package:flutter/material.dart';

import '../../../models/calendar_event.dart';

class CalendarCategoryVisual {
  final Color startColor;
  final Color endColor;
  final IconData icon;

  const CalendarCategoryVisual({
    required this.startColor,
    required this.endColor,
    required this.icon,
  });
}

CalendarCategoryVisual calendarCategoryVisual(CalendarCategory category) {
  switch (category) {
    case CalendarCategory.institucional:
      return const CalendarCategoryVisual(
        startColor: Color(0xFF0F3796),
        endColor: Color(0xFF1EA7D7),
        icon: Icons.account_balance_outlined,
      );
    case CalendarCategory.grado:
      return const CalendarCategoryVisual(
        startColor: Color(0xFF006C67),
        endColor: Color(0xFF32A89D),
        icon: Icons.school_outlined,
      );
    case CalendarCategory.posgrado:
      return const CalendarCategoryVisual(
        startColor: Color(0xFF5B35A6),
        endColor: Color(0xFF9B6CD4),
        icon: Icons.workspace_premium_outlined,
      );
    case CalendarCategory.pucetecGrado:
      return const CalendarCategoryVisual(
        startColor: Color(0xFFC65D05),
        endColor: Color(0xFFF3A83B),
        icon: Icons.precision_manufacturing_outlined,
      );
    case CalendarCategory.personal:
      return const CalendarCategoryVisual(
        startColor: Color(0xFFA6275B),
        endColor: Color(0xFFE46791),
        icon: Icons.event_available_outlined,
      );
    case CalendarCategory.all:
      return const CalendarCategoryVisual(
        startColor: Color(0xFF0F3796),
        endColor: Color(0xFF5779D6),
        icon: Icons.calendar_month_outlined,
      );
  }
}

Color calendarCategoryColor(CalendarCategory category) {
  return calendarCategoryVisual(category).startColor;
}

IconData calendarEventIcon(CalendarEvent event) {
  final title = event.title.toLowerCase();
  if (event.isPersonal) return Icons.auto_awesome_outlined;
  if (title.contains('feriado')) return Icons.celebration_outlined;
  if (title.contains('examen')) return Icons.quiz_outlined;
  if (title.contains('matrícula')) return Icons.how_to_reg_outlined;
  if (title.contains('beca')) return Icons.volunteer_activism_outlined;
  if (title.contains('inicio de clases')) return Icons.rocket_launch_outlined;
  if (title.contains('calificaciones')) return Icons.fact_check_outlined;
  if (title.contains('inducción')) return Icons.groups_outlined;
  return calendarCategoryVisual(event.category).icon;
}

class CalendarEventArtwork extends StatelessWidget {
  final CalendarEvent event;
  final double height;
  final bool showCategory;

  const CalendarEventArtwork({
    super.key,
    required this.event,
    this.height = 92,
    this.showCategory = true,
  });

  @override
  Widget build(BuildContext context) {
    final visual = calendarCategoryVisual(event.category);

    return Semantics(
      image: true,
      label: 'Ilustración de ${event.category.label}',
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [visual.startColor, visual.endColor],
            ),
          ),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned(
                right: -18,
                top: -34,
                child: _DecorativeCircle(
                  size: 116,
                  color: Colors.white.withValues(alpha: 0.10),
                ),
              ),
              Positioned(
                right: 54,
                bottom: -48,
                child: _DecorativeCircle(
                  size: 94,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
              Positioned(
                right: 20,
                top: 16,
                child: Icon(
                  calendarEventIcon(event),
                  color: Colors.white.withValues(alpha: 0.94),
                  size: height * 0.58,
                ),
              ),
              if (showCategory)
                Positioned(
                  left: 14,
                  top: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.17),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.22),
                      ),
                    ),
                    child: Text(
                      event.category.badgeLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                        letterSpacing: 0.35,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DecorativeCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _DecorativeCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
