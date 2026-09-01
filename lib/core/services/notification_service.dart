import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../features/calendar/models/calendar_item.dart';
import '../../features/notifications/services/notification_preferences_service.dart';
import '../../features/tasks/models/task_item.dart';

class NotificationChannels {
  static const tasks = 'zenflow_tasks_channel';
  static const tasksName = 'Task Deadlines';
  static const tasksDesc =
      'Notifications for upcoming task deadlines and action items';

  static const calendar = 'zenflow_calendar_channel';
  static const calendarName = 'Calendar Events';
  static const calendarDesc =
      'Notifications for scheduled calendar events and meetings';

  static const budget = 'zenflow_budget_channel';
  static const budgetName = 'Budget & Spending Alerts';
  static const budgetDesc =
      'Alerts when monthly or category spending exceeds thresholds';

  static const digest = 'zenflow_digest_channel';
  static const digestName = 'Daily Morning Digest';
  static const digestDesc = 'Daily summary of your focus tasks and agenda';
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final StreamController<String?> _payloadStreamController =
      StreamController<String?>.broadcast();

  Stream<String?> get onNotificationTap => _payloadStreamController.stream;

  final NotificationPreferencesService _prefsService =
      NotificationPreferencesService();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  int _stableId(String prefix, String id) {
    return '$prefix-$id'.hashCode.abs() % 100000000;
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 1. Initialize timezone database
      tz.initializeTimeZones();

      // 2. Android settings
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // 3. iOS / macOS settings
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      );

      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          if (response.payload != null && response.payload!.isNotEmpty) {
            _payloadStreamController.add(response.payload);
          }
        },
      );

      // 4. Create Android Notification Channels
      if (Platform.isAndroid) {
        final androidPlugin = _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

        if (androidPlugin != null) {
          await androidPlugin.createNotificationChannel(
            const AndroidNotificationChannel(
              NotificationChannels.tasks,
              NotificationChannels.tasksName,
              description: NotificationChannels.tasksDesc,
              importance: Importance.max,
              enableVibration: true,
              playSound: true,
            ),
          );

          await androidPlugin.createNotificationChannel(
            const AndroidNotificationChannel(
              NotificationChannels.calendar,
              NotificationChannels.calendarName,
              description: NotificationChannels.calendarDesc,
              importance: Importance.max,
              enableVibration: true,
              playSound: true,
            ),
          );

          await androidPlugin.createNotificationChannel(
            const AndroidNotificationChannel(
              NotificationChannels.budget,
              NotificationChannels.budgetName,
              description: NotificationChannels.budgetDesc,
              importance: Importance.high,
              enableVibration: true,
              playSound: true,
            ),
          );

          await androidPlugin.createNotificationChannel(
            const AndroidNotificationChannel(
              NotificationChannels.digest,
              NotificationChannels.digestName,
              description: NotificationChannels.digestDesc,
              importance: Importance.defaultImportance,
              enableVibration: false,
              playSound: true,
            ),
          );
        }
      }

      _isInitialized = true;
      if (kDebugMode) {
        print('[NotificationService] 🟢 Native Notification Engine initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[NotificationService] ❌ Initialization failed: $e');
      }
    }
  }

  Future<bool> requestPermissions() async {
    try {
      if (Platform.isIOS || Platform.isMacOS) {
        final iosPlugin = _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();
        final granted = await iosPlugin?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      } else if (Platform.isAndroid) {
        final androidPlugin = _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        final granted = await androidPlugin?.requestNotificationsPermission();
        return granted ?? false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('[NotificationService] Error requesting permissions: $e');
      }
    }
    return false;
  }

  // ==========================================
  // 🎯 Task Scheduling (15m before due time)
  // ==========================================
  Future<void> scheduleTaskReminder(TaskItem task) async {
    final prefs = await _prefsService.getPreferences();
    if (!prefs.tasksEnabled || task.isCompleted) {
      await cancelTaskReminder(task.id);
      return;
    }

    final targetDateTime = _computeTaskTargetDateTime(task);
    if (targetDateTime == null) return;

    // Alert 15 minutes before
    final alertTime = targetDateTime.subtract(const Duration(minutes: 15));
    if (alertTime.isBefore(DateTime.now())) {
      // Alert time has passed, cancel any old ones
      await cancelTaskReminder(task.id);
      return;
    }

    final id = _stableId('task', task.id);
    await scheduleNotification(
      id: id,
      title: 'Task Reminder (in 15m) ⏰',
      body: task.title,
      scheduledDate: alertTime,
      channelId: NotificationChannels.tasks,
      payload: 'task:${task.id}',
    );

    if (kDebugMode) {
      print('[NotificationService] 📅 Scheduled 15m alert for Task "${task.title}" at $alertTime');
    }
  }

  Future<void> cancelTaskReminder(String taskId) async {
    final id = _stableId('task', taskId);
    await cancel(id);
  }

  DateTime? _computeTaskTargetDateTime(TaskItem task) {
    if (task.dueDate == null) return null;
    int hour = 9;
    int minute = 0;
    if (task.dueTime != null && task.dueTime!.trim().isNotEmpty) {
      final trimmed = task.dueTime!.trim();
      final isPm = trimmed.toLowerCase().contains('pm');
      final isAm = trimmed.toLowerCase().contains('am');
      final cleaned = trimmed.replaceAll(RegExp(r'[a-zA-Z\s]'), '');
      final parts = cleaned.split(':');
      if (parts.isNotEmpty) {
        var h = int.tryParse(parts[0]) ?? 9;
        final m = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
        if (isPm && h < 12) h += 12;
        if (isAm && h == 12) h = 0;
        hour = h;
        minute = m;
      }
    }
    return DateTime(
      task.dueDate!.year,
      task.dueDate!.month,
      task.dueDate!.day,
      hour,
      minute,
    );
  }

  // ==========================================
  // 📅 Calendar Scheduling (15m before event)
  // ==========================================
  Future<void> scheduleEventReminder(CalendarItem event) async {
    final prefs = await _prefsService.getPreferences();
    if (!prefs.calendarEnabled || event.isCompleted) {
      await cancelEventReminder(event.id);
      return;
    }

    // Alert 15 minutes before start
    final alertTime =
        event.startDateTime.subtract(const Duration(minutes: 15));
    if (alertTime.isBefore(DateTime.now())) {
      await cancelEventReminder(event.id);
      return;
    }

    final id = _stableId('event', event.id);
    await scheduleNotification(
      id: id,
      title: 'Upcoming Event (in 15m) 📅',
      body: event.title,
      scheduledDate: alertTime,
      channelId: NotificationChannels.calendar,
      payload: 'event:${event.id}',
    );

    if (kDebugMode) {
      print('[NotificationService] 📅 Scheduled 15m alert for Event "${event.title}" at $alertTime');
    }
  }

  Future<void> cancelEventReminder(String eventId) async {
    final id = _stableId('event', eventId);
    await cancel(id);
  }

  // ==========================================
  // 💸 Budget Warning Alert
  // ==========================================
  Future<void> showBudgetWarning({
    required String title,
    required String message,
    required String category,
  }) async {
    final prefs = await _prefsService.getPreferences();
    if (!prefs.budgetEnabled) return;

    final id = _stableId('budget', category);
    await showInstantNotification(
      id: id,
      title: title,
      body: message,
      channelId: NotificationChannels.budget,
      payload: 'budget:$category',
    );
  }

  // ==========================================
  // 🌅 Daily Morning Digest Scheduling
  // ==========================================
  Future<void> scheduleDailyMorningDigest({
    required List<TaskItem> todayTasks,
    required List<CalendarItem> todayEvents,
  }) async {
    final prefs = await _prefsService.getPreferences();
    if (!prefs.digestEnabled) {
      await cancel(8888);
      return;
    }

    final parts = prefs.digestTime.split(':');
    final hour = int.tryParse(parts.firstOrNull ?? '9') ?? 9;
    final minute = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;

    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final pendingTasks = todayTasks.where((t) => !t.isCompleted).length;
    final eventCount = todayEvents.length;

    String body;
    if (pendingTasks == 0 && eventCount == 0) {
      body = 'Your schedule is clear today. Enjoy your flow!';
    } else {
      final taskPart = pendingTasks > 0
          ? '$pendingTasks ${pendingTasks == 1 ? 'task' : 'tasks'}'
          : '';
      final eventPart = eventCount > 0
          ? '$eventCount ${eventCount == 1 ? 'event' : 'events'}'
          : '';
      final joined = [taskPart, eventPart].where((s) => s.isNotEmpty).join(' & ');
      body = 'You have $joined scheduled for today.';
    }

    await scheduleNotification(
      id: 8888,
      title: 'ZenFlow Morning Digest ☀️',
      body: body,
      scheduledDate: scheduledDate,
      channelId: NotificationChannels.digest,
      payload: 'digest:today',
    );

    if (kDebugMode) {
      print('[NotificationService] 🌅 Scheduled Daily Digest for $scheduledDate ($body)');
    }
  }

  // ==========================================
  // Generic Helpers
  // ==========================================
  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String channelId = NotificationChannels.tasks,
  }) async {
    final details = _notificationDetailsFor(channelId);
    await _notificationsPlugin.show(
      id,
      title,
      body,
      details,
      payload: payload,
    );
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    String channelId = NotificationChannels.tasks,
  }) async {
    if (scheduledDate.isBefore(DateTime.now())) return;

    final details = _notificationDetailsFor(channelId);
    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tzScheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  Future<void> cancel(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }

  NotificationDetails _notificationDetailsFor(String channelId) {
    String channelName;
    String channelDesc;
    Importance importance;
    Priority priority;

    switch (channelId) {
      case NotificationChannels.calendar:
        channelName = NotificationChannels.calendarName;
        channelDesc = NotificationChannels.calendarDesc;
        importance = Importance.max;
        priority = Priority.high;
        break;
      case NotificationChannels.budget:
        channelName = NotificationChannels.budgetName;
        channelDesc = NotificationChannels.budgetDesc;
        importance = Importance.high;
        priority = Priority.high;
        break;
      case NotificationChannels.digest:
        channelName = NotificationChannels.digestName;
        channelDesc = NotificationChannels.digestDesc;
        importance = Importance.defaultImportance;
        priority = Priority.defaultPriority;
        break;
      case NotificationChannels.tasks:
      default:
        channelName = NotificationChannels.tasksName;
        channelDesc = NotificationChannels.tasksDesc;
        importance = Importance.max;
        priority = Priority.high;
        break;
    }

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDesc,
      importance: importance,
      priority: priority,
      playSound: true,
      enableVibration: true,
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    return NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );
  }
}
