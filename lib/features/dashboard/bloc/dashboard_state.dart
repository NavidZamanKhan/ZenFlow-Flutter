import 'package:equatable/equatable.dart';

import '../models/focus_task.dart';
import '../models/dashboard_budget.dart';
import '../models/dashboard_event.dart';
import '../models/dashboard_expense.dart';

enum DashboardStatus { initial, loading, success, failure }

class DashboardState extends Equatable {
  final int selectedTab;
  final List<FocusTask> tasks;
  final List<DashboardEventItem> events;
  final List<DashboardExpense> expenses;
  final DashboardBudget budget;
  final DashboardStatus status;
  final String? errorMessage;

  const DashboardState({
    this.selectedTab = 0,
    this.tasks = const [],
    this.events = const [],
    this.expenses = const [],
    this.budget = const DashboardBudget(monthlyTotal: 0, currency: 'BDT'),
    this.status = DashboardStatus.initial,
    this.errorMessage,
  });

  factory DashboardState.initial() => const DashboardState();

  DashboardState copyWith({
    int? selectedTab,
    List<FocusTask>? tasks,
    List<DashboardEventItem>? events,
    List<DashboardExpense>? expenses,
    DashboardBudget? budget,
    DashboardStatus? status,
    String? errorMessage,
  }) => DashboardState(
    selectedTab: selectedTab ?? this.selectedTab,
    tasks: tasks ?? this.tasks,
    events: events ?? this.events,
    expenses: expenses ?? this.expenses,
    budget: budget ?? this.budget,
    status: status ?? this.status,
    errorMessage: errorMessage,
  );

  @override
  List<Object?> get props => [
    selectedTab,
    tasks,
    events,
    expenses,
    budget,
    status,
    errorMessage,
  ];
}
