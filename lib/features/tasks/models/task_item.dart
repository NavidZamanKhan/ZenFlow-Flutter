import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

import 'task_filter.dart';

class TaskItem extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime? dueDate;
  final String? dueTime; // e.g. "4:30 AM" or "10:30"
  final TaskPriority priority;
  final String category;
  final bool isCompleted;
  final DateTime createdAt;

  const TaskItem({
    required this.id,
    required this.title,
    this.description = '',
    this.dueDate,
    this.dueTime,
    this.priority = TaskPriority.medium,
    this.category = 'General',
    this.isCompleted = false,
    required this.createdAt,
  });

  bool get isOverdue {
    if (isCompleted || dueDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    return due.isBefore(today);
  }

  String get formattedSchedule {
    if (dueDate == null) return 'No due date';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);

    String dateStr;
    if (due == today) {
      dateStr = 'Today';
    } else if (due == today.add(const Duration(days: 1))) {
      dateStr = 'Tomorrow';
    } else {
      dateStr = DateFormat('MMM d, yyyy').format(dueDate!);
    }

    final timeStr = (dueTime != null && dueTime!.isNotEmpty) ? ' · $dueTime' : '';
    final overdueStr = isOverdue ? ' · Overdue' : '';

    return '$dateStr$timeStr$overdueStr';
  }

  TaskItem copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    String? dueTime,
    TaskPriority? priority,
    String? category,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return TaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      dueTime: dueTime ?? this.dueTime,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    final rawDueDate = json['dueDate'] ?? json['due_date'];
    final rawDueTime = json['dueTime'] ?? json['due_time'];
    final rawPriorityStr = json['priority']?.toString().toLowerCase() ?? 'medium';
    final rawCategory = json['category']?.toString();
    final rawCreatedAt = json['createdAt'] ?? json['created_at'];

    TaskPriority parsedPriority = TaskPriority.medium;
    if (rawPriorityStr == 'high') {
      parsedPriority = TaskPriority.high;
    } else if (rawPriorityStr == 'low') {
      parsedPriority = TaskPriority.low;
    }

    return TaskItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled task',
      description: json['description']?.toString() ?? '',
      dueDate: rawDueDate != null ? DateTime.tryParse(rawDueDate.toString()) : null,
      dueTime: rawDueTime?.toString(),
      priority: parsedPriority,
      category: (rawCategory != null && rawCategory.isNotEmpty) ? rawCategory : 'General',
      isCompleted: json['completed'] == true || json['is_complete'] == true,
      createdAt: rawCreatedAt != null
          ? (DateTime.tryParse(rawCreatedAt.toString()) ?? DateTime.now())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate != null ? DateFormat('yyyy-MM-dd').format(dueDate!) : null,
      'dueTime': dueTime,
      'priority': priority.name,
      'category': category,
      'completed': isCompleted,
    };
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        dueDate,
        dueTime,
        priority,
        category,
        isCompleted,
        createdAt,
      ];
}
