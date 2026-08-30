import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../widgets/settings_appearance_card.dart';
import '../widgets/settings_expense_prefs_card.dart';
import '../widgets/settings_security_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
            builder: (context, state) {
              final profile = state.profile;

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
                  const SizedBox(height: 18),

                  // Section 1: Appearance
                  _SectionHeader(
                    icon: LucideIcons.palette,
                    title: 'Appearance',
                    subtitle: 'Choose how you want your workspace to look.',
                  ),
                  const SizedBox(height: 10),
                  SettingsAppearanceCard(
                    displayDensity: profile.displayDensity,
                    onDensityChanged: (density) {
                      context.read<ProfileBloc>().add(
                            UpdateExpensePreferencesEvent(
                              currency: profile.currency,
                              dateFormat: profile.dateFormat,
                              numberFormat: profile.numberFormat,
                              firstDayOfWeek: profile.firstDayOfWeek,
                              defaultPaymentMethod:
                                  profile.defaultPaymentMethod,
                              defaultExpenseCategory:
                                  profile.defaultExpenseCategory,
                              is24HourTime: profile.is24HourTime,
                              displayDensity: density,
                            ),
                          );
                    },
                  ),
                  const SizedBox(height: 26),

                  // Section 2: Expense Preferences
                  _SectionHeader(
                    icon: LucideIcons.credit_card,
                    title: 'Expense preferences',
                    subtitle:
                        'Customize your currency, formatting defaults, and live exchange rates.',
                  ),
                  const SizedBox(height: 10),
                  SettingsExpensePrefsCard(
                    profile: profile,
                    onSave: (updated) {
                      context.read<ProfileBloc>().add(
                            UpdateExpensePreferencesEvent(
                              currency: updated.currency,
                              dateFormat: updated.dateFormat,
                              numberFormat: updated.numberFormat,
                              firstDayOfWeek: updated.firstDayOfWeek,
                              defaultPaymentMethod:
                                  updated.defaultPaymentMethod,
                              defaultExpenseCategory:
                                  updated.defaultExpenseCategory,
                              is24HourTime: updated.is24HourTime,
                              displayDensity: updated.displayDensity,
                            ),
                          );
                    },
                  ),
                  const SizedBox(height: 26),

                  // Section 3: Security & Account
                  _SectionHeader(
                    icon: LucideIcons.shield_check,
                    title: 'Security & Account',
                    subtitle:
                        'Manage your authentication credentials, password, and account deletion.',
                  ),
                  const SizedBox(height: 10),
                  const SettingsSecurityCard(),
                ],
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
            Icon(icon, size: 17, color: zen.accent),
            const SizedBox(width: 8),
            Text(title, style: AppTextStyles.headingSmall(zen.textPrimary)),
          ],
        ),
        const SizedBox(height: 3),
        Text(subtitle, style: AppTextStyles.labelSmall(zen.textSecondary)),
      ],
    );
  }
}
