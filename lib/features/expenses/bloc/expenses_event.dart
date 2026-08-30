import 'package:equatable/equatable.dart';

import '../models/expense_item.dart';
import 'expenses_state.dart';

sealed class ExpensesEvent extends Equatable {
  const ExpensesEvent();
  @override
  List<Object?> get props => [];
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
  const UpdateBudget(this.category, this.amount);
  @override
  List<Object?> get props => [category, amount];
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
