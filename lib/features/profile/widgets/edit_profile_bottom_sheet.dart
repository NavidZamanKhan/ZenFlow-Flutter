import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';
import '../../../core/widgets/zen_avatar.dart';
import '../../../core/widgets/zen_button.dart';
import '../../../core/widgets/zen_text_field.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../models/user_profile.dart';
import 'avatar_picker_bottom_sheet.dart';

class EditProfileBottomSheet extends StatefulWidget {
  final UserProfile initialProfile;
  final ValueChanged<UserProfile> onSaved;

  const EditProfileBottomSheet({
    super.key,
    required this.initialProfile,
    required this.onSaved,
  });

  static Future<void> show(
    BuildContext context, {
    required UserProfile initialProfile,
    required ValueChanged<UserProfile> onSaved,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditProfileBottomSheet(
        initialProfile: initialProfile,
        onSaved: onSaved,
      ),
    );
  }

  @override
  State<EditProfileBottomSheet> createState() => _EditProfileBottomSheetState();
}

class _EditProfileBottomSheetState extends State<EditProfileBottomSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _countryController;
  late final TextEditingController _timeZoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialProfile.fullName);
    _usernameController = TextEditingController(text: widget.initialProfile.username);
    _phoneController = TextEditingController(text: widget.initialProfile.phone);
    _countryController = TextEditingController(text: widget.initialProfile.country);
    _timeZoneController = TextEditingController(text: widget.initialProfile.timeZone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _countryController.dispose();
    _timeZoneController.dispose();
    super.dispose();
  }

  void _submit() {
    final updated = widget.initialProfile.copyWith(
      fullName: _nameController.text.trim(),
      username: _usernameController.text.trim(),
      phone: _phoneController.text.trim(),
      country: _countryController.text.trim(),
      timeZone: _timeZoneController.text.trim(),
    );
    widget.onSaved(updated);
    Navigator.of(context).pop();
  }

  void _openAvatarPicker(BuildContext context, UserProfile currentProfile) {
    AvatarPickerBottomSheet.show(
      context,
      hasExistingAvatar: currentProfile.avatarUrl != null &&
          currentProfile.avatarUrl!.isNotEmpty,
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

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 20,
        right: 20,
        top: 14,
      ),
      decoration: BoxDecoration(
        color: zen.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: zen.border)),
      ),
      child: SingleChildScrollView(
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
            const SizedBox(height: 14),

            // Title Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Edit profile',
                  style: AppTextStyles.headingLarge(zen.textPrimary),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: zen.subtleFill,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(LucideIcons.x, size: 16, color: zen.textMuted),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Centered Avatar with Camera Badge
            BlocBuilder<ProfileBloc, ProfileState>(
              builder: (context, state) {
                final activeProfile = state.profile;
                return Center(
                  child: ZenAvatar(
                    avatarUrl: activeProfile.avatarUrl,
                    initials: activeProfile.initials,
                    size: 76,
                    showCameraBadge: true,
                    isLoading: state.isUploadingAvatar,
                    onTap: () => _openAvatarPicker(context, activeProfile),
                  ),
                );
              },
            ),
            const SizedBox(height: 18),

            // Full Name
            Text('Full name', style: AppTextStyles.labelMedium(zen.textPrimary)),
            const SizedBox(height: 6),
            ZenTextField(controller: _nameController, hintText: 'Full name'),
            const SizedBox(height: 14),

            // Username
            Text('Username', style: AppTextStyles.labelMedium(zen.textPrimary)),
            const SizedBox(height: 6),
            ZenTextField(controller: _usernameController, hintText: 'Username'),
            const SizedBox(height: 14),

            // Phone
            Text('Phone', style: AppTextStyles.labelMedium(zen.textPrimary)),
            const SizedBox(height: 6),
            ZenTextField(
              controller: _phoneController,
              hintText: '+880 1700-000000 (optional)',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 14),

            // Country & TimeZone
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Country', style: AppTextStyles.labelMedium(zen.textPrimary)),
                      const SizedBox(height: 6),
                      ZenTextField(controller: _countryController, hintText: 'Country'),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Time zone', style: AppTextStyles.labelMedium(zen.textPrimary)),
                      const SizedBox(height: 6),
                      ZenTextField(controller: _timeZoneController, hintText: 'Time zone'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel', style: AppTextStyles.labelMedium(zen.textMuted)),
                ),
                const SizedBox(width: 12),
                ZenButton(
                  label: 'Save changes',
                  height: 42,
                  width: 135,
                  onPressed: _submit,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
