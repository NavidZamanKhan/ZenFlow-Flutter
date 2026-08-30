import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';
import '../bloc/expenses_state.dart';

class ExpensesSubtabSwitcher extends StatelessWidget {
  final ExpensesSubTab selected;
  final ValueChanged<ExpensesSubTab> onChanged;
  const ExpensesSubtabSwitcher({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: zen.subtleFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: zen.border),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 380),
            curve: Curves.easeOutCubic,
            alignment: selected == ExpensesSubTab.allExpenses
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: .5,
              heightFactor: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: zen.accent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: zen.accent.withValues(alpha: .28),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              _tab(context, 'All Expenses', ExpensesSubTab.allExpenses),
              _tab(context, 'Budget', ExpensesSubTab.budget),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tab(BuildContext context, String text, ExpensesSubTab value) {
    final active = selected == value;
    final zen = context.zenColors;
    return Expanded(
      child: InkWell(
        onTap: () {
          if (!active) HapticFeedback.selectionClick();
          onChanged(value);
        },
        borderRadius: BorderRadius.circular(12),
        child: Center(
          child: Text(
            text,
            style: AppTextStyles.labelLarge(
              active ? Colors.white : zen.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
