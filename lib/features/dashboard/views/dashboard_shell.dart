import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';
import '../../calendar/bloc/calendar_bloc.dart';
import '../../calendar/views/calendar_screen.dart';
import '../../tasks/bloc/tasks_bloc.dart';
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
      BlocProvider(
        create: (_) => TasksBloc(),
      ),
      BlocProvider(
        create: (_) => CalendarBloc(),
      ),
    ],
    child: const _DashboardShellBody(),
  );
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
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: zen.isDark ? .22 : .07),
              blurRadius: isIos ? 28 : 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: isIos ? 18 : 0,
              sigmaY: isIos ? 18 : 0,
            ),
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: isIos
                    ? zen.card.withValues(alpha: zen.isDark ? .72 : .78)
                    : zen.card,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isIos
                      ? (zen.isDark ? Colors.white : zen.border).withValues(
                          alpha: zen.isDark ? .16 : .82,
                        )
                      : zen.border,
                ),
              ),
              child: SizedBox(
                height: 58,
                child: Stack(
                  children: [
                    IgnorePointer(
                      child: AnimatedAlign(
                        duration: const Duration(milliseconds: 420),
                        curve: Curves.easeOutCubic,
                        alignment: Alignment(
                          -1 +
                              (2 *
                                  selectedIndex /
                                  (_DashboardShellBody._destinations.length -
                                      1)),
                          0,
                        ),
                        child: FractionallySizedBox(
                          widthFactor:
                              1 / _DashboardShellBody._destinations.length,
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
                                  alpha: isIos ? .26 : .18,
                                ),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: zen.accent.withValues(
                                    alpha: isIos ? .14 : .10,
                                  ),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: List.generate(
                        _DashboardShellBody._destinations.length,
                        (index) {
                          final item = _DashboardShellBody._destinations[index];
                          final isSelected = index == selectedIndex;
                          return Expanded(
                            child: InkWell(
                              onTap: () => context.read<DashboardBloc>().add(
                                DashboardTabSelected(index),
                              ),
                              borderRadius: BorderRadius.circular(18),
                              child: AnimatedScale(
                                duration: const Duration(milliseconds: 240),
                                curve: Curves.easeOutBack,
                                scale: isSelected ? 1 : .92,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 180,
                                      ),
                                      child: Icon(
                                        item.icon,
                                        key: ValueKey(isSelected),
                                        size: isSelected ? 20 : 19,
                                        color: isSelected
                                            ? zen.accent
                                            : zen.textMuted,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    AnimatedDefaultTextStyle(
                                      duration: const Duration(
                                        milliseconds: 180,
                                      ),
                                      style: AppTextStyles.labelSmall(
                                        isSelected ? zen.accent : zen.textMuted,
                                      ),
                                      child: Text(item.label),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
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
