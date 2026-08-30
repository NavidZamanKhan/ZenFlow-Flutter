import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

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
    final isAllExpenses = selected == ExpensesSubTab.allExpenses;

    return Container(
      height: 46,
      padding: const EdgeInsets.all(3.5),
      decoration: BoxDecoration(
        color: zen.isDark ? zen.surface : const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Animated Solid Crisp Active Pill (Apple / Linear Style)
          AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            alignment: isAllExpenses
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 1.0,
              child: Container(
                decoration: BoxDecoration(
                  color: zen.isDark ? zen.card : Colors.white,
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: zen.isDark ? 0.35 : 0.08,
                      ),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Tabs Row
          Positioned.fill(
            child: Row(
              children: [
                _TabItem(
                  label: 'All Expenses',
                  icon: LucideIcons.receipt,
                  isSelected: isAllExpenses,
                  onTap: () {
                    if (!isAllExpenses) {
                      HapticFeedback.selectionClick();
                      onChanged(ExpensesSubTab.allExpenses);
                    }
                  },
                ),
                _TabItem(
                  label: 'Budget',
                  icon: LucideIcons.chart_pie,
                  isSelected: !isAllExpenses,
                  onTap: () {
                    if (isAllExpenses) {
                      HapticFeedback.selectionClick();
                      onChanged(ExpensesSubTab.budget);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: Center(
          child: AnimatedScale(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutBack,
            scale: isSelected ? 1.0 : 0.96,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 140),
                  child: Icon(
                    icon,
                    key: ValueKey(isSelected),
                    size: 15,
                    color: isSelected ? zen.accent : zen.textSecondary,
                  ),
                ),
                const SizedBox(width: 7),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 140),
                  style: AppTextStyles.labelMedium(
                    isSelected ? zen.textPrimary : zen.textSecondary,
                  ).copyWith(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13,
                    height: 1.0,
                  ),
                  child: Text(label),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
