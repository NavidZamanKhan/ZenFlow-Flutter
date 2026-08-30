import 'package:flutter_bloc/flutter_bloc.dart';

import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileState.initial()) {
    on<LoadProfileEvent>(_onLoad);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<UpdateExpensePreferencesEvent>(_onUpdatePreferences);
  }

  void _onLoad(LoadProfileEvent event, Emitter<ProfileState> emit) {
    emit(state.copyWith(status: ProfileStatus.success));
  }

  void _onUpdateProfile(UpdateProfileEvent event, Emitter<ProfileState> emit) {
    emit(state.copyWith(
      profile: event.profile,
      status: ProfileStatus.success,
      message: 'Profile updated successfully',
    ));
  }

  void _onUpdatePreferences(
    UpdateExpensePreferencesEvent event,
    Emitter<ProfileState> emit,
  ) {
    final updated = state.profile.copyWith(
      currency: event.currency,
      dateFormat: event.dateFormat,
      numberFormat: event.numberFormat,
      firstDayOfWeek: event.firstDayOfWeek,
      defaultPaymentMethod: event.defaultPaymentMethod,
      defaultExpenseCategory: event.defaultExpenseCategory,
      is24HourTime: event.is24HourTime,
      displayDensity: event.displayDensity,
    );
    emit(state.copyWith(
      profile: updated,
      status: ProfileStatus.success,
      message: 'Preferences saved successfully',
    ));
  }
}
