import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';
import '../../../core/widgets/zen_button.dart';
import '../../../core/widgets/zen_card.dart';
import 'change_password_bottom_sheet.dart';
import 'delete_account_bottom_sheet.dart';

class SettingsSecurityCard extends StatelessWidget {
  const SettingsSecurityCard({super.key});

  void _showDeleteAccountDialog(BuildContext context) {
    DeleteAccountBottomSheet.show(context);
  }

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;

    return ZenCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          // Password Box
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: zen.subtleFill,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: zen.border),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: zen.accent.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(LucideIcons.shield, size: 18, color: zen.accent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Password',
                        style: AppTextStyles.headingSmall(zen.textPrimary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Your account is secured with a password.',
                        style: AppTextStyles.labelSmall(zen.textMuted),
                      ),
                    ],
                  ),
                ),
                ZenButton(
                  label: 'Change password',
                  icon: LucideIcons.key_round,
                  height: 36,
                  width: 145,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  onPressed: () => ChangePasswordBottomSheet.show(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Danger Zone Box
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.danger.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.danger.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    LucideIcons.triangle_alert,
                    size: 18,
                    color: AppColors.danger,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Danger Zone',
                        style: AppTextStyles.headingSmall(AppColors.danger),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Permanently delete your ZenFlow account and all workspace data.',
                        style: AppTextStyles.labelSmall(zen.textMuted),
                      ),
                    ],
                  ),
                ),
                ZenButton(
                  label: 'Delete account',
                  icon: LucideIcons.trash_2,
                  height: 36,
                  width: 135,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  onPressed: () => _showDeleteAccountDialog(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
