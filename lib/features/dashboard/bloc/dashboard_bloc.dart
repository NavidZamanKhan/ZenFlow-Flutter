import 'package:flutter_bloc/flutter_bloc.dart';

import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc() : super(DashboardState.initial()) {
    on<DashboardTabSelected>((event, emit) {
      emit(state.copyWith(selectedTab: event.index));
    });
    on<DashboardTaskToggled>((event, emit) {
      final tasks = state.tasks
          .map(
            (task) => task.id == event.taskId
                ? task.copyWith(isComplete: !task.isComplete)
                : task,
          )
          .toList(growable: false);
      emit(state.copyWith(tasks: tasks));
    });
  }
}
