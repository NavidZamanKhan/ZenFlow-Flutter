import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:intl/intl.dart';

import '../../../core/services/currency_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../calendar/models/calendar_item.dart';
import '../../expenses/models/expense_item.dart';
import '../../tasks/models/task_item.dart';
import '../models/search_result_item.dart';

class StaticDestination {
  final String id;
  final String title;
  final String subtitle;
  final List<String> keywords;
  final IconData icon;
  final int tabIndex; // -1 for custom route
  final String? routeName;

  const StaticDestination({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.keywords,
    required this.icon,
    this.tabIndex = -1,
    this.routeName,
  });
}

class SearchService {
  static const List<StaticDestination> staticDestinations = [
    StaticDestination(
      id: 'page_overview',
      title: 'Overview',
      subtitle: 'Dashboard home & daily focus',
      keywords: ['home', 'dashboard', 'overview', 'focus', 'today'],
      icon: LucideIcons.layout_dashboard,
      tabIndex: 0,
    ),
    StaticDestination(
      id: 'page_tasks',
      title: 'Tasks',
      subtitle: 'Task checklist & priorities',
      keywords: ['todo', 'checklist', 'tasks', 'action'],
      icon: LucideIcons.list_todo,
      tabIndex: 1,
    ),
    StaticDestination(
      id: 'page_calendar',
      title: 'Calendar',
      subtitle: 'Events, deadlines & schedule',
      keywords: ['schedule', 'events', 'calendar', 'dates', 'agenda'],
      icon: LucideIcons.calendar_days,
      tabIndex: 2,
    ),
    StaticDestination(
      id: 'page_expenses',
      title: 'Expenses',
      subtitle: 'Spending tracker & budget',
      keywords: ['spending', 'money', 'expenses', 'budget', 'transactions'],
      icon: LucideIcons.credit_card,
      tabIndex: 3,
    ),
    StaticDestination(
      id: 'page_insights',
      title: 'Insights',
      subtitle: 'Financial analytics & trends',
      keywords: ['charts', 'analytics', 'reports', 'insights', 'statistics'],
      icon: LucideIcons.chart_spline,
      tabIndex: 4,
    ),
    StaticDestination(
      id: 'page_profile',
      title: 'Profile & Account',
      subtitle: 'Personal info & login security',
      keywords: ['account', 'user', 'name', 'email', 'profile', 'password'],
      icon: LucideIcons.user,
      routeName: 'profile',
    ),
    StaticDestination(
      id: 'page_appearance',
      title: 'Appearance',
      subtitle: 'Theme, dark mode & accent colors',
      keywords: ['theme', 'dark', 'light', 'appearance', 'color', 'accent'],
      icon: LucideIcons.palette,
      routeName: 'appearance',
    ),
    StaticDestination(
      id: 'page_expense_preferences',
      title: 'Expense Preferences',
      subtitle: 'Currency & payment methods',
      keywords: ['currency', 'payment', 'bdt', 'usd', 'preferences'],
      icon: LucideIcons.sliders_horizontal,
      routeName: 'expense_prefs',
    ),
  ];

  static bool _matches(String query, List<String?> fields) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    for (final field in fields) {
      if (field != null && field.trim().toLowerCase().contains(q)) {
        return true;
      }
    }
    return false;
  }

  List<SearchResultItem> search({
    required String rawQuery,
    required SearchFilter filter,
    required List<TaskItem> tasks,
    required List<ExpenseItem> expenses,
    required List<CalendarItem> events,
    required String activeCurrency,
    int limitPerCategory = 6,
  }) {
    final query = rawQuery.trim().toLowerCase();
    final results = <SearchResultItem>[];

    // 1. Pages / Navigation Shortcuts
    if (filter == SearchFilter.all || filter == SearchFilter.pages) {
      final matchedPages = staticDestinations.where((dest) {
        if (query.isEmpty) return true;
        return _matches(query, [
          dest.title,
          dest.subtitle,
          ...dest.keywords,
        ]);
      }).take(limitPerCategory);

      for (final p in matchedPages) {
        results.add(
          SearchResultItem(
            id: p.id,
            title: p.title,
            subtitle: p.subtitle,
            type: SearchResultType.page,
            icon: p.icon,
            rawData: p,
          ),
        );
      }
    }

    // 2. Tasks
    if (filter == SearchFilter.all || filter == SearchFilter.tasks) {
      final matchedTasks = tasks.where((t) {
        if (query.isEmpty) return false;
        return _matches(query, [
          t.title,
          t.description,
          t.category,
          t.priority.name,
        ]);
      }).take(limitPerCategory);

      for (final t in matchedTasks) {
        results.add(
          SearchResultItem(
            id: 'task_${t.id}',
            title: t.title,
            subtitle: t.category.isNotEmpty
                ? '${t.category} · ${t.isCompleted ? 'Completed' : t.priority.name.toUpperCase()}'
                : (t.isCompleted ? 'Completed' : t.priority.name.toUpperCase()),
            type: SearchResultType.task,
            icon: t.isCompleted ? LucideIcons.circle_check : LucideIcons.circle,
            color: t.isCompleted ? AppColors.success : null,
            badge: t.isCompleted ? 'Done' : t.priority.name.toUpperCase(),
            rawData: t,
          ),
        );
      }
    }

    // 3. Expenses
    if (filter == SearchFilter.all || filter == SearchFilter.expenses) {
      final matchedExpenses = expenses.where((e) {
        if (query.isEmpty) return false;
        return _matches(query, [
          e.title,
          e.notes,
          e.category,
          e.paymentMethod,
          e.amount.toString(),
          ...e.tags,
        ]);
      }).take(limitPerCategory);

      for (final e in matchedExpenses) {
        final formattedMoney = CurrencyService().formatMoney(
          amount: e.amount,
          currency: e.currency.isNotEmpty ? e.currency : activeCurrency,
        );
        final dateStr = DateFormat('MMM d').format(e.date);

        results.add(
          SearchResultItem(
            id: 'expense_${e.id}',
            title: e.title,
            subtitle: '$dateStr · ${e.category} · ${e.paymentMethod}',
            type: SearchResultType.expense,
            icon: LucideIcons.receipt,
            badge: formattedMoney,
            rawData: e,
          ),
        );
      }
    }

    // 4. Calendar Events
    if (filter == SearchFilter.all || filter == SearchFilter.events) {
      final matchedEvents = events.where((ev) {
        if (query.isEmpty) return false;
        return _matches(query, [
          ev.title,
          ev.description,
          ev.category,
        ]);
      }).take(limitPerCategory);

      for (final ev in matchedEvents) {
        final dateStr = DateFormat('EEE, MMM d').format(ev.startDateTime);
        results.add(
          SearchResultItem(
            id: 'event_${ev.id}',
            title: ev.title,
            subtitle: '$dateStr · ${ev.formattedTime}',
            type: SearchResultType.event,
            icon: LucideIcons.calendar,
            badge: ev.category,
            rawData: ev,
          ),
        );
      }
    }

    return results;
  }
}
