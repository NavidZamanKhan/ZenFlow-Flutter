import 'package:equatable/equatable.dart';

class FocusTask extends Equatable {
  final String id;
  final String title;
  final String detail;
  final String category;
  final bool isComplete;

  const FocusTask({
    required this.id,
    required this.title,
    required this.detail,
    required this.category,
    this.isComplete = false,
  });

  FocusTask copyWith({bool? isComplete}) => FocusTask(
    id: id,
    title: title,
    detail: detail,
    category: category,
    isComplete: isComplete ?? this.isComplete,
  );

  @override
  List<Object?> get props => [id, title, detail, category, isComplete];
}
