import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';
import '../../../core/widgets/zen_card.dart';

class InsightsMetricsGrid extends StatelessWidget {
  final double totalSpending;
  final double spentThisMonth;
  final double dailyAverage;
  final int totalTransactions;

  const InsightsMetricsGrid({
    super.key,
    required this.totalSpending,
    required this.spentThisMonth,
    required this.dailyAverage,
    required this.totalTransactions,
  });

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat('#,##0.00');

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                icon: LucideIcons.wallet,
                label: 'Total spending',
                value: '৳${money.format(totalSpending)}',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                icon: LucideIcons.calendar,
                label: 'This month',
                value: '৳${money.format(spentThisMonth)}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                icon: LucideIcons.clock,
                label: 'Daily average',
                value: '৳${money.format(dailyAverage)}',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                icon: LucideIcons.receipt,
                label: 'Total transactions',
                value: '$totalTransactions',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;

    return ZenCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: zen.accent),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.labelSmall(zen.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.headingSmall(zen.textPrimary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
