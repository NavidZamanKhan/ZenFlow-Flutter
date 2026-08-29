import 'package:dio/dio.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/google_auth_service.dart';
import '../../../core/storage/token_storage_service.dart';
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

      // Save JWT tokens to encrypted secure storage
      await _tokenStorage.saveTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
      );

      return authResponse.user;
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['errors']?.toString() ??
          e.response?.data?['detail']?.toString() ??
          e.message ??
          'Failed to authenticate with Google on server.';
      throw Exception(errorMsg);
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
      final errorMsg = e.response?.data?['detail']?.toString() ??
          e.message ??
          'Failed to fetch user profile.';
      throw Exception(errorMsg);
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
}
