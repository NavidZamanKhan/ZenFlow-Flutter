import 'package:equatable/equatable.dart';

import '../models/calendar_item.dart';

enum CalendarViewMode { month, week, schedule }

abstract class CalendarEvent extends Equatable {
  const CalendarEvent();

  @override
  List<Object?> get props => [];
}

class LoadCalendarEvent extends CalendarEvent {
  const LoadCalendarEvent();
}

class SelectDateEvent extends CalendarEvent {
  final DateTime? selectedDate;

  const SelectDateEvent(this.selectedDate);

  @override
  List<Object?> get props => [selectedDate];
}

class ChangeViewModeEvent extends CalendarEvent {
  final CalendarViewMode viewMode;

  const ChangeViewModeEvent(this.viewMode);

  @override
  List<Object?> get props => [viewMode];
}

class NextMonthEvent extends CalendarEvent {
  const NextMonthEvent();
}

class PreviousMonthEvent extends CalendarEvent {
  const PreviousMonthEvent();
}

class JumpToTodayEvent extends CalendarEvent {
  const JumpToTodayEvent();
}

class AddCalendarItemEvent extends CalendarEvent {
  final CalendarItem item;

  const AddCalendarItemEvent(this.item);

  @override
  List<Object?> get props => [item];
}

class ToggleTaskItemEvent extends CalendarEvent {
  final String itemId;

  const ToggleTaskItemEvent(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

class DeleteCalendarItemEvent extends CalendarEvent {
  final String itemId;

  const DeleteCalendarItemEvent(this.itemId);

  @override
  List<Object?> get props => [itemId];
}
