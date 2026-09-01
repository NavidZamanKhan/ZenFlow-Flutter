import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class ChartSegment extends Equatable {
  final String label;
  final double amount;
  final double percentage;
  final Color color;

  const ChartSegment({
    required this.label,
    required this.amount,
    required this.percentage,
    required this.color,
  });

  @override
  List<Object?> get props => [label, amount, percentage, color];
}
