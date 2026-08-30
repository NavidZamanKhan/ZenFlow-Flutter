import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/calendar_item.dart';
import 'calendar_event.dart';
import 'calendar_state.dart';

class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  CalendarBloc() : super(CalendarState.initial()) {
    on<LoadCalendarEvent>(_onLoadCalendar);
    on<SelectDateEvent>(_onSelectDate);
    on<ChangeViewModeEvent>(_onChangeViewMode);
    on<NextMonthEvent>(_onNextMonth);
    on<PreviousMonthEvent>(_onPreviousMonth);
    on<JumpToTodayEvent>(_onJumpToToday);
    on<AddCalendarItemEvent>(_onAddCalendarItem);
    on<ToggleTaskItemEvent>(_onToggleTaskItem);
    on<DeleteCalendarItemEvent>(_onDeleteCalendarItem);

    // Initial load
    add(const LoadCalendarEvent());
  }

  void _onLoadCalendar(LoadCalendarEvent event, Emitter<CalendarState> emit) {
    emit(state.copyWith(status: CalendarStatus.loading));

    final now = DateTime.now();

    final initialMockItems = [
      CalendarItem(
        id: '1',
        title: 'Going on a walk with my cat',
        description: 'Morning loop in the park.',
        startDateTime: DateTime(now.year, now.month, 28, 4, 25),
        isAllDay: false,
        type: CalendarItemType.taskDeadline,
        isCompleted: true,
        category: 'Personal',
      ),
      CalendarItem(
        id: '2',
        title: 'shouting at the home owner',
        description: 'Discuss plumbing invoice.',
        startDateTime: DateTime(now.year, now.month, 29, 9, 0),
        isAllDay: true,
        type: CalendarItemType.taskDeadline,
        isCompleted: false,
        category: 'Home',
      ),
      CalendarItem(
        id: '3',
        title: 'Going out',
        description: 'Coffee catchup with team.',
        startDateTime: DateTime(now.year, now.month, 30, 4, 30),
        endDateTime: DateTime(now.year, now.month, 30, 6, 0),
        isAllDay: false,
        type: CalendarItemType.event,
        category: 'Social',
      ),
      CalendarItem(
        id: '4',
        title: 'Have to buy pen and notebook',
        description: 'Stationery shop trip.',
        startDateTime: DateTime(now.year, now.month, 30, 14, 0),
        isAllDay: true,
        type: CalendarItemType.taskDeadline,
        isCompleted: false,
        category: 'Shopping',
      ),
      CalendarItem(
        id: '5',
        title: 'Visiting my aunt at the hospital',
        description: 'City General Hospital Ward 4.',
        startDateTime: DateTime(now.year, now.month, 31, 10, 0),
        isAllDay: true,
        type: CalendarItemType.taskDeadline,
        isCompleted: false,
        category: 'Personal',
      ),
      CalendarItem(
        id: '6',
        title: 'Q3 Strategy Alignment',
        description: 'Quarterly review with engineering and design.',
        startDateTime: DateTime(now.year, now.month + 1, 2, 10, 0),
        endDateTime: DateTime(now.year, now.month + 1, 2, 11, 30),
        isAllDay: false,
        type: CalendarItemType.event,
        category: 'Work',
      ),
      CalendarItem(
        id: '7',
        title: 'Weekly Standup & Sync',
        description: 'Sprint planning and blocker resolution.',
        startDateTime: DateTime(now.year, now.month, now.day, 9, 30),
        endDateTime: DateTime(now.year, now.month, now.day, 10, 15),
        isAllDay: false,
        type: CalendarItemType.event,
        category: 'Work',
      ),
    ];

    emit(state.copyWith(
      items: initialMockItems,
      status: CalendarStatus.success,
    ));
  }

  void _onSelectDate(SelectDateEvent event, Emitter<CalendarState> emit) {
    emit(state.copyWith(
      selectedDate: event.selectedDate,
      focusedMonth: DateTime(event.selectedDate.year, event.selectedDate.month, 1),
    ));
  }

  void _onChangeViewMode(ChangeViewModeEvent event, Emitter<CalendarState> emit) {
    emit(state.copyWith(viewMode: event.viewMode));
  }

  void _onNextMonth(NextMonthEvent event, Emitter<CalendarState> emit) {
    final next = DateTime(state.focusedMonth.year, state.focusedMonth.month + 1, 1);
    emit(state.copyWith(focusedMonth: next));
  }

  void _onPreviousMonth(PreviousMonthEvent event, Emitter<CalendarState> emit) {
    final prev = DateTime(state.focusedMonth.year, state.focusedMonth.month - 1, 1);
    emit(state.copyWith(focusedMonth: prev));
  }

  void _onJumpToToday(JumpToTodayEvent event, Emitter<CalendarState> emit) {
    final now = DateTime.now();
    emit(state.copyWith(
      selectedDate: now,
      focusedMonth: DateTime(now.year, now.month, 1),
    ));
  }

  void _onAddCalendarItem(AddCalendarItemEvent event, Emitter<CalendarState> emit) {
    final updated = [event.item, ...state.items];
    emit(state.copyWith(items: updated));
  }

  void _onToggleTaskItem(ToggleTaskItemEvent event, Emitter<CalendarState> emit) {
    final updated = state.items.map((item) {
      if (item.id == event.itemId) {
        return item.copyWith(isCompleted: !item.isCompleted);
      }
      return item;
    }).toList();
    emit(state.copyWith(items: updated));
  }

  void _onDeleteCalendarItem(DeleteCalendarItemEvent event, Emitter<CalendarState> emit) {
    final updated = state.items.where((i) => i.id != event.itemId).toList();
    emit(state.copyWith(items: updated));
  }
}
