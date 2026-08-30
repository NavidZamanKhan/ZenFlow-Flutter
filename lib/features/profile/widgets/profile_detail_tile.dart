import 'package:flutter/material.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';

class ProfileDetailTile extends StatelessWidget {
  final String label;
  final String value;
  final String? helperText;
  final IconData? icon;

  const ProfileDetailTile({
    super.key,
    required this.label,
    required this.value,
    this.helperText,
    this.icon,
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
        Container(
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
                  value.isNotEmpty ? value : 'Optional',
                  style: AppTextStyles.bodyMedium(
                    value.isNotEmpty ? zen.textPrimary : zen.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 5),
          Text(
            helperText!,
            style: AppTextStyles.labelSmall(zen.textMuted).copyWith(fontSize: 11),
          ),
        ],
      ],
    );
  }
}
