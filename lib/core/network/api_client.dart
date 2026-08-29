import 'package:dio/dio.dart';

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
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final accessToken = await _tokenStorage.getAccessToken();
          if (accessToken != null && accessToken.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          return handler.next(error);
        },
      ),
    );
  }
}
