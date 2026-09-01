import 'package:equatable/equatable.dart';

import '../../calendar/models/calendar_item.dart';
import '../../expenses/models/expense_item.dart';
import '../../tasks/models/task_item.dart';
import '../models/search_result_item.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchQueryChangedEvent extends SearchEvent {
  final String query;

  const SearchQueryChangedEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class SearchFilterChangedEvent extends SearchEvent {
  final SearchFilter filter;

  const SearchFilterChangedEvent(this.filter);

  @override
  List<Object?> get props => [filter];
}

class ClearSearchEvent extends SearchEvent {
  const ClearSearchEvent();
}

class UpdateSearchSourcesEvent extends SearchEvent {
  final List<TaskItem> tasks;
  final List<ExpenseItem> expenses;
  final List<CalendarItem> events;
  final String activeCurrency;

  const UpdateSearchSourcesEvent({
    required this.tasks,
    required this.expenses,
    required this.events,
    required this.activeCurrency,
  });

  @override
  List<Object?> get props => [tasks, expenses, events, activeCurrency];
}
