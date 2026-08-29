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

  factory DashboardEventItem.fromJson(Map<String, dynamic> json) {
    final rawStart = json['start_datetime'] ?? json['startDatetime'] ?? json['start'];
    final rawAllDay = json['all_day'] == true || json['allDay'] == true;

    return DashboardEventItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled event',
      start: rawStart != null
          ? (DateTime.tryParse(rawStart.toString()) ?? DateTime.now())
          : DateTime.now(),
      isAllDay: rawAllDay,
    );
  }

  @override
  List<Object?> get props => [id, title, start, isAllDay];
}
