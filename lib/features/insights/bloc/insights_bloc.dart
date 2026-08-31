import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../expenses/services/expenses_service.dart';
import '../models/chart_segment.dart';
import '../models/daily_spending_point.dart';
import '../models/smart_trend_item.dart';
import 'insights_event.dart';
import 'insights_state.dart';

class InsightsBloc extends Bloc<InsightsEvent, InsightsState> {
  final ExpensesService _expensesService;

  InsightsBloc({ExpensesService? expensesService})
      : _expensesService = expensesService ?? ExpensesService(),
        super(InsightsState.initial()) {
    on<LoadInsightsEvent>(_onLoad);
    on<RefreshInsightsEvent>(_onRefresh);
    on<TimeRangeChangedEvent>(_onTimeRangeChanged);

    add(const LoadInsightsEvent());
  }

  Future<void> _onLoad(
    LoadInsightsEvent event,
    Emitter<InsightsState> emit,
  ) async {
    emit(state.copyWith(status: InsightsStatus.loading));
    await _computeAndEmitInsights(emit, state.timeRange);
  }

  Future<void> _onRefresh(
    RefreshInsightsEvent event,
    Emitter<InsightsState> emit,
  ) async {
    await _computeAndEmitInsights(emit, state.timeRange);
  }

  Future<void> _onTimeRangeChanged(
    TimeRangeChangedEvent event,
    Emitter<InsightsState> emit,
  ) async {
    emit(state.copyWith(timeRange: event.timeRange));
    await _computeAndEmitInsights(emit, event.timeRange);
  }

