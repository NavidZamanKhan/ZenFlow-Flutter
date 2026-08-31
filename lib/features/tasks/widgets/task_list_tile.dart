import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final VoidCallback? onDelete;

  const TaskListTile({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;

    final content = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Interactive Checkbox with scale animation & haptic feedback
            GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onToggle();
              },
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  transitionBuilder: (child, anim) =>
                      ScaleTransition(scale: anim, child: child),
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
                      decoration:
                          task.isCompleted ? TextDecoration.lineThrough : null,
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
                          color:
                              task.isOverdue ? AppColors.danger : zen.textMuted,
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

    if (onDelete != null) {
      return Dismissible(
        key: Key('task_${task.id}'),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: AppColors.danger,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(LucideIcons.trash_2, color: Colors.white, size: 20),
              SizedBox(width: 6),
              Text(
                'Delete',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        onDismissed: (_) {
          HapticFeedback.mediumImpact();
          onDelete!();
        },
        child: content,
      );
    }

    return content;
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
        label = 'Med';
        break;
      case TaskPriority.low:
        color = zen.textMuted;
        label = 'Low';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall(color).copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
