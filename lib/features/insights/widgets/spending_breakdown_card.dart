import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../core/services/currency_service.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';
import '../../../core/widgets/zen_card.dart';
import '../models/chart_segment.dart';

class SpendingBreakdownCard extends StatelessWidget {
  final List<ChartSegment> segments;
  final String currency;

  const SpendingBreakdownCard({
    super.key,
    required this.segments,
    this.currency = 'BDT',
  });

  IconData _iconFor(String label) {
    switch (label.toLowerCase()) {
      case 'bills':
        return LucideIcons.receipt;
      case 'shopping':
        return LucideIcons.shopping_bag;
      case 'subscription':
        return LucideIcons.refresh_cw;
      case 'education':
        return LucideIcons.graduation_cap;
      default:
        return LucideIcons.tag;
    }
  }

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;

    return ZenCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.chart_pie, size: 18, color: zen.accent),
              const SizedBox(width: 8),
              Text(
                'Spending breakdown',
                style: AppTextStyles.headingSmall(zen.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: segments.length,
            separatorBuilder: (ctx, idx) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final item = segments[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: item.color.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _iconFor(item.label),
                          size: 14,
                          color: item.color,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        item.label,
                        style: AppTextStyles.bodyMedium(zen.textPrimary),
                      ),
                      const Spacer(),
                      Text(
                        '${item.percentage.toStringAsFixed(1)}% ',
                        style: AppTextStyles.labelSmall(zen.textMuted),
                      ),
                      Text(
                        CurrencyService().formatMoney(
                          amount: item.amount,
                          currency: currency,
                        ),
                        style:
                            AppTextStyles.labelMedium(zen.textPrimary).copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: (item.percentage / 100).clamp(0.0, 1.0),
                      minHeight: 6,
                      backgroundColor: zen.subtleFill,
                      valueColor: AlwaysStoppedAnimation(item.color),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
