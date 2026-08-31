import 'package:flutter_bloc/flutter_bloc.dart';

import '../../tasks/models/task_item.dart';
import '../../tasks/services/tasks_service.dart';
import '../models/calendar_item.dart';
import '../services/calendar_service.dart';
import 'calendar_event.dart';
import 'calendar_state.dart';

class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  final CalendarService _calendarService;
  final TasksService _tasksService;

  CalendarBloc({
    CalendarService? calendarService,
    TasksService? tasksService,
  })  : _calendarService = calendarService ?? CalendarService(),
        _tasksService = tasksService ?? TasksService(),
        super(_initialState()) {
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
      final eventsFuture = _calendarService.getEvents();
      final tasksFuture = _tasksService.getTasks();

      final results = await Future.wait([eventsFuture, tasksFuture]);
      final remoteEvents = results[0] as List<CalendarItem>;
      final remoteTasks = results[1] as List<TaskItem>;

      final mergedItems = <CalendarItem>[...remoteEvents];

      // Convert tasks with due dates into calendar deadline items (Green dots)
      for (final task in remoteTasks) {
        if (task.dueDate != null) {
          mergedItems.add(
            CalendarItem(
              id: 'task_${task.id}',
              title: task.title,
              description: task.description,
              startDateTime: task.dueDate!,
              isAllDay: task.dueTime == null,
              type: CalendarItemType.taskDeadline,
              isCompleted: task.isCompleted,
              category: task.category.isNotEmpty ? task.category : 'Task',
            ),
          );
        }
      }

      if (mergedItems.isNotEmpty) {
        emit(state.copyWith(
          items: mergedItems,
          status: CalendarStatus.success,
        ));
      } else {
        emit(state.copyWith(status: CalendarStatus.success));
      }
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
      final created = await _calendarService.createEvent(event.item);
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
      await _calendarService.deleteEvent(event.itemId);
    } catch (_) {
      emit(state.copyWith(items: previousItems));
    }
  }

  static CalendarState _initialState() {
    final now = DateTime.now();
    final year = now.year;
    final month = now.month;

    return CalendarState(
      selectedDate: now,
      focusedMonth: DateTime(year, month, 1),
      viewMode: CalendarViewMode.month,
      items: [
        CalendarItem(
          id: '1',
          title: 'Team Daily Standup',
          description: 'Sync on sprint deliverables and unblock team members',
          startDateTime: DateTime(year, month, now.day, 9, 30),
          endDateTime: DateTime(year, month, now.day, 10, 0),
          type: CalendarItemType.event,
          category: 'Work',
        ),
        CalendarItem(
          id: '2',
          title: 'Design System Review',
          description: 'Audit mobile UI components and tokens parity',
          startDateTime: DateTime(year, month, now.day, 11, 0),
          endDateTime: DateTime(year, month, now.day, 12, 30),
          type: CalendarItemType.event,
          category: 'Design',
        ),
        CalendarItem(
          id: '3',
          title: 'Quarterly Roadmap Planning',
          description: 'Finalize Q4 milestones and engineering scope',
          startDateTime: DateTime(year, month, now.day),
          isAllDay: true,
          type: CalendarItemType.taskDeadline,
          isCompleted: false,
          category: 'Planning',
        ),
        CalendarItem(
          id: '4',
          title: 'Client Architecture Demo',
          description: 'Live mobile & web cloud deployment walkthrough',
          startDateTime: DateTime(year, month, now.day, 14, 0),
          endDateTime: DateTime(year, month, now.day, 15, 0),
          type: CalendarItemType.event,
          category: 'Work',
        ),
        CalendarItem(
          id: '5',
          title: 'Budget Review & Financial Audit',
          description: 'Review monthly cloud spending and thresholds',
          startDateTime: DateTime(year, month, now.day, 16, 0),
          endDateTime: DateTime(year, month, now.day, 16, 45),
          type: CalendarItemType.event,
          category: 'Finance',
        ),
      ],
      status: CalendarStatus.initial,
    );
  }
}
