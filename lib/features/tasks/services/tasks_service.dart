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
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((e) => TaskItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['detail'] ?? 'Failed to load tasks from server.',
      );
    }
  }

  Future<TaskItem> createTask(TaskItem task) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.tasks,
        data: task.toJson(),
      );
      if (response.statusCode == 201 && response.data != null) {
        return TaskItem.fromJson(response.data as Map<String, dynamic>);
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
      if (response.statusCode == 200 && response.data != null) {
        return TaskItem.fromJson(response.data as Map<String, dynamic>);
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
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['detail'] ?? 'Failed to toggle task status.',
      );
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      await _apiClient.dio.delete('${ApiEndpoints.tasks}$id/');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['detail'] ?? 'Failed to delete task.',
      );
    }
  }
}
