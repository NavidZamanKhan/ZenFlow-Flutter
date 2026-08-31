import 'package:equatable/equatable.dart';

import '../../../core/services/currency_service.dart';
import '../models/category_budget_item.dart';
import '../models/expense_item.dart';

enum ExpensesSubTab { allExpenses, budget }

class ExpensesState extends Equatable {
  final List<ExpenseItem> expenses;
  final List<CategoryBudgetItem> budgets;
  final double monthlyTotalBudget;
  final String budgetCurrency;
  final ExpensesSubTab subTab;
  final String selectedCategory;

  const ExpensesState({
    required this.expenses,
    required this.budgets,
    this.monthlyTotalBudget = 40000.0,
    this.budgetCurrency = 'BDT',
    this.subTab = ExpensesSubTab.allExpenses,
    this.selectedCategory = 'All',
  });

  List<ExpenseItem> get filteredExpenses => selectedCategory == 'All'
      ? expenses
      : expenses
          .where((expense) => expense.category == selectedCategory)
          .toList();

  /// Total across all time converted to target currency
  double convertedTotalExpenses({
    required String toCurrency,
    Map<String, double>? rates,
  }) {
    final cur = CurrencyService();
    return expenses.fold(
      0.0,
      (sum, expense) =>
          sum +
          cur.convertAmount(
            amount: expense.amount,
            toCurrency: toCurrency,
            fromCurrency: expense.currency,
            rates: rates,
          ),
    );
  }

  /// Total spent in current month converted to target currency
  double convertedSpentThisMonth({
    required String toCurrency,
    Map<String, double>? rates,
  }) {
    final now = DateTime.now();
    final cur = CurrencyService();
    return expenses
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .fold(
          0.0,
          (sum, expense) =>
              sum +
              cur.convertAmount(
                amount: expense.amount,
                toCurrency: toCurrency,
                fromCurrency: expense.currency,
                rates: rates,
              ),
        );
  }

  /// Total spent today converted to target currency
  double convertedTodaysSpending({
    required String toCurrency,
    Map<String, double>? rates,
  }) {
    final now = DateTime.now();
    final cur = CurrencyService();
    return expenses
        .where(
          (e) =>
              e.date.year == now.year &&
              e.date.month == now.month &&
              e.date.day == now.day,
        )
        .fold(
          0.0,
          (sum, expense) =>
              sum +
              cur.convertAmount(
                amount: expense.amount,
                toCurrency: toCurrency,
                fromCurrency: expense.currency,
                rates: rates,
              ),
        );
  }

  /// Active monthly budget limit converted to target currency
  double convertedTotalBudget({
    required String toCurrency,
    Map<String, double>? rates,
  }) {
    final cur = CurrencyService();
    final rawBudget = monthlyTotalBudget > 0
        ? monthlyTotalBudget
        : budgets.fold(0.0, (sum, budget) => sum + budget.budgetAmount);
    return cur.convertAmount(
      amount: rawBudget,
      toCurrency: toCurrency,
      fromCurrency: budgetCurrency,
      rates: rates,
    );
  }

  /// Raw unconverted totals (fallback)
  double get totalExpenses =>
      expenses.fold(0.0, (sum, expense) => sum + expense.amount);

  double get spentThisMonth {
    final now = DateTime.now();
    return expenses
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  double get todaysSpending {
    final now = DateTime.now();
    return expenses
        .where(
          (e) =>
              e.date.year == now.year &&
              e.date.month == now.month &&
              e.date.day == now.day,
        )
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  double get totalBudget => monthlyTotalBudget > 0
      ? monthlyTotalBudget
      : budgets.fold(0.0, (sum, budget) => sum + budget.budgetAmount);

  double get remainingBudget => totalBudget - spentThisMonth;

  double get budgetProgress =>
      totalBudget == 0 ? 0 : (spentThisMonth / totalBudget).clamp(0.0, 1.0);

  ExpensesState copyWith({
    List<ExpenseItem>? expenses,
    List<CategoryBudgetItem>? budgets,
    double? monthlyTotalBudget,
    String? budgetCurrency,
    ExpensesSubTab? subTab,
    String? selectedCategory,
  }) =>
      ExpensesState(
        expenses: expenses ?? this.expenses,
        budgets: budgets ?? this.budgets,
        monthlyTotalBudget: monthlyTotalBudget ?? this.monthlyTotalBudget,
        budgetCurrency: budgetCurrency ?? this.budgetCurrency,
        subTab: subTab ?? this.subTab,
        selectedCategory: selectedCategory ?? this.selectedCategory,
      );

  @override
  List<Object?> get props => [
        expenses,
        budgets,
        monthlyTotalBudget,
        budgetCurrency,
        subTab,
        selectedCategory,
      ];
}
