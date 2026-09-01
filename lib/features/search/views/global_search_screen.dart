import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';
import '../../../core/widgets/zen_badge.dart';
import '../../../core/widgets/zen_card.dart';
import '../../../core/widgets/zen_icon_button.dart';
import '../../calendar/bloc/calendar_bloc.dart';
import '../../calendar/models/calendar_item.dart';
import '../../dashboard/bloc/dashboard_bloc.dart';
import '../../dashboard/bloc/dashboard_event.dart';
import '../../expenses/bloc/expenses_bloc.dart';
import '../../expenses/models/expense_item.dart';
import '../../profile/bloc/profile_bloc.dart';
import '../../profile/views/profile_screen.dart';
import '../../tasks/bloc/tasks_bloc.dart';
import '../../tasks/bloc/tasks_event.dart' show ToggleTaskEvent, DeleteTaskEvent;
import '../../tasks/models/task_filter.dart';
import '../../tasks/models/task_item.dart';
import '../../tasks/widgets/task_detail_bottom_sheet.dart';
import '../bloc/search_bloc.dart';
import '../bloc/search_event.dart';
import '../bloc/search_state.dart';
import '../models/search_result_item.dart';
import '../services/search_service.dart';

class GlobalSearchScreen extends StatefulWidget {
  const GlobalSearchScreen({super.key});

