import 'package:equatable/equatable.dart';

class FocusTask extends Equatable {
  final String id;
  final String title;
  final String detail;
  final String category;
  final String priority;
  final DateTime? dueDate;
  final bool isComplete;

  const FocusTask({
    required this.id,
    required this.title,
    required this.detail,
    required this.category,
    this.priority = 'medium',
    this.dueDate,
    this.isComplete = false,
  });

  factory FocusTask.fromJson(Map<String, dynamic> json) {
    // Robust parsing for camelCase and snake_case backend fields
    final rawDueDate = json['dueDate'] ?? json['due_date'];
    final rawDueTime = json['dueTime'] ?? json['due_time'];
    final rawPriority = json['priority']?.toString() ?? 'medium';
    final rawCategory = json['category']?.toString() ?? 'General';
    final rawCompleted = json['completed'] == true || json['is_complete'] == true;

    return FocusTask(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled task',
      detail: rawDueTime?.toString() ?? '',
      category: rawCategory,
      priority: rawPriority,
      dueDate: rawDueDate != null ? DateTime.tryParse(rawDueDate.toString()) : null,
      isComplete: rawCompleted,
    );
  }

  FocusTask copyWith({
    String? id,
    String? title,
    String? detail,
    String? category,
    String? priority,
    DateTime? dueDate,
    bool? isComplete,
  }) {
    return FocusTask(
      id: id ?? this.id,
      title: title ?? this.title,
      detail: detail ?? this.detail,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      isComplete: isComplete ?? this.isComplete,
    );
  }

  @override
  List<Object?> get props => [id, title, detail, category, priority, dueDate, isComplete];
}
