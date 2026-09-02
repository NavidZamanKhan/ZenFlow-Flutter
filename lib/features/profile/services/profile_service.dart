import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/currency_service.dart';
import '../../auth/models/user_model.dart';
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
          avatarUrl: UserModel.resolveAvatarUrl(data['avatarUrl']?.toString()),
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
    String? avatarUrl = localProfile?.avatarUrl;
    bool hasPassword = localProfile?.hasPassword ?? true;

    // 1. Fetch user profile from /api/auth/me/
    try {
      final meResponse = await _apiClient.dio.get(ApiEndpoints.me);
      if (meResponse.statusCode == 200 && meResponse.data != null) {
        final data = meResponse.data as Map<String, dynamic>;
        fullName = data['full_name'] ?? data['fullName'] ?? fullName;
        email = data['email'] ?? email;
        username = email.contains('@') ? email.split('@').first : username;
        hasPassword = data['has_password'] != false;
        final rawAvatar = data['avatar_url'] ?? data['avatar'] ?? data['avatarUrl'];
        if (rawAvatar != null) {
          avatarUrl = UserModel.resolveAvatarUrl(rawAvatar.toString());
        }
      }
    } catch (_) {}

    // 2. Fetch cloud budget currency independently when initializing
    try {
      final budgetResponse = await _apiClient.dio.get(ApiEndpoints.budget);
      if (budgetResponse.statusCode == 200 && budgetResponse.data is Map) {
        final bData = budgetResponse.data as Map;
        final cloudCur = bData['currency']?.toString();
        if (cloudCur != null && cloudCur.isNotEmpty && localProfile == null) {
          activeCurrency = cloudCur;
        }
      }
    } catch (_) {}

    final merged = (localProfile ??
            UserProfile(
              fullName: fullName,
              username: username,
              email: email,
              avatarUrl: avatarUrl,
            ))
        .copyWith(
      fullName: fullName,
      username: username,
      email: email,
      avatarUrl: avatarUrl,
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
          'avatarUrl': profile.avatarUrl,
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

  static const _validCategories = [
    'Food',
    'Bills',
    'Shopping',
    'Subscription',
    'Education',
    'Transportation',
    'Healthcare',
    'Entertainment',
    'Travel',
    'Others',
  ];

  static String _normalizeCategory(String raw) {
    final lower = raw.trim().toLowerCase();
    for (final cat in _validCategories) {
      if (cat.toLowerCase() == lower) return cat;
    }
    return 'Others';
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

        final serverCurrency =
            data['currency']?.toString() ?? oldCurrency;

        final cur = CurrencyService();
        final convertedMonthlyTotal = cur.convertAmount(
          amount: rawMonthly.toDouble(),
          toCurrency: newCurrency,
          fromCurrency: serverCurrency,
        );

        final convertedCategories = <String, double>{};
        categoryMap.forEach((k, v) {
          final normalizedCat = _normalizeCategory(k);
          final amt = (v is num)
              ? v.toDouble()
              : double.tryParse(v.toString()) ?? 0.0;
          convertedCategories[normalizedCat] = cur.convertAmount(
            amount: amt,
            toCurrency: newCurrency,
            fromCurrency: serverCurrency,
          );
        });

        final response = await _apiClient.dio.put(
          ApiEndpoints.budget,
          data: {
            'monthlyTotal': convertedMonthlyTotal,
            'categoryBudgets': convertedCategories,
            'currency': newCurrency,
          },
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          final local = await getProfile();
          if (local != null) {
            await saveLocalProfile(local.copyWith(currency: newCurrency));
          }
        }
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

  /// Uploads a new profile image to the backend via multipart/form-data
  Future<UserProfile> uploadAvatar({required String imagePath}) async {
    final fileName = imagePath.split('/').last;
    final formData = FormData.fromMap({
      'avatar': await MultipartFile.fromFile(
        imagePath,
        filename: fileName,
      ),
    });

    try {
      final response = await _apiClient.dio.patch(
        ApiEndpoints.me,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final rawAvatar = data['avatar_url'] ?? data['avatar'] ?? data['avatarUrl'];
        final resolvedAvatarUrl = UserModel.resolveAvatarUrl(rawAvatar?.toString());

        final current = (await getProfile()) ??
            UserProfile(
              fullName: data['full_name'] ?? 'Navid',
              username: 'navid',
              email: data['email'] ?? '',
            );

        final updated = current.copyWith(avatarUrl: resolvedAvatarUrl);
        await saveLocalProfile(updated);
        return updated;
      } else {
        throw Exception('Failed to upload profile photo.');
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['avatar']?.toString() ??
          e.response?.data?['detail']?.toString() ??
          'Failed to upload profile photo.';
      throw Exception(msg);
    }
  }

  /// Removes the user's avatar on the backend
  Future<UserProfile> deleteAvatar() async {
    try {
      final response = await _apiClient.dio.patch(
        ApiEndpoints.me,
        data: {
          'avatar': null,
        },
      );

      if (response.statusCode == 200) {
        final current = (await getProfile()) ??
            const UserProfile(
              fullName: 'Navid',
              username: 'navid',
              email: '',
            );

        final updated = current.copyWith(clearAvatar: true);
        await saveLocalProfile(updated);
        return updated;
      } else {
        throw Exception('Failed to remove profile photo.');
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['detail'] ?? 'Failed to remove profile photo.',
      );
    }
  }
}
