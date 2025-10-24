import 'package:flutter/material.dart';

/// Represents a single class schedule entry with day and time
class ClassScheduleEntry {
  final int dayOfWeek; // 1 = Monday, 2 = Tuesday, ..., 7 = Sunday
  final TimeOfDay time;

  ClassScheduleEntry({required this.dayOfWeek, required this.time});

  /// Get day name abbreviation
  String get dayName {
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return dayNames[dayOfWeek - 1];
  }

  /// Get full day name
  String get fullDayName {
    const dayNames = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return dayNames[dayOfWeek - 1];
  }

  /// Format time as 12-hour string
  String get formattedTime {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  /// Format time as 24-hour string for storage
  String get time24Hour {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Create from 24-hour time string
  static ClassScheduleEntry fromTimeString(int dayOfWeek, String timeString) {
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return ClassScheduleEntry(
      dayOfWeek: dayOfWeek,
      time: TimeOfDay(hour: hour, minute: minute),
    );
  }

  /// Convert to map for storage
  Map<String, dynamic> toMap() {
    return {'dayOfWeek': dayOfWeek, 'time': time24Hour};
  }

  /// Create from map
  static ClassScheduleEntry fromMap(Map<String, dynamic> map) {
    return fromTimeString(map['dayOfWeek'] as int, map['time'] as String);
  }

  /// Display string for UI
  @override
  String toString() {
    return '$dayName $formattedTime';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ClassScheduleEntry &&
        other.dayOfWeek == dayOfWeek &&
        other.time.hour == time.hour &&
        other.time.minute == time.minute;
  }

  @override
  int get hashCode => dayOfWeek.hashCode ^ time.hashCode;
}
