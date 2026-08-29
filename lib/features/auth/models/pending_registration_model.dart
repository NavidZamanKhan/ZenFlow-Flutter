import 'package:equatable/equatable.dart';

class PendingRegistrationModel extends Equatable {
  final String pendingRegistrationId;
  final String email;
  final String fullName;
  final String message;

  const PendingRegistrationModel({
    required this.pendingRegistrationId,
    required this.email,
    required this.fullName,
    required this.message,
  });

  factory PendingRegistrationModel.fromJson({
    required Map<String, dynamic> json,
    required String email,
    required String fullName,
  }) {
    return PendingRegistrationModel(
      pendingRegistrationId: json['pending_registration_id']?.toString() ?? '',
      email: email,
      fullName: fullName,
      message: json['message']?.toString() ?? 'Verification code sent.',
    );
  }

  @override
  List<Object?> get props => [pendingRegistrationId, email, fullName, message];
}
