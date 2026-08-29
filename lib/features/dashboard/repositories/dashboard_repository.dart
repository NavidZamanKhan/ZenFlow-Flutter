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

  Future<DashboardSnapshot> load() async {
    try {
      final results = await Future.wait([
        _apiClient.dio.get(ApiEndpoints.tasks),
        _apiClient.dio.get(ApiEndpoints.events),
        _apiClient.dio.get(ApiEndpoints.expenses),
        _apiClient.dio.get(ApiEndpoints.budget),
      ]);
      return DashboardSnapshot(
        tasks: _records(results[0])
            .map(FocusTask.fromJson)
            .toList(growable: false),
        events: _records(results[1])
            .map(DashboardEventItem.fromJson)
            .toList(growable: false),
        expenses: _records(results[2])
            .map(DashboardExpense.fromJson)
            .toList(growable: false),
        budget: DashboardBudget.fromJson(_map(results[3].data)),
      );
    } on DioException catch (error) {
      throw Exception(_message(error, 'Could not load your dashboard.'));
    }
  }

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
