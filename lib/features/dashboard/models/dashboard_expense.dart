import 'package:equatable/equatable.dart';

class DashboardExpense extends Equatable {
  final double amount;
  final String currency;
  final DateTime date;

  const DashboardExpense({
    required this.amount,
    required this.currency,
    required this.date,
  });

  factory DashboardExpense.fromJson(Map<String, dynamic> json) =>
      DashboardExpense(
        amount: double.tryParse(json['amount']?.toString() ?? '') ?? 0,
        currency: json['currency']?.toString() ?? 'BDT',
        date:
            DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      );

  @override
  List<Object?> get props => [amount, currency, date];
}
