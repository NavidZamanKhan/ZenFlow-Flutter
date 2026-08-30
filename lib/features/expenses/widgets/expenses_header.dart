import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';
import '../../../core/widgets/zen_button.dart';

class ExpensesHeader extends StatelessWidget {
  final VoidCallback onAddExpense;
  const ExpensesHeader({super.key, required this.onAddExpense});

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MONEY OVERVIEW',
                style: AppTextStyles.labelSmall(zen.accent),
              ),
              const SizedBox(height: 4),
              Text(
                'Expenses & Budget',
                style: AppTextStyles.headingLarge(zen.textPrimary),
              ),
              const SizedBox(height: 5),
              Text(
                'Track every taka with clarity.',
                style: AppTextStyles.bodySmall(zen.textSecondary),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: zen.accentLightBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: zen.accentLightBorder),
              ),
              child: Text('BDT ৳', style: AppTextStyles.labelSmall(zen.accent)),
            ),
            const SizedBox(height: 9),
            ZenButton(
              label: 'Add expense',
              icon: LucideIcons.plus,
              height: 38,
              width: 132,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              onPressed: onAddExpense,
            ),
          ],
        ),
      ],
    );
  }
}
