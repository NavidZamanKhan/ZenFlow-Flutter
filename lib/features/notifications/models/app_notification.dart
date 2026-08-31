import 'package:equatable/equatable.dart';

enum NotificationType { task, reminder, budget }

class AppNotification extends Equatable {
  final String id;
  final NotificationType type;
  final String title;
  final String description;
  final bool isRead;
  final DateTime timestamp;
  final int? targetTabIndex; // 0=Overview, 1=Tasks, 2=Calendar, 3=Expenses, 4=Insights
  final String? targetItemId; // Exact ID of the task or event

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.isRead,
    required this.timestamp,
    this.targetTabIndex,
    this.targetItemId,
  });

  AppNotification copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? description,
    bool? isRead,
    DateTime? timestamp,
    int? targetTabIndex,
    String? targetItemId,
  }) {
    return AppNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      isRead: isRead ?? this.isRead,
      timestamp: timestamp ?? this.timestamp,
      targetTabIndex: targetTabIndex ?? this.targetTabIndex,
      targetItemId: targetItemId ?? this.targetItemId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        title,
        description,
        isRead,
        timestamp,
        targetTabIndex,
        targetItemId,
      ];
}
