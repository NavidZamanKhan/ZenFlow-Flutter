import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';
import '../../../core/widgets/zen_card.dart';
import '../models/smart_trend_item.dart';

class SmartTrendsCard extends StatelessWidget {
  final List<SmartTrendItem> smartAnalytics;
  final List<SmartTrendItem> trendItems;

  const SmartTrendsCard({
    super.key,
    required this.smartAnalytics,
    required this.trendItems,
  });

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Smart Analytics Section Header
        Row(
          children: [
            Icon(LucideIcons.sparkles, size: 18, color: zen.accent),
            const SizedBox(width: 8),
            Text(
              'Smart analytics',
              style: AppTextStyles.headingSmall(zen.textPrimary),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 2-Column Grid of Smart Analytics
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: smartAnalytics.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.5,
          ),
          itemBuilder: (context, index) {
            final item = smartAnalytics[index];
            final color = item.accentColor ?? zen.accent;

            return ZenCard(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Icon(item.icon, size: 16, color: color),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item.title,
                          style: AppTextStyles.labelSmall(zen.textMuted),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.value,
                    style: AppTextStyles.labelMedium(zen.textPrimary).copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 20),

        // Trends Section Header
        Row(
          children: [
            Icon(LucideIcons.trending_up, size: 18, color: zen.accent),
            const SizedBox(width: 8),
            Text(
              'Trends',
              style: AppTextStyles.headingSmall(zen.textPrimary),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 2-Column Grid of Trends
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: trendItems.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.35,
          ),
          itemBuilder: (context, index) {
            final item = trendItems[index];
            final color = item.accentColor ?? zen.accent;

            return ZenCard(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Icon(item.icon, size: 15, color: color),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item.title,
                          style: AppTextStyles.labelSmall(zen.textMuted).copyWith(
                            fontSize: 10.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item.value,
                    style: AppTextStyles.labelMedium(zen.textPrimary).copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle!,
                      style: AppTextStyles.labelSmall(zen.textSecondary).copyWith(
                        fontSize: 10.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
