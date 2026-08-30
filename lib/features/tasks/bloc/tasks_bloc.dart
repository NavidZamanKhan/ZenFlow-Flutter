import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/task_filter.dart';
import '../models/task_item.dart';
import 'tasks_event.dart';
import 'tasks_state.dart';

class TasksBloc extends Bloc<TasksEvent, TasksState> {
  TasksBloc() : super(TasksState.initial()) {
    on<LoadTasksEvent>(_onLoadTasks);
    on<AddTaskEvent>(_onAddTask);
    on<ToggleTaskEvent>(_onToggleTask);
    on<DeleteTaskEvent>(_onDeleteTask);
    on<UpdateTaskEvent>(_onUpdateTask);
    on<FilterStatusChangedEvent>(_onFilterStatusChanged);
    on<FilterCategoryChangedEvent>(_onFilterCategoryChanged);
    on<SearchQueryChangedEvent>(_onSearchQueryChanged);

    // Automatically load initial mock tasks
    add(const LoadTasksEvent());
  }

  void _onLoadTasks(LoadTasksEvent event, Emitter<TasksState> emit) {
    emit(state.copyWith(status: TasksStatus.loading));

    final initialMockTasks = [
      TaskItem(
        id: '1',
        title: 'Visiting my aunt at the hospital',
        description: 'Bring fresh flowers and her medical prescription.',
        dueDate: DateTime.now().add(const Duration(days: 1)),
        dueTime: null,
        priority: TaskPriority.high,
        category: 'Personal',
        isCompleted: false,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      TaskItem(
        id: '2',
        title: 'Going out',
        description: 'Meet with team for weekly coffee catchup.',
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
        dueTime: '4:30 AM',
        priority: TaskPriority.low,
        category: 'Social',
        isCompleted: false,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      TaskItem(
        id: '3',
        title: 'shouting at the home owner',
        description: 'Discuss the plumbing repair invoice reimbursement.',
        dueDate: DateTime.now().subtract(const Duration(days: 2)),
        dueTime: null,
        priority: TaskPriority.high,
        category: 'Home',
        isCompleted: false,
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
      TaskItem(
        id: '4',
        title: 'Have to buy pen and notebook',
        description: 'Get dot grid notebook for UI sketches.',
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
        dueTime: null,
        priority: TaskPriority.medium,
        category: 'Shopping',
        isCompleted: false,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      TaskItem(
        id: '5',
        title: 'Going on a walk with my cat',
        description: 'Evening park loop.',
        dueDate: DateTime.now().subtract(const Duration(days: 3)),
        dueTime: '4:25 AM',
        priority: TaskPriority.high,
        category: 'Personal',
        isCompleted: true,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      TaskItem(
        id: '6',
        title: 'Finalize Q3 roadmap',
        description: 'Align milestones with mobile design system release.',
        dueDate: DateTime.now().add(const Duration(days: 3)),
        dueTime: '2:00 PM',
        priority: TaskPriority.medium,
        category: 'Product',
        isCompleted: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
    ];

    emit(state.copyWith(
      tasks: initialMockTasks,
      status: TasksStatus.success,
    ));
  }

  void _onAddTask(AddTaskEvent event, Emitter<TasksState> emit) {
    final updatedList = [event.task, ...state.tasks];
    emit(state.copyWith(tasks: updatedList));
  }

  void _onToggleTask(ToggleTaskEvent event, Emitter<TasksState> emit) {
    final updatedList = state.tasks.map((task) {
      if (task.id == event.taskId) {
        return task.copyWith(isCompleted: !task.isCompleted);
      }
      return task;
    }).toList();

    emit(state.copyWith(tasks: updatedList));
  }

  void _onDeleteTask(DeleteTaskEvent event, Emitter<TasksState> emit) {
    final updatedList = state.tasks.where((t) => t.id != event.taskId).toList();
    emit(state.copyWith(tasks: updatedList));
  }

  void _onUpdateTask(UpdateTaskEvent event, Emitter<TasksState> emit) {
    final updatedList = state.tasks.map((task) {
      if (task.id == event.task.id) {
        return event.task;
      }
      return task;
    }).toList();

    emit(state.copyWith(tasks: updatedList));
  }

  void _onFilterStatusChanged(FilterStatusChangedEvent event, Emitter<TasksState> emit) {
    emit(state.copyWith(statusFilter: event.statusFilter));
  }

  void _onFilterCategoryChanged(FilterCategoryChangedEvent event, Emitter<TasksState> emit) {
    if (event.category == null || event.category == 'All') {
      emit(state.copyWith(clearCategory: true));
    } else {
      emit(state.copyWith(selectedCategory: event.category));
    }
  }

  void _onSearchQueryChanged(SearchQueryChangedEvent event, Emitter<TasksState> emit) {
    emit(state.copyWith(searchQuery: event.query));
  }
}
