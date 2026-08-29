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
}
