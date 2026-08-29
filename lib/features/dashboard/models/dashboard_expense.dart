import 'package:equatable/equatable.dart';

class DashboardExpense extends Equatable {
  final String id;
  final String title;
  final double amount;
  final String currency;
  final String category;
  final DateTime date;

  const DashboardExpense({
    required this.id,
    required this.title,
    required this.amount,
    required this.currency,
    required this.category,
    required this.date,
  });

  factory DashboardExpense.fromJson(Map<String, dynamic> json) {
    final rawAmount = json['amount'];
    double parsedAmount = 0.0;
    if (rawAmount is num) {
      parsedAmount = rawAmount.toDouble();
    } else if (rawAmount is String) {
      parsedAmount = double.tryParse(rawAmount) ?? 0.0;
    }

    final rawDate = json['date'] ?? json['createdAt'] ?? json['created_at'];

    return DashboardExpense(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Expense',
      amount: parsedAmount,
      currency: json['currency']?.toString() ?? '৳',
      category: json['category']?.toString() ?? 'General',
      date: rawDate != null
          ? (DateTime.tryParse(rawDate.toString()) ?? DateTime.now())
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, title, amount, currency, category, date];
}
