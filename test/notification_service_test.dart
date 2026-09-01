import 'package:flutter_test/flutter_test.dart';
import 'package:zenflow_flutter/core/services/notification_service.dart';
import 'package:zenflow_flutter/features/notifications/models/notification_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NotificationService Tests', () {
    test('NotificationChannels constants are defined properly', () {
      expect(NotificationChannels.tasks, 'zenflow_tasks_channel');
      expect(NotificationChannels.calendar, 'zenflow_calendar_channel');
      expect(NotificationChannels.budget, 'zenflow_budget_channel');
      expect(NotificationChannels.digest, 'zenflow_digest_channel');
    });

    test('NotificationService singleton returns same instance', () {
      final s1 = NotificationService();
      final s2 = NotificationService();
      expect(identical(s1, s2), isTrue);
    });

    test('NotificationPreferences defaults and serialization', () {
      const prefs = NotificationPreferences();
      expect(prefs.tasksEnabled, isTrue);
      expect(prefs.calendarEnabled, isTrue);
      expect(prefs.budgetEnabled, isTrue);
      expect(prefs.digestEnabled, isTrue);
      expect(prefs.digestTime, '09:00');
      expect(prefs.hasPromptedPermission, isFalse);

      final json = prefs.toJson();
      final restored = NotificationPreferences.fromJson(json);
      expect(restored, equals(prefs));

      final modified = prefs.copyWith(
        tasksEnabled: false,
        digestTime: '08:30',
        hasPromptedPermission: true,
      );
      expect(modified.tasksEnabled, isFalse);
      expect(modified.digestTime, '08:30');
      expect(modified.hasPromptedPermission, isTrue);
    });
  });
}
