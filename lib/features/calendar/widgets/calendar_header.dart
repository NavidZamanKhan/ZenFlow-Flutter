import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';
import '../../../core/widgets/zen_button.dart';

class CalendarHeader extends StatelessWidget {
  final VoidCallback onNewEventPressed;

  const CalendarHeader({
    super.key,
    required this.onNewEventPressed,
  });

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main Title Row with "+ New event" button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                'Calendar',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.displayLarge(zen.textPrimary),
              ),
            ),
            ZenButton(
              label: 'New event',
              icon: LucideIcons.plus,
              height: 38,
              width: 120,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              onPressed: onNewEventPressed,
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Legend Row: Events (Blue) & Task Deadlines (Emerald)
        Row(
          children: [
            _LegendItem(
              label: 'Events',
              color: zen.accent,
            ),
            const SizedBox(width: 16),
            _LegendItem(
              label: 'Task deadlines',
              color: AppColors.success,
            ),
          ],
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final Color color;

  const _LegendItem({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.labelSmall(zen.textSecondary),
        ),
      ],
    );
  }
}
