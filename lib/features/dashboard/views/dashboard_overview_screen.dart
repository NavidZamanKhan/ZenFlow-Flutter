import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';
import '../../auth/models/user_model.dart';
import '../../expenses/bloc/expenses_bloc.dart';
import '../../expenses/bloc/expenses_event.dart';
import '../../profile/bloc/profile_bloc.dart';
import '../../profile/bloc/profile_event.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
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
    final zen = context.zenColors;
    final authState = context.watch<AuthBloc>().state;
    final user = authState is AuthenticatedState
        ? authState.user
        : const UserModel(id: '', email: '', fullName: 'ZenFlow user');

    final remaining = state.tasks.where((task) => !task.isComplete).length;

    final content = state.status == DashboardStatus.loading && state.tasks.isEmpty
        ? Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(zen.accent),
            ),
          )
        : ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 118),
            children: [
              if (state.status == DashboardStatus.failure && state.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(LucideIcons.circle_alert, size: 16, color: AppColors.danger),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            state.errorMessage!,
                            style: AppTextStyles.labelSmall(AppColors.danger),
                          ),
                        ),
                      ],
                    ),
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
                activeCurrency: context.select<ProfileBloc, String>(
                  (b) => b.state.profile.currency,
                ),
              ),
            ],
          );

    return ColoredBox(
      color: zen.canvas,
      child: SafeArea(
        child: RefreshIndicator(
          color: zen.accent,
          backgroundColor: zen.card,
          onRefresh: () => _refresh(context),
          child: content,
        ),
      ),
    );
  }

  Future<void> _refresh(BuildContext context) async {
    final bloc = context.read<DashboardBloc>();
    bloc.add(const DashboardLoadRequested());
    context.read<ProfileBloc>().add(const LoadProfileEvent());
    context.read<ExpensesBloc>().add(FetchExpenses());
    await bloc.stream.firstWhere(
      (state) => state.status != DashboardStatus.loading,
    );
  }
}
