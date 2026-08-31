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
    return TasksState(
      tasks: [
        TaskItem(
          id: '1',
          title: 'Finish ZenFlow Flutter App Design',
          description: 'Audit mobile UI components, tokens, and 120 FPS animations',
          dueDate: DateTime(now.year, now.month, now.day),
          dueTime: '5:00 PM',
          priority: TaskPriority.high,
          category: 'Work',
          isCompleted: false,
          createdAt: now,
        ),
        TaskItem(
          id: '2',
          title: 'Quarterly Roadmap Planning',
          description: 'Finalize Q4 milestones and engineering scope with team',
          dueDate: DateTime(now.year, now.month, now.day),
          dueTime: '6:30 PM',
          priority: TaskPriority.high,
          category: 'Planning',
          isCompleted: false,
          createdAt: now,
        ),
        TaskItem(
          id: '3',
          title: 'Review Monthly Budget & Spending',
          description: 'Track category spending and adjust threshold warnings',
          dueDate: DateTime(now.year, now.month, now.day),
          dueTime: '8:00 PM',
          priority: TaskPriority.medium,
          category: 'Finance',
          isCompleted: true,
          createdAt: now,
        ),
        TaskItem(
          id: '4',
          title: 'Team Sync & Sprint Retro',
          description: 'Review previous sprint velocity and action items',
          dueDate: DateTime(now.year, now.month, now.day),
          dueTime: '10:00 AM',
          priority: TaskPriority.medium,
          category: 'Meetings',
          isCompleted: true,
          createdAt: now,
        ),
        TaskItem(
          id: '5',
          title: 'Client Architecture Walkthrough',
          description: 'Demo mobile live sync with Django REST backend',
          dueDate: DateTime(now.year, now.month, now.day),
          dueTime: '2:00 PM',
          priority: TaskPriority.low,
          category: 'Work',
          isCompleted: false,
          createdAt: now,
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
