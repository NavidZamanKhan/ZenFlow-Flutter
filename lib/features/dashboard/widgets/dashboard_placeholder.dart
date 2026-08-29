import 'package:flutter/material.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';

class DashboardPlaceholder extends StatelessWidget {
  final String title;
  final IconData icon;
  const DashboardPlaceholder({
    super.key,
    required this.title,
    required this.icon,
  });
  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: zen.accentSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: zen.accent, size: 28),
          ),
          const SizedBox(height: 14),
          Text(title, style: AppTextStyles.headingMedium(zen.textPrimary)),
          const SizedBox(height: 6),
          Text(
            'Coming next in ZenFlow.',
            style: AppTextStyles.bodySmall(zen.textSecondary),
          ),
        ],
      ),
    );
  }
}
