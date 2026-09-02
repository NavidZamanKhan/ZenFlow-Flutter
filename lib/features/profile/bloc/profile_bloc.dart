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
    on<UploadAvatarEvent>(_onUploadAvatar);
    on<DeleteAvatarEvent>(_onDeleteAvatar);
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
          profile: remote,
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
      await _service.updateProfile(profile: event.profile);
    } catch (_) {
      // Keep optimistic state
    }
  }

  Future<void> _onUploadAvatar(
    UploadAvatarEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(isUploadingAvatar: true));

    try {
      final updated = await _service.uploadAvatar(imagePath: event.imagePath);
      emit(state.copyWith(
        profile: updated,
        isUploadingAvatar: false,
        status: ProfileStatus.success,
        message: 'Profile photo updated successfully',
      ));
    } catch (e) {
      emit(state.copyWith(
        isUploadingAvatar: false,
        status: ProfileStatus.failure,
        message: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  Future<void> _onDeleteAvatar(
    DeleteAvatarEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(isUploadingAvatar: true));

    try {
      final updated = await _service.deleteAvatar();
      emit(state.copyWith(
        profile: updated,
        isUploadingAvatar: false,
        status: ProfileStatus.success,
        message: 'Profile photo removed',
      ));
    } catch (e) {
      emit(state.copyWith(
        isUploadingAvatar: false,
        status: ProfileStatus.failure,
        message: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  Future<void> _onUpdatePreferences(
    UpdateExpensePreferencesEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final oldCurrency = state.profile.currency;
    final newCurrency = event.currency;

    final updated = state.profile.copyWith(
      currency: newCurrency,
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

    await _service.saveLocalProfile(updated);

    if (oldCurrency != newCurrency) {
      await _service.syncConvertedBudgetToCloud(
        oldCurrency: oldCurrency,
        newCurrency: newCurrency,
      );
    }
  }
}
