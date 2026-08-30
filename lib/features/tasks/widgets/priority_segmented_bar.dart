import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';
import '../models/task_filter.dart';

class PrioritySegmentedBar extends StatelessWidget {
  final TaskPriority selectedPriority;
  final ValueChanged<TaskPriority> onPriorityChanged;

  const PrioritySegmentedBar({
    super.key,
    required this.selectedPriority,
    required this.onPriorityChanged,
  });

  static const _priorities = [
    (priority: TaskPriority.low, label: 'Low'),
    (priority: TaskPriority.medium, label: 'Med'),
    (priority: TaskPriority.high, label: 'High'),
  ];

  int get _selectedIndex =>
      _priorities.indexWhere((p) => p.priority == selectedPriority);

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;
    final selectedIndex = _selectedIndex.clamp(0, _priorities.length - 1);

    return Container(
      height: 44,
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
              -1 + (2 * selectedIndex / (_priorities.length - 1)),
              0,
            ),
            child: FractionallySizedBox(
              widthFactor: 1 / _priorities.length,
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

          // Priority Buttons Row
          Positioned.fill(
            child: Row(
              children: List.generate(_priorities.length, (index) {
                final item = _priorities[index];
                final isSelected = index == selectedIndex;

                return Expanded(
                  child: InkWell(
                    onTap: () {
                      if (!isSelected) {
                        HapticFeedback.selectionClick();
                        onPriorityChanged(item.priority);
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
                            fontSize: 13,
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
