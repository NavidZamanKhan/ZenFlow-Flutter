import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';
import '../../../core/widgets/zen_badge.dart';
import '../../../core/widgets/zen_button.dart';

class TasksHeader extends StatelessWidget {
  final int pendingCount;
  final VoidCallback onNewTaskPressed;

  const TasksHeader({
    super.key,
    required this.pendingCount,
    required this.onNewTaskPressed,
  });

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Subtitle matching website
        Text(
          'Stay on top of your day',
          style: AppTextStyles.bodySmall(zen.textSecondary),
        ),
        const SizedBox(height: 4),

        // Main Title Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tasks',
              style: AppTextStyles.displayLarge(zen.textPrimary),
            ),
            Row(
              children: [
                // "X tasks left" Pill Badge
                ZenBadge(
                  label: '$pendingCount ${pendingCount == 1 ? 'task' : 'tasks'} left',
                  color: zen.accent,
                  showDot: false,
                ),
                const SizedBox(width: 10),

                // "+ New task" Pill Button
                ZenButton(
                  label: 'New task',
                  icon: LucideIcons.plus,
                  height: 38,
                  width: 116,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  onPressed: onNewTaskPressed,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
