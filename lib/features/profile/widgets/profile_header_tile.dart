import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';
import '../../../core/widgets/zen_button.dart';
import '../../../core/widgets/zen_card.dart';
import '../models/user_profile.dart';

class ProfileHeaderTile extends StatelessWidget {
  final UserProfile profile;
  final VoidCallback onEditPressed;

  const ProfileHeaderTile({
    super.key,
    required this.profile,
    required this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;

    return ZenCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          // Avatar circle
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: zen.accent,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: zen.accent.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Text(
                profile.initials,
                style: AppTextStyles.headingMedium(Colors.white).copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Name and Email
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.fullName,
                  style: AppTextStyles.headingMedium(zen.textPrimary),
                ),
                const SizedBox(height: 3),
                Text(
                  profile.email,
                  style: AppTextStyles.bodySmall(zen.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Edit profile button
          ZenButton(
            label: 'Edit profile',
            icon: LucideIcons.pencil,
            height: 36,
            width: 116,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            onPressed: onEditPressed,
          ),
        ],
      ),
    );
  }
}
