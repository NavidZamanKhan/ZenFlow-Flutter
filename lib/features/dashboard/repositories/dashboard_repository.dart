import 'dart:async';
import 'package:dio/dio.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../models/dashboard_budget.dart';
import '../models/dashboard_event.dart';
import '../models/dashboard_expense.dart';
import '../models/focus_task.dart';

class DashboardSnapshot {
  final List<FocusTask> tasks;
  final List<DashboardEventItem> events;
  final List<DashboardExpense> expenses;
  final DashboardBudget budget;

  const DashboardSnapshot({
    required this.tasks,
    required this.events,
    required this.expenses,
    required this.budget,
  });
}

class DashboardRepository {
  final ApiClient _apiClient;

  DashboardRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Loads full dashboard data with resilient individual fallback handling
  Future<DashboardSnapshot> load() async {
    final tasksFuture = _fetchTasks();
    final eventsFuture = _fetchEvents();
    final expensesFuture = _fetchExpenses();
    final budgetFuture = _fetchBudget();

    final results = await Future.wait([
      tasksFuture,
      eventsFuture,
      expensesFuture,
      budgetFuture,
    ]);

    return DashboardSnapshot(
      tasks: results[0] as List<FocusTask>,
      events: results[1] as List<DashboardEventItem>,
      expenses: results[2] as List<DashboardExpense>,
      budget: results[3] as DashboardBudget,
    );
  }

  Future<List<FocusTask>> _fetchTasks() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.tasks);
      return _records(response).map(FocusTask.fromJson).toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  Future<List<DashboardEventItem>> _fetchEvents() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.events);
      return _records(response)
          .map(DashboardEventItem.fromJson)
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  Future<List<DashboardExpense>> _fetchExpenses() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.expenses);
      final list = _records(response)
          .map(DashboardExpense.fromJson)
          .toList(growable: false);
      if (list.isNotEmpty) return list;
      return _defaultExpenses;
    } catch (_) {
      return _defaultExpenses;
    }
  }

  Future<DashboardBudget> _fetchBudget() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.budget);
      if (response.data is Map) {
        return DashboardBudget.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
      }
      return _defaultBudget;
    } catch (_) {
      return _defaultBudget;
    }
  }

  static final List<DashboardExpense> _defaultExpenses = [
    DashboardExpense(
      id: '1',
      title: 'Have to buy a mouse',
      amount: 2500,
      currency: '৳',
      category: 'Shopping',
      date: _staticDate,
    ),
    DashboardExpense(
      id: '2',
      title: 'Internet bill',
      amount: 1200,
      currency: '৳',
      category: 'Bills',
      date: _staticDate,
    ),
    DashboardExpense(
      id: '3',
      title: 'YouTube',
      amount: 169,
      currency: '৳',
      category: 'Subscription',
      date: _staticDate,
    ),
    DashboardExpense(
      id: '4',
      title: 'Netflix',
      amount: 1200,
      currency: '৳',
      category: 'Subscription',
      date: _staticDate,
    ),
    DashboardExpense(
      id: '5',
      title: 'Spotify',
      amount: 219,
      currency: '৳',
      category: 'Subscription',
      date: _staticDate,
    ),
    DashboardExpense(
      id: '6',
      title: 'Rent',
      amount: 15000,
      currency: '৳',
      category: 'Bills',
      date: _staticDate,
    ),
  ];

  static const DashboardBudget _defaultBudget = DashboardBudget(
    monthlyTotal: 40000,
    currency: '৳',
  );

  static final DateTime _staticDate = DateTime(2026, 8, 15);

  /// Toggles task completion state with live Django backend sync
  Future<FocusTask> toggleTask(FocusTask task) async {
    try {
      final response = await _apiClient.dio.patch(
        '${ApiEndpoints.tasks}${task.id}/',
        data: {'completed': !task.isComplete},
      );
      return FocusTask.fromJson(_map(response.data));
    } on DioException catch (error) {
      throw Exception(_message(error, 'Could not update this task.'));
    }
  }

  List<Map<String, dynamic>> _records(Response<dynamic> response) {
    final data = response.data;
    final records = data is Map ? data['results'] : data;
    return records is List
        ? records.whereType<Map>().map(_map).toList()
        : const [];
  }

  Map<String, dynamic> _map(dynamic value) => value is Map<String, dynamic>
      ? value
      : Map<String, dynamic>.from(value as Map);

  String _message(DioException error, String fallback) {
    final data = error.response?.data;
    if (data is Map && data['detail'] != null) {
      return data['detail'].toString();
    }
    return fallback;
  }
}
