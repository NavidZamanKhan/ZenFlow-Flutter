import 'package:flutter/material.dart';

import '../../../core/theme/zenflow_theme.dart';
import '../../../core/widgets/zen_card.dart';
import '../../../core/widgets/zen_shimmer.dart';

class InsightsSkeleton extends StatelessWidget {
  const InsightsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;

    return ZenShimmer(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 118),
        children: [
          // 1. Header skeleton
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  ZenSkeletonBox(width: 130, height: 28, borderRadius: 8),
                  SizedBox(height: 6),
                  ZenSkeletonBox(width: 210, height: 14, borderRadius: 6),
                ],
              ),
              const ZenSkeletonBox(width: 40, height: 40, borderRadius: 12),
            ],
          ),
          const SizedBox(height: 16),

          // 2. Time-Range Switcher Pill skeleton
          const ZenSkeletonBox(
            width: double.infinity,
            height: 46,
            borderRadius: 14,
          ),
          const SizedBox(height: 20),

          // 3. 2x2 Metrics Summary Grid skeleton
          Row(
            children: [
              Expanded(
                child: ZenCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      ZenSkeletonBox(width: 80, height: 12, borderRadius: 6),
                      SizedBox(height: 10),
                      ZenSkeletonBox(width: 110, height: 22, borderRadius: 6),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ZenCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      ZenSkeletonBox(width: 80, height: 12, borderRadius: 6),
                      SizedBox(height: 10),
                      ZenSkeletonBox(width: 90, height: 22, borderRadius: 6),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ZenCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      ZenSkeletonBox(width: 80, height: 12, borderRadius: 6),
                      SizedBox(height: 10),
                      ZenSkeletonBox(width: 95, height: 22, borderRadius: 6),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ZenCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      ZenSkeletonBox(width: 80, height: 12, borderRadius: 6),
                      SizedBox(height: 10),
                      ZenSkeletonBox(width: 40, height: 22, borderRadius: 6),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // 4. Category Donut Card skeleton
          ZenCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ZenSkeletonBox(width: 160, height: 18, borderRadius: 6),
                const SizedBox(height: 4),
                const ZenSkeletonBox(width: 120, height: 12, borderRadius: 4),
                const SizedBox(height: 20),
                Row(
                  children: [
                    // Donut circle placeholder
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: zen.isDark
                              ? const Color(0xFF1E2638)
                              : const Color(0xFFE2E8F0),
                          width: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Legend lines
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          ZenSkeletonBox(width: double.infinity, height: 16, borderRadius: 6),
                          SizedBox(height: 10),
                          ZenSkeletonBox(width: double.infinity, height: 16, borderRadius: 6),
                          SizedBox(height: 10),
                          ZenSkeletonBox(width: double.infinity, height: 16, borderRadius: 6),
                          SizedBox(height: 10),
                          ZenSkeletonBox(width: double.infinity, height: 16, borderRadius: 6),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // 5. Daily Spending Chart skeleton
          ZenCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ZenSkeletonBox(width: 130, height: 18, borderRadius: 6),
                SizedBox(height: 4),
                ZenSkeletonBox(width: 170, height: 12, borderRadius: 4),
                SizedBox(height: 20),
                ZenSkeletonBox(width: double.infinity, height: 120, borderRadius: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
