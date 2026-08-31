import 'package:equatable/equatable.dart';

import '../models/category_budget_item.dart';
import '../models/expense_item.dart';

enum ExpensesSubTab { allExpenses, budget }

class ExpensesState extends Equatable {
  final List<ExpenseItem> expenses;
  final List<CategoryBudgetItem> budgets;
  final double monthlyTotalBudget;
  final ExpensesSubTab subTab;
  final String selectedCategory;

  const ExpensesState({
    required this.expenses,
    required this.budgets,
    this.monthlyTotalBudget = 40000.0,
    this.subTab = ExpensesSubTab.allExpenses,
    this.selectedCategory = 'All',
  });

  List<ExpenseItem> get filteredExpenses => selectedCategory == 'All'
      ? expenses
      : expenses
            .where((expense) => expense.category == selectedCategory)
            .toList();

  /// Total across all time
  double get totalExpenses =>
      expenses.fold(0.0, (sum, expense) => sum + expense.amount);

  /// Total spent in current month (e.g. September 2026)
  double get spentThisMonth {
    final now = DateTime.now();
    return expenses
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  /// Total spent today
  double get todaysSpending {
    final now = DateTime.now();
    return expenses
        .where((e) =>
            e.date.year == now.year &&
            e.date.month == now.month &&
            e.date.day == now.day)
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  /// Active monthly budget limit
  double get totalBudget => monthlyTotalBudget > 0
      ? monthlyTotalBudget
      : budgets.fold(0.0, (sum, budget) => sum + budget.budgetAmount);

  /// Remaining monthly budget (Monthly Total - This Month's Spending)
  double get remainingBudget => totalBudget - spentThisMonth;

  double get budgetProgress =>
      totalBudget == 0 ? 0 : (spentThisMonth / totalBudget).clamp(0.0, 1.0);

  ExpensesState copyWith({
    List<ExpenseItem>? expenses,
    List<CategoryBudgetItem>? budgets,
    double? monthlyTotalBudget,
    ExpensesSubTab? subTab,
    String? selectedCategory,
  }) =>
      ExpensesState(
        expenses: expenses ?? this.expenses,
        budgets: budgets ?? this.budgets,
        monthlyTotalBudget: monthlyTotalBudget ?? this.monthlyTotalBudget,
        subTab: subTab ?? this.subTab,
        selectedCategory: selectedCategory ?? this.selectedCategory,
      );

  @override
  List<Object?> get props => [
        expenses,
        budgets,
        monthlyTotalBudget,
        subTab,
        selectedCategory,
      ];
}
