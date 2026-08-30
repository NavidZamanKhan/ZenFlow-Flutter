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
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: zen.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: zen.isDark ? zen.border : zen.border.withValues(alpha: 0.9),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: zen.isDark ? 0.28 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Animated Glowing Sliding Pill Indicator
          AnimatedAlign(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            alignment: isAllExpenses
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 1.0,
              child: Container(
                decoration: BoxDecoration(
                  color: zen.isDark
                      ? zen.accent.withValues(alpha: 0.22)
                      : zen.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: zen.accent.withValues(
                      alpha: zen.isDark ? 0.45 : 0.35,
                    ),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: zen.accent.withValues(
                        alpha: zen.isDark ? 0.20 : 0.14,
                      ),
                      blurRadius: 10,
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
        borderRadius: BorderRadius.circular(12),
        child: Center(
          child: AnimatedScale(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutBack,
            scale: isSelected ? 1.0 : 0.95,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 150),
                  child: Icon(
                    icon,
                    key: ValueKey(isSelected),
                    size: 16,
                    color: isSelected ? zen.accent : zen.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 150),
                  style: AppTextStyles.labelMedium(
                    isSelected ? zen.accent : zen.textSecondary,
                  ).copyWith(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    fontSize: 13.5,
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
