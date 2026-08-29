import 'package:equatable/equatable.dart';

class DashboardBudget extends Equatable {
  final double monthlyTotal;
  final String currency;
  final Map<String, double> categoryBudgets;

  const DashboardBudget({
    required this.monthlyTotal,
    required this.currency,
    this.categoryBudgets = const {},
  });

  factory DashboardBudget.empty() => const DashboardBudget(
        monthlyTotal: 0.0,
        currency: 'BDT',
        categoryBudgets: {},
      );

  factory DashboardBudget.fromJson(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) return DashboardBudget.empty();

    final rawMonthly = json['monthlyTotal'] ?? json['monthly_total'];
    double parsedMonthly = 0.0;
    if (rawMonthly is num) {
      parsedMonthly = rawMonthly.toDouble();
    } else if (rawMonthly is String) {
      parsedMonthly = double.tryParse(rawMonthly) ?? 0.0;
    }

    final catMap = <String, double>{};
    final rawCats = json['categoryBudgets'] ?? json['category_budgets'];
    if (rawCats is Map) {
      rawCats.forEach((k, v) {
        if (v is num) {
          catMap[k.toString()] = v.toDouble();
        } else if (v is String) {
          catMap[k.toString()] = double.tryParse(v) ?? 0.0;
        }
      });
    }

    return DashboardBudget(
      monthlyTotal: parsedMonthly,
      currency: json['currency']?.toString() ?? 'BDT',
      categoryBudgets: catMap,
    );
  }

  @override
  List<Object?> get props => [monthlyTotal, currency, categoryBudgets];
}
