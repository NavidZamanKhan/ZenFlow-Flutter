import 'package:equatable/equatable.dart';

import '../models/category_budget_item.dart';
import '../models/expense_item.dart';

enum ExpensesSubTab { allExpenses, budget }

class ExpensesState extends Equatable {
  final List<ExpenseItem> expenses;
  final List<CategoryBudgetItem> budgets;
  final ExpensesSubTab subTab;
  final String selectedCategory;

  const ExpensesState({
    required this.expenses,
    required this.budgets,
    this.subTab = ExpensesSubTab.allExpenses,
    this.selectedCategory = 'All',
  });

  List<ExpenseItem> get filteredExpenses => selectedCategory == 'All'
      ? expenses
      : expenses
            .where((expense) => expense.category == selectedCategory)
            .toList();
  double get totalExpenses =>
      expenses.fold(0, (sum, expense) => sum + expense.amount);
  double get totalBudget =>
      budgets.fold(0, (sum, budget) => sum + budget.budgetAmount);

  /// The transaction dataset is the authoritative month total. Some categories
  /// (such as Education and Subscription) intentionally have no cap configured.
  double get spentThisMonth => totalExpenses;
  double get remainingBudget => totalBudget - spentThisMonth;
  double get budgetProgress =>
      totalBudget == 0 ? 0 : (spentThisMonth / totalBudget).clamp(0.0, 1.0);

  ExpensesState copyWith({
    List<ExpenseItem>? expenses,
    List<CategoryBudgetItem>? budgets,
    ExpensesSubTab? subTab,
    String? selectedCategory,
  }) => ExpensesState(
    expenses: expenses ?? this.expenses,
    budgets: budgets ?? this.budgets,
    subTab: subTab ?? this.subTab,
    selectedCategory: selectedCategory ?? this.selectedCategory,
  );

  @override
  List<Object?> get props => [expenses, budgets, subTab, selectedCategory];
}
