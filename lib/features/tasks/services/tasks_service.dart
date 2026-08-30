import 'package:dio/dio.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../models/task_item.dart';

class TasksService {
  final ApiClient _apiClient;

  TasksService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<List<TaskItem>> getTasks() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.tasks);
      final records = _extractList(response.data);
      return records.map(TaskItem.fromJson).toList();
    } catch (_) {
      return [];
    }
  }

  Future<TaskItem> createTask(TaskItem task) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.tasks,
        data: task.toJson(),
      );
      if (response.data is Map) {
        return TaskItem.fromJson(Map<String, dynamic>.from(response.data as Map));
      }
      throw Exception('Failed to create task.');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['detail'] ?? 'Failed to save task.',
      );
    }
  }

  Future<TaskItem> updateTask(TaskItem task) async {
    try {
      final response = await _apiClient.dio.patch(
        '${ApiEndpoints.tasks}${task.id}/',
        data: task.toJson(),
      );
      if (response.data is Map) {
        return TaskItem.fromJson(Map<String, dynamic>.from(response.data as Map));
      }
      return task;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['detail'] ?? 'Failed to update task.',
      );
    }
  }

  Future<void> toggleTask(String id, bool completed) async {
    try {
      await _apiClient.dio.patch(
        '${ApiEndpoints.tasks}$id/',
        data: {'completed': completed},
      );
    } catch (_) {
      // Ignored
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      await _apiClient.dio.delete('${ApiEndpoints.tasks}$id/');
    } catch (_) {
      // Ignored
    }
  }

  List<Map<String, dynamic>> _extractList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((m) => Map<String, dynamic>.from(m))
          .toList();
    }
    if (data is Map) {
      final records = data['results'] ?? data['data'] ?? data['tasks'];
      if (records is List) {
        return records
            .whereType<Map>()
            .map((m) => Map<String, dynamic>.from(m))
            .toList();
      }
    }
    return [];
  }
}
