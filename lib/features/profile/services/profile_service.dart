import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/currency_service.dart';
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
          hasPassword: data['hasPassword'] != false,
        );
      }
    } catch (_) {}

    String activeCurrency = localProfile?.currency ?? 'BDT';
    String fullName = localProfile?.fullName ?? 'Navid';
    String email = localProfile?.email ?? 'navid@zenflow.app';
    String username = localProfile?.username ?? 'navid';
    bool hasPassword = localProfile?.hasPassword ?? true;

    // 1. Fetch user profile from /api/me/
    try {
      final meResponse = await _apiClient.dio.get(ApiEndpoints.me);
      if (meResponse.statusCode == 200 && meResponse.data != null) {
        final data = meResponse.data as Map<String, dynamic>;
        fullName = data['full_name'] ?? data['fullName'] ?? fullName;
        email = data['email'] ?? email;
        username = email.contains('@') ? email.split('@').first : username;
        hasPassword = data['has_password'] != false;
      }
    } catch (_) {}

    // 2. Fetch cloud budget currency independently to guarantee 100% real-time sync across devices
    try {
      final budgetResponse = await _apiClient.dio.get(ApiEndpoints.budget);
      if (budgetResponse.statusCode == 200 && budgetResponse.data is Map) {
        final bData = budgetResponse.data as Map;
        final cloudCur = bData['currency']?.toString();
        if (cloudCur != null && cloudCur.isNotEmpty) {
          activeCurrency = cloudCur;
        }
      }
    } catch (_) {}

    final merged = (localProfile ??
            UserProfile(
              fullName: fullName,
              username: username,
              email: email,
            ))
        .copyWith(
      fullName: fullName,
      username: username,
      email: email,
      currency: activeCurrency,
      hasPassword: hasPassword,
    );

    await saveLocalProfile(merged);
    return merged;
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
          'hasPassword': profile.hasPassword,
        }),
      );
    } catch (_) {}
  }

  Future<void> syncConvertedBudgetToCloud({
    required String oldCurrency,
    required String newCurrency,
  }) async {
    try {
      final budgetResponse = await _apiClient.dio.get(ApiEndpoints.budget);
      if (budgetResponse.data is Map) {
        final data = Map<String, dynamic>.from(budgetResponse.data as Map);
        final rawMonthly =
            (data['monthlyTotal'] ?? data['monthly_total'] ?? 40000.0) as num;
        final rawCategoryBudgets =
            data['categoryBudgets'] ?? data['category_budgets'];
        final categoryMap = rawCategoryBudgets is Map
            ? Map<String, dynamic>.from(rawCategoryBudgets)
            : <String, dynamic>{};

        final cur = CurrencyService();
        final convertedMonthlyTotal = cur.convertAmount(
          amount: rawMonthly.toDouble(),
          toCurrency: newCurrency,
          fromCurrency: oldCurrency,
        );

        final convertedCategories = <String, double>{};
        categoryMap.forEach((k, v) {
          final amt = (v is num)
              ? v.toDouble()
              : double.tryParse(v.toString()) ?? 0.0;
          convertedCategories[k] = cur.convertAmount(
            amount: amt,
            toCurrency: newCurrency,
            fromCurrency: oldCurrency,
          );
        });

        await _apiClient.dio.put(
          ApiEndpoints.budget,
          data: {
            'monthlyTotal': convertedMonthlyTotal,
            'categoryBudgets': convertedCategories,
            'currency': newCurrency,
          },
        );
      }
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
