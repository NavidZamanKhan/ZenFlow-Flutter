import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';
import '../models/task_filter.dart';
import '../models/task_item.dart';

class TaskListTile extends StatelessWidget {
  final TaskItem task;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  const TaskListTile({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Interactive Checkbox
            GestureDetector(
              onTap: onToggle,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                  child: task.isCompleted
                      ? Icon(
                          LucideIcons.circle_check,
                          key: const ValueKey('checked'),
                          size: 22,
                          color: zen.accent,
                        )
                      : Icon(
                          LucideIcons.circle,
                          key: const ValueKey('unchecked'),
                          size: 22,
                          color: zen.border,
                        ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Title & Schedule details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: AppTextStyles.bodyMedium(
                      task.isCompleted ? zen.textMuted : zen.textPrimary,
                    ).copyWith(
                      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                      decorationColor: zen.textMuted,
                    ),
                  ),
                  if (task.dueDate != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          LucideIcons.calendar,
                          size: 13,
                          color: task.isOverdue ? AppColors.danger : zen.textMuted,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            task.formattedSchedule,
                            style: AppTextStyles.labelSmall(
                              task.isOverdue ? AppColors.danger : zen.textMuted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Priority Pill on Right
            _PriorityPill(priority: task.priority),
          ],
        ),
      ),
    );
  }
}

class _PriorityPill extends StatelessWidget {
  final TaskPriority priority;

  const _PriorityPill({required this.priority});

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;

    Color color;
    String label;

    switch (priority) {
      case TaskPriority.high:
        color = AppColors.danger;
        label = 'High';
        break;
      case TaskPriority.medium:
        color = zen.accent;
        label = 'Medium';
        break;
      case TaskPriority.low:
        color = zen.textMuted;
        label = 'Low';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall(color),
      ),
    );
  }
}
