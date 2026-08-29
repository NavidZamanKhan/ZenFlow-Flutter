import 'package:equatable/equatable.dart';

sealed class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class DashboardTabSelected extends DashboardEvent {
  final int index;

  const DashboardTabSelected(this.index);

  @override
  List<Object?> get props => [index];
}

class DashboardTaskToggled extends DashboardEvent {
  final String taskId;

  const DashboardTaskToggled(this.taskId);

  @override
  List<Object?> get props => [taskId];
}
