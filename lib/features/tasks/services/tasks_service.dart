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
      final payload = task.toJson(includeId: false);
      final response = await _apiClient.dio.post(
        ApiEndpoints.tasks,
        data: payload,
      );
      if (response.data is Map) {
        return TaskItem.fromJson(Map<String, dynamic>.from(response.data as Map));
      }
      throw Exception('Failed to create task.');
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Failed to save task on cloud.'));
    }
  }

  Future<TaskItem> updateTask(TaskItem task) async {
    try {
      final payload = task.toJson(includeId: false);
      final response = await _apiClient.dio.patch(
        '${ApiEndpoints.tasks}${task.id}/',
        data: payload,
      );
      if (response.data is Map) {
        return TaskItem.fromJson(Map<String, dynamic>.from(response.data as Map));
      }
      return task;
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Failed to update task on cloud.'));
    }
  }

  Future<void> toggleTask(String id, bool completed) async {
    try {
      await _apiClient.dio.patch(
        '${ApiEndpoints.tasks}$id/',
        data: {'completed': completed},
      );
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Failed to sync task status.'));
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      await _apiClient.dio.delete('${ApiEndpoints.tasks}$id/');
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Failed to delete task from cloud.'));
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

  String _extractErrorMessage(DioException e, String fallback) {
    if (e.response?.data != null) {
      final data = e.response!.data;
      if (data is Map) {
        final messages = <String>[];
        data.forEach((k, v) {
          if (v is List) {
            messages.add('$k: ${v.join(', ')}');
          } else if (v is String) {
            messages.add(v);
          }
        });
        if (messages.isNotEmpty) return messages.join('\n');
      }
    }
    return e.message ?? fallback;
  }
}
