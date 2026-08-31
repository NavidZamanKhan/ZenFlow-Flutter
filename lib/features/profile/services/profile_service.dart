import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../models/user_profile.dart';

class ProfileService {
  static const String _prefsStorageKey = 'zenflow_user_profile_prefs';
  final ApiClient _apiClient;
  final FlutterSecureStorage _storage;

  ProfileService({ApiClient? apiClient, FlutterSecureStorage? storage})
      : _apiClient = apiClient ?? ApiClient(),
        _storage = storage ?? const FlutterSecureStorage();

  Future<UserProfile?> getProfile() async {
    UserProfile? localProfile;

    try {
      final cachedRaw = await _storage.read(key: _prefsStorageKey);
      if (cachedRaw != null && cachedRaw.isNotEmpty) {
        final data = jsonDecode(cachedRaw) as Map<String, dynamic>;
        localProfile = UserProfile(
          fullName: data['fullName'] ?? 'Navid Zaman Khan',
          username: data['username'] ?? 'navid',
          email: data['email'] ?? 'navid@zenflow.app',
          phone: data['phone'] ?? '',
          country: data['country'] ?? 'Bangladesh',
          timeZone: data['timeZone'] ?? 'Asia/Dhaka',
          currency: data['currency'] ?? 'BDT',
          dateFormat: data['dateFormat'] ?? 'MM/DD/YYYY',
          numberFormat: data['numberFormat'] ?? '1,234.56',
          firstDayOfWeek: data['firstDayOfWeek'] ?? 'Sunday',
          defaultPaymentMethod: data['defaultPaymentMethod'] ?? 'Card',
          defaultExpenseCategory: data['defaultExpenseCategory'] ?? 'Food',
          is24HourTime: data['is24HourTime'] ?? false,
          displayDensity: data['displayDensity'] ?? 'Comfortable',
        );
      }
    } catch (_) {}

    try {
      final response = await _apiClient.dio.get(ApiEndpoints.me);
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final fullName = data['full_name'] ?? data['fullName'] ?? 'Navid';
        final email = data['email'] ?? '';
        final username = email.contains('@') ? email.split('@').first : 'user';

        final merged = (localProfile ?? UserProfile(
          fullName: fullName,
          username: username,
          email: email,
        )).copyWith(
          fullName: fullName,
          username: username,
          email: email,
        );

        await saveLocalProfile(merged);
        return merged;
      }
    } on DioException {
      // Return cached local profile if server unavailable
    }

    return localProfile;
  }

  Future<void> saveLocalProfile(UserProfile profile) async {
    try {
      await _storage.write(
        key: _prefsStorageKey,
        value: jsonEncode({
          'fullName': profile.fullName,
          'username': profile.username,
          'email': profile.email,
          'phone': profile.phone,
          'country': profile.country,
          'timeZone': profile.timeZone,
          'currency': profile.currency,
          'dateFormat': profile.dateFormat,
          'numberFormat': profile.numberFormat,
          'firstDayOfWeek': profile.firstDayOfWeek,
          'defaultPaymentMethod': profile.defaultPaymentMethod,
          'defaultExpenseCategory': profile.defaultExpenseCategory,
          'is24HourTime': profile.is24HourTime,
          'displayDensity': profile.displayDensity,
        }),
      );
    } catch (_) {}
  }

  Future<void> updateProfile({required UserProfile profile}) async {
    await saveLocalProfile(profile);

    try {
      await _apiClient.dio.patch(
        ApiEndpoints.me,
        data: {
          'full_name': profile.fullName,
        },
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['detail'] ?? 'Failed to update profile on server.',
      );
    }
  }
}
