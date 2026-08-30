import 'package:equatable/equatable.dart';

import '../models/task_filter.dart';
import '../models/task_item.dart';

abstract class TasksEvent extends Equatable {
  const TasksEvent();

  @override
  List<Object?> get props => [];
}

class LoadTasksEvent extends TasksEvent {
  const LoadTasksEvent();
}

class AddTaskEvent extends TasksEvent {
  final TaskItem task;

  const AddTaskEvent(this.task);

  @override
  List<Object?> get props => [task];
}

class ToggleTaskEvent extends TasksEvent {
  final String taskId;

  const ToggleTaskEvent(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

class DeleteTaskEvent extends TasksEvent {
  final String taskId;

  const DeleteTaskEvent(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

class UpdateTaskEvent extends TasksEvent {
  final TaskItem task;

  const UpdateTaskEvent(this.task);

  @override
  List<Object?> get props => [task];
}

class FilterStatusChangedEvent extends TasksEvent {
  final TaskStatusFilter statusFilter;

  const FilterStatusChangedEvent(this.statusFilter);

  @override
  List<Object?> get props => [statusFilter];
}

class FilterCategoryChangedEvent extends TasksEvent {
  final String? category; // null means 'All categories'

  const FilterCategoryChangedEvent(this.category);

  @override
  List<Object?> get props => [category];
}

class SearchQueryChangedEvent extends TasksEvent {
  final String query;

  const SearchQueryChangedEvent(this.query);

  @override
  List<Object?> get props => [query];
}
