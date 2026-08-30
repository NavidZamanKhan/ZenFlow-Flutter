import 'package:dio/dio.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../models/calendar_item.dart';

class CalendarService {
  final ApiClient _apiClient;

  CalendarService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<List<CalendarItem>> getEvents() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.events);
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((e) => CalendarItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['detail'] ?? 'Failed to load events from server.',
      );
    }
  }

  Future<CalendarItem> createEvent(CalendarItem event) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.events,
        data: event.toJson(),
      );
      if (response.statusCode == 201 && response.data != null) {
        return CalendarItem.fromJson(response.data as Map<String, dynamic>);
      }
      throw Exception('Failed to create event.');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['detail'] ?? 'Failed to save event.',
      );
    }
  }

  Future<void> deleteEvent(String id) async {
    try {
      await _apiClient.dio.delete('${ApiEndpoints.events}$id/');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['detail'] ?? 'Failed to delete event.',
      );
    }
  }
}
