import 'package:flutter_test/flutter_test.dart';
import 'package:zenflow_flutter/core/cache/client_cache.dart';
import 'package:zenflow_flutter/features/expenses/bloc/expenses_bloc.dart';
import 'package:zenflow_flutter/features/expenses/bloc/expenses_event.dart';
import 'package:zenflow_flutter/features/expenses/bloc/expenses_state.dart';
import 'package:zenflow_flutter/features/expenses/models/category_budget_item.dart';
import 'package:zenflow_flutter/features/expenses/models/expense_item.dart';
import 'package:zenflow_flutter/features/expenses/services/expenses_service.dart';

class FakeExpensesService extends ExpensesService {
  final List<ExpenseItem> _expenses = [];
  double _monthlyTotal = 40000.0;
  final List<CategoryBudgetItem> _budgets = [];

  @override
  Future<List<ExpenseItem>> getExpenses() async => List.from(_expenses);

  @override
  Future<ExpenseItem> createExpense(ExpenseItem expense) async {
    final created = expense.copyWith(id: 'created-${_expenses.length + 1}');
    _expenses.add(created);
    return created;
  }

  @override
  Future<void> deleteExpense(String id) async {
    _expenses.removeWhere((e) => e.id == id);
  }

  @override
  Future<List<CategoryBudgetItem>> getBudget(List<ExpenseItem> expenses) async {
    return List.from(_budgets);
  }

  @override
  Future<double> getMonthlyBudgetTotal() async => _monthlyTotal;

  @override
  Future<void> updateMonthlyBudgetTotal({
    required double newTotal,
    required String currency,
    required List<CategoryBudgetItem> currentBudgets,
  }) async {
    _monthlyTotal = newTotal;
  }

  @override
  Future<void> updateCategoryBudget({
    required String category,
    required double newAmount,
    required List<CategoryBudgetItem> currentBudgets,
    required String currency,
    required double currentMonthlyTotal,
  }) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Audit Pass 2: ExpensesBloc & Budget State Transitions', () {
    late ClientCache cache;
    late FakeExpensesService service;

    setUp(() {
      cache = ClientCache.instance;
      cache.clear();
      service = FakeExpensesService();
    });

    test('Check 1: UpdateMonthlyBudget updates state optimistically with currency', () async {
      final bloc = ExpensesBloc(service: service, cache: cache);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(bloc.state.monthlyTotalBudget, 40000.0);

      bloc.add(const UpdateMonthlyBudget(50000.0, currency: 'BDT'));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(bloc.state.monthlyTotalBudget, 50000.0);
      expect(bloc.state.budgetCurrency, 'BDT');

      await bloc.close();
    });

    test('Check 2: UpdateBudget updates category limit with active currency', () async {
      final initialBudgets = [
        const CategoryBudgetItem(
          category: 'Food',
          budgetAmount: 10000.0,
          spentAmount: 2500.0,
          currency: 'BDT',
        ),
        const CategoryBudgetItem(
          category: 'Entertainment',
          budgetAmount: 5000.0,
          spentAmount: 2000.0,
          currency: 'BDT',
        ),
      ];

      final bloc = ExpensesBloc(service: service, cache: cache);
      await Future.delayed(const Duration(milliseconds: 50));

      // Seed state
      bloc.emit(ExpensesState(
        expenses: const [],
        budgets: initialBudgets,
        monthlyTotalBudget: 40000.0,
        budgetCurrency: 'BDT',
      ));

      bloc.add(const UpdateBudget('Entertainment', 8000.0, currency: 'BDT'));
      await Future.delayed(const Duration(milliseconds: 50));

      final updatedEnt =
          bloc.state.budgets.firstWhere((b) => b.category == 'Entertainment');
      expect(updatedEnt.budgetAmount, 8000.0);
      expect(updatedEnt.spentAmount, 2000.0);

      // Verify converted budget totals
      expect(bloc.state.convertedTotalBudget(toCurrency: 'BDT'), 40000.0);

      await bloc.close();
    });

    test('Check 3: Adding expense recalculates spent amounts cleanly', () async {
      final bloc = ExpensesBloc(service: service, cache: cache);
      await Future.delayed(const Duration(milliseconds: 50));

      final newExpense = ExpenseItem(
        id: 'test-1',
        title: 'Dinner',
        amount: 1500.0,
        currency: 'BDT',
        category: 'Food',
        date: DateTime.now(),
        paymentMethod: 'Cash',
      );

      bloc.add(AddExpense(newExpense));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(bloc.state.expenses.length, 1);
      expect(bloc.state.expenses.first.title, 'Dinner');
      expect(bloc.state.convertedSpentThisMonth(toCurrency: 'BDT'), 1500.0);

      await bloc.close();
    });
  });
}
