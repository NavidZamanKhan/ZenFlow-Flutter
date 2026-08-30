import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';
import '../../../core/widgets/zen_button.dart';
import '../../../core/widgets/zen_card.dart';
import '../../../core/widgets/zen_text_field.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../models/user_profile.dart';
import '../widgets/preference_picker_sheet.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  late final TextEditingController _nameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _phoneController;
  String _selectedCountry = 'Bangladesh';
  String _selectedTimeZone = 'Asia/Dhaka';

  static const _countries = [
    'Bangladesh',
    'United States',
    'United Kingdom',
    'Canada',
    'Australia',
    'Germany',
    'Singapore',
    'India',
    'Japan',
  ];

  static const _timeZones = [
    'Asia/Dhaka',
    'America/New_York',
    'America/Los_Angeles',
    'Europe/London',
    'Europe/Berlin',
    'Asia/Singapore',
    'Asia/Tokyo',
    'UTC',
  ];

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileBloc>().state.profile;
    _nameController = TextEditingController(text: profile.fullName);
    _usernameController = TextEditingController(text: profile.username);
    _phoneController = TextEditingController(text: profile.phone);
    _selectedCountry = profile.country;
    _selectedTimeZone = profile.timeZone;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _onSave(UserProfile currentProfile) {
    final updated = currentProfile.copyWith(
      fullName: _nameController.text.trim(),
      username: _usernameController.text.trim(),
      phone: _phoneController.text.trim(),
      country: _selectedCountry,
      timeZone: _selectedTimeZone,
    );
    context.read<ProfileBloc>().add(UpdateProfileEvent(updated));
    setState(() => _isEditing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully')),
    );
  }

  void _onCancel(UserProfile currentProfile) {
    setState(() {
      _isEditing = false;
      _nameController.text = currentProfile.fullName;
      _usernameController.text = currentProfile.username;
      _phoneController.text = currentProfile.phone;
      _selectedCountry = currentProfile.country;
      _selectedTimeZone = currentProfile.timeZone;
    });
  }

  void _changeProfilePhoto() {
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile photo picker opened')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: zen.canvas,
        appBar: AppBar(
          backgroundColor: zen.canvas,
          elevation: 0,
          leading: IconButton(
            icon: Icon(LucideIcons.arrow_left, color: zen.textPrimary),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'My Profile',
            style: AppTextStyles.headingMedium(zen.textPrimary),
          ),
          centerTitle: false,
        ),
        body: SafeArea(
          child: BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              final profile = state.profile;

              return ListView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
                children: [
                  Text(
                    'Your personal information',
                    style: AppTextStyles.bodySmall(zen.textSecondary),
                  ),
                  const SizedBox(height: 16),

                  // Main Profile Card (Matching Website 100%)
                  ZenCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Avatar & Edit Button Row
                        Row(
                          children: [
                            // Avatar with Camera Overlay
                            Stack(
                              children: [
                                Container(
                                  width: 62,
                                  height: 62,
                                  decoration: BoxDecoration(
                                    color: zen.accent,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            zen.accent.withValues(alpha: 0.28),
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      profile.initials,
                                      style: AppTextStyles.headingLarge(
                                              Colors.white)
                                          .copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: _changeProfilePhoto,
                                    child: Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: zen.accent,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: zen.card,
                                          width: 2,
                                        ),
                                      ),
                                      child: const Icon(
                                        LucideIcons.camera,
                                        size: 11,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),

                            // Name & Email
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    profile.fullName,
                                    style: AppTextStyles.headingMedium(
                                        zen.textPrimary),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    profile.email,
                                    style: AppTextStyles.bodySmall(
                                        zen.textSecondary),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),

                            // Edit Profile Button (When not editing)
                            if (!_isEditing)
                              ZenButton(
                                label: 'Edit profile',
                                icon: LucideIcons.pencil,
                                height: 36,
                                width: 116,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                onPressed: () =>
                                    setState(() => _isEditing = true),
                              ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Full Name Field
                        Text(
                          'Full name',
                          style: AppTextStyles.labelMedium(zen.textPrimary),
                        ),
                        const SizedBox(height: 6),
                        _isEditing
                            ? ZenTextField(
                                controller: _nameController,
                                hintText: 'Full name',
                              )
                            : _ReadOnlyFieldBox(value: profile.fullName),
                        const SizedBox(height: 16),

                        // Username Field
                        Text(
                          'Username',
                          style: AppTextStyles.labelMedium(zen.textPrimary),
                        ),
                        const SizedBox(height: 6),
                        _isEditing
                            ? ZenTextField(
                                controller: _usernameController,
                                hintText: 'Username',
                              )
                            : _ReadOnlyFieldBox(value: profile.username),
                        const SizedBox(height: 16),

                        // Email Field (Always read-only auth identifier)
                        Text(
                          'Email',
                          style: AppTextStyles.labelMedium(zen.textPrimary),
                        ),
                        const SizedBox(height: 6),
                        _ReadOnlyFieldBox(
                          value: profile.email,
                          icon: LucideIcons.mail,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Your email is the current authentication identifier.',
                          style: AppTextStyles.labelSmall(zen.textMuted)
                              .copyWith(fontSize: 11),
                        ),
                        const SizedBox(height: 16),

                        // Phone Field
                        Text(
                          'Phone',
                          style: AppTextStyles.labelMedium(zen.textPrimary),
                        ),
                        const SizedBox(height: 6),
                        _isEditing
                            ? ZenTextField(
                                controller: _phoneController,
                                hintText: 'Optional',
                                keyboardType: TextInputType.phone,
                              )
                            : _ReadOnlyFieldBox(
                                value: profile.phone.isNotEmpty
                                    ? profile.phone
                                    : 'Optional',
                                isMuted: profile.phone.isEmpty,
                                icon: LucideIcons.phone,
                              ),
                        const SizedBox(height: 16),

                        // Country & Time Zone Row
                        Row(
                          children: [
                            Expanded(
                              child: _DropdownSelector(
                                label: 'Country',
                                value: _isEditing
                                    ? _selectedCountry
                                    : profile.country,
                                isEnabled: _isEditing,
                                onTap: () => PreferencePickerSheet.show(
                                  context,
                                  title: 'Select country',
                                  options: _countries,
                                  selectedValue: _selectedCountry,
                                  onSelected: (val) =>
                                      setState(() => _selectedCountry = val),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _DropdownSelector(
                                label: 'Time zone',
                                value: _isEditing
                                    ? _selectedTimeZone
                                    : profile.timeZone,
                                isEnabled: _isEditing,
                                onTap: () => PreferencePickerSheet.show(
                                  context,
                                  title: 'Select time zone',
                                  options: _timeZones,
                                  selectedValue: _selectedTimeZone,
                                  onSelected: (val) =>
                                      setState(() => _selectedTimeZone = val),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Info Sync Box
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: zen.subtleFill.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: zen.border.withValues(alpha: 0.6)),
                          ),
                          child: Text(
                            'Your full name and avatar image are permanently synced with your cloud account across all devices.',
                            style: AppTextStyles.labelSmall(zen.textSecondary)
                                .copyWith(
                              fontSize: 11.5,
                              height: 1.4,
                            ),
                          ),
                        ),

                        // Save & Cancel Action Row (when editing)
                        if (_isEditing) ...[
                          const SizedBox(height: 22),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => _onCancel(profile),
                                child: Text(
                                  'Cancel',
                                  style: AppTextStyles.labelMedium(
                                      zen.textSecondary),
                                ),
                              ),
                              const SizedBox(width: 12),
                              ZenButton(
                                label: 'Save changes',
                                icon: LucideIcons.bookmark_check,
                                height: 40,
                                width: 145,
                                onPressed: () => _onSave(profile),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ReadOnlyFieldBox extends StatelessWidget {
  final String value;
  final bool isMuted;
  final IconData? icon;

  const _ReadOnlyFieldBox({
    required this.value,
    this.isMuted = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: zen.subtleFill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: zen.border),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: zen.textMuted),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium(
                isMuted ? zen.textMuted : zen.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DropdownSelector extends StatelessWidget {
  final String label;
  final String value;
  final bool isEnabled;
  final VoidCallback onTap;

  const _DropdownSelector({
    required this.label,
    required this.value,
    required this.isEnabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMedium(zen.textPrimary),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: isEnabled ? onTap : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: zen.subtleFill,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isEnabled ? zen.accent : zen.border,
                width: isEnabled ? 1.2 : 1.0,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: AppTextStyles.bodyMedium(zen.textPrimary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  LucideIcons.chevron_down,
                  size: 15,
                  color: isEnabled ? zen.accent : zen.textMuted,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
