import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String fullName;
  final String username;
  final String email;
  final String phone;
  final String country;
  final String timeZone;
  final String currency;
  final String dateFormat;
  final String numberFormat;
  final String firstDayOfWeek;
  final String defaultPaymentMethod;
  final String defaultExpenseCategory;
  final String displayDensity;
  final bool is24HourTime;
  final bool hasPassword;

  const UserProfile({
    required this.fullName,
    required this.username,
    required this.email,
    this.phone = '',
    this.country = 'Bangladesh',
    this.timeZone = 'Asia/Dhaka',
    this.currency = 'BDT',
    this.dateFormat = 'MM/DD/YYYY',
    this.numberFormat = '1,234.56',
    this.firstDayOfWeek = 'Sunday',
    this.defaultPaymentMethod = 'Card',
    this.defaultExpenseCategory = 'Food',
    this.displayDensity = 'comfortable',
    this.is24HourTime = false,
    this.hasPassword = true,
  });

  String get initials {
    if (fullName.trim().isEmpty) return 'N';
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
    String? dateFormat,
    String? numberFormat,
    String? firstDayOfWeek,
    String? defaultPaymentMethod,
    String? defaultExpenseCategory,
    String? displayDensity,
    bool? is24HourTime,
    bool? hasPassword,
  }) {
    return UserProfile(
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      country: country ?? this.country,
      timeZone: timeZone ?? this.timeZone,
      currency: currency ?? this.currency,
      dateFormat: dateFormat ?? this.dateFormat,
      numberFormat: numberFormat ?? this.numberFormat,
      firstDayOfWeek: firstDayOfWeek ?? this.firstDayOfWeek,
      defaultPaymentMethod: defaultPaymentMethod ?? this.defaultPaymentMethod,
      defaultExpenseCategory:
          defaultExpenseCategory ?? this.defaultExpenseCategory,
      displayDensity: displayDensity ?? this.displayDensity,
      is24HourTime: is24HourTime ?? this.is24HourTime,
      hasPassword: hasPassword ?? this.hasPassword,
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
        dateFormat,
        numberFormat,
        firstDayOfWeek,
        defaultPaymentMethod,
        defaultExpenseCategory,
        displayDensity,
        is24HourTime,
        hasPassword,
      ];
}