  static Future<void> show(BuildContext context) {
    final tasksBloc = context.read<TasksBloc>();
    final expensesBloc = context.read<ExpensesBloc>();
    final calendarBloc = context.read<CalendarBloc>();
    final dashboardBloc = context.read<DashboardBloc>();
    final profileBloc = context.read<ProfileBloc>();

    final tasks = tasksBloc.state.tasks.isNotEmpty
        ? tasksBloc.state.tasks
        : dashboardBloc.state.tasks
            .map(
              (f) => TaskItem(
                id: f.id,
                title: f.title,
                priority: TaskPriority.values.firstWhere(
                  (p) => p.name.toLowerCase() == f.priority.toLowerCase(),
                  orElse: () => TaskPriority.medium,
                ),
                isCompleted: f.isComplete,
                category: f.category,
                createdAt: DateTime.now(),
              ),
            )
            .toList();
    final expenses = expensesBloc.state.expenses;
    final events = calendarBloc.state.items;
    final currency = profileBloc.state.profile.currency;

    return Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (ctx, anim, secAnim) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: tasksBloc),
            BlocProvider.value(value: expensesBloc),
            BlocProvider.value(value: calendarBloc),
            BlocProvider.value(value: dashboardBloc),
            BlocProvider.value(value: profileBloc),
            BlocProvider(
              create: (_) => SearchBloc()
                ..add(
                  UpdateSearchSourcesEvent(
                    tasks: tasks,
                    expenses: expenses,
                    events: events,
                    activeCurrency: currency,
                  ),
                ),
            ),
          ],
          child: const GlobalSearchScreen(),
        ),
        transitionsBuilder: (ctx, anim, secAnim, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
            child: child,
          );
        },
      ),
    );
  }

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleResultTap(BuildContext context, SearchResultItem item) {
    HapticFeedback.lightImpact();
    Navigator.of(context).pop();

    if (item.type == SearchResultType.page && item.rawData is StaticDestination) {
      final dest = item.rawData as StaticDestination;
      if (dest.tabIndex >= 0) {
        context.read<DashboardBloc>().add(DashboardTabSelected(dest.tabIndex));
      } else if (dest.routeName == 'profile') {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ProfileScreen(initialTab: 0)),
        );
      } else if (dest.routeName == 'appearance' || dest.routeName == 'expense_prefs') {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ProfileScreen(initialTab: 1)),
        );
      }
    } else if (item.type == SearchResultType.task && item.rawData is TaskItem) {
      final task = item.rawData as TaskItem;
      context.read<DashboardBloc>().add(const DashboardTabSelected(1)); // Tasks tab
      Future.delayed(const Duration(milliseconds: 200), () {
        if (context.mounted) {
          TaskDetailBottomSheet.show(
            context,
            task: task,
            onToggle: () =>
                context.read<TasksBloc>().add(ToggleTaskEvent(task.id)),
            onDelete: () =>
                context.read<TasksBloc>().add(DeleteTaskEvent(task.id)),
          );
        }
      });
    } else if (item.type == SearchResultType.expense && item.rawData is ExpenseItem) {
      context.read<DashboardBloc>().add(const DashboardTabSelected(3)); // Expenses tab
    } else if (item.type == SearchResultType.event && item.rawData is CalendarItem) {
      context.read<DashboardBloc>().add(const DashboardTabSelected(2)); // Calendar tab
    }
  }

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;

    return Scaffold(
      backgroundColor: zen.canvas,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar with Input Field
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  ZenIconButton(
                    icon: LucideIcons.arrow_left,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: zen.card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: zen.border),
                      ),
                      child: TextField(
                        controller: _searchController,
                        focusNode: _focusNode,
                        style: AppTextStyles.bodyMedium(zen.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Search tasks, expenses, events...',
                          hintStyle: AppTextStyles.bodyMedium(zen.textMuted),
                          prefixIcon: Icon(
                            LucideIcons.search,
                            size: 18,
                            color: zen.textMuted,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? GestureDetector(
                                  onTap: () {
                                    _searchController.clear();
                                    context.read<SearchBloc>().add(const ClearSearchEvent());
                                    setState(() {});
                                  },
                                  child: Icon(
                                    LucideIcons.x,
                                    size: 16,
                                    color: zen.textMuted,
                                  ),
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onChanged: (val) {
                          context.read<SearchBloc>().add(SearchQueryChangedEvent(val));
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Horizontal Filter Chips Bar
            BlocBuilder<SearchBloc, SearchState>(
              builder: (context, state) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'All',
                        icon: LucideIcons.layers,
                        isSelected: state.filter == SearchFilter.all,
                        onTap: () => context
                            .read<SearchBloc>()
                            .add(const SearchFilterChangedEvent(SearchFilter.all)),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Tasks',
                        icon: LucideIcons.list_todo,
                        isSelected: state.filter == SearchFilter.tasks,
                        onTap: () => context
                            .read<SearchBloc>()
                            .add(const SearchFilterChangedEvent(SearchFilter.tasks)),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Expenses',
                        icon: LucideIcons.credit_card,
                        isSelected: state.filter == SearchFilter.expenses,
                        onTap: () => context
                            .read<SearchBloc>()
                            .add(const SearchFilterChangedEvent(SearchFilter.expenses)),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Calendar',
                        icon: LucideIcons.calendar_days,
                        isSelected: state.filter == SearchFilter.events,
                        onTap: () => context
                            .read<SearchBloc>()
                            .add(const SearchFilterChangedEvent(SearchFilter.events)),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Pages',
                        icon: LucideIcons.compass,
                        isSelected: state.filter == SearchFilter.pages,
                        onTap: () => context
                            .read<SearchBloc>()
                            .add(const SearchFilterChangedEvent(SearchFilter.pages)),
                      ),
                    ],
                  ),
                );
              },
            ),

            const Divider(height: 1, thickness: 0.5),

            // Search Results List
            Expanded(
              child: BlocBuilder<SearchBloc, SearchState>(
                builder: (context, state) {
                  if (state.results.isEmpty && state.query.isNotEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: zen.subtleFill,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                LucideIcons.search_x,
                                size: 28,
                                color: zen.textMuted,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No matches found',
                              style: AppTextStyles.headingSmall(zen.textPrimary),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'We couldn\'t find anything matching "${state.query}". Try a different keyword.',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodySmall(zen.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                    physics: const BouncingScrollPhysics(),
                    itemCount: state.results.length,
                    separatorBuilder: (_, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = state.results[index];
                      return _SearchResultTile(
                        item: item,
                        onTap: () => _handleResultTap(context, item),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? zen.accent : zen.card,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isSelected ? zen.accent : zen.border,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.white : zen.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.labelSmall(
                isSelected ? Colors.white : zen.textSecondary,
              ).copyWith(fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  final SearchResultItem item;
  final VoidCallback onTap;

  const _SearchResultTile({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;

    Color iconBg;
    Color iconColor;
    switch (item.type) {
      case SearchResultType.page:
        iconBg = zen.accent.withValues(alpha: 0.12);
        iconColor = zen.accent;
        break;
      case SearchResultType.task:
        iconBg = const Color(0xFF3B82F6).withValues(alpha: 0.12);
        iconColor = const Color(0xFF3B82F6);
        break;
      case SearchResultType.expense:
        iconBg = const Color(0xFF10B981).withValues(alpha: 0.12);
        iconColor = const Color(0xFF10B981);
        break;
      case SearchResultType.event:
        iconBg = const Color(0xFFF59E0B).withValues(alpha: 0.12);
        iconColor = const Color(0xFFF59E0B);
        break;
    }

    return ZenCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              item.icon,
              size: 18,
              color: item.color ?? iconColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: AppTextStyles.labelLarge(zen.textPrimary).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  item.subtitle,
                  style: AppTextStyles.labelSmall(zen.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (item.badge != null) ...[
            const SizedBox(width: 8),
            ZenBadge(
              label: item.badge!,
              color: item.type == SearchResultType.expense
                  ? AppColors.success
                  : zen.accent,
              showDot: false,
            ),
          ],
          const SizedBox(width: 6),
          Icon(
            LucideIcons.chevron_right,
            size: 16,
            color: zen.textMuted,
          ),
        ],
      ),
    );
  }
}
