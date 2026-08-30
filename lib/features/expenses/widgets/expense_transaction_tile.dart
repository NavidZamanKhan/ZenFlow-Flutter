import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';
import '../models/expense_item.dart';

class ExpenseTransactionTile extends StatelessWidget {
  final ExpenseItem expense;
  final VoidCallback? onDelete;
  const ExpenseTransactionTile({
    super.key,
    required this.expense,
    this.onDelete,
  });

  IconData get _icon => switch (expense.category) {
    'Bills' => LucideIcons.receipt,
    'Shopping' => LucideIcons.shopping_bag,
    'Food' => LucideIcons.utensils,
    'Transportation' => LucideIcons.car,
    'Entertainment' => LucideIcons.tv,
    'Education' => LucideIcons.graduation_cap,
    _ => LucideIcons.credit_card,
  };

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;
    final money = '৳${NumberFormat('#,##0.00').format(expense.amount)}';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: zen.accentLightBg,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(_icon, size: 19, color: zen.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelLarge(zen.textPrimary),
                ),
                const SizedBox(height: 3),
                Text(
                  '${expense.category} · ${DateFormat('MM/dd/yyyy').format(expense.date)} · ${expense.paymentMethod}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelSmall(zen.textSecondary),
                ),
                if (expense.isRecurring)
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: zen.subtleFill,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.refresh_cw,
                            size: 11,
                            color: zen.textMuted,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            expense.recurringInterval ?? 'recurring',
                            style: AppTextStyles.labelSmall(zen.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('-$money', style: AppTextStyles.labelLarge(zen.textPrimary)),
              if (onDelete != null)
                InkWell(
                  onTap: onDelete,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5, left: 8),
                    child: Icon(
                      LucideIcons.trash_2,
                      size: 14,
                      color: zen.textMuted,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
