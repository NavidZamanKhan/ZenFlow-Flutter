import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';
import '../../../core/widgets/zen_avatar.dart';
import '../../../core/widgets/zen_button.dart';
import '../../../core/widgets/zen_card.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../models/user_profile.dart';
import 'avatar_picker_bottom_sheet.dart';

class ProfileHeaderTile extends StatelessWidget {
  final UserProfile profile;
  final VoidCallback onEditPressed;

  const ProfileHeaderTile({
    super.key,
    required this.profile,
    required this.onEditPressed,
  });

  void _openAvatarPicker(BuildContext context) {
    AvatarPickerBottomSheet.show(
      context,
      hasExistingAvatar:
          profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty,
      onImageSelected: (path) {
        context.read<ProfileBloc>().add(UploadAvatarEvent(path));
      },
      onRemoveAvatar: () {
        context.read<ProfileBloc>().add(const DeleteAvatarEvent());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;

    return ZenCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          // Avatar circle with camera badge & upload loading state
          BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              return ZenAvatar(
                avatarUrl: profile.avatarUrl,
                initials: profile.initials,
                size: 60,
                showCameraBadge: true,
                isLoading: state.isUploadingAvatar,
                onTap: () => _openAvatarPicker(context),
              );
            },
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
