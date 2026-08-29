import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String? avatar;
  final bool emailVerified;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.avatar,
    this.emailVerified = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? json['name']?.toString() ?? '',
      avatar: json['avatar']?.toString(),
      emailVerified: json['email_verified'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'avatar': avatar,
      'email_verified': emailVerified,
    };
  }

  @override
  List<Object?> get props => [id, email, fullName, avatar, emailVerified];
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

    return AuthResponseModel(
      accessToken: json['access']?.toString() ?? json['access_token']?.toString() ?? '',
      refreshToken: json['refresh']?.toString() ?? json['refresh_token']?.toString() ?? '',
      user: UserModel.fromJson(userJson),
    );
  }

  @override
  List<Object?> get props => [accessToken, refreshToken, user];
}
