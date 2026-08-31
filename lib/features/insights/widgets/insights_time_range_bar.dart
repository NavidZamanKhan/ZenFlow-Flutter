import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';
import '../bloc/insights_state.dart';

class InsightsTimeRangeBar extends StatelessWidget {
  final InsightsTimeRange activeRange;
  final ValueChanged<InsightsTimeRange> onRangeChanged;

  const InsightsTimeRangeBar({
    super.key,
    required this.activeRange,
    required this.onRangeChanged,
  });

  static const _ranges = [
    (InsightsTimeRange.thisMonth, 'This month'),
    (InsightsTimeRange.last30Days, 'Last 30 days'),
    (InsightsTimeRange.allTime, 'All time'),
  ];

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;

    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: zen.subtleFill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: zen.border.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = constraints.maxWidth / _ranges.length;
          final activeIndex =
              _ranges.indexWhere((r) => r.$1 == activeRange).clamp(0, 2);

          return Stack(
            children: [
              // Smooth sliding indicator pill
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                left: activeIndex * tabWidth,
                top: 0,
                bottom: 0,
                width: tabWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: zen.card,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: zen.isDark ? 0.28 : 0.06),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),

              // Tab text labels
              Row(
                children: _ranges.map((item) {
                  final isSelected = item.$1 == activeRange;

                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        if (!isSelected) {
                          HapticFeedback.selectionClick();
                          onRangeChanged(item.$1);
                        }
                      },
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: AppTextStyles.labelSmall(
                            isSelected ? zen.textPrimary : zen.textMuted,
                          ).copyWith(
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 12,
                          ),
                          child: Text(item.$2),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}
