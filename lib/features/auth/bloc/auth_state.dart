import 'package:equatable/equatable.dart';
import '../models/pending_registration_model.dart';
import '../models/user_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitialState extends AuthState {}

class AuthLoadingState extends AuthState {
  final String? message;

  const AuthLoadingState({this.message});

  @override
  List<Object?> get props => [message];
}

class AuthenticatedState extends AuthState {
  final UserModel user;

  const AuthenticatedState(this.user);

  @override
  List<Object?> get props => [user];
}

class PendingOtpState extends AuthState {
  final PendingRegistrationModel pendingRegistration;
  final bool isResending;
  final String? resendMessage;

  const PendingOtpState({
    required this.pendingRegistration,
    this.isResending = false,
    this.resendMessage,
  });

  PendingOtpState copyWith({
    PendingRegistrationModel? pendingRegistration,
    bool? isResending,
    String? resendMessage,
  }) {
    return PendingOtpState(
      pendingRegistration: pendingRegistration ?? this.pendingRegistration,
      isResending: isResending ?? this.isResending,
      resendMessage: resendMessage,
    );
  }

  @override
  List<Object?> get props => [pendingRegistration, isResending, resendMessage];
}

class UnauthenticatedState extends AuthState {}

class AuthFailureState extends AuthState {
  final String errorMessage;

  const AuthFailureState(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
