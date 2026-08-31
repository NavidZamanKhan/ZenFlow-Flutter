import 'package:equatable/equatable.dart';

import '../../dashboard/models/dashboard_budget.dart';
import '../../dashboard/models/dashboard_event.dart';
import '../../dashboard/models/dashboard_expense.dart';
import '../../dashboard/models/focus_task.dart';

abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object?> get props => [];
}

class DeriveNotificationsEvent extends NotificationsEvent {
  final List<FocusTask> tasks;
  final List<DashboardEventItem> events;
  final List<DashboardExpense> expenses;
  final DashboardBudget budget;

  const DeriveNotificationsEvent({
    required this.tasks,
    required this.events,
    required this.expenses,
    required this.budget,
  });

  @override
  List<Object?> get props => [tasks, events, expenses, budget];
}

class MarkNotificationAsReadEvent extends NotificationsEvent {
  final String id;

  const MarkNotificationAsReadEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class MarkAllNotificationsAsReadEvent extends NotificationsEvent {
  const MarkAllNotificationsAsReadEvent();
}
