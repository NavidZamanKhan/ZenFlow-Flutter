import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../app_colors.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  static const String _themeModeKey = 'zenflow_theme_mode';
  static const String _accentColorKey = 'zenflow_accent_color';

  final FlutterSecureStorage _storage;

  ThemeBloc({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage(),
        super(const ThemeState()) {
    on<LoadThemeEvent>(_onLoadTheme);
    on<ChangeThemeModeEvent>(_onChangeThemeMode);
    on<ChangeAccentColorEvent>(_onChangeAccentColor);

    add(const LoadThemeEvent());
  }

  Future<void> _onLoadTheme(
    LoadThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    try {
      final savedMode = await _storage.read(key: _themeModeKey);
      final savedAccent = await _storage.read(key: _accentColorKey);

      ThemeMode themeMode = state.themeMode;
      if (savedMode == 'dark') {
        themeMode = ThemeMode.dark;
      } else if (savedMode == 'light') {
        themeMode = ThemeMode.light;
      } else if (savedMode == 'system') {
        themeMode = ThemeMode.system;
      }

      AppAccentColor accentColor = state.accentColor;
      if (savedAccent == 'blue') {
        accentColor = AppAccentColor.blue;
      } else if (savedAccent == 'teal') {
        accentColor = AppAccentColor.teal;
      } else if (savedAccent == 'violet') {
        accentColor = AppAccentColor.violet;
      } else if (savedAccent == 'coral') {
        accentColor = AppAccentColor.coral;
      }

      emit(state.copyWith(themeMode: themeMode, accentColor: accentColor));
    } catch (_) {}
  }

  Future<void> _onChangeThemeMode(
    ChangeThemeModeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    emit(state.copyWith(themeMode: event.themeMode));
    try {
      final modeStr = switch (event.themeMode) {
        ThemeMode.dark => 'dark',
        ThemeMode.light => 'light',
        ThemeMode.system => 'system',
      };
      await _storage.write(key: _themeModeKey, value: modeStr);
    } catch (_) {}
  }

  Future<void> _onChangeAccentColor(
    ChangeAccentColorEvent event,
    Emitter<ThemeState> emit,
  ) async {
    emit(state.copyWith(accentColor: event.accentColor));
    try {
      final accentStr = switch (event.accentColor) {
        AppAccentColor.blue => 'blue',
        AppAccentColor.teal => 'teal',
        AppAccentColor.violet => 'violet',
        AppAccentColor.coral => 'coral',
      };
      await _storage.write(key: _accentColorKey, value: accentStr);
    } catch (_) {}
  }
}
