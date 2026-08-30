import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/tasks_service.dart';
import 'tasks_event.dart';
import 'tasks_state.dart';

class TasksBloc extends Bloc<TasksEvent, TasksState> {
  final TasksService _service;

  TasksBloc({TasksService? service})
      : _service = service ?? TasksService(),
        super(TasksState.initial()) {
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

  Future<void> _onLoadTasks(
    LoadTasksEvent event,
    Emitter<TasksState> emit,
  ) async {
    emit(state.copyWith(status: TasksStatus.loading));
    try {
      final tasks = await _service.getTasks();
      emit(state.copyWith(
        tasks: tasks,
        status: TasksStatus.success,
      ));
    } catch (_) {
      // Keep existing state if offline
      emit(state.copyWith(status: TasksStatus.success));
    }
  }

  Future<void> _onAddTask(
    AddTaskEvent event,
    Emitter<TasksState> emit,
  ) async {
    final previousTasks = state.tasks;
    emit(state.copyWith(tasks: [event.task, ...state.tasks]));

    try {
      final created = await _service.createTask(event.task);
      final updatedList = state.tasks
          .map((t) => t.id == event.task.id ? created : t)
          .toList();
      emit(state.copyWith(tasks: updatedList));
    } catch (_) {
      emit(state.copyWith(tasks: previousTasks));
    }
  }

  Future<void> _onToggleTask(
    ToggleTaskEvent event,
    Emitter<TasksState> emit,
  ) async {
    final previousTasks = state.tasks;
    bool targetCompleted = false;

    final updatedList = state.tasks.map((task) {
      if (task.id == event.taskId) {
        targetCompleted = !task.isCompleted;
        return task.copyWith(isCompleted: targetCompleted);
      }
      return task;
    }).toList();

    emit(state.copyWith(tasks: updatedList));

    try {
      await _service.toggleTask(event.taskId, targetCompleted);
    } catch (_) {
      emit(state.copyWith(tasks: previousTasks));
    }
  }

  Future<void> _onDeleteTask(
    DeleteTaskEvent event,
    Emitter<TasksState> emit,
  ) async {
    final previousTasks = state.tasks;
    final updatedList =
        state.tasks.where((t) => t.id != event.taskId).toList();
    emit(state.copyWith(tasks: updatedList));

    try {
      await _service.deleteTask(event.taskId);
    } catch (_) {
      emit(state.copyWith(tasks: previousTasks));
    }
  }

  Future<void> _onUpdateTask(
    UpdateTaskEvent event,
    Emitter<TasksState> emit,
  ) async {
    final previousTasks = state.tasks;
    final updatedList = state.tasks.map((task) {
      if (task.id == event.task.id) {
        return event.task;
      }
      return task;
    }).toList();

    emit(state.copyWith(tasks: updatedList));

    try {
      final updated = await _service.updateTask(event.task);
      final listWithServerItem = state.tasks
          .map((t) => t.id == event.task.id ? updated : t)
          .toList();
      emit(state.copyWith(tasks: listWithServerItem));
    } catch (_) {
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
