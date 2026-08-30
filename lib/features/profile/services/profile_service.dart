import 'package:dio/dio.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../models/user_profile.dart';

class ProfileService {
  final ApiClient _apiClient;

  ProfileService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<UserProfile?> getProfile() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.me);
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final fullName = data['full_name'] ?? data['fullName'] ?? 'Navid';
        final email = data['email'] ?? '';
        final username = email.contains('@') ? email.split('@').first : 'user';

        return UserProfile(
          fullName: fullName,
          username: username,
          email: email,
          country: 'Bangladesh',
          timeZone: 'Asia/Dhaka',
        );
      }
      return null;
    } on DioException {
      return null;
    }
  }

  Future<void> updateProfile({required String fullName}) async {
    try {
      await _apiClient.dio.patch(
        ApiEndpoints.me,
        data: {'full_name': fullName},
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['detail'] ?? 'Failed to update profile on server.',
      );
    }
  }
}
