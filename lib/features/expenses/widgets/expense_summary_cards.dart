import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';
import '../../../core/widgets/zen_card.dart';

class ExpenseSummaryCards extends StatelessWidget {
  final double total;
  final double month;
  final double remaining;

  const ExpenseSummaryCards({
    super.key,
    required this.total,
    required this.month,
    required this.remaining,
  });

  String _money(double value) => '৳${NumberFormat('#,##0.00').format(value)}';

  @override
  Widget build(BuildContext context) {
    final dailyAvg = month / (DateTime.now().day.clamp(1, 31));

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _card(
                context,
                'Total expenses',
                _money(total),
                LucideIcons.receipt,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _card(
                context,
                'Remaining budget',
                _money(remaining),
                LucideIcons.wallet,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _card(
                context,
                'Spent this month',
                _money(month),
                LucideIcons.credit_card,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _card(
                context,
                'Daily average',
                _money(dailyAvg),
                LucideIcons.calendar,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _card(
    BuildContext context,
    String label,
    String amount,
    IconData icon,
  ) {
    final zen = context.zenColors;

    return ZenCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelSmall(zen.textSecondary),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: zen.accentLightBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 15, color: zen.accent),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.headingSmall(zen.textPrimary),
          ),
        ],
      ),
    );
  }
}
