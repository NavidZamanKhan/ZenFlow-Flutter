import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/category_budget_item.dart';
import '../models/expense_item.dart';
import 'expenses_event.dart';
import 'expenses_state.dart';

class ExpensesBloc extends Bloc<ExpensesEvent, ExpensesState> {
  ExpensesBloc() : super(_initialState()) {
    on<AddExpense>(
      (event, emit) =>
          emit(state.copyWith(expenses: [event.expense, ...state.expenses])),
    );
    on<DeleteExpense>(
      (event, emit) => emit(
        state.copyWith(
          expenses: state.expenses
              .where((item) => item.id != event.expenseId)
              .toList(),
        ),
      ),
    );
    on<SwitchSubTab>(
      (event, emit) => emit(state.copyWith(subTab: event.subTab)),
    );
    on<FilterExpenses>(
      (event, emit) => emit(state.copyWith(selectedCategory: event.category)),
    );
    on<UpdateBudget>(_updateBudget);
  }

  void _updateBudget(UpdateBudget event, Emitter<ExpensesState> emit) => emit(
    state.copyWith(
      budgets: state.budgets
          .map(
            (item) => item.category == event.category
                ? item.copyWith(budgetAmount: event.amount)
                : item,
          )
          .toList(),
    ),
  );

  static ExpensesState _initialState() => ExpensesState(
    budgets: const [
      CategoryBudgetItem(
        category: 'Bills',
        budgetAmount: 20000,
        spentAmount: 16200,
      ),
      CategoryBudgetItem(
        category: 'Shopping',
        budgetAmount: 5000,
        spentAmount: 2500,
      ),
      CategoryBudgetItem(category: 'Food', budgetAmount: 10000, spentAmount: 0),
      CategoryBudgetItem(
        category: 'Transportation',
        budgetAmount: 2000,
        spentAmount: 0,
      ),
      CategoryBudgetItem(
        category: 'Entertainment',
        budgetAmount: 3000,
        spentAmount: 0,
      ),
    ],
    expenses: [
      _expense('1', 'Rent', 15000, 'Bills', 8, 'Card', recurring: true),
      _expense(
        '2',
        'University fees',
        4500,
        'Education',
        8,
        'Card',
        recurring: true,
      ),
      _expense('3', 'Have to buy a mouse', 2500, 'Shopping', 27, 'Cash'),
      _expense(
        '4',
        'Netflix',
        1200,
        'Subscription',
        8,
        'Card',
        recurring: true,
      ),
      _expense(
        '5',
        'Internet bill',
        1200,
        'Bills',
        10,
        'Mobile Wallet',
        recurring: true,
      ),
      _expense('6', 'Spotify', 219, 'Subscription', 5, 'Card', recurring: true),
      _expense(
        '7',
        'YouTube',
        169,
        'Subscription',
        10,
        'Card',
        recurring: true,
      ),
    ],
  );

  static ExpenseItem _expense(
    String id,
    String title,
    double amount,
    String category,
    int day,
    String method, {
    bool recurring = false,
  }) => ExpenseItem(
    id: id,
    title: title,
    amount: amount,
    category: category,
    date: DateTime(2026, 8, day),
    paymentMethod: method,
    isRecurring: recurring,
    recurringInterval: recurring ? 'monthly' : null,
  );
}
