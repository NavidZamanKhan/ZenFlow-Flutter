import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationChannels {
  static const tasks = 'zenflow_tasks_channel';
  static const tasksName = 'Task Deadlines';
  static const tasksDesc = 'Notifications for upcoming task deadlines and action items';

  static const calendar = 'zenflow_calendar_channel';
  static const calendarName = 'Calendar Events';
  static const calendarDesc = 'Notifications for scheduled calendar events and meetings';

  static const budget = 'zenflow_budget_channel';
  static const budgetName = 'Budget & Spending Alerts';
  static const budgetDesc = 'Alerts when monthly or category spending exceeds thresholds';

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

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 1. Initialize timezone database
      tz.initializeTimeZones();

      // 2. Android settings
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // 3. iOS / macOS settings (do not auto-request on startup; allow contextual primer)
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
        print('[NotificationService] 🟢 Native Notification Engine initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[NotificationService] ❌ Initialization failed: $e');
      }
    }
  }

  /// Request permissions on-demand (e.g. after showing contextual primer)
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
        final granted =
            await androidPlugin?.requestNotificationsPermission();
        return granted ?? false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('[NotificationService] Error requesting permissions: $e');
      }
    }
    return false;
  }

  /// Check if notification permissions are currently enabled
  Future<bool> areNotificationsEnabled() async {
    try {
      if (Platform.isAndroid) {
        final androidPlugin = _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        final enabled = await androidPlugin?.areNotificationsEnabled();
        return enabled ?? false;
      } else if (Platform.isIOS) {
        // iOS requires checking settings via Darwin implementation
        return true;
      }
    } catch (_) {}
    return true;
  }

  /// Show an immediate push notification
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

  /// Schedule a notification at an exact future date & time
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    String channelId = NotificationChannels.tasks,
  }) async {
    if (scheduledDate.isBefore(DateTime.now())) {
      // Do not schedule past notifications
      return;
    }

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

  /// Cancel a specific scheduled notification by ID
  Future<void> cancel(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  /// Cancel all scheduled notifications
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
