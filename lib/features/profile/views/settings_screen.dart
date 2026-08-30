import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/bloc/theme_bloc.dart';
import '../../../core/theme/bloc/theme_event.dart';
import '../../../core/theme/bloc/theme_state.dart';
import '../../../core/theme/zenflow_theme.dart';
import '../../../core/widgets/zen_card.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../widgets/change_password_bottom_sheet.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const _accentColors = [
    (name: 'ZenFlow blue', accent: AppAccentColor.blue),
    (name: 'Soft teal', accent: AppAccentColor.teal),
    (name: 'Violet', accent: AppAccentColor.violet),
    (name: 'Coral', accent: AppAccentColor.coral),
  ];

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
            'Settings',
            style: AppTextStyles.headingMedium(zen.textPrimary),
          ),
          centerTitle: false,
        ),
        body: SafeArea(
          child: BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, profileState) {
              return BlocBuilder<ThemeBloc, ThemeState>(
                builder: (context, themeState) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
                    children: [
                      Text(
                        'Shape your ZenFlow experience',
                        style: AppTextStyles.bodySmall(zen.textSecondary),
                      ),
                      const SizedBox(height: 16),

                      // Section 1: Appearance
                      _SectionHeader(
                        icon: LucideIcons.palette,
                        title: 'Appearance',
                        subtitle: 'Choose how you want your workspace to look.',
                      ),
                      const SizedBox(height: 10),
                      ZenCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Theme Mode', style: AppTextStyles.labelMedium(zen.textPrimary)),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                _ThemeModeOption(
                                  icon: LucideIcons.sun,
                                  label: 'Light',
                                  isSelected: themeState.themeMode == ThemeMode.light,
                                  onTap: () => context.read<ThemeBloc>().add(
                                    const ChangeThemeModeEvent(ThemeMode.light),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _ThemeModeOption(
                                  icon: LucideIcons.moon,
                                  label: 'Dark',
                                  isSelected: themeState.themeMode == ThemeMode.dark,
                                  onTap: () => context.read<ThemeBloc>().add(
                                    const ChangeThemeModeEvent(ThemeMode.dark),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _ThemeModeOption(
                                  icon: LucideIcons.monitor,
                                  label: 'System',
                                  isSelected: themeState.themeMode == ThemeMode.system,
                                  onTap: () => context.read<ThemeBloc>().add(
                                    const ChangeThemeModeEvent(ThemeMode.system),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            Text('Accent Color', style: AppTextStyles.labelMedium(zen.textPrimary)),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _accentColors.map((acc) {
                                final isSelected = themeState.accentColor == acc.accent;
                                final palette = AppColors.accents[acc.accent]!;

                                return GestureDetector(
                                  onTap: () => context.read<ThemeBloc>().add(
                                    ChangeAccentColorEvent(acc.accent),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? palette.base.withValues(alpha: 0.15)
                                          : zen.subtleFill,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected ? palette.base : zen.border,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: palette.base,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          acc.name,
                                          style: AppTextStyles.labelSmall(
                                            isSelected ? palette.base : zen.textSecondary,
                                          ).copyWith(
                                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Section 2: Expense Preferences
                      _SectionHeader(
                        icon: LucideIcons.credit_card,
                        title: 'Expense Preferences',
                        subtitle: 'Customize currency and live exchange rates.',
                      ),
                      const SizedBox(height: 10),
                      ZenCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Live Exchange Rate Pill
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: zen.subtleFill,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: zen.border),
                              ),
                              child: Row(
                                children: [
                                  Icon(LucideIcons.globe, size: 16, color: zen.accent),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              'Live Exchange Rate ',
                                              style: AppTextStyles.labelSmall(zen.textPrimary).copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                              decoration: BoxDecoration(
                                                color: AppColors.success.withValues(alpha: 0.15),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                'Live',
                                                style: TextStyle(
                                                  color: AppColors.success,
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '\$1.00 USD ≈ 123.18 BDT',
                                          style: AppTextStyles.bodySmall(zen.textSecondary),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(LucideIcons.refresh_cw, size: 15, color: zen.accent),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // 24-Hour Time Switch
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('24-Hour Time', style: AppTextStyles.bodyMedium(zen.textPrimary)),
                                    Text('Store & display times in 24h format', style: AppTextStyles.labelSmall(zen.textMuted)),
                                  ],
                                ),
                                Switch.adaptive(
                                  value: profileState.profile.is24HourTime,
                                  activeTrackColor: zen.accent,
                                  onChanged: (val) {
                                    context.read<ProfileBloc>().add(
                                      UpdateExpensePreferencesEvent(
                                        currency: profileState.profile.currency,
                                        is24HourTime: val,
                                        displayDensity: profileState.profile.displayDensity,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Section 3: Security & Danger Zone
                      _SectionHeader(
                        icon: LucideIcons.shield_check,
                        title: 'Security & Account',
                        subtitle: 'Manage authentication credentials and account actions.',
                      ),
                      const SizedBox(height: 10),
                      ZenCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // Password Row
                            Row(
                              children: [
                                Icon(LucideIcons.lock, size: 18, color: zen.accent),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Password', style: AppTextStyles.bodyMedium(zen.textPrimary)),
                                      Text('Your account is secured with a password', style: AppTextStyles.labelSmall(zen.textMuted)),
                                    ],
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => ChangePasswordBottomSheet.show(context),
                                  child: Text('Change', style: AppTextStyles.labelMedium(zen.accent)),
                                ),
                              ],
                            ),
                            const Divider(height: 20),

                            // Danger Zone Row
                            Row(
                              children: [
                                Icon(LucideIcons.triangle_alert, size: 18, color: AppColors.danger),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Delete Account', style: AppTextStyles.bodyMedium(AppColors.danger)),
                                      Text('Permanently remove your account and data', style: AppTextStyles.labelSmall(zen.textMuted)),
                                    ],
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {},
                                  child: Text('Delete', style: AppTextStyles.labelMedium(AppColors.danger)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: zen.accent),
            const SizedBox(width: 6),
            Text(title, style: AppTextStyles.headingSmall(zen.textPrimary)),
          ],
        ),
        const SizedBox(height: 2),
        Text(subtitle, style: AppTextStyles.labelSmall(zen.textSecondary)),
      ],
    );
  }
}

class _ThemeModeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeModeOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? (zen.isDark ? zen.accentSoft : zen.accentLightBg)
                : zen.subtleFill,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? zen.accent : zen.border,
              width: isSelected ? 1.4 : 1.0,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: isSelected ? zen.accent : zen.textSecondary),
              const SizedBox(height: 6),
              Text(
                label,
                style: AppTextStyles.labelSmall(
                  isSelected ? zen.accent : zen.textSecondary,
                ).copyWith(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
