import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';
import '../../../core/widgets/zen_button.dart';
import '../models/task_item.dart';

class TaskDetailBottomSheet extends StatelessWidget {
  final TaskItem task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const TaskDetailBottomSheet({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
  });

  static Future<void> show(
    BuildContext context, {
    required TaskItem task,
    required VoidCallback onToggle,
    required VoidCallback onDelete,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => TaskDetailBottomSheet(
        task: task,
        onToggle: onToggle,
        onDelete: onDelete,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
      decoration: BoxDecoration(
        color: zen.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: zen.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Grab Handle
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: zen.border,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Header Row: Category Badge & Delete Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: zen.subtleFill,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: zen.border),
                ),
                child: Text(
                  task.category,
                  style: AppTextStyles.labelSmall(zen.textSecondary),
                ),
              ),
              IconButton(
                icon: const Icon(LucideIcons.trash_2, size: 18, color: AppColors.danger),
                onPressed: () {
                  onDelete();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Task Title
          Text(
            task.title,
            style: AppTextStyles.headingLarge(zen.textPrimary).copyWith(
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
          const SizedBox(height: 8),

          // Schedule info
          if (task.dueDate != null)
            Row(
              children: [
                Icon(
                  LucideIcons.calendar,
                  size: 15,
                  color: task.isOverdue ? AppColors.danger : zen.textMuted,
                ),
                const SizedBox(width: 6),
                Text(
                  task.formattedSchedule,
                  style: AppTextStyles.bodySmall(
                    task.isOverdue ? AppColors.danger : zen.textSecondary,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 16),

          // Description Note
          if (task.description.isNotEmpty) ...[
            Text('Notes', style: AppTextStyles.labelSmall(zen.textMuted)),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: zen.subtleFill,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                task.description,
                style: AppTextStyles.bodyMedium(zen.textPrimary),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Toggle Action Button
          ZenButton(
            label: task.isCompleted ? 'Mark as incomplete' : 'Mark as completed',
            icon: task.isCompleted ? LucideIcons.circle : LucideIcons.circle_check,
            variant: task.isCompleted ? ZenButtonVariant.outlined : ZenButtonVariant.primary,
            onPressed: () {
              onToggle();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
