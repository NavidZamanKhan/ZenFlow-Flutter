import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/cache/client_cache.dart';
import '../models/task_item.dart';
import '../services/tasks_service.dart';
import 'tasks_event.dart';
import 'tasks_state.dart';

class TasksBloc extends Bloc<TasksEvent, TasksState> {
  static const String _cacheKey = 'tasks_list';
  final TasksService _service;
  final ClientCache _cache;

  TasksBloc({TasksService? service, ClientCache? cache})
      : _service = service ?? TasksService(),
        _cache = cache ?? ClientCache.instance,
        super(_getInitialState(cache ?? ClientCache.instance)) {
    on<LoadTasksEvent>(_onLoadTasks);
    on<AddTaskEvent>(_onAddTask);
    on<ToggleTaskEvent>(_onToggleTask);
    on<DeleteTaskEvent>(_onDeleteTask);
    on<UpdateTaskEvent>(_onUpdateTask);
    on<FilterStatusChangedEvent>(_onFilterStatusChanged);
    on<FilterCategoryChangedEvent>(_onFilterCategoryChanged);
    on<SearchQueryChangedEvent>(_onSearchQueryChanged);

    add(const LoadTasksEvent());
  }

  static TasksState _getInitialState(ClientCache cache) {
    final cached = cache.get<List<TaskItem>>(_cacheKey);
    if (cached != null && cached.isNotEmpty) {
      return TasksState.initial().copyWith(
        tasks: cached,
        status: TasksStatus.success,
      );
    }
    return TasksState.initial();
  }

  Future<void> _onLoadTasks(
    LoadTasksEvent event,
    Emitter<TasksState> emit,
  ) async {
    if (state.tasks.isEmpty) {
      emit(state.copyWith(status: TasksStatus.loading));
    }

    try {
      final tasks = await _service.getTasks();
      _cache.set(_cacheKey, tasks);
      emit(state.copyWith(
        tasks: tasks,
        status: TasksStatus.success,
      ));
    } catch (_) {
      // Fallback to cache
      emit(state.copyWith(status: TasksStatus.success));
    }
  }

  Future<void> _onAddTask(
    AddTaskEvent event,
    Emitter<TasksState> emit,
  ) async {
    final previousTasks = state.tasks;
    final tempId = event.task.id.startsWith('temp-')
        ? event.task.id
        : 'temp-${DateTime.now().millisecondsSinceEpoch}';
    final optimisticTask = event.task.copyWith(id: tempId);

    // 1. Instant 0ms Optimistic UI update
    final optimisticList = [optimisticTask, ...state.tasks];
    _cache.set(_cacheKey, optimisticList);
    emit(state.copyWith(tasks: optimisticList, status: TasksStatus.success));

    // 2. Silent background network execution
    try {
      final created = await _service.createTask(optimisticTask);
      final syncedList = state.tasks
          .map((t) => t.id == tempId ? created : t)
          .toList();
      _cache.set(_cacheKey, syncedList);
      emit(state.copyWith(tasks: syncedList));
    } catch (_) {
      // Rollback on network failure
      _cache.set(_cacheKey, previousTasks);
      emit(state.copyWith(tasks: previousTasks));
    }
  }

  Future<void> _onToggleTask(
    ToggleTaskEvent event,
    Emitter<TasksState> emit,
  ) async {
    final previousTasks = state.tasks;
    bool targetCompleted = false;

    // 1. Instant 0ms Optimistic UI update
    final optimisticList = state.tasks.map((task) {
      if (task.id == event.taskId) {
        targetCompleted = !task.isCompleted;
        return task.copyWith(isCompleted: targetCompleted);
      }
      return task;
    }).toList();

    _cache.set(_cacheKey, optimisticList);
    emit(state.copyWith(tasks: optimisticList, status: TasksStatus.success));

    // 2. Silent background network execution
    try {
      await _service.toggleTask(event.taskId, targetCompleted);
    } catch (_) {
      _cache.set(_cacheKey, previousTasks);
      emit(state.copyWith(tasks: previousTasks));
    }
  }

  Future<void> _onDeleteTask(
    DeleteTaskEvent event,
    Emitter<TasksState> emit,
  ) async {
    final previousTasks = state.tasks;

    // 1. Instant 0ms Optimistic UI update
    final optimisticList =
        state.tasks.where((t) => t.id != event.taskId).toList();
    _cache.set(_cacheKey, optimisticList);
    emit(state.copyWith(tasks: optimisticList, status: TasksStatus.success));

    // 2. Silent background network execution
    try {
      await _service.deleteTask(event.taskId);
    } catch (_) {
      _cache.set(_cacheKey, previousTasks);
      emit(state.copyWith(tasks: previousTasks));
    }
  }

  Future<void> _onUpdateTask(
    UpdateTaskEvent event,
    Emitter<TasksState> emit,
  ) async {
    final previousTasks = state.tasks;

    // 1. Instant 0ms Optimistic UI update
    final optimisticList = state.tasks.map((task) {
      if (task.id == event.task.id) {
        return event.task;
      }
      return task;
    }).toList();

    _cache.set(_cacheKey, optimisticList);
    emit(state.copyWith(tasks: optimisticList, status: TasksStatus.success));

    // 2. Silent background network execution
    try {
      final updated = await _service.updateTask(event.task);
      final syncedList = state.tasks
          .map((t) => t.id == event.task.id ? updated : t)
          .toList();
      _cache.set(_cacheKey, syncedList);
      emit(state.copyWith(tasks: syncedList));
    } catch (_) {
      _cache.set(_cacheKey, previousTasks);
      emit(state.copyWith(tasks: previousTasks));
    }
  }

  void _onFilterStatusChanged(
    FilterStatusChangedEvent event,
    Emitter<TasksState> emit,
  ) {
    emit(state.copyWith(statusFilter: event.statusFilter));
  }

  void _onFilterCategoryChanged(
    FilterCategoryChangedEvent event,
    Emitter<TasksState> emit,
  ) {
    if (event.category == null || event.category == 'All') {
      emit(state.copyWith(clearCategory: true));
    } else {
      emit(state.copyWith(selectedCategory: event.category));
    }
  }

  void _onSearchQueryChanged(
    SearchQueryChangedEvent event,
    Emitter<TasksState> emit,
  ) {
    emit(state.copyWith(searchQuery: event.query));
  }
}
