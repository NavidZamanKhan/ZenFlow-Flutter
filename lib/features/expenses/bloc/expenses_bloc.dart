import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/category_budget_item.dart';
import '../models/expense_item.dart';
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
      if (expenses.isNotEmpty) {
        final budgets = await _service.getBudget(expenses);
        emit(state.copyWith(
          expenses: expenses,
          budgets: budgets.isNotEmpty ? budgets : state.budgets,
        ));
      }
    } catch (_) {
      // Keep existing state if offline or token pending
    }
  }

  Future<void> _onAddExpense(
    AddExpense event,
    Emitter<ExpensesState> emit,
  ) async {
    final previousExpenses = state.expenses;
    emit(state.copyWith(expenses: [event.expense, ...state.expenses]));

    try {
      final created = await _service.createExpense(event.expense);
      final updatedList = state.expenses
          .map((e) => e.id == event.expense.id ? created : e)
          .toList();
      final updatedBudgets = await _service.getBudget(updatedList);
      emit(state.copyWith(
        expenses: updatedList,
        budgets: updatedBudgets.isNotEmpty ? updatedBudgets : state.budgets,
      ));
    } catch (_) {
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

  static ExpensesState _initialState() => ExpensesState(
        budgets: const [
          CategoryBudgetItem(category: 'Bills', budgetAmount: 20000, spentAmount: 16200),
          CategoryBudgetItem(category: 'Shopping', budgetAmount: 5000, spentAmount: 2500),
          CategoryBudgetItem(category: 'Food', budgetAmount: 10000, spentAmount: 0),
          CategoryBudgetItem(category: 'Transportation', budgetAmount: 2000, spentAmount: 0),
          CategoryBudgetItem(category: 'Entertainment', budgetAmount: 3000, spentAmount: 0),
        ],
        expenses: [
          ExpenseItem(
            id: '1',
            title: 'Have to buy a mouse',
            amount: 2500,
            category: 'Shopping',
            date: DateTime(2026, 8, 27),
            paymentMethod: 'Cash',
          ),
          ExpenseItem(
            id: '2',
            title: 'Internet bill',
            amount: 1200,
            category: 'Bills',
            date: DateTime(2026, 8, 10),
            paymentMethod: 'Mobile Wallet',
            isRecurring: true,
            recurringInterval: 'monthly',
          ),
          ExpenseItem(
            id: '3',
            title: 'YouTube',
            amount: 169,
            category: 'Subscription',
            date: DateTime(2026, 8, 10),
            paymentMethod: 'Card',
            isRecurring: true,
            recurringInterval: 'monthly',
          ),
          ExpenseItem(
            id: '4',
            title: 'Netflix',
            amount: 1200,
            category: 'Subscription',
            date: DateTime(2026, 8, 8),
            paymentMethod: 'Card',
            isRecurring: true,
            recurringInterval: 'monthly',
          ),
          ExpenseItem(
            id: '5',
            title: 'Spotify',
            amount: 219,
            category: 'Subscription',
            date: DateTime(2026, 8, 5),
            paymentMethod: 'Card',
            isRecurring: true,
            recurringInterval: 'monthly',
          ),
          ExpenseItem(
            id: '6',
            title: 'Rent',
            amount: 15000,
            category: 'Bills',
            date: DateTime(2026, 8, 5),
            paymentMethod: 'Card',
            isRecurring: true,
            recurringInterval: 'monthly',
          ),
        ],
      );
}
