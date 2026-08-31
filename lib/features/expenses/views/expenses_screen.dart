import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';
import '../../../core/widgets/zen_card.dart';
import '../bloc/expenses_bloc.dart';
import '../bloc/expenses_event.dart';
import '../bloc/expenses_state.dart';
import '../models/category_budget_item.dart';
import '../widgets/category_budget_tile.dart';
import '../widgets/edit_budget_bottom_sheet.dart';
import '../widgets/expense_summary_cards.dart';
import '../widgets/expense_transaction_tile.dart';
import '../widgets/expenses_header.dart';
import '../widgets/expenses_subtab_switcher.dart';
import '../widgets/new_expense_bottom_sheet.dart';

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});
  static const _filters = [
    'All',
    'Bills',
    'Shopping',
    'Subscription',
    'Education',
    'Food',
    'Transportation',
  ];

  static Color? _categoryColor(String name) {
    switch (name) {
      case 'Bills':
        return const Color(0xFF8B5CF6);
      case 'Shopping':
        return const Color(0xFFEC4899);
      case 'Subscription':
        return const Color(0xFF3B82F6);
      case 'Education':
        return const Color(0xFF06B6D4);
      case 'Food':
        return const Color(0xFFF59E0B);
      case 'Transportation':
        return const Color(0xFF10B981);
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).unfocus(),
      child: ColoredBox(
        color: zen.canvas,
        child: SafeArea(
          child: BlocBuilder<ExpensesBloc, ExpensesState>(
            builder: (context, state) {
              return RefreshIndicator(
                color: zen.accent,
                backgroundColor: zen.card,
                onRefresh: () async {
                  context.read<ExpensesBloc>().add(const FetchExpenses());
                  await Future.delayed(const Duration(milliseconds: 650));
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 118),
                  children: <Widget>[
                    ExpensesHeader(
                      onAddExpense: () => NewExpenseBottomSheet.show(
                        context,
                        onCreated: (item) =>
                            context.read<ExpensesBloc>().add(AddExpense(item)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ExpensesSubtabSwitcher(
                      selected: state.subTab,
                      onChanged: (tab) =>
                          context.read<ExpensesBloc>().add(SwitchSubTab(tab)),
                    ),
                    const SizedBox(height: 16),
                    state.subTab == ExpensesSubTab.allExpenses
                        ? _allExpenses(context, state)
                        : _budget(context, state),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _allExpenses(BuildContext context, ExpensesState state) {
    final zen = context.zenColors;
    final expenses = state.filteredExpenses;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExpenseSummaryCards(
          total: state.totalExpenses,
          today: state.todaysSpending,
          month: state.spentThisMonth,
          remaining: state.remainingBudget,
          monthlyBudget: state.monthlyTotalBudget,
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _filters.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (_, index) {
              final filter = _filters[index];
              final active = filter == state.selectedCategory;
              final dotColor = _categoryColor(filter);

              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  context.read<ExpensesBloc>().add(FilterExpenses(filter));
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: active ? zen.accent : zen.subtleFill,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: active ? zen.accent : zen.border.withValues(alpha: 0.8),
                      width: 1.0,
                    ),
                    boxShadow: active
                        ? [
                            BoxShadow(
                              color: zen.accent.withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (dotColor != null && !active) ...[
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: dotColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 240),
                        curve: Curves.easeOutCubic,
                        style: AppTextStyles.labelSmall(
                          active ? Colors.white : zen.textPrimary,
                        ).copyWith(
                          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 12.5,
                        ),
                        child: Text(filter),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        ZenCard(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 4, 5),
                child: Row(
                  children: [
                    Icon(LucideIcons.receipt, size: 17, color: zen.accent),
                    const SizedBox(width: 8),
                    Text(
                      'Recent transactions',
                      style: AppTextStyles.headingSmall(zen.textPrimary),
                    ),
                    const Spacer(),
                    Text(
                      '${expenses.length} items',
                      style: AppTextStyles.labelSmall(zen.textMuted),
                    ),
                  ],
                ),
              ),
              if (expenses.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 34),
                  child: Center(
                    child: Text(
                      'No expenses in this category.',
                      style: AppTextStyles.bodyMedium(zen.textSecondary),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: expenses.length,
                  separatorBuilder: (_, _) =>
                      Divider(height: 1, color: zen.border),
                  itemBuilder: (_, index) => ExpenseTransactionTile(
                    expense: expenses[index],
                    onDelete: () => context.read<ExpensesBloc>().add(
                      DeleteExpense(expenses[index].id),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _budget(BuildContext context, ExpensesState state) {
    final zen = context.zenColors;
    final money = NumberFormat('#,##0.00');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ZenCard(
          customBgColor: zen.isDark ? zen.card : zen.accentLightBg,
          customBorderColor: zen.accentLightBorder,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(LucideIcons.wallet, size: 19, color: zen.accent),
                  const SizedBox(width: 8),
                  Text(
                    'Monthly budget',
                    style: AppTextStyles.headingSmall(zen.textPrimary),
                  ),
                  const Spacer(),
                  Icon(LucideIcons.pencil, size: 16, color: zen.accent),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '৳${money.format(state.totalBudget)}',
                style: AppTextStyles.displayMedium(zen.textPrimary),
              ),
              const SizedBox(height: 5),
              Text(
                '৳${money.format(state.spentThisMonth)} spent · ৳${money.format(state.remainingBudget)} remaining',
                style: AppTextStyles.bodySmall(zen.textSecondary),
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: state.budgetProgress,
                  minHeight: 10,
                  backgroundColor: zen.subtleFill,
                  valueColor: AlwaysStoppedAnimation(zen.accent),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${(state.budgetProgress * 100).round()}% used this month',
                style: AppTextStyles.labelSmall(zen.accent),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Category limits',
          style: AppTextStyles.headingSmall(zen.textPrimary),
        ),
        const SizedBox(height: 10),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.budgets.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (_, index) => CategoryBudgetTile(
            budget: state.budgets[index],
            onEdit: () => _editBudget(context, state.budgets[index]),
          ),
        ),
      ],
    );
  }

  void _editBudget(BuildContext context, CategoryBudgetItem item) =>
      EditBudgetBottomSheet.show(
        context,
        budget: item,
        onSaved: (amount) => context.read<ExpensesBloc>().add(
          UpdateBudget(item.category, amount),
        ),
      );
}
