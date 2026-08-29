import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/zenflow_theme.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';
import '../../auth/models/user_model.dart';
import '../bloc/dashboard_state.dart';
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
    return ColoredBox(
      color: context.zenColors.canvas,
      child: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 118),
          children: [
            DashboardHeader(user: user, remainingTasks: remaining),
            const SizedBox(height: 26),
            FocusTasksCard(tasks: state.tasks),
            const SizedBox(height: 14),
            const ProductivityCard(),
            const SizedBox(height: 14),
            const RemindersCard(),
            const SizedBox(height: 14),
            const ExpenseSnapshotCard(),
          ],
        ),
      ),
    );
  }
}
