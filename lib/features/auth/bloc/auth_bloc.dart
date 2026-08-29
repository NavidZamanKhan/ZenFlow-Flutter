import 'package:flutter_bloc/flutter_bloc.dart';

import '../repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository(),
        super(AuthInitialState()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<GoogleSignInRequestedEvent>(_onGoogleSignInRequested);
    on<LogoutRequestedEvent>(_onLogoutRequested);
    on<LoginSubmittedEvent>(_onLoginSubmitted);
    on<RegisterSubmittedEvent>(_onRegisterSubmitted);
    on<VerifyOtpSubmittedEvent>(_onVerifyOtpSubmitted);
    on<ResendOtpRequestedEvent>(_onResendOtpRequested);
    on<CancelOtpVerificationEvent>(_onCancelOtpVerification);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState(message: 'Checking session...'));
    try {
      final user = await _authRepository.checkAuthStatus();
      if (user != null) {
        emit(AuthenticatedState(user));
      } else {
        emit(UnauthenticatedState());
      }
    } catch (_) {
      emit(UnauthenticatedState());
    }
  }

  Future<void> _onGoogleSignInRequested(
    GoogleSignInRequestedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState(message: 'Connecting to Google...'));
    try {
      final user = await _authRepository.googleSignIn();
      emit(AuthenticatedState(user));
    } catch (e) {
      emit(AuthFailureState(e.toString().replaceAll('Exception: ', '')));
      emit(UnauthenticatedState());
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequestedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState(message: 'Signing out...'));
    await _authRepository.logout();
    emit(UnauthenticatedState());
  }

  Future<void> _onLoginSubmitted(
    LoginSubmittedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState(message: 'Signing in...'));
    try {
      final user = await _authRepository.login(
        email: event.email,
        password: event.password,
      );
      emit(AuthenticatedState(user));
    } catch (e) {
      emit(AuthFailureState(e.toString().replaceAll('Exception: ', '')));
      emit(UnauthenticatedState());
    }
  }

  Future<void> _onRegisterSubmitted(
    RegisterSubmittedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState(message: 'Creating account...'));
    try {
      final pending = await _authRepository.register(
        fullName: event.fullName,
        email: event.email,
        password: event.password,
        confirmPassword: event.confirmPassword,
      );
      emit(PendingOtpState(pendingRegistration: pending));
    } catch (e) {
      emit(AuthFailureState(e.toString().replaceAll('Exception: ', '')));
      emit(UnauthenticatedState());
    }
  }

  Future<void> _onVerifyOtpSubmitted(
    VerifyOtpSubmittedEvent event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;
    emit(const AuthLoadingState(message: 'Verifying code...'));
    try {
      final user = await _authRepository.verifyEmail(
        pendingRegistrationId: event.pendingRegistrationId,
        otp: event.otp,
      );
      emit(AuthenticatedState(user));
    } catch (e) {
      emit(AuthFailureState(e.toString().replaceAll('Exception: ', '')));
      if (currentState is PendingOtpState) {
        emit(currentState);
      } else {
        emit(UnauthenticatedState());
      }
    }
  }

  Future<void> _onResendOtpRequested(
    ResendOtpRequestedEvent event,
    Emitter<AuthState> emit,
  ) async {
    if (state is! PendingOtpState) return;
    final current = state as PendingOtpState;

    emit(current.copyWith(isResending: true, resendMessage: null));
    try {
      final message = await _authRepository.resendOtp(
        pendingRegistrationId: event.pendingRegistrationId,
      );
      emit(current.copyWith(isResending: false, resendMessage: message));
    } catch (e) {
      emit(AuthFailureState(e.toString().replaceAll('Exception: ', '')));
      emit(current.copyWith(isResending: false));
    }
  }

  void _onCancelOtpVerification(
    CancelOtpVerificationEvent event,
    Emitter<AuthState> emit,
  ) {
    emit(UnauthenticatedState());
  }
}
