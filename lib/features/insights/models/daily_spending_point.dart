import 'package:equatable/equatable.dart';

class DailySpendingPoint extends Equatable {
  final int day;
  final double amount;

  const DailySpendingPoint({
    required this.day,
    required this.amount,
  });

  @override
  List<Object?> get props => [day, amount];
}
