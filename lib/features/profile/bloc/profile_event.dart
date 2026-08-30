import 'package:equatable/equatable.dart';

import '../models/user_profile.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfileEvent extends ProfileEvent {
  const LoadProfileEvent();
}

class UpdateProfileEvent extends ProfileEvent {
  final UserProfile profile;

  const UpdateProfileEvent(this.profile);

  @override
  List<Object?> get props => [profile];
}

class UpdateExpensePreferencesEvent extends ProfileEvent {
  final String currency;
  final bool is24HourTime;
  final String displayDensity;

  const UpdateExpensePreferencesEvent({
    required this.currency,
    required this.is24HourTime,
    required this.displayDensity,
  });

  @override
  List<Object?> get props => [currency, is24HourTime, displayDensity];
}
