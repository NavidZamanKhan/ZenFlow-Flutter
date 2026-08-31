import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:intl/intl.dart';

import '../../../core/services/currency_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../expenses/services/expenses_service.dart';
import '../models/chart_segment.dart';
import '../models/daily_spending_point.dart';
import '../models/smart_trend_item.dart';
import 'insights_event.dart';
import 'insights_state.dart';

class InsightsBloc extends Bloc<InsightsEvent, InsightsState> {
  final ExpensesService _expensesService;
  final CurrencyService _currencyService;

  InsightsBloc({
    ExpensesService? expensesService,
    CurrencyService? currencyService,
  })  : _expensesService = expensesService ?? ExpensesService(),
        _currencyService = currencyService ?? CurrencyService(),
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
    await _computeAndEmitInsights(emit, state.timeRange, event.activeCurrency);
  }

  Future<void> _onRefresh(
    RefreshInsightsEvent event,
    Emitter<InsightsState> emit,
  ) async {
    await _computeAndEmitInsights(emit, state.timeRange, event.activeCurrency);
  }

  Future<void> _onTimeRangeChanged(
    TimeRangeChangedEvent event,
    Emitter<InsightsState> emit,
  ) async {
    emit(state.copyWith(timeRange: event.timeRange));
    await _computeAndEmitInsights(emit, event.timeRange, event.activeCurrency);
  }

  /// Converts an amount from its recorded currency to the active display currency.
  double _convert(double amount, String fromCurrency, String toCurrency) {
    if (fromCurrency == toCurrency || amount == 0) return amount;
    return _currencyService.convertAmount(
      amount: amount,
      toCurrency: toCurrency,
      fromCurrency: fromCurrency,
    );
  }

  Future<void> _computeAndEmitInsights(
    Emitter<InsightsState> emit,
    InsightsTimeRange range,
    String activeCurrency,
  ) async {
    try {
      final allExpenses = await _expensesService.getExpenses();
      final budgets = await _expensesService.getBudget(allExpenses);

      if (allExpenses.isEmpty) {
        emit(state.copyWith(status: InsightsStatus.success));
        return;
      }

      final now = DateTime.now();

      // 1. Calculate Total Spending & Month Spending matching Web
      double totalSpent = 0.0;
      final categoryTotals = <String, double>{};
      final uniqueDates = <String>{};

      for (final exp in allExpenses) {
        final converted = _convert(exp.amount, exp.currency, activeCurrency);
        totalSpent += converted;
        final dateStr = DateFormat('yyyy-MM-dd').format(exp.date);
        uniqueDates.add(dateStr);
      }

      double spentThisMonth = 0.0;
      final thisMonthExpenses = allExpenses.where(
        (exp) => exp.date.year == now.year && exp.date.month == now.month,
      );
      for (final exp in thisMonthExpenses) {
        spentThisMonth += _convert(exp.amount, exp.currency, activeCurrency);
      }

      // 2. Daily Average (Matches web: total spent / count of unique active spending dates)
      final dailyAverage = uniqueDates.isNotEmpty
          ? totalSpent / uniqueDates.length
          : 0.0;

      // 3. Category Segments (All-time mix converted)
      for (final exp in allExpenses) {
        final converted = _convert(exp.amount, exp.currency, activeCurrency);
        categoryTotals[exp.category] =
            (categoryTotals[exp.category] ?? 0.0) + converted;
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

      // 4. Payment Method Segments (Converted)
      final paymentTotals = <String, double>{};
      for (final exp in allExpenses) {
        final converted = _convert(exp.amount, exp.currency, activeCurrency);
        paymentTotals[exp.paymentMethod] =
            (paymentTotals[exp.paymentMethod] ?? 0.0) + converted;
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

      // 5. Daily Spending Points for current month (Converted)
      final dailyMap = <int, double>{};
      for (final exp in thisMonthExpenses) {
        final converted = _convert(exp.amount, exp.currency, activeCurrency);
        dailyMap[exp.date.day] = (dailyMap[exp.date.day] ?? 0.0) + converted;
      }

      final sortedDays = dailyMap.keys.toList()..sort();
      final dailyPoints = sortedDays.map((day) {
        return DailySpendingPoint(
          day: day,
          amount: dailyMap[day] ?? 0.0,
        );
      }).toList();

      // 6. Weekly Spending Breakdown (Mon..Sun, last 7 days converted)
      final weeklyAmounts = <double>[0, 0, 0, 0, 0, 0, 0];
      final sevenDaysAgo = now.subtract(const Duration(days: 7));
      final recentExpenses = allExpenses.where((e) => e.date.isAfter(sevenDaysAgo));
      for (final exp in recentExpenses) {
        final dayOfWeek = (exp.date.weekday - 1).clamp(0, 6);
        final converted = _convert(exp.amount, exp.currency, activeCurrency);
        weeklyAmounts[dayOfWeek] += converted;
      }

      // 7. Total Budget & Remaining (Converted from budget's base currency)
      final budgetCurrency =
          budgets.isNotEmpty ? budgets.first.currency : 'BDT';
      double rawBudgetTotal = 0.0;
      for (final b in budgets) {
        rawBudgetTotal += b.budgetAmount;
      }
      if (rawBudgetTotal == 0) rawBudgetTotal = 40000.0;

      final convertedBudget =
          _convert(rawBudgetTotal, budgetCurrency, activeCurrency);
      final remaining =
          (convertedBudget - spentThisMonth).clamp(0.0, double.infinity);
      final budgetUtilization =
          convertedBudget > 0 ? (spentThisMonth / convertedBudget) * 100 : 0.0;

      // 8. Smart Analytics & Trends
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
          value: _currencyService.formatMoney(
            amount: remaining,
            currency: activeCurrency,
          ),
          subtitle: 'Unspent budget this month.',
          icon: LucideIcons.sparkles,
          accentColor: const Color(0xFF8B5CF6),
        ),
      ];

      emit(state.copyWith(
        totalSpending: totalSpent,
        spentThisMonth: spentThisMonth,
        dailyAverage: dailyAverage,
        totalTransactions: allExpenses.length,
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
