import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String fullName;
  final String username;
  final String email;
  final String phone;
  final String country;
  final String timeZone;
  final String currency;
  final String displayDensity;
  final bool is24HourTime;

  const UserProfile({
    required this.fullName,
    required this.username,
    required this.email,
    this.phone = '',
    this.country = 'Bangladesh',
    this.timeZone = 'Asia/Dhaka',
    this.currency = 'BDT',
    this.displayDensity = 'comfortable',
    this.is24HourTime = false,
  });

  String get initials {
    if (fullName.trim().isEmpty) return 'U';
    final parts = fullName.trim().split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return fullName.substring(0, 1).toUpperCase();
  }

  UserProfile copyWith({
    String? fullName,
    String? username,
    String? email,
    String? phone,
    String? country,
    String? timeZone,
    String? currency,
    String? displayDensity,
    bool? is24HourTime,
  }) {
    return UserProfile(
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      country: country ?? this.country,
      timeZone: timeZone ?? this.timeZone,
      currency: currency ?? this.currency,
      displayDensity: displayDensity ?? this.displayDensity,
      is24HourTime: is24HourTime ?? this.is24HourTime,
    );
  }

  @override
  List<Object?> get props => [
        fullName,
        username,
        email,
        phone,
        country,
        timeZone,
        currency,
        displayDensity,
        is24HourTime,
      ];
}
