import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';
import '../../../core/widgets/zen_badge.dart';
import '../../../core/widgets/zen_button.dart';
import '../../../core/widgets/zen_card.dart';
import '../../../core/widgets/zen_icon_button.dart';
import '../../../core/widgets/zen_text_field.dart';
import '../widgets/accent_color_selector.dart';
import '../widgets/sample_metric_card.dart';
import '../widgets/sample_task_bottom_sheet.dart';
import '../widgets/theme_mode_selector.dart';

class ThemeShowcaseScreen extends StatelessWidget {
  const ThemeShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // --- Header Bar ---
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        // ZenFlow Brand Logo
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: zen.accent,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: zen.accent.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              'Z',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ZenFlow',
                              style: AppTextStyles.headingMedium(zen.textPrimary),
                            ),
                            Text(
                              'Modular BLoC Architecture',
                              style: AppTextStyles.bodySmall(zen.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                    ZenIconButton(
                      icon: LucideIcons.bell,
                      hasBadge: true,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),

            // --- Body Content ---
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // --- Theme Appearance Card ---
                  ZenCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(LucideIcons.palette, size: 18, color: zen.accent),
                            const SizedBox(width: 8),
                            Text(
                              'Theme Appearance',
                              style: AppTextStyles.headingSmall(zen.textPrimary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const ThemeModeSelector(),
                        const SizedBox(height: 16),
                        Text(
                          'Accent Color',
                          style: AppTextStyles.labelMedium(zen.textSecondary),
                        ),
                        const SizedBox(height: 10),
                        const AccentColorSelector(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // --- Quick Metric Cards ---
                  Row(
                    children: [
                      Expanded(
                        child: SampleMetricCard(
                          title: 'Tasks Completed',
                          value: '0/4',
                          tag: 'Today',
                          icon: LucideIcons.circle_check,
                          tagColor: zen.accent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: SampleMetricCard(
                          title: 'Total Spending',
                          value: '৳24,788',
                          tag: 'Monthly',
                          icon: LucideIcons.wallet,
                          tagColor: AppColors.categoryBills,
                          iconColor: AppColors.categoryBills,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // --- Form & Button Primitives ---
                  ZenCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reusable Components (lib/core/widgets/)',
                          style: AppTextStyles.headingSmall(zen.textPrimary),
                        ),
                        const SizedBox(height: 14),
                        const ZenTextField(
                          hintText: 'e.g. Finalize Q3 roadmap...',
                          prefixIcon: Icon(LucideIcons.search, size: 18),
                        ),
                        const SizedBox(height: 14),
                        ZenButton(
                          label: 'Open Task Modal (Modular)',
                          icon: LucideIcons.plus,
                          onPressed: () => SampleTaskBottomSheet.show(context),
                        ),
                        const SizedBox(height: 10),
                        ZenButton(
                          label: 'Secondary Outlined Action',
                          variant: ZenButtonVariant.outlined,
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // --- Semantic Badges ---
                  ZenCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Semantic Categories & Badges',
                          style: AppTextStyles.headingSmall(zen.textPrimary),
                        ),
                        const SizedBox(height: 14),
                        const Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ZenBadge(label: 'Bills', color: AppColors.categoryBills),
                            ZenBadge(label: 'Education', color: AppColors.categoryEducation),
                            ZenBadge(label: 'Shopping', color: AppColors.categoryShopping),
                            ZenBadge(label: 'Subscription', color: AppColors.categorySubscription),
                            ZenBadge(label: 'Food', color: AppColors.categoryFood),
                            ZenBadge(label: 'On-Budget', color: AppColors.success),
                            ZenBadge(label: 'Overdue', color: AppColors.danger),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
