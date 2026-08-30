import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';
import '../bloc/calendar_event.dart';

class CalendarViewSwitcher extends StatelessWidget {
  final CalendarViewMode currentMode;
  final ValueChanged<CalendarViewMode> onModeChanged;

  const CalendarViewSwitcher({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
  });

  static const _modes = [
    (mode: CalendarViewMode.month, label: 'Month'),
    (mode: CalendarViewMode.week, label: 'Week'),
    (mode: CalendarViewMode.schedule, label: 'Schedule'),
  ];

  int get _selectedIndex =>
      _modes.indexWhere((m) => m.mode == currentMode);

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;
    final selectedIndex = _selectedIndex.clamp(0, _modes.length - 1);

    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: zen.subtleFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: zen.border),
      ),
      child: Stack(
        children: [
          // Animated Glowing Sliding Indicator
          AnimatedAlign(
            duration: const Duration(milliseconds: 380),
            curve: Curves.easeOutCubic,
            alignment: Alignment(
              -1 + (2 * selectedIndex / (_modes.length - 1)),
              0,
            ),
            child: FractionallySizedBox(
              widthFactor: 1 / _modes.length,
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

          // Options Row
          Row(
            children: List.generate(_modes.length, (index) {
              final item = _modes[index];
              final isSelected = index == selectedIndex;

              return Expanded(
                child: InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onModeChanged(item.mode);
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
