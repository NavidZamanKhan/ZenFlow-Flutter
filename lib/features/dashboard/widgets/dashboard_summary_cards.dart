import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../core/services/currency_service.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';
import '../../../core/widgets/zen_card.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../models/dashboard_budget.dart';
import '../models/dashboard_event.dart';
import '../models/dashboard_expense.dart';

class RemindersCard extends StatelessWidget {
  final List<DashboardEventItem> events;
  const RemindersCard({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;
    final upcoming = events
        .where((event) => !event.start.isBefore(DateTime.now().subtract(const Duration(days: 1))))
        .take(4)
        .toList();

    return ZenCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.calendar_days, size: 18, color: zen.accent),
              const SizedBox(width: 8),
              Text(
                'Up next & deadlines',
                style: AppTextStyles.headingSmall(zen.textPrimary),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  context.read<DashboardBloc>().add(const DashboardTabSelected(2));
                },
                child: Row(
                  children: [
                    Text(
                      'View all',
                      style: AppTextStyles.labelSmall(zen.accent),
                    ),
                    const SizedBox(width: 2),
                    Icon(LucideIcons.chevron_right, size: 14, color: zen.accent),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (upcoming.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'No upcoming events or deadlines.',
                style: AppTextStyles.bodySmall(zen.textMuted),
              ),
            )
          else
            ...upcoming.map(
              (event) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ReminderRow(
                  title: event.title,
                  time: _eventTime(event),
                  color: zen.accent,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    context.read<DashboardBloc>().add(const DashboardTabSelected(2));
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

String _eventTime(DashboardEventItem event) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final date = DateTime(event.start.year, event.start.month, event.start.day);
  final isToday = date == today;
  final dateStr = isToday ? 'Today' : '${event.start.day}/${event.start.month}';

  if (event.isAllDay) return '$dateStr · All day';
  final hour = event.start.hour % 12 == 0 ? 12 : event.start.hour % 12;
  final timeStr =
      '$hour:${event.start.minute.toString().padLeft(2, '0')} ${event.start.hour >= 12 ? 'PM' : 'AM'}';
  return '$dateStr · $timeStr';
}

class _ReminderRow extends StatelessWidget {
  final String title;
  final String time;
  final Color color;
  final VoidCallback onTap;

  const _ReminderRow({
    required this.title,
    required this.time,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyMedium(zen.textPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: zen.subtleFill,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: zen.border.withValues(alpha: 0.5)),
              ),
              child: Text(
                time,
                style: AppTextStyles.labelSmall(zen.textSecondary).copyWith(
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

class ExpenseSnapshotCard extends StatelessWidget {
  final List<DashboardExpense> expenses;
  final DashboardBudget budget;

  const ExpenseSnapshotCard({
    super.key,
    required this.expenses,
    required this.budget,
  });

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;
    final now = DateTime.now();
    final spent = expenses
        .where(
          (expense) =>
              expense.date.year == now.year && expense.date.month == now.month,
        )
        .fold<double>(0, (sum, expense) => sum + expense.amount);
    final progress = budget.monthlyTotal == 0
        ? 0.0
        : (spent / budget.monthlyTotal).clamp(0.0, 1.0);

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        context.read<DashboardBloc>().add(const DashboardTabSelected(3));
      },
      borderRadius: BorderRadius.circular(20),
      child: ZenCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(LucideIcons.credit_card, size: 18, color: zen.accent),
                const SizedBox(width: 8),
                Text(
                  'Monthly spending',
                  style: AppTextStyles.headingSmall(zen.textPrimary),
                ),
                const Spacer(),
                Icon(LucideIcons.arrow_up_right, size: 17, color: zen.accent),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              _amount(spent, budget.currency),
              style: AppTextStyles.statNumber(zen.textPrimary),
            ),
            const SizedBox(height: 3),
            Text(
              budget.monthlyTotal == 0
                  ? 'Set a monthly budget to track spending'
                  : 'of ${_amount(budget.monthlyTotal, budget.currency)} monthly budget',
              style: AppTextStyles.bodySmall(zen.textMuted),
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                color: zen.accent,
                backgroundColor: zen.subtleFill,
              ),
            ),
            const SizedBox(height: 9),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  budget.monthlyTotal == 0
                      ? '${expenses.length} expenses this month'
                      : '${_amount(budget.monthlyTotal - spent, budget.currency)} remaining',
                  style: AppTextStyles.labelMedium(zen.accent),
                ),
                Text(
                  '${(progress * 100).toStringAsFixed(0)}% used',
                  style: AppTextStyles.labelSmall(zen.textMuted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String _amount(double amount, String currency) =>
    CurrencyService().formatMoney(amount: amount, currency: currency);
