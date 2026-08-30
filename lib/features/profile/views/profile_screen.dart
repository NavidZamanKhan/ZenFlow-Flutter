import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';
import '../../../core/widgets/zen_card.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../widgets/edit_profile_bottom_sheet.dart';
import '../widgets/profile_detail_tile.dart';
import '../widgets/profile_header_tile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
                  // Subtitle
                  Text(
                    'Your personal information',
                    style: AppTextStyles.bodySmall(zen.textSecondary),
                  ),
                  const SizedBox(height: 16),

                  // Hero Avatar Tile
                  ProfileHeaderTile(
                    profile: profile,
                    onEditPressed: () {
                      EditProfileBottomSheet.show(
                        context,
                        initialProfile: profile,
                        onSaved: (updated) {
                          context.read<ProfileBloc>().add(UpdateProfileEvent(updated));
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // Detail Fields Card
                  ZenCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(LucideIcons.user, size: 18, color: zen.accent),
                            const SizedBox(width: 8),
                            Text(
                              'Profile Details',
                              style: AppTextStyles.headingSmall(zen.textPrimary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        ProfileDetailTile(
                          label: 'Full name',
                          value: profile.fullName,
                        ),
                        const SizedBox(height: 14),

                        ProfileDetailTile(
                          label: 'Username',
                          value: profile.username,
                        ),
                        const SizedBox(height: 14),

                        ProfileDetailTile(
                          label: 'Email',
                          value: profile.email,
                          helperText: 'Your email is the current authentication identifier.',
                          icon: LucideIcons.mail,
                        ),
                        const SizedBox(height: 14),

                        ProfileDetailTile(
                          label: 'Phone',
                          value: profile.phone,
                          icon: LucideIcons.phone,
                        ),
                        const SizedBox(height: 14),

                        Row(
                          children: [
                            Expanded(
                              child: ProfileDetailTile(
                                label: 'Country',
                                value: profile.country,
                                icon: LucideIcons.globe,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ProfileDetailTile(
                                label: 'Time zone',
                                value: profile.timeZone,
                                icon: LucideIcons.clock,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Cloud Sync Info Box
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: zen.subtleFill,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: zen.border),
                    ),
                    child: Row(
                      children: [
                        Icon(LucideIcons.cloud, size: 16, color: zen.accent),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Your profile is permanently synced with your cloud account across all devices.',
                            style: AppTextStyles.labelSmall(zen.textSecondary),
                          ),
                        ),
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
