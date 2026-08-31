import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../core/services/currency_service.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';
import '../../../core/widgets/zen_card.dart';

class ExpenseSummaryCards extends StatelessWidget {
  final double total;
  final double today;
  final double month;
  final double remaining;
  final double monthlyBudget;
  final String currency;

  const ExpenseSummaryCards({
    super.key,
    required this.total,
    required this.today,
    required this.month,
    required this.remaining,
    this.monthlyBudget = 40000.0,
    this.currency = 'BDT',
  });

  String _money(double value) =>
      CurrencyService().formatMoney(amount: value, currency: currency);

  @override
  Widget build(BuildContext context) {
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
                "Today's spending",
                _money(today),
                LucideIcons.calendar,
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
                'This month',
                _money(month),
                LucideIcons.credit_card,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _card(
                context,
                'Remaining budget',
                _money(remaining),
                LucideIcons.wallet,
                subtitle:
                    '${_money(month)} of ${_money(monthlyBudget)} spent',
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
    IconData icon, {
    String? subtitle,
  }) {
    final zen = context.zenColors;

    return ZenCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelSmall(zen.textSecondary),
                ),
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
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelSmall(zen.textMuted),
            ),
          ],
        ],
      ),
    );
  }
}
