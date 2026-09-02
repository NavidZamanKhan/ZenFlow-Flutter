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

class UploadAvatarEvent extends ProfileEvent {
  final String imagePath;

  const UploadAvatarEvent(this.imagePath);

  @override
  List<Object?> get props => [imagePath];
}

class DeleteAvatarEvent extends ProfileEvent {
  const DeleteAvatarEvent();
}

class UpdateExpensePreferencesEvent extends ProfileEvent {
  final String currency;
  final String dateFormat;
  final String numberFormat;
  final String firstDayOfWeek;
  final String defaultPaymentMethod;
  final String defaultExpenseCategory;
  final bool is24HourTime;
  final String displayDensity;

  const UpdateExpensePreferencesEvent({
    required this.currency,
    required this.dateFormat,
    required this.numberFormat,
    required this.firstDayOfWeek,
    required this.defaultPaymentMethod,
    required this.defaultExpenseCategory,
    required this.is24HourTime,
    required this.displayDensity,
  });

  @override
  List<Object?> get props => [
        currency,
        dateFormat,
        numberFormat,
        firstDayOfWeek,
        defaultPaymentMethod,
        defaultExpenseCategory,
        is24HourTime,
        displayDensity,
      ];
}
