import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../app_colors.dart';

class ThemeState extends Equatable {
  final ThemeMode themeMode;
  final AppAccentColor accentColor;

  const ThemeState({
    this.themeMode = ThemeMode.light,
    this.accentColor = AppAccentColor.blue,
  });

  ThemeState copyWith({
    ThemeMode? themeMode,
    AppAccentColor? accentColor,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      accentColor: accentColor ?? this.accentColor,
    );
  }

  @override
  List<Object?> get props => [themeMode, accentColor];
}
