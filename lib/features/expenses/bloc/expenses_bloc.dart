import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/category_budget_item.dart';
import '../services/expenses_service.dart';
import 'expenses_event.dart';
import 'expenses_state.dart';

class ExpensesBloc extends Bloc<ExpensesEvent, ExpensesState> {
  final ExpensesService _service;

  ExpensesBloc({ExpensesService? service})
      : _service = service ?? ExpensesService(),
        super(_initialState()) {
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
  }

  Future<void> _onFetchExpenses(
    FetchExpenses event,
    Emitter<ExpensesState> emit,
  ) async {
    try {
      final expenses = await _service.getExpenses();
      final budgets = await _service.getBudget(expenses);
      emit(state.copyWith(
        expenses: expenses,
        budgets: budgets.isNotEmpty ? budgets : state.budgets,
      ));
    } catch (_) {
      // Keep existing state if offline or token pending
    }
  }

  Future<void> _onAddExpense(
    AddExpense event,
    Emitter<ExpensesState> emit,
  ) async {
    // Optimistic insert
    final previousExpenses = state.expenses;
    emit(state.copyWith(expenses: [event.expense, ...state.expenses]));

    try {
      final created = await _service.createExpense(event.expense);
      // Replace dummy with server created
      final updatedList = state.expenses
          .map((e) => e.id == event.expense.id ? created : e)
          .toList();
      final updatedBudgets = await _service.getBudget(updatedList);
      emit(state.copyWith(
        expenses: updatedList,
        budgets: updatedBudgets.isNotEmpty ? updatedBudgets : state.budgets,
      ));
    } catch (_) {
      // Rollback on network failure
      emit(state.copyWith(expenses: previousExpenses));
    }
  }

  Future<void> _onDeleteExpense(
    DeleteExpense event,
    Emitter<ExpensesState> emit,
  ) async {
    final previousExpenses = state.expenses;
    emit(state.copyWith(
      expenses:
          state.expenses.where((item) => item.id != event.expenseId).toList(),
    ));

    try {
      await _service.deleteExpense(event.expenseId);
      final updatedBudgets = await _service.getBudget(state.expenses);
      emit(state.copyWith(
        budgets: updatedBudgets.isNotEmpty ? updatedBudgets : state.budgets,
      ));
    } catch (_) {
      // Rollback on failure
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
    } catch (_) {
      // Keep optimistic UI
    }
  }

  static ExpensesState _initialState() => const ExpensesState(
        budgets: [
          CategoryBudgetItem(category: 'Bills', budgetAmount: 20000, spentAmount: 16200),
          CategoryBudgetItem(category: 'Shopping', budgetAmount: 5000, spentAmount: 2500),
          CategoryBudgetItem(category: 'Food', budgetAmount: 10000, spentAmount: 0),
          CategoryBudgetItem(category: 'Transportation', budgetAmount: 2000, spentAmount: 0),
          CategoryBudgetItem(category: 'Entertainment', budgetAmount: 3000, spentAmount: 0),
        ],
        expenses: [],
      );
}
