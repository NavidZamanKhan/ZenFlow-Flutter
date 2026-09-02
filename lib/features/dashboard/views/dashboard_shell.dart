import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
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
      context.read<ExpensesBloc>().add(const FetchExpenses());
    }
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            extendBody: true,
            body: _buildFadedBody(context, state),
            bottomNavigationBar: _ZenBottomNavigation(
              selectedIndex: state.selectedTab,
            ),
          ),
        ),
      );

  Widget _buildFadedBody(BuildContext context, DashboardState state) {
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.padding.bottom;
    final screenHeight = mediaQuery.size.height;

    if (screenHeight <= 0) return _bodyFor(context, state);

    // Floating bar geometry: height = 58, margin = 14 + bottomInset
    // Top of bar is (58 + 14 + bottomInset) from bottom
    // Midpoint of bar is (28 + 14 + bottomInset) from bottom
    final pillTop = (screenHeight - (58 + 14 + bottomInset)) / screenHeight;
    final pillMid = (screenHeight - (28 + 14 + bottomInset)) / screenHeight;

    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [
            0.0,
            pillTop.clamp(0.0, 1.0),
            pillMid.clamp(0.0, 1.0),
            1.0,
          ],
          colors: const [
            Colors.black,
            Colors.black,
            Colors.transparent,
            Colors.transparent,
          ],
        ).createShader(bounds);
      },
      blendMode: BlendMode.dstIn,
      child: _bodyFor(context, state),
    );
  }

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
    final isIos = defaultTargetPlatform == TargetPlatform.iOS;
    final totalTabs = _DashboardShellBody.destinations.length;

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: zen.isDark ? .24 : .08),
              blurRadius: isIos ? 28 : 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: zen.isDark
                    ? zen.card.withValues(alpha: .85)
                    : Colors.white.withValues(alpha: .88),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: zen.border.withValues(alpha: zen.isDark ? .4 : .8),
                  width: 1,
                ),
              ),
              child: SizedBox(
                height: 58,
                child: Stack(
                  children: [
                    // Continuous Silky Smooth Sliding Background Pill
                    IgnorePointer(
                      child: AnimatedAlign(
                        duration: const Duration(milliseconds: 360),
                        curve: Curves.easeOutCubic,
                        alignment: Alignment(
                          -1.0 + (2.0 * selectedIndex / (totalTabs - 1)),
                          0,
                        ),
                        child: FractionallySizedBox(
                          widthFactor: 1 / totalTabs,
                          heightFactor: 1,
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: zen.isDark
                                  ? zen.accent.withValues(alpha: .22)
                                  : zen.accentSoft,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: zen.accent.withValues(
                                  alpha: isIos ? .28 : .18,
                                ),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: zen.accent.withValues(
                                    alpha: isIos ? .16 : .10,
                                  ),
                                  blurRadius: 12,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Interactive Tab Buttons Layer
                    Row(
                      children: List.generate(totalTabs, (index) {
                        final destination =
                            _DashboardShellBody.destinations[index];
                        final isSelected = selectedIndex == index;

                        return Expanded(
                          child: InkWell(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              context.read<DashboardBloc>().add(
                                    DashboardTabSelected(index),
                                  );
                            },
                            borderRadius: BorderRadius.circular(18),
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AnimatedScale(
                                  duration: const Duration(milliseconds: 240),
                                  curve: Curves.easeOutBack,
                                  scale: isSelected ? 1.08 : 0.92,
                                  child: Icon(
                                    destination.icon,
                                    size: isSelected ? 20 : 19,
                                    color: isSelected
                                        ? zen.accent
                                        : zen.textMuted,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 200),
                                  style: AppTextStyles.labelSmall(
                                    isSelected ? zen.accent : zen.textMuted,
                                  ).copyWith(
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    fontSize: 10.5,
                                  ),
                                  child: Text(
                                    destination.label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
