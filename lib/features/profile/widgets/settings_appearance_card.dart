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
import 'preference_picker_sheet.dart';

class SettingsAppearanceCard extends StatelessWidget {
  final String displayDensity;
  final ValueChanged<String> onDensityChanged;

  const SettingsAppearanceCard({
    super.key,
    required this.displayDensity,
    required this.onDensityChanged,
  });

  static const _accentColors = [
    (name: 'ZenFlow blue', accent: AppAccentColor.blue),
    (name: 'Soft teal', accent: AppAccentColor.teal),
    (name: 'Violet', accent: AppAccentColor.violet),
    (name: 'Coral', accent: AppAccentColor.coral),
  ];

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return ZenCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Theme Mode Header
              Text(
                'Theme',
                style: AppTextStyles.labelMedium(zen.textPrimary),
              ),
              const SizedBox(height: 12),

              // 3 Theme Mode Cards (Light, Dark, System)
              Column(
                children: [
                  _ThemeCard(
                    icon: LucideIcons.sun,
                    title: 'Light',
                    subtitle: 'Bright workspace with light surfaces',
                    isSelected: themeState.themeMode == ThemeMode.light,
                    onTap: () => context.read<ThemeBloc>().add(
                          const ChangeThemeModeEvent(ThemeMode.light),
                        ),
                  ),
                  const SizedBox(height: 8),
                  _ThemeCard(
                    icon: LucideIcons.moon,
                    title: 'Dark',
                    subtitle: 'Dimmed surfaces for low-light focus',
                    isSelected: themeState.themeMode == ThemeMode.dark,
                    onTap: () => context.read<ThemeBloc>().add(
                          const ChangeThemeModeEvent(ThemeMode.dark),
                        ),
                  ),
                  const SizedBox(height: 8),
                  _ThemeCard(
                    icon: LucideIcons.monitor,
                    title: 'System',
                    subtitle: 'Match your device appearance setting',
                    isSelected: themeState.themeMode == ThemeMode.system,
                    onTap: () => context.read<ThemeBloc>().add(
                          const ChangeThemeModeEvent(ThemeMode.system),
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // Accent Color Header & Subtitle
              Text(
                'Accent color',
                style: AppTextStyles.labelMedium(zen.textPrimary),
              ),
              const SizedBox(height: 10),

              // 2x2 Grid of Accent Color Pills
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _accentColors.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 2.8,
                ),
                itemBuilder: (context, index) {
                  final item = _accentColors[index];
                  final isSelected = themeState.accentColor == item.accent;
                  final palette = AppColors.accents[item.accent]!;

                  return GestureDetector(
                    onTap: () => context.read<ThemeBloc>().add(
                          ChangeAccentColorEvent(item.accent),
                        ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? palette.base.withValues(alpha: 0.12)
                            : zen.subtleFill,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? palette.base : zen.border,
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: palette.base,
                              shape: BoxShape.circle,
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: palette.base.withValues(alpha: 0.4),
                                        blurRadius: 6,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              item.name,
                              style: AppTextStyles.labelSmall(
                                isSelected ? palette.base : zen.textPrimary,
                              ).copyWith(
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 6),
              Text(
                'Instantly personalizes dashboard chrome and branding.',
                style: AppTextStyles.labelSmall(zen.textMuted).copyWith(fontSize: 11),
              ),
              const SizedBox(height: 22),

              // Display Density
              Text(
                'Display density',
                style: AppTextStyles.labelMedium(zen.textPrimary),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () => PreferencePickerSheet.show(
                  context,
                  title: 'Display density',
                  options: const ['comfortable', 'compact'],
                  selectedValue: displayDensity,
                  onSelected: onDensityChanged,
                ),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: zen.subtleFill,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: zen.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        displayDensity,
                        style: AppTextStyles.bodyMedium(zen.textPrimary),
                      ),
                      Icon(LucideIcons.chevron_down, size: 16, color: zen.textMuted),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Choose between comfortable spacing or data-dense compact layout.',
                style: AppTextStyles.labelSmall(zen.textMuted).copyWith(fontSize: 11),
              ),
              const SizedBox(height: 18),

              // Live Sync Info Box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: zen.subtleFill.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: zen.border.withValues(alpha: 0.6)),
                ),
                child: Text(
                  'Appearance changes apply live immediately. Accent color updates dashboard chrome (navigation, brand mark, focus rings, and Settings actions).',
                  style: AppTextStyles.labelSmall(zen.textSecondary).copyWith(
                    fontSize: 11.5,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ThemeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? (zen.isDark ? zen.accentSoft : zen.accentLightBg)
              : zen.subtleFill,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? zen.accent : zen.border,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? zen.accent.withValues(alpha: 0.15)
                    : zen.card,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 18,
                color: isSelected ? zen.accent : zen.textSecondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.labelMedium(
                      isSelected ? zen.accent : zen.textPrimary,
                    ).copyWith(
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.labelSmall(zen.textMuted).copyWith(
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(LucideIcons.circle_check, size: 18, color: zen.accent),
          ],
        ),
      ),
    );
  }
}
