import 'package:equatable/equatable.dart';

class FocusTask extends Equatable {
  final String id;
  final String title;
  final String detail;
  final String category;
  final DateTime? dueDate;
  final bool isComplete;

  const FocusTask({
    required this.id,
    required this.title,
    required this.detail,
    required this.category,
    this.dueDate,
    this.isComplete = false,
  });

  factory FocusTask.fromJson(Map<String, dynamic> json) => FocusTask(
    id: json['id']?.toString() ?? '',
    title: json['title']?.toString() ?? 'Untitled task',
    detail: json['dueTime']?.toString() ?? '',
    category: json['category']?.toString() ?? '',
    dueDate: DateTime.tryParse(json['dueDate']?.toString() ?? ''),
    isComplete: json['completed'] == true,
  );

  FocusTask copyWith({bool? isComplete}) => FocusTask(
    id: id,
    title: title,
    detail: detail,
    category: category,
    dueDate: dueDate,
    isComplete: isComplete ?? this.isComplete,
  );

  @override
  List<Object?> get props => [id, title, detail, category, dueDate, isComplete];
}
