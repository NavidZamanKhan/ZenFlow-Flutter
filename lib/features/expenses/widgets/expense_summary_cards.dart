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
  Widget build(BuildContext context) => Column(
    children: [
      _card(context, 'Total expenses', _money(total), LucideIcons.receipt),
      const SizedBox(height: 10),
      Row(
        children: [
          Expanded(
            child: _card(
              context,
              'Spent this month',
              _money(month),
              LucideIcons.credit_card,
              compact: true,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _card(
              context,
              'Remaining budget',
              _money(remaining),
              LucideIcons.wallet,
              compact: true,
            ),
          ),
        ],
      ),
    ],
  );

  Widget _card(
    BuildContext context,
    String label,
    String amount,
    IconData icon, {
    bool compact = false,
  }) {
    final zen = context.zenColors;
    return ZenCard(
      padding: EdgeInsets.all(compact ? 14 : 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: zen.accentLightBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: zen.accent),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelSmall(zen.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  amount,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.headingSmall(zen.textPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
