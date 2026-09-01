import 'package:equatable/equatable.dart';

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

  factory InsightsState.initial() => const InsightsState(
        totalSpending: 0.0,
        spentThisMonth: 0.0,
        dailyAverage: 0.0,
        totalTransactions: 0,
        categorySegments: [],
        paymentSegments: [],
        dailyPoints: [],
        weeklyAmounts: [0, 0, 0, 0, 0, 0, 0],
        smartAnalytics: [],
        trendItems: [],
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
