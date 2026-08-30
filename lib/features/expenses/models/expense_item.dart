import 'package:equatable/equatable.dart';

class ExpenseItem extends Equatable {
  final String id;
  final String title;
  final double amount;
  final String currency;
  final String category;
  final DateTime date;
  final String paymentMethod;
  final bool isRecurring;
  final String? recurringInterval;

  const ExpenseItem({
    required this.id,
    required this.title,
    required this.amount,
    this.currency = 'BDT',
    required this.category,
    required this.date,
    required this.paymentMethod,
    this.isRecurring = false,
    this.recurringInterval,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    amount,
    currency,
    category,
    date,
    paymentMethod,
    isRecurring,
    recurringInterval,
  ];
}
