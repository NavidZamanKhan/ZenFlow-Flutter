import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../constants/api_endpoints.dart';
import '../storage/token_storage_service.dart';

class ApiClient {
  late final Dio dio;
  final TokenStorageService _tokenStorage;

  ApiClient({TokenStorageService? tokenStorage})
      : _tokenStorage = tokenStorage ?? TokenStorageService() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
          final accessToken = await _tokenStorage.getAccessToken();
          if (accessToken != null && accessToken.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
          if (kDebugMode) {
            debugPrint('[ApiClient] 🚀 ${options.method} ${options.path}');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            debugPrint(
              '[ApiClient] 🟢 [${response.statusCode}] ${response.requestOptions.path}',
            );
          }
          return handler.next(response);
        },
        onError: (DioException error, handler) async {
          final statusCode = error.response?.statusCode;
          final isAuthError = statusCode == 401;
          final isRefreshRequest =
              error.requestOptions.path == ApiEndpoints.refresh;

          // Transparent Token Refresh on 401
          if (isAuthError && !isRefreshRequest) {
            final refreshToken = await _tokenStorage.getRefreshToken();
            if (refreshToken != null && refreshToken.isNotEmpty) {
              try {
                if (kDebugMode) {
                  debugPrint(
                    '[ApiClient] 🔄 Access token expired. Refreshing token...',
                  );
                }

                // Make unintercepted call to refresh token
                final refreshDio = Dio(
                  BaseOptions(
                    baseUrl: ApiEndpoints.baseUrl,
                    headers: {'Content-Type': 'application/json'},
                  ),
                );
                final refreshResponse = await refreshDio.post(
                  ApiEndpoints.refresh,
                  data: {'refresh': refreshToken},
                );

                if (refreshResponse.statusCode == 200 &&
                    refreshResponse.data is Map) {
                  final newAccess =
                      refreshResponse.data['access']?.toString();
                  final newRefresh =
                      refreshResponse.data['refresh']?.toString() ??
                          refreshToken;

                  if (newAccess != null && newAccess.isNotEmpty) {
                    await _tokenStorage.saveTokens(
                      accessToken: newAccess,
                      refreshToken: newRefresh,
                    );

                    // Retry original request with new access token
                    final originalOptions = error.requestOptions;
                    originalOptions.headers['Authorization'] =
                        'Bearer $newAccess';

                    final clonedResponse = await dio.fetch(originalOptions);
                    return handler.resolve(clonedResponse);
                  }
                }
              } catch (refreshErr) {
                if (kDebugMode) {
                  debugPrint('[ApiClient] ❌ Token refresh failed: $refreshErr');
                }
                await _tokenStorage.clearTokens();
              }
            }
          }

          if (kDebugMode) {
            debugPrint(
              '[ApiClient] ⚠️ Error [${error.response?.statusCode}]: ${error.requestOptions.path}',
            );
          }
          return handler.next(error);
        },
      ),
    );
  }
}
