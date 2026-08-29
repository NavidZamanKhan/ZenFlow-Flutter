import 'package:flutter/material.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';
import '../../../core/widgets/zen_card.dart';

class SampleMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String tag;
  final IconData icon;
  final Color tagColor;
  final Color? iconColor;

  const SampleMetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.tag,
    required this.icon,
    required this.tagColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;

    return ZenCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 18, color: iconColor ?? zen.accent),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: tagColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  tag,
                  style: AppTextStyles.labelSmall(tagColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.statNumber(zen.textPrimary),
          ),
          Text(
            title,
            style: AppTextStyles.bodySmall(zen.textSecondary),
          ),
        ],
      ),
    );
  }
}
