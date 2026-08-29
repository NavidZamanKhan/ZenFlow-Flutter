import 'package:flutter_bloc/flutter_bloc.dart';

import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(const ThemeState()) {
    on<ChangeThemeModeEvent>(_onChangeThemeMode);
    on<ChangeAccentColorEvent>(_onChangeAccentColor);
  }

  void _onChangeThemeMode(ChangeThemeModeEvent event, Emitter<ThemeState> emit) {
    emit(state.copyWith(themeMode: event.themeMode));
  }

  void _onChangeAccentColor(ChangeAccentColorEvent event, Emitter<ThemeState> emit) {
    emit(state.copyWith(accentColor: event.accentColor));
  }
}
