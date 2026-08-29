import 'package:dio/dio.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/google_auth_service.dart';
import '../../../core/storage/token_storage_service.dart';
import '../models/pending_registration_model.dart';
import '../models/user_model.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final GoogleAuthService _googleAuthService;
  final TokenStorageService _tokenStorage;

  AuthRepository({
    ApiClient? apiClient,
    GoogleAuthService? googleAuthService,
    TokenStorageService? tokenStorage,
  })  : _apiClient = apiClient ?? ApiClient(),
        _googleAuthService = googleAuthService ?? GoogleAuthService(),
        _tokenStorage = tokenStorage ?? TokenStorageService();

  /// Step 1 of Registration: Sends registration details and returns PendingRegistrationModel
  Future<PendingRegistrationModel> register({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.register,
        data: {
          'full_name': fullName.trim(),
          'email': email.trim().toLowerCase(),
          'password': password,
          'confirm_password': confirmPassword,
        },
      );

      final pending = PendingRegistrationModel.fromJson(
        json: response.data,
        email: email.trim().toLowerCase(),
        fullName: fullName.trim(),
      );

      if (pending.pendingRegistrationId.isEmpty) {
        throw Exception('An account with this email already exists. Please log in.');
      }

      return pending;
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Registration failed. Please check your inputs.'));
    }
  }

  /// Step 2 of Registration: Verifies 6-digit email OTP and issues JWT tokens
  Future<UserModel> verifyEmail({
    required String pendingRegistrationId,
    required String otp,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.verifyEmail,
        data: {
          'pending_registration_id': pendingRegistrationId,
          'otp': otp.trim(),
        },
      );

      final authResponse = AuthResponseModel.fromJson(response.data);

      await _tokenStorage.saveTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
      );

      return authResponse.user;
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Invalid or expired verification code.'));
    }
  }

  /// Resends a new 6-digit OTP code to the user's email
  Future<String> resendOtp({
    required String pendingRegistrationId,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.resendOtp,
        data: {
          'pending_registration_id': pendingRegistrationId,
        },
      );

      return response.data?['message']?.toString() ?? 'A new verification code has been sent.';
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Failed to resend code. Please try again later.'));
    }
  }

  /// Authenticates user with email and password
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.login,
        data: {
          'email': email.trim().toLowerCase(),
          'password': password,
        },
      );

      final authResponse = AuthResponseModel.fromJson(response.data);

      await _tokenStorage.saveTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
      );

      return authResponse.user;
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Invalid email or password.'));
    }
  }

  /// Authenticates using Google OAuth and exchanges token with Django backend
  Future<UserModel> googleSignIn() async {
    final googleResult = await _googleAuthService.signIn();
    if (googleResult == null) {
      throw Exception('Google sign-in was cancelled.');
    }

    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.googleAuth,
        data: {
          if (googleResult.idToken != null) 'id_token': googleResult.idToken,
          if (googleResult.accessToken != null) 'access_token': googleResult.accessToken,
        },
      );

      final authResponse = AuthResponseModel.fromJson(response.data);

      await _tokenStorage.saveTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
      );

      return authResponse.user;
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Failed to authenticate with Google on server.'));
    }
  }

  /// Logs out the user, invalidating tokens and clearing storage
  Future<void> logout() async {
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await _apiClient.dio.post(
          ApiEndpoints.logout,
          data: {'refresh': refreshToken},
        );
      }
    } catch (_) {
      // Ignore network errors on logout
    } finally {
      await _googleAuthService.signOut();
      await _tokenStorage.clearTokens();
    }
  }

  /// Fetches current user profile using the stored access token
  Future<UserModel> getProfile() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.me);
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Failed to fetch user profile.'));
    }
  }

  /// Checks if valid session exists on app startup
  Future<UserModel?> checkAuthStatus() async {
    final hasTokens = await _tokenStorage.hasTokens();
    if (!hasTokens) return null;

    try {
      return await getProfile();
    } catch (_) {
      await _tokenStorage.clearTokens();
      return null;
    }
  }

  /// Helper to extract clean user-friendly error messages from Django responses
  String _extractErrorMessage(DioException e, String defaultMessage) {
    if (e.response?.data != null) {
      final data = e.response!.data;
      if (data is Map) {
        if (data.containsKey('errors')) {
          final errors = data['errors'];
          if (errors is List && errors.isNotEmpty) {
            return errors.join('\n');
          }
          return errors.toString();
        }
        if (data.containsKey('detail')) {
          return data['detail'].toString();
        }
        if (data.containsKey('message')) {
          return data['message'].toString();
        }
        // Extract validation errors from field maps: e.g. {"password": ["..."]}
        final fieldErrors = <String>[];
        data.forEach((key, value) {
          if (value is List) {
            fieldErrors.add('${key.replaceAll('_', ' ')}: ${value.join(', ')}');
          } else if (value is String) {
            fieldErrors.add(value);
          }
        });
        if (fieldErrors.isNotEmpty) {
          return fieldErrors.join('\n');
        }
      }
    }
    return e.message ?? defaultMessage;
  }
}
