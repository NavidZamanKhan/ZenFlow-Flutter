import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../core/theme/app_colors.dart';
import '../models/chart_segment.dart';
import '../models/daily_spending_point.dart';
import '../models/smart_trend_item.dart';

enum InsightsStatus { initial, loading, success, failure }
enum InsightsTimeRange { allTime, thisMonth, last30Days }

class InsightsState extends Equatable {
  final double totalSpending;
  final double spentThisMonth;
  final double dailyAverage;
  final int totalTransactions;
  final List<ChartSegment> categorySegments;
  final List<ChartSegment> paymentSegments;
  final List<DailySpendingPoint> dailyPoints;
  final List<double> weeklyAmounts; // Mon..Sun
  final List<SmartTrendItem> smartAnalytics;
  final List<SmartTrendItem> trendItems;
  final InsightsTimeRange timeRange;
  final InsightsStatus status;

  const InsightsState({
    required this.totalSpending,
    required this.spentThisMonth,
    required this.dailyAverage,
    required this.totalTransactions,
    required this.categorySegments,
    required this.paymentSegments,
    required this.dailyPoints,
    required this.weeklyAmounts,
    required this.smartAnalytics,
    required this.trendItems,
    this.timeRange = InsightsTimeRange.thisMonth,
    this.status = InsightsStatus.initial,
  });

  factory InsightsState.initial() => InsightsState(
        totalSpending: 20288.0,
        spentThisMonth: 20288.0,
        dailyAverage: 654.45,
        totalTransactions: 6,
        categorySegments: const [
          ChartSegment(
            label: 'Bills',
            amount: 16200.0,
            percentage: 79.8,
            color: AppColors.categoryBills,
          ),
          ChartSegment(
            label: 'Shopping',
            amount: 2500.0,
            percentage: 12.3,
            color: AppColors.categoryShopping,
          ),
          ChartSegment(
            label: 'Subscription',
            amount: 1588.0,
            percentage: 7.8,
            color: AppColors.categorySubscription,
          ),
        ],
        paymentSegments: const [
          ChartSegment(
            label: 'Card',
            amount: 16200.0,
            percentage: 79.8,
            color: Color(0xFF3B82F6),
          ),
          ChartSegment(
            label: 'Mobile Wallet',
            amount: 2500.0,
            percentage: 12.3,
            color: Color(0xFFF59E0B),
          ),
          ChartSegment(
            label: 'Cash',
            amount: 1588.0,
            percentage: 7.8,
            color: Color(0xFF10B981),
          ),
        ],
        dailyPoints: const [
          DailySpendingPoint(day: 5, amount: 1200),
          DailySpendingPoint(day: 10, amount: 1588),
          DailySpendingPoint(day: 15, amount: 15000),
          DailySpendingPoint(day: 20, amount: 2500),
        ],
        weeklyAmounts: const [15000, 1200, 169, 1200, 219, 2500, 0],
        smartAnalytics: const [
          SmartTrendItem(
            title: 'Budget Health',
            value: '50.7%',
            subtitle: 'of total monthly limit used.',
            icon: LucideIcons.trending_down,
            accentColor: AppColors.success,
          ),
          SmartTrendItem(
            title: 'Top Category',
            value: 'Bills',
            subtitle: '79.8% of all transactions.',
            icon: LucideIcons.circle_alert,
            accentColor: AppColors.warning,
          ),
        ],
        trendItems: const [
          SmartTrendItem(
            title: 'Preferred Payment',
            value: 'Card',
            subtitle: 'Primary payment method used.',
            icon: LucideIcons.credit_card,
            accentColor: AppColors.info,
          ),
          SmartTrendItem(
            title: 'Savings Potential',
            value: '৳19,712',
            subtitle: 'Unspent budget this month.',
            icon: LucideIcons.sparkles,
            accentColor: Color(0xFF8B5CF6),
          ),
        ],
        timeRange: InsightsTimeRange.thisMonth,
        status: InsightsStatus.initial,
      );

  InsightsState copyWith({
    double? totalSpending,
    double? spentThisMonth,
    double? dailyAverage,
    int? totalTransactions,
    List<ChartSegment>? categorySegments,
    List<ChartSegment>? paymentSegments,
    List<DailySpendingPoint>? dailyPoints,
    List<double>? weeklyAmounts,
    List<SmartTrendItem>? smartAnalytics,
    List<SmartTrendItem>? trendItems,
    InsightsTimeRange? timeRange,
    InsightsStatus? status,
  }) {
    return InsightsState(
      totalSpending: totalSpending ?? this.totalSpending,
      spentThisMonth: spentThisMonth ?? this.spentThisMonth,
      dailyAverage: dailyAverage ?? this.dailyAverage,
      totalTransactions: totalTransactions ?? this.totalTransactions,
      categorySegments: categorySegments ?? this.categorySegments,
      paymentSegments: paymentSegments ?? this.paymentSegments,
      dailyPoints: dailyPoints ?? this.dailyPoints,
      weeklyAmounts: weeklyAmounts ?? this.weeklyAmounts,
      smartAnalytics: smartAnalytics ?? this.smartAnalytics,
      trendItems: trendItems ?? this.trendItems,
      timeRange: timeRange ?? this.timeRange,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
        totalSpending,
        spentThisMonth,
        dailyAverage,
        totalTransactions,
        categorySegments,
        paymentSegments,
        dailyPoints,
        weeklyAmounts,
        smartAnalytics,
        trendItems,
        timeRange,
        status,
      ];
}
