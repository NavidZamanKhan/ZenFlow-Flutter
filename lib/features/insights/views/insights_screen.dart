import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/zenflow_theme.dart';
import '../../profile/bloc/profile_bloc.dart';
import '../../profile/bloc/profile_state.dart';
import '../bloc/insights_bloc.dart';
import '../bloc/insights_event.dart';
import '../bloc/insights_state.dart';
import '../widgets/animated_donut_chart.dart';
import '../widgets/daily_spending_chart.dart';
import '../widgets/insights_header.dart';
import '../widgets/insights_metrics_grid.dart';
import '../widgets/insights_time_range_bar.dart';
import '../widgets/smart_trends_card.dart';
import '../widgets/spending_breakdown_card.dart';
import '../widgets/weekly_spending_chart.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;
    final currency = context.select<ProfileBloc, String>(
      (b) => b.state.profile.currency,
    );

    return BlocListener<ProfileBloc, ProfileState>(
      listenWhen: (prev, curr) => prev.profile.currency != curr.profile.currency,
      listener: (context, profileState) {
        // When currency changes in profile, re-compute insights with new currency
        context.read<InsightsBloc>().add(
              RefreshInsightsEvent(activeCurrency: profileState.profile.currency),
            );
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: ColoredBox(
          color: zen.canvas,
          child: SafeArea(
            child: BlocBuilder<InsightsBloc, InsightsState>(
              builder: (context, state) {
                return RefreshIndicator(
                  color: zen.accent,
                  backgroundColor: zen.card,
                  onRefresh: () async {
                    context
                        .read<InsightsBloc>()
                        .add(RefreshInsightsEvent(activeCurrency: currency));
                    await Future.delayed(const Duration(milliseconds: 650));
                  },
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 118),
                    children: [
                      // Header
                      const InsightsHeader(),
                      const SizedBox(height: 16),

                      // Time-Range Segmented Switcher
                      InsightsTimeRangeBar(
                        activeRange: state.timeRange,
                        onRangeChanged: (newRange) {
                          context.read<InsightsBloc>().add(
                                TimeRangeChangedEvent(newRange,
                                    activeCurrency: currency),
                              );
                        },
                      ),
                      const SizedBox(height: 20),

                      // 4 Metrics Summary
                      InsightsMetricsGrid(
                        totalSpending: state.totalSpending,
                        spentThisMonth: state.spentThisMonth,
                        dailyAverage: state.dailyAverage,
                        totalTransactions: state.totalTransactions,
                        currency: currency,
                      ),
                      const SizedBox(height: 18),

                      // Expenses by Category Donut
                      AnimatedDonutChart(
                        title: 'Expenses by category',
                        subtitle: 'Your all-time category mix',
                        segments: state.categorySegments,
                        currency: currency,
                      ),
                      const SizedBox(height: 18),

                      // Daily Spending Spline Line Chart
                      DailySpendingChart(
                        points: state.dailyPoints,
                        currency: currency,
                      ),
                      const SizedBox(height: 18),

                      // Weekly Spending Bar Chart
                      WeeklySpendingChart(
                        weeklyAmounts: state.weeklyAmounts,
                        currency: currency,
                      ),
                      const SizedBox(height: 18),

                      // Payment Methods Donut
                      AnimatedDonutChart(
                        title: 'Payment methods',
                        subtitle: 'Distribution by amount spent',
                        segments: state.paymentSegments,
                        currency: currency,
                      ),
                      const SizedBox(height: 18),

                      // Category Spending Breakdown Bars
                      SpendingBreakdownCard(
                        segments: state.categorySegments,
                        currency: currency,
                      ),
                      const SizedBox(height: 18),

                      // Smart Analytics & Trends
                      SmartTrendsCard(
                        smartAnalytics: state.smartAnalytics,
                        trendItems: state.trendItems,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
