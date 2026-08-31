import 'package:equatable/equatable.dart';

import '../models/calendar_item.dart';
import 'calendar_event.dart';

enum CalendarStatus { initial, loading, success, failure }

class CalendarState extends Equatable {
  final List<CalendarItem> items;
  final DateTime? selectedDate;
  final DateTime focusedMonth;
  final CalendarViewMode viewMode;
  final CalendarStatus status;
  final String? errorMessage;

  const CalendarState({
    required this.items,
    this.selectedDate,
    required this.focusedMonth,
    this.viewMode = CalendarViewMode.month,
    this.status = CalendarStatus.initial,
    this.errorMessage,
  });

  factory CalendarState.initial() {
    final now = DateTime.now();
    return CalendarState(
      items: const [],
      selectedDate: now,
      focusedMonth: DateTime(now.year, now.month, 1),
      viewMode: CalendarViewMode.month,
      status: CalendarStatus.initial,
    );
  }

  List<CalendarItem> get itemsForSelectedDate {
    if (selectedDate != null) {
      return items.where((item) => item.isSameDay(selectedDate!)).toList()
        ..sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
    }

    // When no specific date is focused, return all items in the focused month
    return items.where((item) {
      return item.startDateTime.year == focusedMonth.year &&
          item.startDateTime.month == focusedMonth.month;
    }).toList()
      ..sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
  }

  List<CalendarItem> itemsForDate(DateTime date) {
    return items.where((item) => item.isSameDay(date)).toList();
  }

  bool hasEventsOnDate(DateTime date) {
    return items.any(
      (item) => item.isSameDay(date) && item.type == CalendarItemType.event,
    );
  }

  bool hasDeadlinesOnDate(DateTime date) {
    return items.any(
      (item) => item.isSameDay(date) && item.type == CalendarItemType.taskDeadline,
    );
  }

  CalendarState copyWith({
    List<CalendarItem>? items,
    DateTime? selectedDate,
    bool clearSelectedDate = false,
    DateTime? focusedMonth,
    CalendarViewMode? viewMode,
    CalendarStatus? status,
    String? errorMessage,
  }) {
    return CalendarState(
      items: items ?? this.items,
      selectedDate: clearSelectedDate ? null : (selectedDate ?? this.selectedDate),
      focusedMonth: focusedMonth ?? this.focusedMonth,
      viewMode: viewMode ?? this.viewMode,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        items,
        selectedDate,
        focusedMonth,
        viewMode,
        status,
        errorMessage,
      ];
}
