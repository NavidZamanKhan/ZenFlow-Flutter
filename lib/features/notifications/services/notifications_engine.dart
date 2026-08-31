import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

import '../../dashboard/models/dashboard_budget.dart';
import '../../dashboard/models/dashboard_event.dart';
import '../../dashboard/models/dashboard_expense.dart';
import '../../dashboard/models/focus_task.dart';
import '../models/app_notification.dart';

class NotificationsEngine {
  static const String _readStorageKey = 'zenflow_read_notifications';
  final FlutterSecureStorage _storage;
  final Set<String> _readIds = {};
  bool _isHydrated = false;

  NotificationsEngine({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<void> _hydrate() async {
    if (_isHydrated) return;
    try {
      final raw = await _storage.read(key: _readStorageKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          _readIds.addAll(decoded.map((e) => e.toString()));
        }
      }
    } catch (_) {
      // Fallback in-memory
    }
    _isHydrated = true;
  }

  Future<void> markAsRead(String id) async {
    await _hydrate();
    _readIds.add(id);
    await _persist();
  }

  Future<void> markAllAsRead(List<AppNotification> notifications) async {
    await _hydrate();
    for (final n in notifications) {
      _readIds.add(n.id);
    }
    await _persist();
  }

  Future<void> _persist() async {
    try {
      await _storage.write(
        key: _readStorageKey,
        value: jsonEncode(_readIds.toList()),
      );
    } catch (_) {}
  }

  Future<List<AppNotification>> derive({
    required List<FocusTask> tasks,
    required List<DashboardEventItem> events,
    required List<DashboardExpense> expenses,
    required DashboardBudget budget,
  }) async {
    await _hydrate();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final currentMonthStr = DateFormat('yyyy-MM').format(now);

    final list = <AppNotification>[];

    // 1. Task Notifications
    for (final task in tasks) {
      if (task.isComplete) continue;
      if (task.dueDate == null) continue;

      final taskDate = DateTime(
        task.dueDate!.year,
        task.dueDate!.month,
        task.dueDate!.day,
      );

      final dateLabel = DateFormat('MMM d').format(task.dueDate!);

      if (taskDate.isBefore(today)) {
        // Overdue Task
        final id = 'notif-task-overdue-${task.id}';
        list.add(
          AppNotification(
            id: id,
            type: NotificationType.task,
            title: 'Task overdue: ${task.title}',
            description: 'Was due on $dateLabel.',
            isRead: _readIds.contains(id),
            timestamp: task.dueDate!,
            targetTabIndex: 1, // Tasks tab
            targetItemId: task.id,
          ),
        );
      } else if (taskDate.isAtSameMomentAs(today)) {
        // Due Today
        final id = 'notif-task-today-${task.id}';
        list.add(
          AppNotification(
            id: id,
            type: NotificationType.task,
            title: 'Task due today: ${task.title}',
            description: task.detail.isNotEmpty
                ? 'Scheduled for ${task.detail}. Stay focused.'
                : 'Scheduled for today. Stay focused.',
            isRead: _readIds.contains(id),
            timestamp: task.dueDate!,
            targetTabIndex: 1, // Tasks tab
            targetItemId: task.id,
          ),
        );
      } else if (taskDate.isAtSameMomentAs(tomorrow)) {
        // Due Tomorrow
        final id = 'notif-task-tomorrow-${task.id}';
        list.add(
          AppNotification(
            id: id,
            type: NotificationType.task,
            title: 'Task due tomorrow: ${task.title}',
            description: 'Due tomorrow ($dateLabel).',
            isRead: _readIds.contains(id),
            timestamp: task.dueDate!,
            targetTabIndex: 1, // Tasks tab
            targetItemId: task.id,
          ),
        );
      }
    }

    // 2. Calendar Event Reminders
    for (final event in events) {
      final eventDate = DateTime(
        event.start.year,
        event.start.month,
        event.start.day,
      );

      final timeLabel = event.isAllDay
          ? ''
          : ' at ${DateFormat('h:mm a').format(event.start)}';

      if (eventDate.isAtSameMomentAs(today)) {
        final id = 'notif-event-today-${event.id}';
        list.add(
          AppNotification(
            id: id,
            type: NotificationType.reminder,
            title: 'Event today: ${event.title}',
            description: 'Happening today$timeLabel.',
            isRead: _readIds.contains(id),
            timestamp: event.start,
            targetTabIndex: 2, // Calendar tab
            targetItemId: event.id,
          ),
        );
      } else if (eventDate.isAtSameMomentAs(tomorrow)) {
        final id = 'notif-event-tomorrow-${event.id}';
        list.add(
          AppNotification(
            id: id,
            type: NotificationType.reminder,
            title: 'Event tomorrow: ${event.title}',
            description: 'Scheduled for tomorrow$timeLabel.',
            isRead: _readIds.contains(id),
            timestamp: event.start,
            targetTabIndex: 2, // Calendar tab
            targetItemId: event.id,
          ),
        );
      }
    }

    // 3. Budget & Expense Alerts (Current Month)
    final currentMonthExpenses = expenses.where((e) {
      final expMonthStr = DateFormat('yyyy-MM').format(e.date);
      return expMonthStr == currentMonthStr;
    }).toList();

    final totalSpent = currentMonthExpenses.fold<double>(
      0.0,
      (sum, e) => sum + e.amount,
    );

    if (budget.monthlyTotal > 0) {
      final ratio = totalSpent / budget.monthlyTotal;
      final currency = budget.currency == 'BDT' ? '৳' : budget.currency;
      final formattedSpent =
          '$currency${NumberFormat('#,##0').format(totalSpent)}';
      final formattedBudget =
          '$currency${NumberFormat('#,##0').format(budget.monthlyTotal)}';

      if (ratio >= 1.0) {
        final id = 'notif-budget-total-100-$currentMonthStr';
        list.add(
          AppNotification(
            id: id,
            type: NotificationType.budget,
            title: 'Monthly budget exceeded',
            description:
                'You\'ve spent $formattedSpent of your $formattedBudget total budget.',
            isRead: _readIds.contains(id),
            timestamp: now,
            targetTabIndex: 3, // Expenses tab
          ),
        );
      } else if (ratio >= 0.9) {
        final id = 'notif-budget-total-90-$currentMonthStr';
        list.add(
          AppNotification(
            id: id,
            type: NotificationType.budget,
            title: 'Monthly budget at 90%',
            description:
                'You\'ve used $formattedSpent (${(ratio * 100).round()}%) of your $formattedBudget limit.',
            isRead: _readIds.contains(id),
            timestamp: now,
            targetTabIndex: 3, // Expenses tab
          ),
        );
      } else if (ratio >= 0.8) {
        final id = 'notif-budget-total-80-$currentMonthStr';
        list.add(
          AppNotification(
            id: id,
            type: NotificationType.budget,
            title: 'Monthly budget at 80%',
            description:
                'You\'ve used $formattedSpent (${(ratio * 100).round()}%) of your $formattedBudget limit.',
            isRead: _readIds.contains(id),
            timestamp: now,
            targetTabIndex: 3, // Expenses tab
          ),
        );
      }
    }

    // 4. Sort: Unread first, then latest timestamp
    list.sort((a, b) {
      if (a.isRead != b.isRead) {
        return a.isRead ? 1 : -1;
      }
      return b.timestamp.compareTo(a.timestamp);
    });

    return list;
  }
}
