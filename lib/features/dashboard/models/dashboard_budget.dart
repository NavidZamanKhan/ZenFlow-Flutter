import 'package:equatable/equatable.dart';

class DashboardBudget extends Equatable {
  final double monthlyTotal;
  final String currency;

  const DashboardBudget({required this.monthlyTotal, required this.currency});

  factory DashboardBudget.fromJson(Map<String, dynamic> json) =>
      DashboardBudget(
        monthlyTotal:
            double.tryParse(json['monthlyTotal']?.toString() ?? '') ?? 0,
        currency: json['currency']?.toString() ?? 'BDT',
      );

  @override
  List<Object?> get props => [monthlyTotal, currency];
}
