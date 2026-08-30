import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/profile_service.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileService _service;

  ProfileBloc({ProfileService? service})
      : _service = service ?? ProfileService(),
        super(ProfileState.initial()) {
    on<LoadProfileEvent>(_onLoad);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<UpdateExpensePreferencesEvent>(_onUpdatePreferences);
  }

  Future<void> _onLoad(
    LoadProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      final remote = await _service.getProfile();
      if (remote != null) {
        emit(state.copyWith(
          profile: state.profile.copyWith(
            fullName: remote.fullName,
            username: remote.username,
            email: remote.email,
          ),
          status: ProfileStatus.success,
        ));
      } else {
        emit(state.copyWith(status: ProfileStatus.success));
      }
    } catch (_) {
      emit(state.copyWith(status: ProfileStatus.success));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(
      profile: event.profile,
      status: ProfileStatus.success,
      message: 'Profile updated successfully',
    ));

    try {
      await _service.updateProfile(fullName: event.profile.fullName);
    } catch (_) {
      // Keep optimistic state
    }
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
