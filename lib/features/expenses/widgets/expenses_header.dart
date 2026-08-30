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
            'Expenses & Budget',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.headingLarge(zen.textPrimary).copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 10),
        ZenButton(
          label: 'Add expense',
          icon: LucideIcons.plus,
          height: 38,
          width: 124,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          onPressed: onAddExpense,
        ),
      ],
    );
  }
}
