import 'package:equatable/equatable.dart';

import '../models/app_notification.dart';

class NotificationsState extends Equatable {
  final List<AppNotification> notifications;
  final int unreadCount;

  const NotificationsState({
    required this.notifications,
    required this.unreadCount,
  });

  factory NotificationsState.initial() => const NotificationsState(
        notifications: [],
        unreadCount: 0,
      );

  NotificationsState copyWith({
    List<AppNotification>? notifications,
    int? unreadCount,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  @override
  List<Object?> get props => [notifications, unreadCount];
}
