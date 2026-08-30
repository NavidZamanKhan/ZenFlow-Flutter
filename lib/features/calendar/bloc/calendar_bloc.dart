import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/calendar_service.dart';
import 'calendar_event.dart';
import 'calendar_state.dart';

class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  final CalendarService _service;

  CalendarBloc({CalendarService? service})
      : _service = service ?? CalendarService(),
        super(CalendarState.initial()) {
    on<LoadCalendarEvent>(_onLoadCalendar);
    on<SelectDateEvent>(_onSelectDate);
    on<ChangeViewModeEvent>(_onChangeViewMode);
    on<NextMonthEvent>(_onNextMonth);
    on<PreviousMonthEvent>(_onPreviousMonth);
    on<JumpToTodayEvent>(_onJumpToToday);
    on<AddCalendarItemEvent>(_onAddCalendarItem);
    on<ToggleTaskItemEvent>(_onToggleTaskItem);
    on<DeleteCalendarItemEvent>(_onDeleteCalendarItem);

    add(const LoadCalendarEvent());
  }

  Future<void> _onLoadCalendar(
    LoadCalendarEvent event,
    Emitter<CalendarState> emit,
  ) async {
    emit(state.copyWith(status: CalendarStatus.loading));
    try {
      final events = await _service.getEvents();
      emit(state.copyWith(
        items: events,
        status: CalendarStatus.success,
      ));
    } catch (_) {
      emit(state.copyWith(status: CalendarStatus.success));
    }
  }

  void _onSelectDate(SelectDateEvent event, Emitter<CalendarState> emit) {
    emit(state.copyWith(
      selectedDate: event.selectedDate,
      focusedMonth:
          DateTime(event.selectedDate.year, event.selectedDate.month, 1),
    ));
  }

  void _onChangeViewMode(
    ChangeViewModeEvent event,
    Emitter<CalendarState> emit,
  ) {
    emit(state.copyWith(viewMode: event.viewMode));
  }

  void _onNextMonth(NextMonthEvent event, Emitter<CalendarState> emit) {
    final next =
        DateTime(state.focusedMonth.year, state.focusedMonth.month + 1, 1);
    emit(state.copyWith(focusedMonth: next));
  }

  void _onPreviousMonth(
    PreviousMonthEvent event,
    Emitter<CalendarState> emit,
  ) {
    final prev =
        DateTime(state.focusedMonth.year, state.focusedMonth.month - 1, 1);
    emit(state.copyWith(focusedMonth: prev));
  }

  void _onJumpToToday(JumpToTodayEvent event, Emitter<CalendarState> emit) {
    final now = DateTime.now();
    emit(state.copyWith(
      selectedDate: now,
      focusedMonth: DateTime(now.year, now.month, 1),
    ));
  }

  Future<void> _onAddCalendarItem(
    AddCalendarItemEvent event,
    Emitter<CalendarState> emit,
  ) async {
    final previousItems = state.items;
    emit(state.copyWith(items: [event.item, ...state.items]));

    try {
      final created = await _service.createEvent(event.item);
      final updated = state.items
          .map((i) => i.id == event.item.id ? created : i)
          .toList();
      emit(state.copyWith(items: updated));
    } catch (_) {
      emit(state.copyWith(items: previousItems));
    }
  }

  void _onToggleTaskItem(
    ToggleTaskItemEvent event,
    Emitter<CalendarState> emit,
  ) {
    final updated = state.items.map((item) {
      if (item.id == event.itemId) {
        return item.copyWith(isCompleted: !item.isCompleted);
      }
      return item;
    }).toList();
    emit(state.copyWith(items: updated));
  }

  Future<void> _onDeleteCalendarItem(
    DeleteCalendarItemEvent event,
    Emitter<CalendarState> emit,
  ) async {
    final previousItems = state.items;
    final updated =
        state.items.where((i) => i.id != event.itemId).toList();
    emit(state.copyWith(items: updated));

    try {
      await _service.deleteEvent(event.itemId);
    } catch (_) {
      emit(state.copyWith(items: previousItems));
    }
  }
}
