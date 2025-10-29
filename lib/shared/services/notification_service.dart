import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../constants/app_constants.dart';

class NotificationService extends GetxService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> initialize() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Dhaka')); // Set your timezone

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
          macOS: initializationSettingsIOS,
        );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    await _createNotificationChannels();
    await _requestPermissions();
  }

  Future<void> _createNotificationChannels() async {
    const List<AndroidNotificationChannel> channels = [
      AndroidNotificationChannel(
        AppConstants.assignmentChannelId,
        'Assignment Notifications',
        description: 'Notifications for assignment due dates and updates',
        importance: Importance.high,
      ),
      AndroidNotificationChannel(
        AppConstants.gradeChannelId,
        'Grade Notifications',
        description: 'Notifications for grade updates',
        importance: Importance.high,
      ),
      AndroidNotificationChannel(
        AppConstants.generalChannelId,
        'General Notifications',
        description: 'General app notifications',
        importance: Importance.defaultImportance,
      ),
      AndroidNotificationChannel(
        AppConstants.courseReminderChannelId,
        'Class Reminders',
        description: 'Notifications reminding you of upcoming classes',
        importance: Importance.high,
      ),
    ];

    for (final channel in channels) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);
    }
  }

  Future<void> _requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    // Request notification permission
    await androidImplementation?.requestNotificationsPermission();

    // Request exact alarm permission (required for Android 12+)
    await androidImplementation?.requestExactAlarmsPermission();

    final IOSFlutterLocalNotificationsPlugin? iosImplementation =
        _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();

    await iosImplementation?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  /// Check if exact alarm permission is granted (Android 12+)
  Future<bool> canScheduleExactAlarms() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    if (androidImplementation == null) {
      return true; // Not Android, assume permission is granted
    }

    final bool? canSchedule = await androidImplementation
        .canScheduleExactNotifications();
    return canSchedule ?? false;
  }

  /// Request exact alarm permission if not granted
  Future<void> ensureExactAlarmPermission() async {
    final bool hasPermission = await canScheduleExactAlarms();

    if (!hasPermission) {
      print('⚠️ Exact alarm permission not granted. Requesting...');
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      await androidImplementation?.requestExactAlarmsPermission();

      // Check again after request
      final bool hasPermissionNow = await canScheduleExactAlarms();
      if (hasPermissionNow) {
        print('✅ Exact alarm permission granted!');
      } else {
        print(
          '❌ Exact alarm permission denied. Notifications may not work as expected.',
        );
      }
    } else {
      print('✅ Exact alarm permission already granted');
    }
  }

  void _onNotificationTapped(NotificationResponse notificationResponse) {
    final String? payload = notificationResponse.payload;
    if (payload != null) {
      _handleNotificationPayload(payload);
    }
  }

  void _handleNotificationPayload(String payload) {
    try {
      // Parse payload and navigate accordingly
      final parts = payload.split('|');
      if (parts.length >= 2) {
        final type = parts[0];
        final id = parts[1];

        switch (type) {
          case 'assignment':
            Get.toNamed('/assignment-detail', arguments: {'id': id});
            break;
          case 'grade':
            Get.toNamed('/grades');
            break;
          case 'course':
            Get.toNamed('/course-detail', arguments: {'id': id});
            break;
          default:
            Get.toNamed('/main');
        }
      }
    } catch (e) {
      Get.toNamed('/main');
    }
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String channelId = AppConstants.generalChannelId,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          AppConstants.generalChannelId,
          'General Notifications',
          channelDescription: 'General app notifications',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        );

    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails();

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
      macOS: iosNotificationDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  /// Test method to show a course reminder notification immediately
  Future<void> showCourseReminderNotification({
    required int id,
    required String courseName,
    required String classroom,
    required String classTime,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          AppConstants.courseReminderChannelId,
          'Class Reminders',
          channelDescription: 'Notifications reminding you of upcoming classes',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          playSound: true,
          enableVibration: true,
        );

    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
      macOS: iosNotificationDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      id,
      '📚 Class Starting Soon',
      '$courseName at $classTime in $classroom',
      notificationDetails,
      payload: 'course|test',
    );
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    String channelId = AppConstants.generalChannelId,
  }) async {
    print('🔔 Scheduling notification:');
    print('   ID: $id');
    print('   Title: $title');
    print('   Scheduled for: $scheduledDate');
    print('   Current time: ${DateTime.now()}');
    print(
      '   Time until notification: ${scheduledDate.difference(DateTime.now()).inSeconds} seconds',
    );

    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          AppConstants.assignmentChannelId,
          'Assignment Notifications',
          channelDescription:
              'Notifications for assignment due dates and updates',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          showWhen: true,
        );

    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
      macOS: iosNotificationDetails,
    );

    try {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
      print('✅ Notification scheduled successfully!');
    } catch (e) {
      print('❌ Failed to schedule notification: $e');
      rethrow;
    }
  }

  Future<void> scheduleAssignmentReminder({
    required String assignmentId,
    required String assignmentTitle,
    required DateTime dueDate,
  }) async {
    final int notificationId = assignmentId.hashCode;

    // Schedule notification 24 hours before due date
    final DateTime reminderDate = dueDate.subtract(const Duration(days: 1));

    if (reminderDate.isAfter(DateTime.now())) {
      await scheduleNotification(
        id: notificationId,
        title: 'Assignment Due Tomorrow',
        body: '$assignmentTitle is due tomorrow',
        scheduledDate: reminderDate,
        payload: 'assignment|$assignmentId',
        channelId: AppConstants.assignmentChannelId,
      );
    }

    // Schedule notification 1 hour before due date
    final DateTime urgentReminderDate = dueDate.subtract(
      const Duration(hours: 1),
    );

    if (urgentReminderDate.isAfter(DateTime.now())) {
      await scheduleNotification(
        id: notificationId + 1,
        title: 'Assignment Due Soon!',
        body: '$assignmentTitle is due in 1 hour',
        scheduledDate: urgentReminderDate,
        payload: 'assignment|$assignmentId',
        channelId: AppConstants.assignmentChannelId,
      );
    }
  }

  Future<void> showGradeNotification({
    required String courseTitle,
    required String grade,
    required String assignmentTitle,
  }) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: 'New Grade Available',
      body: 'You received $grade for $assignmentTitle in $courseTitle',
      payload: 'grade|',
      channelId: AppConstants.gradeChannelId,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelAssignmentNotifications(String assignmentId) async {
    final int notificationId = assignmentId.hashCode;
    await cancelNotification(notificationId);
    await cancelNotification(notificationId + 1);
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  // Schedule recurring course reminders (with individual times per day)
  Future<void> scheduleCourseRemindersDetailed({
    required String courseId,
    required String courseName,
    required String classroom,
    required Map<int, String> dayTimeMap, // Map of dayOfWeek -> "HH:mm" format
    required int reminderMinutes, // 10 or 15 minutes before
  }) async {
    // Check and request exact alarm permission if needed
    await ensureExactAlarmPermission();

    // Verify permission is granted before proceeding
    final bool canSchedule = await canScheduleExactAlarms();
    if (!canSchedule) {
      print(
        '❌ Cannot schedule notifications: Exact alarm permission not granted',
      );
      print(
        '💡 Please enable exact alarm permission in Settings > Apps > My Pi > Alarms & reminders',
      );
      return;
    }

    // Cancel any existing notifications for this course
    await cancelCourseReminders(courseId);

    // Schedule notification for each day with its specific time
    for (final entry in dayTimeMap.entries) {
      final dayOfWeek = entry.key;
      final classTime = entry.value;

      // Parse class time for this specific day
      final timeParts = classTime.split(':');
      if (timeParts.length != 2) {
        print('Invalid class time format for day $dayOfWeek: $classTime');
        continue;
      }

      final hour = int.tryParse(timeParts[0]);
      final minute = int.tryParse(timeParts[1]);

      if (hour == null ||
          minute == null ||
          hour < 0 ||
          hour > 23 ||
          minute < 0 ||
          minute > 59) {
        print('Invalid time values for day $dayOfWeek: $hour:$minute');
        continue;
      }

      // Schedule notification for this specific day-time combination for the next 8 weeks
      for (int weekOffset = 0; weekOffset < 8; weekOffset++) {
        final now = DateTime.now();
        var nextClassDate = _getNextWeekday(now, dayOfWeek);

        // Add week offset to get future weeks
        nextClassDate = nextClassDate.add(Duration(days: 7 * weekOffset));

        // Set the class time for this specific day
        nextClassDate = DateTime(
          nextClassDate.year,
          nextClassDate.month,
          nextClassDate.day,
          hour,
          minute,
        );

        // Calculate reminder time
        final reminderTime = nextClassDate.subtract(
          Duration(minutes: reminderMinutes),
        );

        // Only schedule if the reminder time is in the future
        if (reminderTime.isAfter(now)) {
          // Generate unique notification ID for this course, day, and week
          final notificationId =
              _generateCourseNotificationId(courseId, dayOfWeek) +
              weekOffset; // Add week offset to make ID unique

          print(
            '📅 Course: $courseName | Day: $dayOfWeek | Time: $classTime | Week: $weekOffset',
          );
          print('   ⏰ Class time: $nextClassDate');
          print('   🔔 Reminder time: $reminderTime');
          print('   🕐 Current time: $now');
          print('   ✓ Is in future: ${reminderTime.isAfter(now)}');

          // Schedule the notification
          await _scheduleCourseReminder(
            id: notificationId,
            courseName: courseName,
            classroom: classroom,
            reminderTime: reminderTime,
            classTime: classTime, // Use the specific time for this day
            reminderMinutes: reminderMinutes,
            dayOfWeek: dayOfWeek,
            courseId: courseId,
          );
        } else {
          print(
            '   ⚠️ Skipped: Day $dayOfWeek Week $weekOffset - Reminder time has already passed',
          );
        }
      }
    }
  }

  // Schedule recurring course reminders (legacy method for backward compatibility)
  Future<void> scheduleCourseReminders({
    required String courseId,
    required String courseName,
    required String classroom,
    required List<int> scheduleDays, // 1 (Monday) to 7 (Sunday)
    required String classTime, // "HH:mm" format
    required int reminderMinutes, // 10 or 15 minutes before
  }) async {
    // Check and request exact alarm permission if needed
    await ensureExactAlarmPermission();

    // Verify permission is granted before proceeding
    final bool canSchedule = await canScheduleExactAlarms();
    if (!canSchedule) {
      print(
        '❌ Cannot schedule notifications: Exact alarm permission not granted',
      );
      print(
        '💡 Please enable exact alarm permission in Settings > Apps > My Pi > Alarms & reminders',
      );
      return;
    }

    // Cancel any existing notifications for this course
    await cancelCourseReminders(courseId);

    // Parse class time
    final timeParts = classTime.split(':');
    if (timeParts.length != 2) {
      print('Invalid class time format: $classTime');
      return;
    }

    final hour = int.tryParse(timeParts[0]);
    final minute = int.tryParse(timeParts[1]);

    if (hour == null ||
        minute == null ||
        hour < 0 ||
        hour > 23 ||
        minute < 0 ||
        minute > 59) {
      print('Invalid time values: $hour:$minute');
      return;
    }

    // Schedule notification for each day of the week for the next 8 weeks
    for (final dayOfWeek in scheduleDays) {
      if (dayOfWeek < 1 || dayOfWeek > 7) continue;

      // Schedule for the next 8 weeks to ensure continuous notifications
      for (int weekOffset = 0; weekOffset < 8; weekOffset++) {
        final now = DateTime.now();
        var nextClassDate = _getNextWeekday(now, dayOfWeek);

        // Add week offset to get future weeks
        nextClassDate = nextClassDate.add(Duration(days: 7 * weekOffset));

        // Set the class time
        nextClassDate = DateTime(
          nextClassDate.year,
          nextClassDate.month,
          nextClassDate.day,
          hour,
          minute,
        );

        // Calculate reminder time
        final reminderTime = nextClassDate.subtract(
          Duration(minutes: reminderMinutes),
        );

        // Only schedule if the reminder time is in the future
        if (reminderTime.isAfter(now)) {
          // Generate unique notification ID for this course, day, and week
          final notificationId =
              _generateCourseNotificationId(courseId, dayOfWeek) +
              weekOffset; // Add week offset to make ID unique

          print('📅 Course: $courseName | Day: $dayOfWeek | Week: $weekOffset');
          print('   ⏰ Class time: $nextClassDate');
          print('   🔔 Reminder time: $reminderTime');
          print('   🕐 Current time: $now');
          print('   ✓ Is in future: ${reminderTime.isAfter(now)}');

          // Schedule the notification
          await _scheduleCourseReminder(
            id: notificationId,
            courseName: courseName,
            classroom: classroom,
            reminderTime: reminderTime,
            classTime: classTime,
            reminderMinutes: reminderMinutes,
            dayOfWeek: dayOfWeek,
            courseId: courseId,
          );
        } else {
          print(
            '   ⚠️ Skipped: Week $weekOffset - Reminder time has already passed',
          );
        }
      }
    }
  }

  DateTime _getNextWeekday(DateTime date, int dayOfWeek) {
    // dayOfWeek: 1 (Monday) to 7 (Sunday)
    // DateTime.weekday: 1 (Monday) to 7 (Sunday)

    final daysUntilNext = (dayOfWeek - date.weekday + 7) % 7;
    if (daysUntilNext == 0) {
      // If it's today, return today (the reminder time check will determine if it's schedulable)
      return date;
    }
    return date.add(Duration(days: daysUntilNext));
  }

  int _generateCourseNotificationId(String courseId, int dayOfWeek) {
    // Create a unique ID based on course ID and day of week
    return (courseId.hashCode + dayOfWeek * 1000).abs() % 2147483647;
  }

  Future<void> _scheduleCourseReminder({
    required int id,
    required String courseName,
    required String classroom,
    required DateTime reminderTime,
    required String classTime,
    required int reminderMinutes,
    required int dayOfWeek,
    required String courseId,
  }) async {
    const dayNames = [
      '',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    // Format time to 12-hour format
    final timeParts = classTime.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final displayMinute = minute.toString().padLeft(2, '0');
    final formattedTime = '$displayHour:$displayMinute $period';

    final AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          AppConstants.courseReminderChannelId,
          'Class Reminders',
          channelDescription: 'Notifications reminding you of upcoming classes',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          playSound: true,
          enableVibration: true,
          showWhen: true,
        );

    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
      macOS: iosNotificationDetails,
    );

    // Schedule notification for the specific date and time (non-recurring)
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      '📚 Class Starting Soon',
      '$courseName at $formattedTime in $classroom',
      tz.TZDateTime.from(reminderTime, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'course|$courseId',
      // Remove recurring - schedule individual notifications for each occurrence
    );

    print(
      '✅ Scheduled reminder for $courseName on ${dayNames[dayOfWeek]} at $formattedTime (Reminder: $reminderMinutes min before)',
    );
  }

  Future<void> cancelCourseReminders(String courseId) async {
    // Cancel notifications for all days of the week and all weeks
    for (int dayOfWeek = 1; dayOfWeek <= 7; dayOfWeek++) {
      for (int weekOffset = 0; weekOffset < 8; weekOffset++) {
        final notificationId =
            _generateCourseNotificationId(courseId, dayOfWeek) + weekOffset;
        await cancelNotification(notificationId);
      }
    }
    print('✅ Cancelled all reminders for course: $courseId');
  }
}
