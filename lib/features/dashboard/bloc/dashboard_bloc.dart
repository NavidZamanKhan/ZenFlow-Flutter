import 'package:flutter_bloc/flutter_bloc.dart';

import 'dashboard_event.dart';
import 'dashboard_state.dart';
import '../repositories/dashboard_repository.dart';
import '../models/focus_task.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository _repository;

  DashboardBloc({DashboardRepository? repository})
    : _repository = repository ?? DashboardRepository(),
      super(DashboardState.initial()) {
    on<DashboardTabSelected>((event, emit) {
      emit(state.copyWith(selectedTab: event.index));
    });
    on<DashboardLoadRequested>(_loadDashboard);
    on<DashboardTaskToggled>(_toggleTask);
  }

  Future<void> _loadDashboard(
    DashboardLoadRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(status: DashboardStatus.loading));
    try {
      final snapshot = await _repository.load();
      emit(
        state.copyWith(
          tasks: snapshot.tasks,
          events: snapshot.events,
          expenses: snapshot.expenses,
          budget: snapshot.budget,
          status: DashboardStatus.success,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: DashboardStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _toggleTask(
    DashboardTaskToggled event,
    Emitter<DashboardState> emit,
  ) async {
    final task = state.tasks
        .where((item) => item.id == event.taskId)
        .firstOrNull;
    if (task == null) return;
    final optimistic = task.copyWith(isComplete: !task.isComplete);
    emit(state.copyWith(tasks: _replaceTask(optimistic)));
    try {
      final updated = await _repository.toggleTask(task);
      emit(state.copyWith(tasks: _replaceTask(updated)));
    } catch (error) {
      emit(
        state.copyWith(
          tasks: _replaceTask(task),
          errorMessage: error.toString(),
        ),
      );
    }
  }

  List<FocusTask> _replaceTask(FocusTask replacement) => state.tasks
      .map((task) => task.id == replacement.id ? replacement : task)
      .toList(growable: false);
}
