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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            'Expenses',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.displayLarge(zen.textPrimary),
          ),
        ),
        const SizedBox(width: 12),
        ZenButton(
          label: 'Add expense',
          icon: LucideIcons.plus,
          height: 38,
          width: 132,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          onPressed: onAddExpense,
        ),
      ],
    );
  }
}
