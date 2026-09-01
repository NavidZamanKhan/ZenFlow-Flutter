import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/cache/client_cache.dart';
import '../../../core/services/notification_service.dart';
import '../../tasks/models/task_item.dart';
import '../../tasks/services/tasks_service.dart';
import '../models/calendar_item.dart';
import '../services/calendar_service.dart';
import 'calendar_event.dart';
import 'calendar_state.dart';

class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  static const String _cacheKey = 'calendar_events_list';
  final CalendarService _calendarService;
  final TasksService _tasksService;
  final ClientCache _cache;
  final NotificationService _notificationService;

  CalendarBloc({
    CalendarService? calendarService,
    TasksService? tasksService,
    ClientCache? cache,
    NotificationService? notificationService,
  })  : _calendarService = calendarService ?? CalendarService(),
        _tasksService = tasksService ?? TasksService(),
        _cache = cache ?? ClientCache.instance,
        _notificationService = notificationService ?? NotificationService(),
        super(_getInitialState(cache ?? ClientCache.instance)) {
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

  static CalendarState _getInitialState(ClientCache cache) {
    final now = DateTime.now();
    final cached = cache.get<List<CalendarItem>>(_cacheKey);
    return CalendarState(
      selectedDate: now,
      focusedMonth: DateTime(now.year, now.month, 1),
      viewMode: CalendarViewMode.month,
      items: (cached != null && cached.isNotEmpty) ? cached : const [],
      status: (cached != null && cached.isNotEmpty)
          ? CalendarStatus.success
          : CalendarStatus.initial,
    );
  }

  Future<void> _onLoadCalendar(
    LoadCalendarEvent event,
    Emitter<CalendarState> emit,
  ) async {
    if (state.items.isEmpty) {
      emit(state.copyWith(status: CalendarStatus.loading));
    }

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

      _cache.set(_cacheKey, mergedItems);
      emit(state.copyWith(
        items: mergedItems,
        status: CalendarStatus.success,
      ));

      // Auto-schedule 15m alerts for upcoming events
      for (final ev in remoteEvents) {
        if (ev.type == CalendarItemType.event && !ev.isCompleted) {
          unawaited(_notificationService.scheduleEventReminder(ev));
        }
      }
    } catch (_) {
      emit(state.copyWith(status: CalendarStatus.success));
    }
  }

  void _onSelectDate(SelectDateEvent event, Emitter<CalendarState> emit) {
    if (event.selectedDate == null) {
      emit(state.copyWith(clearSelectedDate: true));
      return;
    }

    final target = event.selectedDate!;
    if (state.selectedDate != null &&
        state.selectedDate!.year == target.year &&
        state.selectedDate!.month == target.month &&
        state.selectedDate!.day == target.day) {
      emit(state.copyWith(clearSelectedDate: true));
    } else {
      emit(state.copyWith(
        selectedDate: target,
        focusedMonth: DateTime(target.year, target.month, 1),
      ));
    }
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
    final tempId = event.item.id.startsWith('temp-')
        ? event.item.id
        : 'temp-${DateTime.now().millisecondsSinceEpoch}';
    final optimisticItem = event.item.copyWith(id: tempId);

    final optimisticList = [optimisticItem, ...state.items];
    _cache.set(_cacheKey, optimisticList);
    emit(state.copyWith(items: optimisticList, status: CalendarStatus.success));

    if (event.item.type == CalendarItemType.event) {
      unawaited(_notificationService.scheduleEventReminder(optimisticItem));
    }

    try {
      if (event.item.type == CalendarItemType.taskDeadline) {
        String? dueTimeStr;
        if (!event.item.isAllDay) {
          final h =
              event.item.startDateTime.hour.toString().padLeft(2, '0');
          final m =
              event.item.startDateTime.minute.toString().padLeft(2, '0');
          dueTimeStr = '$h:$m';
        }
        final createdTask = await _tasksService.createTask(
          TaskItem(
            id: tempId,
            title: event.item.title,
            description: event.item.description,
            dueDate: event.item.startDateTime,
            dueTime: dueTimeStr,
            category: event.item.category,
            createdAt: DateTime.now(),
          ),
        );
        final deadlineItem = CalendarItem(
          id: 'task_${createdTask.id}',
          title: createdTask.title,
          description: createdTask.description,
          startDateTime: createdTask.dueDate ?? event.item.startDateTime,
          isAllDay: createdTask.dueTime == null,
          type: CalendarItemType.taskDeadline,
          isCompleted: createdTask.isCompleted,
          category: createdTask.category,
        );
        final updated = state.items
            .map((i) => i.id == tempId ? deadlineItem : i)
            .toList();
        _cache.set(_cacheKey, updated);
        emit(state.copyWith(items: updated));
      } else {
        final created = await _calendarService.createEvent(optimisticItem);
        final updated = state.items
            .map((i) => i.id == tempId ? created : i)
            .toList();
        _cache.set(_cacheKey, updated);
        emit(state.copyWith(items: updated));

        unawaited(_notificationService.cancelEventReminder(tempId));
        unawaited(_notificationService.scheduleEventReminder(created));
      }
    } catch (_) {
      unawaited(_notificationService.cancelEventReminder(tempId));
      _cache.set(_cacheKey, previousItems);
      emit(state.copyWith(items: previousItems));
    }
  }

  Future<void> _onToggleTaskItem(
    ToggleTaskItemEvent event,
    Emitter<CalendarState> emit,
  ) async {
    final previousItems = state.items;
    bool targetCompleted = false;
    final updated = state.items.map((item) {
      if (item.id == event.itemId) {
        targetCompleted = !item.isCompleted;
        return item.copyWith(isCompleted: targetCompleted);
      }
      return item;
    }).toList();
    _cache.set(_cacheKey, updated);
    emit(state.copyWith(items: updated));

    try {
      if (event.itemId.startsWith('task_')) {
        final realTaskId = event.itemId.replaceFirst('task_', '');
        await _tasksService.toggleTask(realTaskId, targetCompleted);
      }
    } catch (_) {
      _cache.set(_cacheKey, previousItems);
      emit(state.copyWith(items: previousItems));
    }
  }

  Future<void> _onDeleteCalendarItem(
    DeleteCalendarItemEvent event,
    Emitter<CalendarState> emit,
  ) async {
    final previousItems = state.items;
    final updated =
        state.items.where((i) => i.id != event.itemId).toList();
    _cache.set(_cacheKey, updated);
    emit(state.copyWith(items: updated));

    unawaited(_notificationService.cancelEventReminder(event.itemId));

    try {
      if (event.itemId.startsWith('task_')) {
        final realTaskId = event.itemId.replaceFirst('task_', '');
        await _tasksService.deleteTask(realTaskId);
      } else {
        await _calendarService.deleteEvent(event.itemId);
      }
    } catch (_) {
      _cache.set(_cacheKey, previousItems);
      emit(state.copyWith(items: previousItems));
    }
  }
}
