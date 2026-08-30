import 'package:equatable/equatable.dart';

class CategoryBudgetItem extends Equatable {
  final String category;
  final double budgetAmount;
  final double spentAmount;
  final String currency;

  const CategoryBudgetItem({
    required this.category,
    required this.budgetAmount,
    required this.spentAmount,
    this.currency = 'BDT',
  });

  double get progress =>
      budgetAmount == 0 ? 0 : (spentAmount / budgetAmount).clamp(0.0, 1.0);
  int get percentUsed =>
      budgetAmount == 0 ? 0 : ((spentAmount / budgetAmount) * 100).round();
  bool get isWarning => percentUsed >= 75;

  CategoryBudgetItem copyWith({double? budgetAmount, double? spentAmount}) =>
      CategoryBudgetItem(
        category: category,
        budgetAmount: budgetAmount ?? this.budgetAmount,
        spentAmount: spentAmount ?? this.spentAmount,
        currency: currency,
      );

  @override
  List<Object?> get props => [category, budgetAmount, spentAmount, currency];
}
