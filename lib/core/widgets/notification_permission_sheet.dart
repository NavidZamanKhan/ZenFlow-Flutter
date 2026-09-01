import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../services/notification_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/zenflow_theme.dart';
import '../widgets/zen_button.dart';
import '../../features/notifications/services/notification_preferences_service.dart';

class NotificationPermissionSheet extends StatelessWidget {
  const NotificationPermissionSheet({super.key});

  static Future<bool> showIfNeeded(BuildContext context) async {
    final prefsService = NotificationPreferencesService();
    final prefs = await prefsService.getPreferences();

    if (prefs.hasPromptedPermission) {
      return false;
    }

    if (!context.mounted) return false;

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const NotificationPermissionSheet(),
    );

    await prefsService.savePreferences(
      prefs.copyWith(hasPromptedPermission: true),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 34),
      decoration: BoxDecoration(
        color: zen.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: zen.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: zen.textMuted.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Glowing Bell Icon
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: zen.accent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: zen.accent.withValues(alpha: 0.25),
                  blurRadius: 18,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              LucideIcons.bell_ring,
              size: 32,
              color: zen.accent,
            ),
          ),
          const SizedBox(height: 18),

          // Title & Description
          Text(
            'Stay on Top of Your Day',
            textAlign: TextAlign.center,
            style: AppTextStyles.headingMedium(zen.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'ZenFlow uses on-device smart alerts to keep you focused without disturbing your flow.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium(zen.textSecondary),
          ),
          const SizedBox(height: 24),

          // Value Proposition Bullets
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: zen.subtleFill,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: zen.border),
            ),
            child: Column(
              children: [
                _BenefitRow(
                  icon: LucideIcons.alarm_clock,
                  iconColor: const Color(0xFF3B82F6),
                  title: '15-Min Task & Event Alerts',
                  subtitle: 'Get timely reminders before due times and meetings',
                ),
                const SizedBox(height: 14),
                _BenefitRow(
                  icon: LucideIcons.shield_alert,
                  iconColor: AppColors.danger,
                  title: 'Smart Budget Warnings',
                  subtitle: 'Immediate alerts before exceeding monthly limits',
                ),
                const SizedBox(height: 14),
                _BenefitRow(
                  icon: LucideIcons.sun,
                  iconColor: const Color(0xFFF59E0B),
                  title: '9:00 AM Morning Digest',
                  subtitle: 'A clean briefing of today\'s focus items',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Action Buttons
          ZenButton(
            label: 'Enable Notifications',
            icon: LucideIcons.bell,
            onPressed: () async {
              HapticFeedback.mediumImpact();
              final granted = await NotificationService().requestPermissions();
              if (context.mounted) {
                Navigator.of(context).pop(granted);
              }
            },
          ),
          const SizedBox(height: 10),
          ZenButton(
            label: 'Maybe Later',
            variant: ZenButtonVariant.outlined,
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
        ],
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _BenefitRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.labelLarge(zen.textPrimary).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTextStyles.labelSmall(zen.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
