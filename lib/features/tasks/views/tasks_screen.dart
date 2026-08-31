import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';
import '../../../core/widgets/zen_card.dart';
import '../bloc/tasks_bloc.dart';
import '../bloc/tasks_event.dart';
import '../bloc/tasks_state.dart';
import '../models/task_filter.dart';
import '../widgets/new_task_bottom_sheet.dart';
import '../widgets/task_detail_bottom_sheet.dart';
import '../widgets/task_list_tile.dart';
import '../widgets/tasks_header.dart';
import '../widgets/tasks_search_filter_bar.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openNewTaskModal(BuildContext context) {
    NewTaskBottomSheet.show(
      context,
      onTaskCreated: (newTask) {
        context.read<TasksBloc>().add(AddTaskEvent(newTask));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).unfocus(),
      child: ColoredBox(
        color: zen.canvas,
        child: SafeArea(
          child: BlocBuilder<TasksBloc, TasksState>(
            builder: (context, state) {
              final tasks = state.filteredTasks;

              return RefreshIndicator(
                color: zen.accent,
                backgroundColor: zen.card,
                onRefresh: () async {
                  context.read<TasksBloc>().add(const LoadTasksEvent());
                  await Future.delayed(const Duration(milliseconds: 650));
                },
                child: ListView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 118),
              children: [
                // Top Header (Title + Count + New Task button)
                TasksHeader(
                  pendingCount: state.pendingCount,
                  onNewTaskPressed: () => _openNewTaskModal(context),
                ),
                const SizedBox(height: 20),

                // Search & Filter Bar
                TasksSearchFilterBar(
                  searchController: _searchController,
                  onSearchChanged: (query) {
                    context.read<TasksBloc>().add(SearchQueryChangedEvent(query));
                  },
                  onClearSearch: () {
                    context.read<TasksBloc>().add(const SearchQueryChangedEvent(''));
                  },
                  selectedStatus: state.statusFilter,
                  onStatusSelected: (status) {
                    context.read<TasksBloc>().add(FilterStatusChangedEvent(status));
                  },
                  categories: state.allCategories,
                  selectedCategory: state.selectedCategory,
                  onCategorySelected: (cat) {
                    context.read<TasksBloc>().add(FilterCategoryChangedEvent(cat));
                  },
                ),
                const SizedBox(height: 20),

                // Tasks Card Container (Website card parity)
                ZenCard(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Card Header
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Row(
                          children: [
                            Icon(LucideIcons.list_todo, size: 18, color: zen.accent),
                            const SizedBox(width: 8),
                            Text(
                              state.statusFilter == TaskStatusFilter.all
                                  ? 'All tasks'
                                  : '${state.statusFilter.name[0].toUpperCase()}${state.statusFilter.name.substring(1)} tasks',
                              style: AppTextStyles.headingSmall(zen.textPrimary),
                            ),
                            const Spacer(),
                            Text(
                              '${tasks.length} ${tasks.length == 1 ? 'item' : 'items'}',
                              style: AppTextStyles.labelSmall(zen.textMuted),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Task List or Empty State
                      if (tasks.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 36),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(LucideIcons.circle_check, size: 36, color: zen.border),
                                const SizedBox(height: 10),
                                Text(
                                  state.searchQuery.isNotEmpty
                                      ? 'No tasks matching "${state.searchQuery}"'
                                      : 'No tasks in this view.',
                                  style: AppTextStyles.bodyMedium(zen.textMuted),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: tasks.length,
                          separatorBuilder: (ctx, idx) => Divider(
                            height: 1,
                            thickness: 0.8,
                            color: zen.border.withValues(alpha: 0.5),
                          ),
                          itemBuilder: (context, index) {
                            final task = tasks[index];
                            return TaskListTile(
                              task: task,
                              onToggle: () {
                                context.read<TasksBloc>().add(ToggleTaskEvent(task.id));
                              },
                              onDelete: () {
                                context.read<TasksBloc>().add(DeleteTaskEvent(task.id));
                              },
                              onTap: () {
                                TaskDetailBottomSheet.show(
                                  context,
                                  task: task,
                                  onToggle: () {
                                    context.read<TasksBloc>().add(ToggleTaskEvent(task.id));
                                  },
                                  onDelete: () {
                                    context.read<TasksBloc>().add(DeleteTaskEvent(task.id));
                                  },
                                );
                              },
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ),
  ),
);
  }
}
