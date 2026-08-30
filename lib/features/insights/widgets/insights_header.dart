import 'package:flutter/material.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';

class InsightsHeader extends StatelessWidget {
  const InsightsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Clarity on where your money flows',
              style: AppTextStyles.bodySmall(zen.textSecondary),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: zen.isDark ? zen.accentSoft : zen.accentLightBg,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: zen.accentLightBorder),
              ),
              child: Text(
                'BDT ৳',
                style: AppTextStyles.labelSmall(zen.accent),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Insights',
          style: AppTextStyles.displayLarge(zen.textPrimary),
        ),
      ],
    );
  }
}
