import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_colors.dart';

class ThemeState {
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
}

class ThemeNotifier extends StateNotifier<ThemeState> {
  ThemeNotifier() : super(const ThemeState());

  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
  }

  void setAccentColor(AppAccentColor accent) {
    state = state.copyWith(accentColor: accent);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});
