import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/bloc/theme_bloc.dart';
import '../../../core/theme/bloc/theme_event.dart';
import '../../../core/theme/bloc/theme_state.dart';
import '../../../core/theme/zenflow_theme.dart';

class AccentColorSelector extends StatelessWidget {
  const AccentColorSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AppAccentColor.values.map((accent) {
            final palette = AppColors.accents[accent]!;
            final isSelected = state.accentColor == accent;

            return InkWell(
              onTap: () {
                context.read<ThemeBloc>().add(ChangeAccentColorEvent(accent));
              },
              borderRadius: BorderRadius.circular(100),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (zen.isDark ? palette.darkSoftFill : palette.lightBg)
                      : zen.surface,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: isSelected ? palette.base : zen.border,
                    width: isSelected ? 1.5 : 1,
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
                      palette.name,
                      style: AppTextStyles.labelSmall(
                        isSelected ? zen.textPrimary : zen.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
