import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';
import '../../../core/widgets/zen_card.dart';
import '../models/calendar_item.dart';

class CalendarWeekStrip extends StatelessWidget {
  final DateTime selectedDate;
  final List<CalendarItem> items;
  final ValueChanged<DateTime> onDateSelected;

  const CalendarWeekStrip({
    super.key,
    required this.selectedDate,
    required this.items,
    required this.onDateSelected,
  });

  List<DateTime> _generateWeekDays(DateTime current) {
    final startOfWeek = current.subtract(Duration(days: current.weekday % 7));
    return List.generate(7, (i) => startOfWeek.add(Duration(days: i)));
  }

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;
    final weekDays = _generateWeekDays(selectedDate);

    return ZenCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: weekDays.map((day) {
          final isSelected = day.year == selectedDate.year &&
              day.month == selectedDate.month &&
              day.day == selectedDate.day;
          final isToday = day.year == DateTime.now().year &&
              day.month == DateTime.now().month &&
              day.day == DateTime.now().day;

          final hasEvents = items.any(
            (item) => item.isSameDay(day) && item.type == CalendarItemType.event,
          );
          final hasDeadlines = items.any(
            (item) => item.isSameDay(day) && item.type == CalendarItemType.taskDeadline,
          );

          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onDateSelected(day);
              },
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? zen.accent
                      : (isToday ? (zen.isDark ? zen.accentSoft : zen.accentLightBg) : Colors.transparent),
                  borderRadius: BorderRadius.circular(16),
                  border: isToday && !isSelected
                      ? Border.all(color: zen.accent.withValues(alpha: 0.4), width: 1.2)
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('E').format(day).toUpperCase(),
                      style: AppTextStyles.labelSmall(
                        isSelected ? Colors.white70 : zen.textMuted,
                      ).copyWith(fontSize: 10.5),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${day.day}',
                      style: AppTextStyles.headingSmall(
                        isSelected ? Colors.white : zen.textPrimary,
                      ).copyWith(fontSize: 15),
                    ),
                    const SizedBox(height: 4),

                    // Dot Indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (hasEvents)
                          Container(
                            width: 4,
                            height: 4,
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white : zen.accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                        if (hasDeadlines)
                          Container(
                            width: 4,
                            height: 4,
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white : AppColors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
