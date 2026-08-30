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
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: zen.subtleFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: zen.border,
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // Animated Sliding Glow Pill (Exact match to bottom navigation bar)
          AnimatedAlign(
            duration: const Duration(milliseconds: 380),
            curve: Curves.easeOutCubic,
            alignment: Alignment(
              -1 + (2 * selectedIndex / (_priorities.length - 1)),
              0,
            ),
            child: FractionallySizedBox(
              widthFactor: 1 / _priorities.length,
              heightFactor: 1,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: zen.isDark
                      ? zen.accent.withValues(alpha: .22)
                      : zen.accentSoft,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: zen.accent.withValues(alpha: .26),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: zen.accent.withValues(alpha: .14),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Priority Buttons Row
          Row(
            children: List.generate(_priorities.length, (index) {
              final item = _priorities[index];
              final isSelected = index == selectedIndex;

              return Expanded(
                child: InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onPriorityChanged(item.priority);
                  },
                  borderRadius: BorderRadius.circular(12),
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeOutBack,
                    scale: isSelected ? 1.0 : 0.94,
                    child: Center(
                      child: Text(
                        item.label,
                        style: AppTextStyles.labelMedium(
                          isSelected ? zen.accent : zen.textSecondary,
                        ).copyWith(
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
