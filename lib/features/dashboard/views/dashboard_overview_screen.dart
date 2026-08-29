import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/zenflow_theme.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';
import '../../auth/models/user_model.dart';
import '../bloc/dashboard_state.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_summary_cards.dart';
import '../widgets/focus_tasks_card.dart';
import '../widgets/productivity_card.dart';

class DashboardOverviewScreen extends StatelessWidget {
  final DashboardState state;
  const DashboardOverviewScreen({super.key, required this.state});
  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final user = authState is AuthenticatedState
        ? authState.user
        : const UserModel(id: '', email: '', fullName: 'ZenFlow user');
    final remaining = state.tasks.where((task) => !task.isComplete).length;
    final content =
        state.status == DashboardStatus.loading && state.tasks.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 118),
            children: [
              if (state.status == DashboardStatus.failure)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _DashboardError(
                    message:
                        state.errorMessage ?? 'Could not load your dashboard.',
                  ),
                ),
              DashboardHeader(user: user, remainingTasks: remaining),
              const SizedBox(height: 26),
              FocusTasksCard(tasks: state.tasks),
              const SizedBox(height: 14),
              ProductivityCard(tasks: state.tasks),
              const SizedBox(height: 14),
              RemindersCard(events: state.events),
              const SizedBox(height: 14),
              ExpenseSnapshotCard(
                expenses: state.expenses,
                budget: state.budget,
              ),
            ],
          );
    return ColoredBox(
      color: context.zenColors.canvas,
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _refresh(context),
          child: content,
        ),
      ),
    );
  }
}

Future<void> _refresh(BuildContext context) async {
  final bloc = context.read<DashboardBloc>();
  bloc.add(const DashboardLoadRequested());
  await bloc.stream.firstWhere(
    (state) => state.status != DashboardStatus.loading,
  );
}

class _DashboardError extends StatelessWidget {
  final String message;
  const _DashboardError({required this.message});
  @override
  Widget build(BuildContext context) => Text(
    message,
    style: TextStyle(color: Theme.of(context).colorScheme.error),
  );
}
