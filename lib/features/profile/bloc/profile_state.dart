import 'package:equatable/equatable.dart';

import '../models/user_profile.dart';

enum ProfileStatus { initial, loading, success, failure }

class ProfileState extends Equatable {
  final UserProfile profile;
  final ProfileStatus status;
  final bool isUploadingAvatar;
  final String? message;

  const ProfileState({
    required this.profile,
    this.status = ProfileStatus.initial,
    this.isUploadingAvatar = false,
    this.message,
  });

  factory ProfileState.initial() => const ProfileState(
        profile: UserProfile(
          fullName: 'Navid',
          username: 'itsnavidzamankhan',
          email: 'itsnavidzamankhan@gmail.com',
          avatarUrl: null,
          phone: '',
          country: 'Bangladesh',
          timeZone: 'Asia/Dhaka',
          currency: 'BDT',
          displayDensity: 'comfortable',
          is24HourTime: false,
        ),
        status: ProfileStatus.initial,
        isUploadingAvatar: false,
      );

  ProfileState copyWith({
    UserProfile? profile,
    ProfileStatus? status,
    bool? isUploadingAvatar,
    String? message,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      status: status ?? this.status,
      isUploadingAvatar: isUploadingAvatar ?? this.isUploadingAvatar,
      message: message,
    );
  }

  @override
  List<Object?> get props => [profile, status, isUploadingAvatar, message];
}