  Future<void> _computeAndEmitInsights(
    Emitter<InsightsState> emit,
    InsightsTimeRange range,
  ) async {
    try {
      final allExpenses = await _expensesService.getExpenses();
      final budgets = await _expensesService.getBudget(allExpenses);

      final now = DateTime.now();
      final filteredExpenses = allExpenses.where((exp) {
        switch (range) {
          case InsightsTimeRange.thisMonth:
            return exp.date.year == now.year && exp.date.month == now.month;
          case InsightsTimeRange.last30Days:
            return exp.date.isAfter(now.subtract(const Duration(days: 30)));
          case InsightsTimeRange.allTime:
            return true;
        }
      }).toList();

      if (filteredExpenses.isEmpty && allExpenses.isEmpty) {
        emit(state.copyWith(status: InsightsStatus.success));
        return;
      }

      final targetExpenses =
          filteredExpenses.isNotEmpty ? filteredExpenses : allExpenses;

      // 1. Category Segments
      final categoryTotals = <String, double>{};
      double totalSpent = 0.0;

      for (final exp in targetExpenses) {
        categoryTotals[exp.category] =
            (categoryTotals[exp.category] ?? 0.0) + exp.amount;
        totalSpent += exp.amount;
      }

      final categorySegments = categoryTotals.entries.map((e) {
        final pct = totalSpent > 0 ? (e.value / totalSpent) * 100 : 0.0;
        return ChartSegment(
          label: e.key,
          amount: e.value,
          percentage: pct,
          color: _colorForCategory(e.key),
        );
      }).toList()
        ..sort((a, b) => b.amount.compareTo(a.amount));

      // 2. Payment Method Segments
      final paymentTotals = <String, double>{};
      for (final exp in targetExpenses) {
        paymentTotals[exp.paymentMethod] =
            (paymentTotals[exp.paymentMethod] ?? 0.0) + exp.amount;
      }

      final paymentSegments = paymentTotals.entries.map((e) {
        final pct = totalSpent > 0 ? (e.value / totalSpent) * 100 : 0.0;
        return ChartSegment(
          label: e.key,
          amount: e.value,
          percentage: pct,
          color: _colorForPayment(e.key),
        );
      }).toList()
        ..sort((a, b) => b.amount.compareTo(a.amount));

      // 3. Daily Spending Points (Sorted by day)
      final dailyMap = <int, double>{};
      for (final exp in targetExpenses) {
        dailyMap[exp.date.day] = (dailyMap[exp.date.day] ?? 0.0) + exp.amount;
      }

      final sortedDays = dailyMap.keys.toList()..sort();
      final dailyPoints = sortedDays.map((day) {
        return DailySpendingPoint(
          day: day,
          amount: dailyMap[day] ?? 0.0,
        );
      }).toList();

      // 4. Weekly Spending Breakdown (Mon..Sun amounts)
      final weeklyAmounts = <double>[0, 0, 0, 0, 0, 0, 0];
      for (final exp in targetExpenses) {
        final dayOfWeek = (exp.date.weekday - 1).clamp(0, 6);
        weeklyAmounts[dayOfWeek] += exp.amount;
      }

      // 5. Total Budget & Remaining
      double totalBudget = 0.0;
      for (final b in budgets) {
        totalBudget += b.budgetAmount;
      }
      if (totalBudget == 0) totalBudget = 40000.0;

      final remaining = (totalBudget - totalSpent).clamp(0.0, double.infinity);
      final budgetUtilization =
          totalBudget > 0 ? (totalSpent / totalBudget) * 100 : 0.0;
      final dailyAverage = totalSpent / (DateTime.now().day.clamp(1, 31));

      // 6. Smart Analytics & Trends
      final topCategory = categorySegments.isNotEmpty
          ? categorySegments.first.label
          : 'Bills';
      final topCategoryPct = categorySegments.isNotEmpty
          ? categorySegments.first.percentage.toStringAsFixed(1)
          : '0.0';

      final smartAnalytics = [
        SmartTrendItem(
          title: 'Budget Health',
          value: '${budgetUtilization.toStringAsFixed(1)}%',
          subtitle: 'of total monthly limit used.',
          icon: LucideIcons.trending_down,
          accentColor: AppColors.success,
        ),
        SmartTrendItem(
          title: 'Top Category',
          value: topCategory,
          subtitle: '$topCategoryPct% of all transactions.',
          icon: LucideIcons.circle_alert,
          accentColor: AppColors.warning,
        ),
      ];

      final trendItems = [
        SmartTrendItem(
          title: 'Preferred Payment',
          value: paymentSegments.isNotEmpty
              ? paymentSegments.first.label
              : 'Card',
          subtitle: 'Primary payment method used.',
          icon: LucideIcons.credit_card,
          accentColor: AppColors.info,
        ),
        SmartTrendItem(
          title: 'Savings Potential',
          value: '৳${NumberFormat('#,##0').format(remaining)}',
          subtitle: 'Unspent budget this month.',
          icon: LucideIcons.sparkles,
          accentColor: const Color(0xFF8B5CF6),
        ),
      ];

      emit(state.copyWith(
        totalSpending: totalSpent,
        spentThisMonth: totalSpent,
        dailyAverage: dailyAverage,
        totalTransactions: targetExpenses.length,
        categorySegments: categorySegments,
        paymentSegments: paymentSegments,
        dailyPoints: dailyPoints.isNotEmpty ? dailyPoints : state.dailyPoints,
        weeklyAmounts: weeklyAmounts,
        smartAnalytics: smartAnalytics,
        trendItems: trendItems,
        status: InsightsStatus.success,
      ));
    } catch (_) {
      emit(state.copyWith(status: InsightsStatus.success));
    }
  }

  Color _colorForCategory(String cat) {
    switch (cat.toLowerCase()) {
      case 'bills':
        return AppColors.categoryBills;
      case 'shopping':
        return AppColors.categoryShopping;
      case 'subscription':
        return AppColors.categorySubscription;
      case 'education':
        return AppColors.categoryEducation;
      case 'food':
        return AppColors.categoryFood;
      case 'transportation':
        return AppColors.categoryTransportation;
      case 'healthcare':
        return AppColors.categoryHealthcare;
      case 'travel':
        return AppColors.categoryTravel;
      default:
        return AppColors.categoryOthers;
    }
  }

  Color _colorForPayment(String method) {
    switch (method.toLowerCase()) {
      case 'card':
        return const Color(0xFF3B82F6);
      case 'cash':
        return const Color(0xFF10B981);
      case 'mobile wallet':
      case 'mobile':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF8B5CF6);
    }
  }
}
