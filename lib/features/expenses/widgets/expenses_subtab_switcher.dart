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
      height: 52,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: zen.isDark ? zen.card : zen.subtleFill,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: zen.isDark ? zen.border : zen.border.withValues(alpha: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: zen.isDark ? 0.25 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Animated Glowing Sliding Pill Indicator (Identical to Bottom Bar)
          AnimatedAlign(
            duration: const Duration(milliseconds: 320),
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
                      : zen.accentSoft,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: zen.accent.withValues(
                      alpha: zen.isDark ? 0.32 : 0.24,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: zen.accent.withValues(
                        alpha: zen.isDark ? 0.18 : 0.12,
                      ),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Tabs Row
          Row(
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
        borderRadius: BorderRadius.circular(16),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutBack,
          scale: isSelected ? 1.0 : 0.94,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: Icon(
                  icon,
                  key: ValueKey(isSelected),
                  size: isSelected ? 17 : 16,
                  color: isSelected ? zen.accent : zen.textMuted,
                ),
              ),
              const SizedBox(width: 7),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 180),
                style: AppTextStyles.labelMedium(
                  isSelected ? zen.accent : zen.textMuted,
                ).copyWith(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
