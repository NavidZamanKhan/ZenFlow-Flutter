import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../core/services/notification_service.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';
import '../../../core/widgets/notification_permission_sheet.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';
import '../../calendar/bloc/calendar_bloc.dart';
import '../../calendar/bloc/calendar_event.dart';
import '../../calendar/views/calendar_screen.dart';
import '../../expenses/bloc/expenses_bloc.dart';
import '../../expenses/bloc/expenses_event.dart';
import '../../expenses/bloc/expenses_state.dart';
import '../../expenses/views/expenses_screen.dart';
import '../../insights/bloc/insights_bloc.dart';
import '../../insights/bloc/insights_event.dart';
import '../../insights/views/insights_screen.dart';
import '../../notifications/bloc/notifications_bloc.dart';
import '../../notifications/bloc/notifications_event.dart';
import '../../profile/bloc/profile_bloc.dart';
import '../../profile/bloc/profile_event.dart';
import '../../profile/bloc/profile_state.dart';
import '../../tasks/bloc/tasks_bloc.dart';
import '../../tasks/bloc/tasks_event.dart';
import '../../tasks/views/tasks_screen.dart';
import '../../tasks/widgets/task_detail_bottom_sheet.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/dashboard_placeholder.dart';
import 'dashboard_overview_screen.dart';

class DashboardShell extends StatelessWidget {
  const DashboardShell({super.key});

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (_) => DashboardBloc()..add(const DashboardLoadRequested()),
      ),
      BlocProvider(
        create: (_) => TasksBloc()..add(const LoadTasksEvent()),
      ),
      BlocProvider(
        create: (_) => CalendarBloc()..add(const LoadCalendarEvent()),
      ),
      BlocProvider(
        create: (_) => ExpensesBloc()..add(const FetchExpenses()),
      ),
      BlocProvider(create: (_) => InsightsBloc()),
      BlocProvider(create: (_) => NotificationsBloc()),
    ],
    child: const _DashboardAuthSyncListener(
      child: _DashboardShellBody(),
    ),
  );
}

class _DashboardAuthSyncListener extends StatelessWidget {
  final Widget child;

  const _DashboardAuthSyncListener({required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listenWhen: (previous, current) => current is AuthenticatedState,
          listener: (context, state) {
            // When user logs in or switches accounts, trigger fresh live cloud sync across all features
            context.read<DashboardBloc>().add(const DashboardLoadRequested());
            context.read<TasksBloc>().add(const LoadTasksEvent());
            context.read<CalendarBloc>().add(const LoadCalendarEvent());
            context.read<ExpensesBloc>().add(const FetchExpenses());
            context.read<ProfileBloc>().add(const LoadProfileEvent());
          },
        ),
        BlocListener<DashboardBloc, DashboardState>(
          listenWhen: (previous, current) =>
              current.status == DashboardStatus.success ||
              (current.tasks.isNotEmpty && previous.tasks != current.tasks),
          listener: (context, state) {
            // Dynamically derive alerts whenever dashboard data updates
            context.read<NotificationsBloc>().add(
                  DeriveNotificationsEvent(
                    tasks: state.tasks,
                    events: state.events,
                    expenses: state.expenses,
                    budget: state.budget,
                  ),
                );

            // Schedule Daily Morning Digest with latest tasks & events
            final tasks = context.read<TasksBloc>().state.tasks;
            final events = context.read<CalendarBloc>().state.items;
            NotificationService().scheduleDailyMorningDigest(
              todayTasks: tasks,
              todayEvents: events,
            );
          },
        ),
        BlocListener<ProfileBloc, ProfileState>(
          listenWhen: (previous, current) =>
              previous.profile.currency != current.profile.currency,
          listener: (context, state) {
            // When user changes currency in Settings or Profile, sync Insights, Expenses, and Dashboard immediately
            final newCur = state.profile.currency;
            context.read<InsightsBloc>().add(
                  RefreshInsightsEvent(activeCurrency: newCur),
                );
            context.read<ExpensesBloc>().add(const FetchExpenses());
            context.read<DashboardBloc>().add(const DashboardLoadRequested());
          },
        ),
        BlocListener<ExpensesBloc, ExpensesState>(
          listenWhen: (previous, current) =>
              previous.expenses != current.expenses ||
              previous.monthlyTotalBudget != current.monthlyTotalBudget,
          listener: (context, state) {
            // When expenses or budget change, update Insights in real-time
            final activeCur = context.read<ProfileBloc>().state.profile.currency;
            context.read<InsightsBloc>().add(
                  RefreshInsightsEvent(activeCurrency: activeCur),
                );
          },
        ),
      ],
      child: child,
    );
  }
}

