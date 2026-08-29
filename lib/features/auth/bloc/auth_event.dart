import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthStatusEvent extends AuthEvent {}

class GoogleSignInRequestedEvent extends AuthEvent {}

class LogoutRequestedEvent extends AuthEvent {}

class LoginSubmittedEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginSubmittedEvent({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class RegisterSubmittedEvent extends AuthEvent {
  final String fullName;
  final String email;
  final String password;
  final String confirmPassword;

  const RegisterSubmittedEvent({
    required this.fullName,
    required this.email,
    required this.password,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [fullName, email, password, confirmPassword];
}

class VerifyOtpSubmittedEvent extends AuthEvent {
  final String pendingRegistrationId;
  final String otp;

  const VerifyOtpSubmittedEvent({
    required this.pendingRegistrationId,
    required this.otp,
  });

  @override
  List<Object?> get props => [pendingRegistrationId, otp];
}

class ResendOtpRequestedEvent extends AuthEvent {
  final String pendingRegistrationId;

  const ResendOtpRequestedEvent({
    required this.pendingRegistrationId,
  });

  @override
  List<Object?> get props => [pendingRegistrationId];
}

class CancelOtpVerificationEvent extends AuthEvent {}
