import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';
import '../../../core/widgets/zen_card.dart';
import '../bloc/calendar_bloc.dart';
import '../bloc/calendar_event.dart';
import '../models/calendar_item.dart';

class CalendarDayAgenda extends StatelessWidget {
  final DateTime? selectedDate;
  final DateTime focusedMonth;
  final List<CalendarItem> items;
  final VoidCallback onAddEventPressed;
  final VoidCallback? onClearSelection;

  const CalendarDayAgenda({
    super.key,
    this.selectedDate,
    required this.focusedMonth,
    required this.items,
    required this.onAddEventPressed,
    this.onClearSelection,
  });

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;

    String headerTitle;
    if (selectedDate != null) {
      final dateHeading = DateFormat('EEEE, MMMM d').format(selectedDate!);
      final isToday = selectedDate!.year == DateTime.now().year &&
          selectedDate!.month == DateTime.now().month &&
          selectedDate!.day == DateTime.now().day;
      headerTitle = isToday ? 'Today · $dateHeading' : dateHeading;
    } else {
      headerTitle = '${DateFormat('MMMM yyyy').format(focusedMonth)} Overview';
    }

    return ZenCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Date / Month Title & Item Count
          Row(
            children: [
              Icon(
                selectedDate != null ? LucideIcons.clock : LucideIcons.calendar,
                size: 18,
                color: zen.accent,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  headerTitle,
                  style: AppTextStyles.headingSmall(zen.textPrimary),
                ),
              ),
              if (selectedDate != null && onClearSelection != null) ...[
                GestureDetector(
                  onTap: onClearSelection,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: zen.subtleFill,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: zen.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Show all',
                          style: AppTextStyles.labelSmall(zen.textSecondary).copyWith(fontSize: 11),
                        ),
                        const SizedBox(width: 3),
                        Icon(LucideIcons.x, size: 11, color: zen.textMuted),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                '${items.length} ${items.length == 1 ? 'item' : 'items'}',
                style: AppTextStyles.labelSmall(zen.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Items or Empty State
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Column(
                  children: [
                    Icon(LucideIcons.calendar_check_2, size: 32, color: zen.border),
                    const SizedBox(height: 10),
                    Text(
                      selectedDate != null
                          ? 'No events or deadlines for this day.'
                          : 'No events or deadlines in ${DateFormat('MMMM yyyy').format(focusedMonth)}.',
                      style: AppTextStyles.bodyMedium(zen.textMuted),
                    ),
                    const SizedBox(height: 14),
                    TextButton.icon(
                      onPressed: onAddEventPressed,
                      icon: Icon(LucideIcons.plus, size: 16, color: zen.accent),
                      label: Text('Add event', style: AppTextStyles.labelMedium(zen.accent)),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (ctx, idx) => Divider(
                height: 1,
                thickness: 0.8,
                color: zen.border.withValues(alpha: 0.5),
              ),
              itemBuilder: (context, index) {
                final item = items[index];
                return _AgendaItemTile(
                  item: item,
                  showDatePrefix: selectedDate == null,
                );
              },
            ),
        ],
      ),
    );
  }
}

class _AgendaItemTile extends StatelessWidget {
  final CalendarItem item;
  final bool showDatePrefix;

  const _AgendaItemTile({
    required this.item,
    this.showDatePrefix = false,
  });

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;
    final isDeadline = item.type == CalendarItemType.taskDeadline;
    final color = isDeadline ? AppColors.success : zen.accent;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // If task deadline, show checkbox. If event, show colored dot/indicator.
          if (isDeadline)
            GestureDetector(
              onTap: () {
                context.read<CalendarBloc>().add(ToggleTaskItemEvent(item.id));
              },
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(
                  item.isCompleted ? LucideIcons.circle_check : LucideIcons.circle,
                  size: 20,
                  color: item.isCompleted ? AppColors.success : zen.border,
                ),
              ),
            )
          else
            Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.only(right: 14),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.35),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),

          // Title & Time info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: AppTextStyles.bodyMedium(
                    item.isCompleted ? zen.textMuted : zen.textPrimary,
                  ).copyWith(
                    decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    if (showDatePrefix) ...[
                      Text(
                        DateFormat('MMM d').format(item.startDateTime),
                        style: AppTextStyles.labelSmall(zen.accent).copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text('•', style: TextStyle(color: zen.textMuted, fontSize: 10)),
                      const SizedBox(width: 6),
                    ],
                    Icon(LucideIcons.clock, size: 12, color: zen.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      item.formattedTime,
                      style: AppTextStyles.labelSmall(zen.textMuted),
                    ),
                    if (item.category.isNotEmpty && item.category != 'General') ...[
                      const SizedBox(width: 8),
                      Text('•', style: TextStyle(color: zen.textMuted, fontSize: 10)),
                      const SizedBox(width: 8),
                      Text(
                        item.category,
                        style: AppTextStyles.labelSmall(zen.textSecondary),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Type Tag (Event vs Deadline)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              isDeadline ? 'Deadline' : 'Event',
              style: AppTextStyles.labelSmall(color).copyWith(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}
