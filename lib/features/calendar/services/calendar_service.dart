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
      final records = _extractList(response.data);
      return records.map(CalendarItem.fromJson).toList();
    } catch (_) {
      return [];
    }
  }

  Future<CalendarItem> createEvent(CalendarItem event) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.events,
        data: event.toJson(),
      );
      if (response.data is Map) {
        return CalendarItem.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
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
      final records = data['results'] ?? data['data'] ?? data['events'];
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
