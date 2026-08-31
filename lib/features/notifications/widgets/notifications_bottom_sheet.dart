import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';
import '../../dashboard/bloc/dashboard_bloc.dart';
import '../../dashboard/bloc/dashboard_event.dart';
import '../../tasks/bloc/tasks_bloc.dart';
import '../../tasks/bloc/tasks_event.dart';
import '../../tasks/widgets/task_detail_bottom_sheet.dart';
import '../bloc/notifications_bloc.dart';
import '../bloc/notifications_event.dart';
import '../bloc/notifications_state.dart';
import '../models/app_notification.dart';

class NotificationsBottomSheet extends StatelessWidget {
  const NotificationsBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    HapticFeedback.mediumImpact();
    final notifBloc = context.read<NotificationsBloc>();
    final tasksBloc = context.read<TasksBloc>();
    final dashBloc = context.read<DashboardBloc>();

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: notifBloc),
          BlocProvider.value(value: tasksBloc),
          BlocProvider.value(value: dashBloc),
        ],
        child: const NotificationsBottomSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.78,
      ),
      decoration: BoxDecoration(
        color: zen.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: zen.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: BlocBuilder<NotificationsBloc, NotificationsState>(
          builder: (context, state) {
            final notifications = state.notifications;
            final unreadCount = state.unreadCount;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Drag Handle
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 8),
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: zen.border,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                // Header
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      Text(
                        'Notifications',
                        style: AppTextStyles.headingSmall(zen.textPrimary),
                      ),
                      const SizedBox(width: 8),
                      if (unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: AppColors.danger.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            '$unreadCount unread',
                            style: AppTextStyles.labelSmall(AppColors.danger)
                                .copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      const Spacer(),
                      if (unreadCount > 0)
                        TextButton.icon(
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            context.read<NotificationsBloc>().add(
                                  const MarkAllNotificationsAsReadEvent(),
                                );
                          },
                          icon: Icon(
                            LucideIcons.check_check,
                            size: 15,
                            color: zen.accent,
                          ),
                          label: Text(
                            'Mark all read',
                            style: AppTextStyles.labelSmall(zen.accent)
                                .copyWith(fontWeight: FontWeight.w600),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                          ),
                        ),
                    ],
                  ),
                ),
                Divider(color: zen.border.withValues(alpha: 0.6), height: 1),

                // Notification List or Empty State
                Flexible(
                  child: notifications.isEmpty
                      ? _buildEmptyState(context, zen)
                      : ListView.separated(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          itemCount: notifications.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 6),
                          itemBuilder: (context, index) {
                            final item = notifications[index];
                            return _NotificationTile(notification: item);
                          },
                        ),
                ),

                if (unreadCount > 0) ...[
                  Divider(
                      color: zen.border.withValues(alpha: 0.6), height: 1),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                    child: SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          context.read<NotificationsBloc>().add(
                                const MarkAllNotificationsAsReadEvent(),
                              );
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: zen.accent.withValues(alpha: 0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'Mark all as read',
                          style: AppTextStyles.labelMedium(zen.accent).copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ZenColors zen) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: zen.accent.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.bell,
                size: 24,
                color: zen.accent,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'You\'re all caught up',
              style: AppTextStyles.headingSmall(zen.textPrimary),
            ),
            const SizedBox(height: 5),
            Text(
              'New task deadlines, calendar reminders, and budget alerts will appear here.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall(zen.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;

  const _NotificationTile({required this.notification});

  String _formatRelativeTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(dt);
  }

  IconData get _icon {
    switch (notification.type) {
      case NotificationType.task:
        return LucideIcons.list_todo;
      case NotificationType.reminder:
        return LucideIcons.calendar_days;
      case NotificationType.budget:
        return LucideIcons.wallet;
    }
  }

  Color get _iconColor {
    switch (notification.type) {
      case NotificationType.task:
        return const Color(0xFF8B5CF6); // Purple
      case NotificationType.reminder:
        return const Color(0xFF06B6D4); // Cyan / Teal
      case NotificationType.budget:
        return const Color(0xFFF59E0B); // Amber
    }
  }

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;
    final isRead = notification.isRead;
    final color = _iconColor;

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        context.read<NotificationsBloc>().add(
              MarkNotificationAsReadEvent(notification.id),
            );

        final targetTab = notification.targetTabIndex;
        final targetItemId = notification.targetItemId;
        final isTaskType = notification.type == NotificationType.task;
        final tasksBloc = context.read<TasksBloc>();
        final dashboardBloc = context.read<DashboardBloc>();

        Navigator.of(context).pop();

        if (targetTab != null) {
          dashboardBloc.add(DashboardTabSelected(targetTab));
        }

        if (isTaskType && targetItemId != null) {
          final matchedTasks = tasksBloc.state.tasks.where(
            (t) => t.id == targetItemId,
          );

          if (matchedTasks.isNotEmpty) {
            final matchedTask = matchedTasks.first;
            Future.delayed(const Duration(milliseconds: 280), () {
              if (context.mounted) {
                TaskDetailBottomSheet.show(
                  context,
                  task: matchedTask,
                  onToggle: () {
                    tasksBloc.add(ToggleTaskEvent(matchedTask.id));
                  },
                  onDelete: () {
                    tasksBloc.add(DeleteTaskEvent(matchedTask.id));
                  },
                );
              }
            });
          }
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isRead ? Colors.transparent : zen.subtleFill,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isRead
                ? Colors.transparent
                : zen.border.withValues(alpha: 0.6),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(_icon, size: 17, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: AppTextStyles.bodyMedium(
                            isRead ? zen.textSecondary : zen.textPrimary,
                          ).copyWith(
                            fontWeight:
                                isRead ? FontWeight.w500 : FontWeight.w700,
                            fontSize: 13.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!isRead)
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: AppColors.danger,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    notification.description,
                    style: AppTextStyles.bodySmall(zen.textMuted).copyWith(
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _formatRelativeTime(notification.timestamp),
                    style: AppTextStyles.labelSmall(zen.textMuted).copyWith(
                      fontSize: 10.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
