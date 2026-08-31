import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';
import '../models/task_filter.dart';

class TasksStatusSegmentedBar extends StatelessWidget {
  final TaskStatusFilter selectedStatus;
  final ValueChanged<TaskStatusFilter> onStatusChanged;

  const TasksStatusSegmentedBar({
    super.key,
    required this.selectedStatus,
    required this.onStatusChanged,
  });

  static const _statuses = [
    (status: TaskStatusFilter.all, label: 'All'),
    (status: TaskStatusFilter.pending, label: 'Pending'),
    (status: TaskStatusFilter.overdue, label: 'Overdue'),
    (status: TaskStatusFilter.completed, label: 'Completed'),
  ];

  int get _selectedIndex =>
      _statuses.indexWhere((s) => s.status == selectedStatus);

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;
    final selectedIndex = _selectedIndex.clamp(0, _statuses.length - 1);

    return Container(
      height: 42,
      padding: const EdgeInsets.all(3.5),
      decoration: BoxDecoration(
        color: zen.isDark ? zen.surface : const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Animated Solid Crisp Active Pill (Apple / Linear Style)
          AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            alignment: Alignment(
              -1 + (2 * selectedIndex / (_statuses.length - 1)),
              0,
            ),
            child: FractionallySizedBox(
              widthFactor: 1 / _statuses.length,
              heightFactor: 1.0,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  color: zen.isDark ? zen.card : Colors.white,
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: zen.isDark ? 0.35 : 0.08,
                      ),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Status Buttons Row
          Positioned.fill(
            child: Row(
              children: List.generate(_statuses.length, (index) {
                final item = _statuses[index];
                final isSelected = index == selectedIndex;

                return Expanded(
                  child: InkWell(
                    onTap: () {
                      if (!isSelected) {
                        HapticFeedback.selectionClick();
                        onStatusChanged(item.status);
                      }
                    },
                    borderRadius: BorderRadius.circular(11),
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    child: Center(
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOutBack,
                        scale: isSelected ? 1.0 : 0.96,
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 140),
                          style: AppTextStyles.labelMedium(
                            isSelected ? zen.textPrimary : zen.textSecondary,
                          ).copyWith(
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            fontSize: 12.5,
                            height: 1.0,
                          ),
                          child: Text(item.label),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
