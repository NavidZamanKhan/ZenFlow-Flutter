import 'package:equatable/equatable.dart';

class DashboardEventItem extends Equatable {
  final String id;
  final String title;
  final DateTime start;
  final bool isAllDay;

  const DashboardEventItem({
    required this.id,
    required this.title,
    required this.start,
    required this.isAllDay,
  });

  factory DashboardEventItem.fromJson(Map<String, dynamic> json) =>
      DashboardEventItem(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? 'Untitled event',
        start:
            DateTime.tryParse(json['start_datetime']?.toString() ?? '') ??
            DateTime.now(),
        isAllDay: json['all_day'] == true,
      );

  @override
  List<Object?> get props => [id, title, start, isAllDay];
}
