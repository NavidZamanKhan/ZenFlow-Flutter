import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../app_colors.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object?> get props => [];
}

class ChangeThemeModeEvent extends ThemeEvent {
  final ThemeMode themeMode;

  const ChangeThemeModeEvent(this.themeMode);

  @override
  List<Object?> get props => [themeMode];
}

class ChangeAccentColorEvent extends ThemeEvent {
  final AppAccentColor accentColor;

  const ChangeAccentColorEvent(this.accentColor);

  @override
  List<Object?> get props => [accentColor];
}
