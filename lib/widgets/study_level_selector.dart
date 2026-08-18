import 'package:flutter/material.dart';

import '../models/user_profile.dart';

/// Selector adaptable para los niveles académicos disponibles en la app.
class StudyLevelSelector extends StatelessWidget {
  final StudyLevel value;
  final ValueChanged<StudyLevel> onChanged;

  const StudyLevelSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 10.0;
        final compact = constraints.maxWidth < 480;
        final itemWidth = compact
            ? (constraints.maxWidth - spacing) / 2
            : (constraints.maxWidth - (spacing * 2)) / 3;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: StudyLevel.values.indexed.map((entry) {
            final index = entry.$1;
            final level = entry.$2;
            final width = compact && index == StudyLevel.values.length - 1
                ? constraints.maxWidth
                : itemWidth;

            return SizedBox(
              width: width,
              child: _LevelButton(
                level: level,
                active: value == level,
                onTap: () => onChanged(level),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _LevelButton extends StatelessWidget {
  final StudyLevel level;
  final bool active;
  final VoidCallback onTap;

  const _LevelButton({
    required this.level,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: active
              ? colors.primary.withValues(alpha: 0.14)
              : colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: active
                ? colors.primary.withValues(alpha: 0.45)
                : colors.outlineVariant,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              level.icon,
              size: 18,
              color: active ? colors.primary : colors.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                level.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: active ? colors.primary : colors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension on StudyLevel {
  IconData get icon {
    switch (this) {
      case StudyLevel.grado:
        return Icons.school_outlined;
      case StudyLevel.posgrado:
        return Icons.workspace_premium_outlined;
      case StudyLevel.pucetec:
        return Icons.precision_manufacturing_outlined;
    }
  }
}
