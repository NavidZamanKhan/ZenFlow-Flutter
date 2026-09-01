import 'package:equatable/equatable.dart';

import '../models/expense_item.dart';
import 'expenses_state.dart';

sealed class ExpensesEvent extends Equatable {
  const ExpensesEvent();
  @override
  List<Object?> get props => [];
}

class FetchExpenses extends ExpensesEvent {
  const FetchExpenses();
}

class AddExpense extends ExpensesEvent {
  final ExpenseItem expense;
  const AddExpense(this.expense);
  @override
  List<Object?> get props => [expense];
}

class DeleteExpense extends ExpensesEvent {
  final String expenseId;
  const DeleteExpense(this.expenseId);
  @override
  List<Object?> get props => [expenseId];
}

class UpdateBudget extends ExpensesEvent {
  final String category;
  final double amount;
  final String currency;
  const UpdateBudget(this.category, this.amount, {this.currency = 'BDT'});
  @override
  List<Object?> get props => [category, amount, currency];
}

class UpdateMonthlyBudget extends ExpensesEvent {
  final double amount;
  final String currency;
  const UpdateMonthlyBudget(this.amount, {this.currency = 'BDT'});
  @override
  List<Object?> get props => [amount, currency];
}

class SwitchSubTab extends ExpensesEvent {
  final ExpensesSubTab subTab;
  const SwitchSubTab(this.subTab);
  @override
  List<Object?> get props => [subTab];
}

class FilterExpenses extends ExpensesEvent {
  final String category;
  const FilterExpenses(this.category);
  @override
  List<Object?> get props => [category];
}
