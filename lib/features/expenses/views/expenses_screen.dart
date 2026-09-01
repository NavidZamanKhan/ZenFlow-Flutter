import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../core/services/currency_service.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';
import '../../../core/widgets/zen_card.dart';
import '../../profile/bloc/profile_bloc.dart';
import '../../profile/bloc/profile_event.dart';
import '../bloc/expenses_bloc.dart';
import '../bloc/expenses_event.dart';
import '../bloc/expenses_state.dart';
import '../models/category_budget_item.dart';
import '../widgets/category_budget_tile.dart';
import '../widgets/edit_budget_bottom_sheet.dart';
import '../widgets/edit_monthly_budget_bottom_sheet.dart';
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
              final isAllExpenses =
                  state.subTab == ExpensesSubTab.allExpenses;
              return RefreshIndicator(
                color: zen.accent,
                backgroundColor: zen.card,
                onRefresh: () async {
                  context.read<ProfileBloc>().add(const LoadProfileEvent());
                  context.read<ExpensesBloc>().add(const FetchExpenses());
                  await Future.delayed(const Duration(milliseconds: 650));
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 118),
                  children: [
                    ExpensesHeader(
                      onAddExpense: () {
                        HapticFeedback.lightImpact();
                        final currency =
                            context.read<ProfileBloc>().state.profile.currency;
                        NewExpenseBottomSheet.show(
                          context,
                          currency: currency,
                          onCreated: (expense) {
                            context.read<ExpensesBloc>().add(AddExpense(expense));
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 18),
                    ExpensesSubtabSwitcher(
                      selected: state.subTab,
                      onChanged: (tab) {
                        HapticFeedback.selectionClick();
                        context.read<ExpensesBloc>().add(SwitchSubTab(tab));
                      },
                    ),
                    const SizedBox(height: 18),
                    AnimatedCrossFade(
                      duration: const Duration(milliseconds: 250),
                      crossFadeState: isAllExpenses
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      firstChild: _allExpenses(context, state),
                      secondChild: _budget(context, state),
                    ),
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
    final currency = context.select<ProfileBloc, String>(
      (bloc) => bloc.state.profile.currency,
    );

    final total = state.convertedTotalExpenses(toCurrency: currency);
    final today = state.convertedTodaysSpending(toCurrency: currency);
    final month = state.convertedSpentThisMonth(toCurrency: currency);
    final budgetTotal = state.convertedTotalBudget(toCurrency: currency);
    final remaining = budgetTotal - month;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExpenseSummaryCards(
          total: total,
          today: today,
          month: month,
          remaining: remaining,
          monthlyBudget: budgetTotal,
          currency: currency,
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: active ? zen.accent : zen.subtleFill,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: active
                          ? zen.accent
                          : zen.border.withValues(alpha: 0.8),
                      width: 1.0,
                    ),
                    boxShadow: active
                        ? [
                            BoxShadow(
                              color: zen.accent.withValues(alpha: 0.28),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (dotColor != null) ...[
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: active ? Colors.white : dotColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        filter,
                        style: AppTextStyles.labelSmall(
                          active ? Colors.white : zen.textSecondary,
                        ).copyWith(
                          fontWeight:
                              active ? FontWeight.w700 : FontWeight.w500,
                        ),
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Text(
                      'Recent Expenses',
                      style: AppTextStyles.headingSmall(zen.textPrimary),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: zen.accentSoft,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${expenses.length}',
                        style: AppTextStyles.labelSmall(zen.accent).copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              if (expenses.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 36),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.inbox, size: 36, color: zen.textMuted),
                        const SizedBox(height: 10),
                        Text(
                          'No expenses found',
                          style: AppTextStyles.bodyMedium(zen.textSecondary),
                        ),
                      ],
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
                    activeCurrency: currency,
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
    final currency = context.select<ProfileBloc, String>(
      (bloc) => bloc.state.profile.currency,
    );

    final budgetTotal = state.convertedTotalBudget(toCurrency: currency);
    final spentThisMonth = state.convertedSpentThisMonth(toCurrency: currency);
    final remainingBudget = budgetTotal - spentThisMonth;
    final budgetProgress = budgetTotal > 0
        ? (spentThisMonth / budgetTotal).clamp(0.0, 1.0)
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ZenCard(
          onTap: () => _editMonthlyBudget(context, budgetTotal),
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
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 28, minHeight: 28),
                    icon: Icon(LucideIcons.pencil, size: 16, color: zen.accent),
                    onPressed: () =>
                        _editMonthlyBudget(context, budgetTotal),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                CurrencyService().formatMoney(
                  amount: budgetTotal,
                  currency: currency,
                ),
                style: AppTextStyles.displayMedium(zen.textPrimary),
              ),
              const SizedBox(height: 5),
              Text(
                '${CurrencyService().formatMoney(amount: spentThisMonth, currency: currency)} spent · ${CurrencyService().formatMoney(amount: remainingBudget, currency: currency)} remaining',
                style: AppTextStyles.bodySmall(zen.textSecondary),
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: budgetProgress,
                  minHeight: 10,
                  backgroundColor: zen.subtleFill,
                  valueColor: AlwaysStoppedAnimation(zen.accent),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${(budgetProgress * 100).round()}% used this month',
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
            activeCurrency: currency,
            onEdit: () => _editBudget(context, state.budgets[index]),
          ),
        ),
      ],
    );
  }

  void _editMonthlyBudget(BuildContext context, double currentBudget) {
    HapticFeedback.lightImpact();
    final currency = context.read<ProfileBloc>().state.profile.currency;
    EditMonthlyBudgetBottomSheet.show(
      context,
      currentBudget: currentBudget,
      currency: currency,
      onSaved: (amount) => context.read<ExpensesBloc>().add(
        UpdateMonthlyBudget(amount, currency: currency),
      ),
    );
  }

  void _editBudget(BuildContext context, CategoryBudgetItem item) {
    HapticFeedback.lightImpact();
    final currency = context.read<ProfileBloc>().state.profile.currency;
    EditBudgetBottomSheet.show(
      context,
      budget: item,
      currency: currency,
      onSaved: (amount) => context.read<ExpensesBloc>().add(
        UpdateBudget(item.category, amount, currency: currency),
      ),
    );
  }
}
