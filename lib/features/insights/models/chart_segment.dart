import 'package:flutter/material.dart';

class ChartSegment {
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
}
