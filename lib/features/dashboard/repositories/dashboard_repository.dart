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
    // Fetch tasks, events, expenses, and budget in parallel with independent fault isolation
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
      return _records(response).map(DashboardEventItem.fromJson).toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  Future<List<DashboardExpense>> _fetchExpenses() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.expenses);
      return _records(response).map(DashboardExpense.fromJson).toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  Future<DashboardBudget> _fetchBudget() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.budget);
      if (response.data is Map) {
        return DashboardBudget.fromJson(Map<String, dynamic>.from(response.data as Map));
      }
      return DashboardBudget.empty();
    } catch (_) {
      return DashboardBudget.empty();
    }
  }

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
    if (data is Map && data['detail'] != null) return data['detail'].toString();
    return fallback;
  }
}
