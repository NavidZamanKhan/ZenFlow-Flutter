import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';
import '../../../core/widgets/zen_avatar.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_state.dart';
import '../views/profile_screen.dart';

class UserMenuBottomSheet extends StatelessWidget {
  const UserMenuBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    final profileBloc = context.read<ProfileBloc>();

    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: profileBloc,
        child: const UserMenuBottomSheet(),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.zenColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Log out',
          style: AppTextStyles.headingMedium(context.zenColors.textPrimary),
        ),
        content: Text(
          'Are you sure you want to log out of your ZenFlow account?',
          style: AppTextStyles.bodyMedium(context.zenColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: AppTextStyles.labelMedium(context.zenColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop(); // dismiss dialog
              Navigator.of(context).pop(); // dismiss bottom sheet
              context.read<AuthBloc>().add(LogoutRequestedEvent());
            },
            child: const Text('Log out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;

    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final profile = state.profile;

        return Container(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 34),
          decoration: BoxDecoration(
            color: zen.card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(top: BorderSide(color: zen.border)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Grab handle
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: zen.border,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // User Info Header Card (Tapping opens Profile directly)
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ProfileScreen(initialTab: 0),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: zen.subtleFill,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: zen.border),
                  ),
                  child: Row(
                    children: [
                      ZenAvatar(
                        avatarUrl: profile.avatarUrl,
                        initials: profile.initials,
                        size: 44,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile.fullName,
                              style: AppTextStyles.headingSmall(zen.textPrimary),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              profile.email,
                              style:
                                  AppTextStyles.labelSmall(zen.textSecondary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        LucideIcons.chevron_right,
                        size: 16,
                        color: zen.textMuted,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Menu Items
              _MenuItem(
                icon: LucideIcons.user,
                label: 'My Profile',
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ProfileScreen(initialTab: 0),
                    ),
                  );
                },
              ),
              const SizedBox(height: 6),
              _MenuItem(
                icon: LucideIcons.settings,
                label: 'Settings',
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ProfileScreen(initialTab: 1),
                    ),
                  );
                },
              ),
              const SizedBox(height: 6),
              _MenuItem(
                icon: LucideIcons.log_out,
                label: 'Log out',
                color: AppColors.danger,
                onTap: () => _showLogoutDialog(context),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;
    final itemColor = color ?? zen.textPrimary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: itemColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyMedium(itemColor).copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(LucideIcons.chevron_right, size: 16, color: zen.textMuted),
          ],
        ),
      ),
    );
  }
}
