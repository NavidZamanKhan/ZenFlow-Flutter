import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/notification_preferences.dart';

class NotificationPreferencesService {
  static const _key = 'zenflow_notification_preferences';
  final FlutterSecureStorage _storage;

  NotificationPreferencesService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<NotificationPreferences> getPreferences() async {
    try {
      final data = await _storage.read(key: _key);
      if (data != null && data.isNotEmpty) {
        return NotificationPreferences.fromJson(data);
      }
    } catch (_) {}
    return const NotificationPreferences();
  }

  Future<void> savePreferences(NotificationPreferences prefs) async {
    try {
      await _storage.write(key: _key, value: prefs.toJson());
    } catch (_) {}
  }
}
