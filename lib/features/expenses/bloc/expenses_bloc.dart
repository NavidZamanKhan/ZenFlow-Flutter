import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/cache/client_cache.dart';
import '../../../core/services/notification_service.dart';
import '../models/category_budget_item.dart';
import '../models/expense_item.dart';
import '../services/expenses_service.dart';
import 'expenses_event.dart';
import 'expenses_state.dart';

class ExpensesBloc extends Bloc<ExpensesEvent, ExpensesState> {
  static const String _cacheKey = 'expenses_list';
  final ExpensesService _service;
  final ClientCache _cache;
  final NotificationService _notificationService;

  ExpensesBloc({
    ExpensesService? service,
    ClientCache? cache,
    NotificationService? notificationService,
  })  : _service = service ?? ExpensesService(),
        _cache = cache ?? ClientCache.instance,
        _notificationService = notificationService ?? NotificationService(),
        super(_getInitialState(cache ?? ClientCache.instance)) {
    on<FetchExpenses>(_onFetchExpenses);
    on<AddExpense>(_onAddExpense);
    on<DeleteExpense>(_onDeleteExpense);
    on<SwitchSubTab>(
      (event, emit) => emit(state.copyWith(subTab: event.subTab)),
    );
    on<FilterExpenses>(
      (event, emit) => emit(state.copyWith(selectedCategory: event.category)),
    );
    on<UpdateBudget>(_onUpdateBudget);

    add(FetchExpenses());
  }

  static ExpensesState _getInitialState(ClientCache cache) {
    final cached = cache.get<List<ExpenseItem>>(_cacheKey);
    return ExpensesState(
      budgets: const [],
      expenses: (cached != null && cached.isNotEmpty) ? cached : const [],
      monthlyTotalBudget: 40000.0,
    );
  }

  void _checkBudgetThresholds(List<CategoryBudgetItem> budgets) {
    for (final b in budgets) {
      if (b.budgetAmount > 0) {
        final pct = b.percentUsed;
        if (pct >= 100) {
          unawaited(
            _notificationService.showBudgetWarning(
              title: 'Budget Exceeded: ${b.category} ⚠️',
              message:
                  'You have reached 100% of your ${b.category} budget for this month.',
              category: b.category,
            ),
          );
        } else if (pct >= 80) {
          unawaited(
            _notificationService.showBudgetWarning(
              title: 'Budget Alert: ${b.category} 💸',
              message:
                  'You have used $pct% of your ${b.category} monthly budget.',
              category: b.category,
            ),
          );
        }
      }
    }
  }

  Future<void> _onFetchExpenses(
    FetchExpenses event,
    Emitter<ExpensesState> emit,
  ) async {
    try {
      final expenses = await _service.getExpenses();
      _cache.set(_cacheKey, expenses);
      final budgets = await _service.getBudget(expenses);
      final monthlyTotal = await _service.getMonthlyBudgetTotal();
      final budgetCurrency =
          budgets.isNotEmpty ? budgets.first.currency : state.budgetCurrency;
      emit(state.copyWith(
        expenses: expenses,
        budgets: budgets.isNotEmpty ? budgets : state.budgets,
        monthlyTotalBudget: monthlyTotal,
        budgetCurrency: budgetCurrency,
      ));
    } catch (_) {}
  }

  Future<void> _onAddExpense(
    AddExpense event,
    Emitter<ExpensesState> emit,
  ) async {
    final previousExpenses = state.expenses;
    final tempId = event.expense.id.startsWith('temp-')
        ? event.expense.id
        : 'temp-${DateTime.now().millisecondsSinceEpoch}';
    final optimisticExpense = event.expense.copyWith(id: tempId);

    // 1. Instant 0ms Optimistic UI update
    final optimisticList = [optimisticExpense, ...state.expenses];
    _cache.set(_cacheKey, optimisticList);
    emit(state.copyWith(expenses: optimisticList));

    // 2. Silent background network execution
    try {
      final created = await _service.createExpense(optimisticExpense);
      final updatedList = state.expenses
          .map((e) => e.id == tempId ? created : e)
          .toList();
      _cache.set(_cacheKey, updatedList);
      final budgets = await _service.getBudget(updatedList);
      emit(state.copyWith(
        expenses: updatedList,
        budgets: budgets.isNotEmpty ? budgets : state.budgets,
      ));

      _checkBudgetThresholds(budgets);
    } catch (_) {
      _cache.set(_cacheKey, previousExpenses);
      emit(state.copyWith(expenses: previousExpenses));
    }
  }

  Future<void> _onDeleteExpense(
    DeleteExpense event,
    Emitter<ExpensesState> emit,
  ) async {
    final previousExpenses = state.expenses;

    // 1. Instant 0ms Optimistic UI update
    final optimisticList =
        state.expenses.where((item) => item.id != event.expenseId).toList();
    _cache.set(_cacheKey, optimisticList);
    emit(state.copyWith(expenses: optimisticList));

    // 2. Silent background network execution
    try {
      await _service.deleteExpense(event.expenseId);
      final budgets = await _service.getBudget(optimisticList);
      emit(state.copyWith(
        budgets: budgets.isNotEmpty ? budgets : state.budgets,
      ));
    } catch (_) {
      _cache.set(_cacheKey, previousExpenses);
      emit(state.copyWith(expenses: previousExpenses));
    }
  }

  Future<void> _onUpdateBudget(
    UpdateBudget event,
    Emitter<ExpensesState> emit,
  ) async {
    final updatedBudgets = state.budgets
        .map(
          (item) => item.category == event.category
              ? item.copyWith(budgetAmount: event.amount)
              : item,
        )
        .toList();

    emit(state.copyWith(budgets: updatedBudgets));

    try {
      await _service.updateCategoryBudget(
        category: event.category,
        newAmount: event.amount,
        currentBudgets: updatedBudgets,
      );
    } catch (_) {}
  }
}
