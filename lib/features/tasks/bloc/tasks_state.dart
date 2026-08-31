import 'package:equatable/equatable.dart';

import '../models/task_filter.dart';
import '../models/task_item.dart';

enum TasksStatus { initial, loading, success, failure }

class TasksState extends Equatable {
  final List<TaskItem> tasks;
  final TasksStatus status;
  final TaskStatusFilter statusFilter;
  final String? selectedCategory;
  final String searchQuery;
  final String? errorMessage;

  const TasksState({
    required this.tasks,
    this.status = TasksStatus.initial,
    this.statusFilter = TaskStatusFilter.all,
    this.selectedCategory,
    this.searchQuery = '',
    this.errorMessage,
  });

  factory TasksState.initial() {
    final now = DateTime.now();
    final year = now.year;
    final month = now.month;

    return TasksState(
      tasks: [
        TaskItem(
          id: '1',
          title: 'Going on a walk',
          description: 'Morning walk routine',
          dueDate: DateTime(year, month, 28),
          dueTime: '4:25 AM',
          priority: TaskPriority.medium,
          category: 'Personal',
          isCompleted: true,
          createdAt: DateTime(year, month, 28, 4, 0),
        ),
        TaskItem(
          id: '2',
          title: 'shouting at the home owner',
          description: 'Discuss apartment maintenance and issues',
          dueDate: DateTime(year, month, 29),
          dueTime: null,
          priority: TaskPriority.high,
          category: 'General',
          isCompleted: false,
          createdAt: DateTime(year, month, 29, 10, 0),
        ),
        TaskItem(
          id: '3',
          title: 'Have to buy pen and notebook',
          description: 'Stationery shopping for work and notes',
          dueDate: DateTime(year, month, 30),
          dueTime: null,
          priority: TaskPriority.medium,
          category: 'Shopping',
          isCompleted: false,
          createdAt: DateTime(year, month, 30, 9, 0),
        ),
        TaskItem(
          id: '4',
          title: 'Going out',
          description: 'Early morning outing',
          dueDate: DateTime(year, month, 30),
          dueTime: '4:30 AM',
          priority: TaskPriority.medium,
          category: 'Personal',
          isCompleted: false,
          createdAt: DateTime(year, month, 30, 4, 0),
        ),
        TaskItem(
          id: '5',
          title: 'Visiting my aunt at the hospital',
          description: 'Hospital visit and checkup',
          dueDate: DateTime(year, month, 31),
          dueTime: null,
          priority: TaskPriority.high,
          category: 'Family',
          isCompleted: true,
          createdAt: DateTime(year, month, 31, 8, 0),
        ),
      ],
      status: TasksStatus.initial,
    );
  }

  List<TaskItem> get filteredTasks {
    return tasks.where((task) {
      // 1. Search Query
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        final matchTitle = task.title.toLowerCase().contains(q);
        final matchDesc = task.description.toLowerCase().contains(q);
        final matchCat = task.category.toLowerCase().contains(q);
        if (!matchTitle && !matchDesc && !matchCat) return false;
      }

      // 2. Category Filter
      if (selectedCategory != null && selectedCategory!.isNotEmpty && selectedCategory != 'All') {
        if (task.category.toLowerCase() != selectedCategory!.toLowerCase()) {
          return false;
        }
      }

      // 3. Status Filter
      switch (statusFilter) {
        case TaskStatusFilter.all:
          return true;
        case TaskStatusFilter.pending:
          return !task.isCompleted;
        case TaskStatusFilter.overdue:
          return task.isOverdue;
        case TaskStatusFilter.completed:
          return task.isCompleted;
      }
    }).toList();
  }

  int get pendingCount => tasks.where((t) => !t.isCompleted).length;

  int get completedCount => tasks.where((t) => t.isCompleted).length;

  List<String> get allCategories {
    final set = <String>{'All'};
    for (final task in tasks) {
      if (task.category.isNotEmpty) {
        set.add(task.category);
      }
    }
    return set.toList();
  }

  TasksState copyWith({
    List<TaskItem>? tasks,
    TasksStatus? status,
    TaskStatusFilter? statusFilter,
    String? selectedCategory,
    bool clearCategory = false,
    String? searchQuery,
    String? errorMessage,
  }) {
    return TasksState(
      tasks: tasks ?? this.tasks,
      status: status ?? this.status,
      statusFilter: statusFilter ?? this.statusFilter,
      selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        tasks,
        status,
        statusFilter,
        selectedCategory,
        searchQuery,
        errorMessage,
      ];
}
