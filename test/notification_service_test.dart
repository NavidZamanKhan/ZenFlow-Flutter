import 'package:flutter_test/flutter_test.dart';
import 'package:zenflow_flutter/core/services/notification_service.dart';

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
  });
}
