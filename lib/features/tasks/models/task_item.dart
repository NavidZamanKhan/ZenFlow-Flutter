import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

import 'task_filter.dart';

class TaskItem extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime? dueDate;
  final String? dueTime; // Normalized 24-hour e.g. "14:30" or "09:15"
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

  String get formattedDueTime {
    if (dueTime == null || dueTime!.trim().isEmpty) return '';
    try {
      final trimmed = dueTime!.trim();
      if (trimmed.toLowerCase().contains('am') || trimmed.toLowerCase().contains('pm')) {
        return trimmed;
      }
      final parts = trimmed.split(':');
      if (parts.length >= 2) {
        final hour = int.tryParse(parts[0]) ?? 0;
        final minute = int.tryParse(parts[1]) ?? 0;
        final period = hour >= 12 ? 'PM' : 'AM';
        final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
        final displayMin = minute.toString().padLeft(2, '0');
        return '$displayHour:$displayMin $period';
      }
    } catch (_) {}
    return dueTime!;
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

    final timeStr = formattedDueTime.isNotEmpty ? ' · $formattedDueTime' : '';
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

  static String? normalizeDueTimeTo24h(String? rawTime) {
    if (rawTime == null || rawTime.trim().isEmpty) return null;
    final trimmed = rawTime.trim();
    if (RegExp(r'^\d{1,2}:\d{2}$').hasMatch(trimmed)) {
      final parts = trimmed.split(':');
      final h = parts[0].padLeft(2, '0');
      final m = parts[1].padLeft(2, '0');
      return '$h:$m';
    }
    if (RegExp(r'^\d{1,2}:\d{2}:\d{2}$').hasMatch(trimmed)) {
      final parts = trimmed.split(':');
      final h = parts[0].padLeft(2, '0');
      final m = parts[1].padLeft(2, '0');
      return '$h:$m';
    }
    try {
      final parsed = DateFormat('h:mm a').parse(trimmed.toUpperCase());
      return DateFormat('HH:mm').format(parsed);
    } catch (_) {
      try {
        final parsed = DateFormat('hh:mm a').parse(trimmed.toUpperCase());
        return DateFormat('HH:mm').format(parsed);
      } catch (_) {
        return null;
      }
    }
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
      dueTime: normalizeDueTimeTo24h(rawDueTime?.toString()),
      priority: parsedPriority,
      category: (rawCategory != null && rawCategory.isNotEmpty) ? rawCategory : 'General',
      isCompleted: json['completed'] == true || json['is_complete'] == true,
      createdAt: rawCreatedAt != null
          ? (DateTime.tryParse(rawCreatedAt.toString()) ?? DateTime.now())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson({bool includeId = true}) {
    final normalizedTime = normalizeDueTimeTo24h(dueTime);
    return {
      if (includeId && id.isNotEmpty && !id.startsWith('temp-')) 'id': id,
      'title': title.trim(),
      'description': description.trim(),
      'dueDate': dueDate != null ? DateFormat('yyyy-MM-dd').format(dueDate!) : null,
      'dueTime': (dueDate != null) ? normalizedTime : null,
      'priority': priority.name,
      'category': category.trim().isNotEmpty ? category.trim() : 'General',
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
