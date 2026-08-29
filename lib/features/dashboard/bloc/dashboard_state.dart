import 'package:equatable/equatable.dart';

import '../models/focus_task.dart';

class DashboardState extends Equatable {
  final int selectedTab;
  final List<FocusTask> tasks;

  const DashboardState({this.selectedTab = 0, required this.tasks});

  factory DashboardState.initial() => const DashboardState(
    tasks: [
      FocusTask(
        id: 'weekly-plan',
        title: 'Plan the week ahead',
        detail: 'Today · 10:00 AM',
        category: 'Personal',
      ),
      FocusTask(
        id: 'project-update',
        title: 'Share the project update',
        detail: 'Today · 2:30 PM',
        category: 'Work',
      ),
      FocusTask(
        id: 'design-review',
        title: 'Review dashboard designs',
        detail: 'Tomorrow',
        category: 'ZenFlow',
        isComplete: true,
      ),
    ],
  );

  DashboardState copyWith({int? selectedTab, List<FocusTask>? tasks}) =>
      DashboardState(
        selectedTab: selectedTab ?? this.selectedTab,
        tasks: tasks ?? this.tasks,
      );

  @override
  List<Object?> get props => [selectedTab, tasks];
}
