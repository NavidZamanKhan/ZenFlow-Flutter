import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';
import '../../../core/widgets/zen_card.dart';
import '../../tasks/bloc/tasks_bloc.dart';
import '../../tasks/bloc/tasks_event.dart';
import '../../tasks/widgets/new_task_bottom_sheet.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../models/focus_task.dart';

class FocusTasksCard extends StatelessWidget {
  final List<FocusTask> tasks;

  const FocusTasksCard({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;
    final completed = tasks.where((task) => task.isComplete).length;

    return ZenCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.list_todo, size: 18, color: zen.accent),
              const SizedBox(width: 8),
              Text(
                'Today\'s tasks',
                style: AppTextStyles.headingSmall(zen.textPrimary),
              ),
              const Spacer(),
              Text(
                '$completed/${tasks.length} complete',
                style: AppTextStyles.labelSmall(zen.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (tasks.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Center(
                child: Text(
                  'Nothing on your list yet.',
                  style: AppTextStyles.bodySmall(zen.textMuted),
                ),
              ),
            )
          else
            ...tasks.take(5).map((task) => _FocusTaskTile(task: task)),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () {
              NewTaskBottomSheet.show(
                context,
                onTaskCreated: (newTask) {
                  context.read<TasksBloc>().add(AddTaskEvent(newTask));
                  context
                      .read<DashboardBloc>()
                      .add(const DashboardLoadRequested());
                },
              );
            },
            icon: Icon(LucideIcons.plus, size: 16, color: zen.accent),
            label: Text(
              'Add task',
              style: AppTextStyles.labelMedium(zen.accent),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 4),
            ),
          ),
        ],
      ),
    );
  }
}

class _FocusTaskTile extends StatelessWidget {
  final FocusTask task;

  const _FocusTaskTile({required this.task});

  String get _scheduleLabel {
    if (task.dueDate == null) return 'No due date';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(
      task.dueDate!.year,
      task.dueDate!.month,
      task.dueDate!.day,
    );
    final date = due == today
        ? 'Today'
        : due == today.add(const Duration(days: 1))
            ? 'Tomorrow'
            : '${due.day}/${due.month}';
    return task.detail.isEmpty ? date : '$date · ${task.detail}';
  }

  Color _categoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'personal':
        return const Color(0xFF8B5CF6);
      case 'shopping':
        return const Color(0xFFEC4899);
      case 'family':
        return const Color(0xFFF59E0B);
      case 'work':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF3B82F6);
    }
  }

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;
    final catColor = _categoryColor(task.category);

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        context.read<DashboardBloc>().add(DashboardTaskToggled(task.id));
      },
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
        child: Row(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: Icon(
                task.isComplete ? LucideIcons.circle_check : LucideIcons.circle,
                key: ValueKey(task.isComplete),
                size: 20,
                color: task.isComplete ? zen.accent : zen.border,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: AppTextStyles.bodyMedium(
                      task.isComplete ? zen.textMuted : zen.textPrimary,
                    ).copyWith(
                      decoration:
                          task.isComplete ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _scheduleLabel,
                    style: AppTextStyles.labelSmall(zen.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: catColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                task.category.isEmpty ? 'General' : task.category,
                style: AppTextStyles.labelSmall(catColor).copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
