import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';
import '../../calendar/bloc/calendar_bloc.dart';
import '../../calendar/bloc/calendar_event.dart';
import '../../calendar/views/calendar_screen.dart';
import '../../expenses/bloc/expenses_bloc.dart';
import '../../expenses/bloc/expenses_event.dart';
import '../../expenses/views/expenses_screen.dart';
import '../../insights/bloc/insights_bloc.dart';
import '../../insights/views/insights_screen.dart';
import '../../profile/bloc/profile_bloc.dart';
import '../../profile/bloc/profile_event.dart';
import '../../tasks/bloc/tasks_bloc.dart';
import '../../tasks/bloc/tasks_event.dart';
import '../../tasks/views/tasks_screen.dart';
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
      BlocProvider(create: (_) => TasksBloc()),
      BlocProvider(create: (_) => CalendarBloc()),
      BlocProvider(
        create: (_) => ExpensesBloc()..add(const FetchExpenses()),
      ),
      BlocProvider(create: (_) => InsightsBloc()),
      BlocProvider(create: (_) => ProfileBloc()..add(const LoadProfileEvent())),
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
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) => current is AuthenticatedState,
      listener: (context, state) {
        // When user logs in or switches accounts, trigger fresh live cloud sync across all features
        context.read<DashboardBloc>().add(const DashboardLoadRequested());
        context.read<TasksBloc>().add(const LoadTasksEvent());
        context.read<CalendarBloc>().add(const LoadCalendarEvent());
        context.read<ExpensesBloc>().add(const FetchExpenses());
        context.read<ProfileBloc>().add(const LoadProfileEvent());
      },
      child: child,
    );
  }
}

class _DashboardShellBody extends StatelessWidget {
  const _DashboardShellBody();
  static const _destinations = [
    (label: 'Overview', icon: LucideIcons.layout_dashboard),
    (label: 'Tasks', icon: LucideIcons.list_todo),
    (label: 'Calendar', icon: LucideIcons.calendar_days),
    (label: 'Expenses', icon: LucideIcons.credit_card),
    (label: 'Insights', icon: LucideIcons.chart_no_axes_combined),
  ];

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
    if (state.selectedTab == 0) return DashboardOverviewScreen(state: state);
    if (state.selectedTab == 1) return const TasksScreen();
    if (state.selectedTab == 2) return const CalendarScreen();
    if (state.selectedTab == 3) return const ExpensesScreen();
    if (state.selectedTab == 4) return const InsightsScreen();
    final item = _destinations[state.selectedTab];
    return DashboardPlaceholder(title: item.label, icon: item.icon);
  }
}

class _ZenBottomNavigation extends StatelessWidget {
  final int selectedIndex;
  const _ZenBottomNavigation({required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;
    final isIos = defaultTargetPlatform == TargetPlatform.iOS;
    final totalTabs = _DashboardShellBody._destinations.length;

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
                            _DashboardShellBody._destinations[index];
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
