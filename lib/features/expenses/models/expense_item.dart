import 'package:equatable/equatable.dart';

class ExpenseItem extends Equatable {
  final String id;
  final String title;
  final double amount;
  final String currency;
  final String category;
  final DateTime date;
  final String paymentMethod;
  final String? notes;
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
    this.notes,
    this.isRecurring = false,
    this.recurringInterval,
  });

  factory ExpenseItem.fromJson(Map<String, dynamic> json) {
    return ExpenseItem(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      amount: (json['amount'] is num)
          ? (json['amount'] as num).toDouble()
          : double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      currency: json['currency'] ?? 'BDT',
      category: json['category'] ?? 'Others',
      date: json['date'] != null
          ? DateTime.tryParse(json['date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      paymentMethod: json['paymentMethod'] ?? json['payment_method'] ?? 'Card',
      notes: json['notes'],
      isRecurring: json['isRecurring'] ?? json['is_recurring'] ?? false,
      recurringInterval:
          json['recurringInterval'] ?? json['recurring_interval'],
    );
  }

  Map<String, dynamic> toJson({bool includeId = true}) {
    return {
      if (includeId && id.isNotEmpty && !id.startsWith('temp-')) 'id': id,
      'title': title.trim(),
      'amount': amount,
      'currency': currency,
      'category': category.trim().isNotEmpty ? category.trim() : 'Others',
      'date':
          '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
      'paymentMethod': paymentMethod,
      if (notes != null && notes!.trim().isNotEmpty) 'notes': notes!.trim(),
      'isRecurring': isRecurring,
      if (isRecurring && recurringInterval != null)
        'recurringInterval': recurringInterval,
    };
  }

  ExpenseItem copyWith({
    String? id,
    String? title,
    double? amount,
    String? currency,
    String? category,
    DateTime? date,
    String? paymentMethod,
    String? notes,
    bool? isRecurring,
    String? recurringInterval,
  }) {
    return ExpenseItem(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      category: category ?? this.category,
      date: date ?? this.date,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringInterval: recurringInterval ?? this.recurringInterval,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        amount,
        currency,
        category,
        date,
        paymentMethod,
        notes,
        isRecurring,
        recurringInterval,
      ];
}
