import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_colors.dart';
import 'core/theme/app_text_styles.dart';
import 'core/theme/theme_provider.dart';
import 'core/theme/zenflow_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: ZenFlowApp(),
    ),
  );
}

class ZenFlowApp extends ConsumerWidget {
  const ZenFlowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);

    return MaterialApp(
      title: 'ZenFlow',
      debugShowCheckedModeBanner: false,
      themeMode: themeState.themeMode,
      theme: ZenFlowTheme.lightTheme(themeState.accentColor),
      darkTheme: ZenFlowTheme.darkTheme(themeState.accentColor),
      home: const ThemeShowcaseScreen(),
    );
  }
}

class ThemeShowcaseScreen extends ConsumerWidget {
  const ThemeShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
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
                        // ZenFlow Z Logo Mark
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
                              'Theme & Design System',
                              style: AppTextStyles.bodySmall(zen.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Notification Icon with Counter
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: zen.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: zen.border),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(LucideIcons.bell, size: 18, color: zen.textPrimary),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.danger,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- Main Content ---
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // --- Theme Mode Selector Card ---
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: zen.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: zen.border),
                    ),
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
                        const SizedBox(width: 0, height: 14),
                        Row(
                          children: [
                            _ThemeModeOption(
                              title: 'Light',
                              icon: LucideIcons.sun,
                              isSelected: themeState.themeMode == ThemeMode.light,
                              onTap: () => themeNotifier.setThemeMode(ThemeMode.light),
                            ),
                            const SizedBox(width: 8),
                            _ThemeModeOption(
                              title: 'Dark',
                              icon: LucideIcons.moon,
                              isSelected: themeState.themeMode == ThemeMode.dark,
                              onTap: () => themeNotifier.setThemeMode(ThemeMode.dark),
                            ),
                            const SizedBox(width: 8),
                            _ThemeModeOption(
                              title: 'System',
                              icon: LucideIcons.laptop,
                              isSelected: themeState.themeMode == ThemeMode.system,
                              onTap: () => themeNotifier.setThemeMode(ThemeMode.system),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Accent Color',
                          style: AppTextStyles.labelMedium(zen.textSecondary),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: AppAccentColor.values.map((accent) {
                            final palette = AppColors.accents[accent]!;
                            final isSelected = themeState.accentColor == accent;
                            return InkWell(
                              onTap: () => themeNotifier.setAccentColor(accent),
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
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // --- Quick Metric Cards Preview ---
                  Row(
                    children: [
                      // Metric 1: Tasks
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: zen.card,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: zen.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(LucideIcons.circle_check, size: 18, color: zen.accent),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: zen.accentLightBg,
                                      borderRadius: BorderRadius.circular(100),
                                      border: Border.all(color: zen.accentLightBorder),
                                    ),
                                    child: Text(
                                      'Today',
                                      style: AppTextStyles.labelSmall(zen.accent),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '0/4',
                                style: AppTextStyles.statNumber(zen.textPrimary),
                              ),
                              Text(
                                'Tasks Completed',
                                style: AppTextStyles.bodySmall(zen.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Metric 2: Monthly Spend
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: zen.card,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: zen.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(LucideIcons.wallet, size: 18, color: AppColors.categoryBills),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.categoryBills.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: Text(
                                      'Monthly',
                                      style: AppTextStyles.labelSmall(AppColors.categoryBills),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '৳24,788',
                                style: AppTextStyles.statNumber(zen.textPrimary),
                              ),
                              Text(
                                'Total Spending',
                                style: AppTextStyles.bodySmall(zen.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // --- UI Elements Preview Card ---
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: zen.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: zen.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Components & Form Controls',
                          style: AppTextStyles.headingSmall(zen.textPrimary),
                        ),
                        const SizedBox(height: 14),
                        // Text Field
                        TextField(
                          decoration: InputDecoration(
                            hintText: 'e.g. Finalize Q3 roadmap...',
                            prefixIcon: Icon(LucideIcons.search, size: 18, color: zen.textMuted),
                          ),
                        ),
                        const SizedBox(height: 14),
                        // Primary Button
                        ElevatedButton.icon(
                          onPressed: () {
                            _showSampleTaskModal(context);
                          },
                          icon: const Icon(LucideIcons.plus, size: 18),
                          label: const Text('Open Sample New Task Modal'),
                        ),
                        const SizedBox(height: 10),
                        // Outlined Button
                        OutlinedButton(
                          onPressed: () {},
                          child: const Text('Secondary Outlined Action'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // --- Category Pills Preview ---
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: zen.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: zen.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Semantic Categories & Badges',
                          style: AppTextStyles.headingSmall(zen.textPrimary),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: const [
                            _CategoryPill(label: 'Bills', color: AppColors.categoryBills),
                            _CategoryPill(label: 'Education', color: AppColors.categoryEducation),
                            _CategoryPill(label: 'Shopping', color: AppColors.categoryShopping),
                            _CategoryPill(label: 'Subscription', color: AppColors.categorySubscription),
                            _CategoryPill(label: 'Food', color: AppColors.categoryFood),
                            _CategoryPill(label: 'On-Budget', color: AppColors.success),
                            _CategoryPill(label: 'Overdue', color: AppColors.danger),
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

  void _showSampleTaskModal(BuildContext context) {
    final zen = context.zenColors;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: zen.surface,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'New Task',
                    style: AppTextStyles.headingMedium(zen.textPrimary),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: Icon(LucideIcons.x, color: zen.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Title',
                  hintText: 'e.g. Finalize Q3 roadmap',
                ),
              ),
              const SizedBox(height: 14),
              const TextField(
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Description (optional)',
                  hintText: 'Add details, links, or notes...',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Create Task'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ThemeModeOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeModeOption({
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

class _CategoryPill extends StatelessWidget {
  final String label;
  final Color color;

  const _CategoryPill({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.labelSmall(color),
          ),
        ],
      ),
    );
  }
}
