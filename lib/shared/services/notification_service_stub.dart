// Web stub for NotificationService.
// Browser notifications require a completely different API; local notifications
// are a mobile concept.  All methods are safe no-ops on web.

import 'package:get/get.dart';

class NotificationService extends GetxService {
  @override
  void onInit() => super.onInit();

  Future<void> initialize() async {}

  Future<bool> canScheduleExactAlarms() async => false;
  Future<void> ensureExactAlarmPermission() async {}

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String channelId = '',
  }) async {}

  Future<void> showCourseReminderNotification({
    required int id,
    required String courseName,
    required String classroom,
    required String classTime,
  }) async {}

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    String channelId = '',
  }) async {}

  Future<void> scheduleAssignmentReminder({
    required String assignmentId,
    required String assignmentTitle,
    required DateTime dueDate,
  }) async {}

  Future<void> showGradeNotification({
    required String courseTitle,
    required String grade,
    required String assignmentTitle,
  }) async {}

  Future<void> cancelNotification(int id) async {}
  Future<void> cancelAssignmentNotifications(String assignmentId) async {}
  Future<void> cancelAllNotifications() async {}

  /// Returns an empty list on web – no pending local notifications.
  Future<List<dynamic>> getPendingNotifications() async => [];

  Future<void> scheduleCourseRemindersDetailed({
    required String courseId,
    required String courseName,
    required String classroom,
    required Map<int, String> dayTimeMap,
    required int reminderMinutes,
  }) async {}

  Future<void> scheduleCourseReminders({
    required String courseId,
    required String courseName,
    required String classroom,
    required List<int> scheduleDays,
    required String classTime,
    required int reminderMinutes,
  }) async {}

  Future<void> cancelCourseReminders(String courseId) async {}
}
