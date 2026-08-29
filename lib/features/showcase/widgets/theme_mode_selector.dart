import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/bloc/theme_bloc.dart';
import '../../../core/theme/bloc/theme_event.dart';
import '../../../core/theme/bloc/theme_state.dart';
import '../../../core/theme/zenflow_theme.dart';

class ThemeModeSelector extends StatelessWidget {
  const ThemeModeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return Row(
          children: [
            _OptionCard(
              title: 'Light',
              icon: LucideIcons.sun,
              isSelected: state.themeMode == ThemeMode.light,
              onTap: () {
                context.read<ThemeBloc>().add(const ChangeThemeModeEvent(ThemeMode.light));
              },
            ),
            const SizedBox(width: 8),
            _OptionCard(
              title: 'Dark',
              icon: LucideIcons.moon,
              isSelected: state.themeMode == ThemeMode.dark,
              onTap: () {
                context.read<ThemeBloc>().add(const ChangeThemeModeEvent(ThemeMode.dark));
              },
            ),
            const SizedBox(width: 8),
            _OptionCard(
              title: 'System',
              icon: LucideIcons.laptop,
              isSelected: state.themeMode == ThemeMode.system,
              onTap: () {
                context.read<ThemeBloc>().add(const ChangeThemeModeEvent(ThemeMode.system));
              },
            ),
          ],
        );
      },
    );
  }
}

class _OptionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionCard({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? (zen.isDark ? zen.accentSoft : zen.accentLightBg)
                : zen.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? zen.accent : zen.border,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? zen.accent : zen.textSecondary,
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: AppTextStyles.labelSmall(
                  isSelected ? zen.textPrimary : zen.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
