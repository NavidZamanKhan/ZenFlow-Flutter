import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../models/chart_segment.dart';
import '../models/daily_spending_point.dart';
import '../models/smart_trend_item.dart';
import 'insights_event.dart';
import 'insights_state.dart';

class InsightsBloc extends Bloc<InsightsEvent, InsightsState> {
  InsightsBloc() : super(InsightsState.initial()) {
    on<LoadInsightsEvent>(_onLoad);
    on<RefreshInsightsEvent>(_onRefresh);

    add(const LoadInsightsEvent());
  }

  void _onLoad(LoadInsightsEvent event, Emitter<InsightsState> emit) {
    emit(state.copyWith(status: InsightsStatus.loading));

    final categorySegments = [
      const ChartSegment(
        label: 'Bills',
        amount: 16200.00,
        percentage: 79.9,
        color: Color(0xFF8B5CF6), // Violet
      ),
      const ChartSegment(
        label: 'Shopping',
        amount: 2500.00,
        percentage: 12.3,
        color: Color(0xFFEC4899), // Pink
      ),
      const ChartSegment(
        label: 'Subscription',
        amount: 1588.00,
        percentage: 7.8,
        color: Color(0xFF06B6D4), // Cyan
      ),
    ];

    final paymentSegments = [
      const ChartSegment(
        label: 'Card',
        amount: 16588.00,
        percentage: 81.8,
        color: Color(0xFF3B82F6), // Blue
      ),
      const ChartSegment(
        label: 'Cash',
        amount: 2500.00,
        percentage: 12.3,
        color: Color(0xFF06B6D4), // Cyan
      ),
      const ChartSegment(
        label: 'Mobile Wallet',
        amount: 1200.00,
        percentage: 5.8,
        color: Color(0xFF10B981), // Emerald
      ),
    ];

    // Generate 31 points with real peaks from transactions
    final dailyPoints = List.generate(31, (index) {
      final day = index + 1;
      double amount = 0;
      if (day == 5) amount = 15219;
      if (day == 8) amount = 1200;
      if (day == 10) amount = 1369;
      if (day == 27) amount = 2500;
      return DailySpendingPoint(day: day, amount: amount);
    });

    final weeklyAmounts = [0.0, 0.0, 0.0, 20288.0, 0.0, 0.0, 0.0];

    final smartAnalytics = [
      const SmartTrendItem(
        title: 'Highest category',
        value: 'Bills (৳16,200.00)',
        subtitle: 'Bills is your highest spending category.',
        icon: LucideIcons.trending_up,
        accentColor: Color(0xFF8B5CF6),
      ),
      const SmartTrendItem(
        title: 'Lowest category',
        value: 'Subscription (৳1,588.00)',
        subtitle: 'Subscription is your lowest active category.',
        icon: LucideIcons.trending_down,
        accentColor: Color(0xFF06B6D4),
      ),
      const SmartTrendItem(
        title: 'Daily average',
        value: '৳5,072.00 / day',
        subtitle: 'Average spending per active spending day.',
        icon: LucideIcons.sparkles,
        accentColor: Color(0xFF10B981),
      ),
      const SmartTrendItem(
        title: 'Recorded transactions',
        value: '6 transactions',
        subtitle: '6 transactions were recorded this month.',
        icon: LucideIcons.receipt,
        accentColor: Color(0xFF3B82F6),
      ),
    ];

    final trendItems = [
      const SmartTrendItem(
        title: 'Biggest category increase',
        value: 'Bills',
        subtitle: '৳16,200.00 more than last month',
        icon: LucideIcons.arrow_up_right,
        accentColor: Color(0xFF8B5CF6),
      ),
      const SmartTrendItem(
        title: 'Most active spending day',
        value: '08/05/2026',
        subtitle: '2 transactions recorded',
        icon: LucideIcons.calendar,
        accentColor: Color(0xFF3B82F6),
      ),
      const SmartTrendItem(
        title: 'Most expensive day',
        value: '08/05/2026',
        subtitle: '৳15,219.00 total spent',
        icon: LucideIcons.credit_card,
        accentColor: Color(0xFFEF4444),
      ),
      const SmartTrendItem(
        title: 'Largest single expense',
        value: 'Rent',
        subtitle: '৳15,000.00 on 08/05/2026',
        icon: LucideIcons.wallet,
        accentColor: Color(0xFFEC4899),
      ),
      const SmartTrendItem(
        title: 'Average transaction value',
        value: '৳3,381.33',
        subtitle: 'Across 6 transactions',
        icon: LucideIcons.chart_pie,
        accentColor: Color(0xFF06B6D4),
      ),
    ];

    emit(state.copyWith(
      totalSpending: 20288.00,
      spentThisMonth: 20288.00,
      dailyAverage: 5072.00,
      totalTransactions: 6,
      categorySegments: categorySegments,
      paymentSegments: paymentSegments,
      dailyPoints: dailyPoints,
      weeklyAmounts: weeklyAmounts,
      smartAnalytics: smartAnalytics,
      trendItems: trendItems,
      status: InsightsStatus.success,
    ));
  }

  void _onRefresh(RefreshInsightsEvent event, Emitter<InsightsState> emit) {
    add(const LoadInsightsEvent());
  }
}
