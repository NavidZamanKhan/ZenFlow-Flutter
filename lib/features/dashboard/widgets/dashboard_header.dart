import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';
import '../../../core/widgets/zen_badge.dart';
import '../../../core/widgets/zen_icon_button.dart';
import '../../auth/models/user_model.dart';
import '../../notifications/bloc/notifications_bloc.dart';
import '../../notifications/bloc/notifications_state.dart';
import '../../notifications/widgets/notifications_bottom_sheet.dart';
import '../../profile/bloc/profile_bloc.dart';
import '../../profile/bloc/profile_state.dart';
import '../../profile/widgets/user_menu_bottom_sheet.dart';

class DashboardHeader extends StatelessWidget {
  final UserModel user;
  final int remainingTasks;

  const DashboardHeader({
    super.key,
    required this.user,
    required this.remainingTasks,
  });

  String get _firstName =>
      user.fullName.trim().split(' ').firstOrNull ?? 'there';

  String get _salutation {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    if (hour < 21) return 'Good evening';
    return 'Good night';
  }

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$_salutation, $_firstName',
                style: AppTextStyles.bodySmall(zen.textSecondary),
              ),
              const SizedBox(height: 3),
              Text(
                'Today\'s focus',
                style: AppTextStyles.displayMedium(zen.textPrimary),
              ),
              const SizedBox(height: 10),
              ZenBadge(
                label:
                    '$remainingTasks ${remainingTasks == 1 ? 'task' : 'tasks'} to go',
                color: zen.accent,
                showDot: false,
                icon: LucideIcons.list_todo,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Row(
          children: [
            // Notifications Bell with dynamic live unread counter
            BlocBuilder<NotificationsBloc, NotificationsState>(
              builder: (context, notifState) {
                final unread = notifState.unreadCount;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ZenIconButton(
                      icon: LucideIcons.bell,
                      hasBadge: false,
                      size: 40,
                      onTap: () => NotificationsBottomSheet.show(context),
                    ),
                    if (unread > 0)
                      Positioned(
                        right: 2,
                        top: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: AppColors.danger,
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(color: zen.card, width: 1.5),
                          ),
                          constraints: const BoxConstraints(
                              minWidth: 16, minHeight: 16),
                          child: Center(
                            child: Text(
                              unread > 9 ? '9+' : '$unread',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                height: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(width: 8),

            // User Avatar Pill -> opens UserMenuBottomSheet
            BlocBuilder<ProfileBloc, ProfileState>(
              builder: (context, profileState) {
                final initials = profileState.profile.initials;

                return GestureDetector(
                  onTap: () => UserMenuBottomSheet.show(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: zen.accent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: zen.accent.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: AppTextStyles.labelMedium(Colors.white).copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
