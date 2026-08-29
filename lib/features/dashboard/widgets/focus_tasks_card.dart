import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';
import '../../../core/widgets/zen_card.dart';
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
          ...tasks.map((task) => _FocusTaskTile(task: task)),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () {},
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

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;
    return InkWell(
      onTap: () =>
          context.read<DashboardBloc>().add(DashboardTaskToggled(task.id)),
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
        child: Row(
          children: [
            Icon(
              task.isComplete ? LucideIcons.circle_check : LucideIcons.circle,
              size: 20,
              color: task.isComplete ? zen.accent : zen.border,
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style:
                        AppTextStyles.bodyMedium(
                          task.isComplete ? zen.textMuted : zen.textPrimary,
                        ).copyWith(
                          decoration: task.isComplete
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    task.detail,
                    style: AppTextStyles.labelSmall(zen.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: zen.subtleFill,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                task.category,
                style: AppTextStyles.labelSmall(zen.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
