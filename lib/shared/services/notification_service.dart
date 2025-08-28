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

    await androidImplementation?.requestNotificationsPermission();

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
            Get.toNamed('/home');
        }
      }
    } catch (e) {
      Get.toNamed('/home');
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

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    String channelId = AppConstants.generalChannelId,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          AppConstants.assignmentChannelId,
          'Assignment Notifications',
          channelDescription:
              'Notifications for assignment due dates and updates',
          importance: Importance.high,
          priority: Priority.high,
        );

    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails();

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
      macOS: iosNotificationDetails,
    );

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
}
