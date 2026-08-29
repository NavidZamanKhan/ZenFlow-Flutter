import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';
import '../../../core/widgets/zen_card.dart';

class RemindersCard extends StatelessWidget {
  const RemindersCard({super.key});
  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;
    return ZenCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.bell, size: 18, color: zen.accent),
              const SizedBox(width: 8),
              Text(
                'Up next',
                style: AppTextStyles.headingSmall(zen.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const _ReminderRow(
            title: 'Team stand-up',
            time: '10:30 AM',
            color: Color(0xFF8B5CF6),
          ),
          const SizedBox(height: 12),
          const _ReminderRow(
            title: 'Design review',
            time: '2:00 PM',
            color: Color(0xFFF97316),
          ),
          const SizedBox(height: 12),
          _ReminderRow(
            title: 'Weekly planning',
            time: 'Tomorrow',
            color: zen.accent,
          ),
        ],
      ),
    );
  }
}

class _ReminderRow extends StatelessWidget {
  final String title;
  final String time;
  final Color color;
  const _ReminderRow({
    required this.title,
    required this.time,
    required this.color,
  });
  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;
    return Row(
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Text(title, style: AppTextStyles.bodyMedium(zen.textPrimary)),
        ),
        Text(time, style: AppTextStyles.labelSmall(zen.textMuted)),
      ],
    );
  }
}

class ExpenseSnapshotCard extends StatelessWidget {
  const ExpenseSnapshotCard({super.key});
  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;
    return ZenCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.credit_card, size: 18, color: zen.accent),
              const SizedBox(width: 8),
              Text(
                'This month',
                style: AppTextStyles.headingSmall(zen.textPrimary),
              ),
              const Spacer(),
              Icon(LucideIcons.arrow_up_right, size: 17, color: zen.accent),
            ],
          ),
          const SizedBox(height: 14),
          Text('৳ 24,788', style: AppTextStyles.statNumber(zen.textPrimary)),
          const SizedBox(height: 3),
          Text(
            'of ৳ 40,000 monthly budget',
            style: AppTextStyles.bodySmall(zen.textMuted),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: .62,
              minHeight: 8,
              color: zen.accent,
              backgroundColor: zen.subtleFill,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            '৳ 15,212 left to spend',
            style: AppTextStyles.labelMedium(zen.accent),
          ),
        ],
      ),
    );
  }
}
