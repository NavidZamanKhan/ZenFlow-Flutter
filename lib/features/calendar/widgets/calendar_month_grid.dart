import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';
import '../../../core/widgets/zen_card.dart';
import '../models/calendar_item.dart';

class CalendarMonthGrid extends StatelessWidget {
  final DateTime focusedMonth;
  final DateTime? selectedDate;
  final List<CalendarItem> items;
  final ValueChanged<DateTime> onDateSelected;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onTodayPressed;

  const CalendarMonthGrid({
    super.key,
    required this.focusedMonth,
    this.selectedDate,
    required this.items,
    required this.onDateSelected,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onTodayPressed,
  });

  static const _weekdays = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];

  List<DateTime> _generateMonthDays(DateTime month) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);

    // Days before first of month to align with Sunday start (Sunday = 0, Monday = 1, etc.)
    final leadingDays = firstDayOfMonth.weekday % 7;
    final startDate = firstDayOfMonth.subtract(Duration(days: leadingDays));

    // Total cells: standard 35 or 42 grid cells
    final totalDays = (leadingDays + lastDayOfMonth.day) > 35 ? 42 : 35;

    return List.generate(
      totalDays,
      (index) => startDate.add(Duration(days: index)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;
    final monthDays = _generateMonthDays(focusedMonth);
    final monthTitle = DateFormat('MMMM yyyy').format(focusedMonth);

    return ZenCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      child: Column(
        children: [
          // Month Navigator Bar (< August 2026 > and Today button)
          Row(
            children: [
              Icon(LucideIcons.calendar, size: 18, color: zen.accent),
              const SizedBox(width: 8),
              Text(
                monthTitle,
                style: AppTextStyles.headingSmall(zen.textPrimary),
              ),
              const Spacer(),

              // Previous Month
              _NavArrowButton(icon: LucideIcons.chevron_left, onTap: onPreviousMonth),
              const SizedBox(width: 4),

              // Today Button
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onTodayPressed();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: zen.subtleFill,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: zen.border),
                  ),
                  child: Text(
                    'Today',
                    style: AppTextStyles.labelSmall(zen.textSecondary),
                  ),
                ),
              ),
              const SizedBox(width: 4),

              // Next Month
              _NavArrowButton(icon: LucideIcons.chevron_right, onTap: onNextMonth),
            ],
          ),
          const SizedBox(height: 16),

          // Weekdays Row (SUN MON TUE WED THU FRI SAT)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _weekdays.map((day) {
              return Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: AppTextStyles.labelSmall(zen.textMuted).copyWith(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),

          // Days Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: monthDays.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 4,
              childAspectRatio: 0.95,
            ),
            itemBuilder: (context, index) {
              final day = monthDays[index];
              final isCurrentMonth = day.month == focusedMonth.month;
              final isSelected = selectedDate != null &&
                  day.year == selectedDate!.year &&
                  day.month == selectedDate!.month &&
                  day.day == selectedDate!.day;
              final isToday = day.year == DateTime.now().year &&
                  day.month == DateTime.now().month &&
                  day.day == DateTime.now().day;

              final hasEvents = items.any(
                (item) => item.isSameDay(day) && item.type == CalendarItemType.event,
              );
              final hasDeadlines = items.any(
                (item) => item.isSameDay(day) && item.type == CalendarItemType.taskDeadline,
              );

              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onDateSelected(day);
                },
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? zen.accent
                        : (isToday ? (zen.isDark ? zen.accentSoft : zen.accentLightBg) : Colors.transparent),
                    borderRadius: BorderRadius.circular(14),
                    border: isToday && !isSelected
                        ? Border.all(color: zen.accent.withValues(alpha: 0.4), width: 1.2)
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${day.day}',
                        style: AppTextStyles.bodyMedium(
                          isSelected
                              ? Colors.white
                              : (!isCurrentMonth
                                  ? zen.textMuted.withValues(alpha: 0.4)
                                  : zen.textPrimary),
                        ).copyWith(
                          fontWeight: (isSelected || isToday) ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 3),

                      // Colored Dot Indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (hasEvents)
                            Container(
                              width: 4.5,
                              height: 4.5,
                              margin: const EdgeInsets.symmetric(horizontal: 1.5),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.white : zen.accent,
                                shape: BoxShape.circle,
                              ),
                            ),
                          if (hasDeadlines)
                            Container(
                              width: 4.5,
                              height: 4.5,
                              margin: const EdgeInsets.symmetric(horizontal: 1.5),
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
              );
            },
          ),
        ],
      ),
    );
  }
}

class _NavArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavArrowButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: zen.subtleFill,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16, color: zen.textSecondary),
      ),
    );
  }
}
