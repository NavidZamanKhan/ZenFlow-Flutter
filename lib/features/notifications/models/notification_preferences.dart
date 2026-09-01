import 'dart:convert';
import 'package:equatable/equatable.dart';

class NotificationPreferences extends Equatable {
  final bool tasksEnabled;
  final bool calendarEnabled;
  final bool budgetEnabled;
  final bool digestEnabled;
  final String digestTime; // e.g. "09:00" (24h format)
  final bool hasPromptedPermission;

  const NotificationPreferences({
    this.tasksEnabled = true,
    this.calendarEnabled = true,
    this.budgetEnabled = true,
    this.digestEnabled = true,
    this.digestTime = '09:00',
    this.hasPromptedPermission = false,
  });

  NotificationPreferences copyWith({
    bool? tasksEnabled,
    bool? calendarEnabled,
    bool? budgetEnabled,
    bool? digestEnabled,
    String? digestTime,
    bool? hasPromptedPermission,
  }) {
    return NotificationPreferences(
      tasksEnabled: tasksEnabled ?? this.tasksEnabled,
      calendarEnabled: calendarEnabled ?? this.calendarEnabled,
      budgetEnabled: budgetEnabled ?? this.budgetEnabled,
      digestEnabled: digestEnabled ?? this.digestEnabled,
      digestTime: digestTime ?? this.digestTime,
      hasPromptedPermission:
          hasPromptedPermission ?? this.hasPromptedPermission,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tasksEnabled': tasksEnabled,
      'calendarEnabled': calendarEnabled,
      'budgetEnabled': budgetEnabled,
      'digestEnabled': digestEnabled,
      'digestTime': digestTime,
      'hasPromptedPermission': hasPromptedPermission,
    };
  }

  factory NotificationPreferences.fromMap(Map<String, dynamic> map) {
    return NotificationPreferences(
      tasksEnabled: map['tasksEnabled'] ?? true,
      calendarEnabled: map['calendarEnabled'] ?? true,
      budgetEnabled: map['budgetEnabled'] ?? true,
      digestEnabled: map['digestEnabled'] ?? true,
      digestTime: map['digestTime'] ?? '09:00',
      hasPromptedPermission: map['hasPromptedPermission'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory NotificationPreferences.fromJson(String source) =>
      NotificationPreferences.fromMap(
          json.decode(source) as Map<String, dynamic>);

  @override
  List<Object?> get props => [
        tasksEnabled,
        calendarEnabled,
        budgetEnabled,
        digestEnabled,
        digestTime,
        hasPromptedPermission,
      ];
}
