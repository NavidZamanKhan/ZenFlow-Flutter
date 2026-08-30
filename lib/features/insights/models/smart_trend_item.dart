import 'package:flutter/material.dart';

class SmartTrendItem {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color? accentColor;

  const SmartTrendItem({
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    this.accentColor,
  });
}
