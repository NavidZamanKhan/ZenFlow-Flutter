import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../core/services/currency_service.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';
import '../../../core/widgets/zen_card.dart';
import '../models/category_budget_item.dart';

class CategoryBudgetTile extends StatelessWidget {
  final CategoryBudgetItem budget;
  final VoidCallback onEdit;
  final String activeCurrency;

  const CategoryBudgetTile({
    super.key,
    required this.budget,
    required this.onEdit,
    this.activeCurrency = 'BDT',
  });

  String _money(double value) => CurrencyService().formatMoney(
        amount: value,
        currency: activeCurrency,
        fromCurrency: budget.currency,
      );

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;
    final color = budget.isWarning ? Colors.amber.shade700 : zen.accent;
    final remaining = budget.budgetAmount - budget.spentAmount;
    return ZenCard(
      onTap: onEdit,
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(LucideIcons.wallet, size: 17, color: color),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  budget.category,
                  style: AppTextStyles.labelLarge(zen.textPrimary),
                ),
              ),
              if (budget.isWarning)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: .15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.triangle_alert, size: 12, color: color),
                      const SizedBox(width: 3),
                      Text(
                        '${budget.percentUsed}% used',
                        style: AppTextStyles.labelSmall(color),
                      ),
                    ],
                  ),
                )
              else
                Text(
                  '${budget.percentUsed}% used',
                  style: AppTextStyles.labelSmall(zen.textSecondary),
                ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: budget.progress,
              minHeight: 8,
              backgroundColor: zen.subtleFill,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              Text(
                '${_money(budget.spentAmount)} spent',
                style: AppTextStyles.labelSmall(zen.textSecondary),
              ),
              const Spacer(),
              Text(
                '${_money(remaining)} left',
                style: AppTextStyles.labelSmall(zen.textSecondary),
              ),
              const SizedBox(width: 8),
              Icon(LucideIcons.pencil, size: 14, color: zen.accent),
            ],
          ),
        ],
      ),
    );
  }
}
