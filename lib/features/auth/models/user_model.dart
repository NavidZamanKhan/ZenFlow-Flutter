import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String? avatar;
  final bool emailVerified;
  final bool hasPassword;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.avatar,
    this.emailVerified = false,
    this.hasPassword = true,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? json['name']?.toString() ?? '',
      avatar: json['avatar']?.toString(),
      emailVerified: json['email_verified'] == true,
      hasPassword: json['has_password'] != false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'avatar': avatar,
      'email_verified': emailVerified,
      'has_password': hasPassword,
    };
  }

  @override
  List<Object?> get props => [id, email, fullName, avatar, emailVerified, hasPassword];
}

class AuthResponseModel extends Equatable {
  final String accessToken;
  final String refreshToken;
  final UserModel user;

  const AuthResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] is Map<String, dynamic>
        ? json['user'] as Map<String, dynamic>
        : json;

    final tokensJson = json['tokens'] is Map<String, dynamic>
        ? json['tokens'] as Map<String, dynamic>
        : json;

    final access = tokensJson['access']?.toString() ??
        tokensJson['access_token']?.toString() ??
        json['access']?.toString() ??
        json['access_token']?.toString() ??
        '';

    final refresh = tokensJson['refresh']?.toString() ??
        tokensJson['refresh_token']?.toString() ??
        json['refresh']?.toString() ??
        json['refresh_token']?.toString() ??
        '';

    return AuthResponseModel(
      accessToken: access,
      refreshToken: refresh,
      user: UserModel.fromJson(userJson),
    );
  }

  @override
  List<Object?> get props => [accessToken, refreshToken, user];
}
