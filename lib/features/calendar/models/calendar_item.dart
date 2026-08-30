import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

enum CalendarItemType { event, taskDeadline }

class CalendarItem extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime startDateTime;
  final DateTime? endDateTime;
  final bool isAllDay;
  final CalendarItemType type;
  final bool isCompleted;
  final String category;

  const CalendarItem({
    required this.id,
    required this.title,
    this.description = '',
    required this.startDateTime,
    this.endDateTime,
    this.isAllDay = false,
    this.type = CalendarItemType.event,
    this.isCompleted = false,
    this.category = 'General',
  });

  bool isSameDay(DateTime date) {
    return startDateTime.year == date.year &&
        startDateTime.month == date.month &&
        startDateTime.day == date.day;
  }

  String get formattedTime {
    if (isAllDay) return 'All day';
    final startTimeStr = DateFormat('h:mm a').format(startDateTime);
    if (endDateTime != null) {
      final endTimeStr = DateFormat('h:mm a').format(endDateTime!);
      return '$startTimeStr - $endTimeStr';
    }
    return startTimeStr;
  }

  factory CalendarItem.fromJson(Map<String, dynamic> json) {
    final rawStart = json['start_datetime'] ?? json['startDateTime'];
    final rawEnd = json['end_datetime'] ?? json['endDateTime'];

    return CalendarItem(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? 'Untitled Event',
      description: json['description'] ?? '',
      startDateTime: rawStart != null
          ? (DateTime.tryParse(rawStart.toString()) ?? DateTime.now())
          : DateTime.now(),
      endDateTime: rawEnd != null ? DateTime.tryParse(rawEnd.toString()) : null,
      isAllDay: json['all_day'] ?? json['isAllDay'] ?? false,
      type: CalendarItemType.event,
      isCompleted: json['completed'] ?? false,
      category: json['category'] ?? 'Event',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'start_datetime': startDateTime.toIso8601String(),
      if (endDateTime != null) 'end_datetime': endDateTime!.toIso8601String(),
      'all_day': isAllDay,
    };
  }

  CalendarItem copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startDateTime,
    DateTime? endDateTime,
    bool? isAllDay,
    CalendarItemType? type,
    bool? isCompleted,
    String? category,
  }) {
    return CalendarItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDateTime: startDateTime ?? this.startDateTime,
      endDateTime: endDateTime ?? this.endDateTime,
      isAllDay: isAllDay ?? this.isAllDay,
      type: type ?? this.type,
      isCompleted: isCompleted ?? this.isCompleted,
      category: category ?? this.category,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        startDateTime,
        endDateTime,
        isAllDay,
        type,
        isCompleted,
        category,
      ];
}