class _DashboardShellBody extends StatefulWidget {
  const _DashboardShellBody();

  static const destinations = [
    (label: 'Overview', icon: LucideIcons.layout_dashboard),
    (label: 'Tasks', icon: LucideIcons.list_todo),
    (label: 'Calendar', icon: LucideIcons.calendar_days),
    (label: 'Expenses', icon: LucideIcons.credit_card),
    (label: 'Insights', icon: LucideIcons.chart_no_axes_combined),
  ];

  @override
  State<_DashboardShellBody> createState() => _DashboardShellBodyState();
}

class _DashboardShellBodyState extends State<_DashboardShellBody>
    with WidgetsBindingObserver {
  StreamSubscription<String?>? _notificationTapSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // 1. Subscribe to Notification Tap Stream for smart deep-linking
    _notificationTapSub =
        NotificationService().onNotificationTap.listen(_handleNotificationTap);

    // 2. Show contextual soft permission primer if never prompted before
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          NotificationPermissionSheet.showIfNeeded(context);
        }
      });
    });
  }

  @override
  void dispose() {
    _notificationTapSub?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _handleNotificationTap(String? payload) {
    if (payload == null || !mounted) return;

    if (payload.startsWith('task:')) {
      final taskId = payload.replaceFirst('task:', '');
      context.read<DashboardBloc>().add(const DashboardTabSelected(1));
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          final tasks = context.read<TasksBloc>().state.tasks;
          final task = tasks.where((t) => t.id == taskId).firstOrNull;
          if (task != null) {
            TaskDetailBottomSheet.show(
              context,
              task: task,
              onToggle: () =>
                  context.read<TasksBloc>().add(ToggleTaskEvent(task.id)),
              onDelete: () =>
                  context.read<TasksBloc>().add(DeleteTaskEvent(task.id)),
            );
          }
        }
      });
    } else if (payload.startsWith('event:')) {
      context.read<DashboardBloc>().add(const DashboardTabSelected(2));
    } else if (payload.startsWith('budget:')) {
      context.read<DashboardBloc>().add(const DashboardTabSelected(3));
    } else if (payload.startsWith('digest:')) {
      context.read<DashboardBloc>().add(const DashboardTabSelected(0));
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<ProfileBloc>().add(const LoadProfileEvent());
      context.read<ExpensesBloc>().add(FetchExpenses());
    }
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            body: _bodyFor(context, state),
            bottomNavigationBar: _ZenBottomNavigation(
              selectedIndex: state.selectedTab,
            ),
          ),
        ),
      );

  Widget _bodyFor(BuildContext context, DashboardState state) {
    if (state.selectedTab == 0) {
      return DashboardOverviewScreen(
        key: const ValueKey('overview_tab_screen'),
        state: state,
      );
    }
    if (state.selectedTab == 1) {
      return const TasksScreen(key: ValueKey('tasks_tab_screen'));
    }
    if (state.selectedTab == 2) {
      return const CalendarScreen(key: ValueKey('calendar_tab_screen'));
    }
    if (state.selectedTab == 3) {
      return const ExpensesScreen(key: ValueKey('expenses_tab_screen'));
    }
    if (state.selectedTab == 4) {
      return const InsightsScreen(key: ValueKey('insights_tab_screen'));
    }
    return const DashboardPlaceholder(
      title: 'Overview',
      icon: LucideIcons.layout_dashboard,
    );
  }
}

class _ZenBottomNavigation extends StatelessWidget {
  final int selectedIndex;

  const _ZenBottomNavigation({required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;

    return Container(
      decoration: BoxDecoration(
        color: zen.canvas.withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(
            color: zen.border.withValues(alpha: 0.6),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              _DashboardShellBody.destinations.length,
              (index) {
                final item = _DashboardShellBody.destinations[index];
                final isSelected = index == selectedIndex;

                return _NavItem(
                  icon: item.icon,
                  label: item.label,
                  isSelected: isSelected,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context
                        .read<DashboardBloc>()
                        .add(DashboardTabSelected(index));
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? zen.accent.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? zen.accent : zen.textMuted,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.labelSmall(
                isSelected ? zen.accent : zen.textMuted,
              ).copyWith(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 10.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
