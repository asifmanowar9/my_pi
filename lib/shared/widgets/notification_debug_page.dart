import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import '../services/notification_service.dart';

/// Debug page to test and verify notification functionality
class NotificationDebugPage extends StatefulWidget {
  const NotificationDebugPage({super.key});

  @override
  State<NotificationDebugPage> createState() => _NotificationDebugPageState();
}

class _NotificationDebugPageState extends State<NotificationDebugPage> {
  List<PendingNotificationRequest> _pendingNotifications = [];
  bool _isLoading = false;
  bool? _hasExactAlarmPermission;

  @override
  void initState() {
    super.initState();
    _loadPendingNotifications();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    try {
      final notificationService = Get.find<NotificationService>();
      final canSchedule = await notificationService.canScheduleExactAlarms();
      setState(() {
        _hasExactAlarmPermission = canSchedule;
      });
    } catch (e) {
      print('Error checking permissions: $e');
    }
  }

  Future<void> _requestExactAlarmPermission() async {
    try {
      final notificationService = Get.find<NotificationService>();
      await notificationService.ensureExactAlarmPermission();
      await _checkPermissions();
    } catch (e) {
      Get.snackbar('Error', 'Failed to request permission: $e');
    }
  }

  void _showBatteryOptimizationInstructions() {
    Get.dialog(
      AlertDialog(
        title: const Text('Battery Optimization Issue'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Scheduled notifications are not working because Android is blocking them.\n\n'
                'To fix this:\n\n',
                style: TextStyle(fontSize: 14),
              ),
              const Text(
                '1. Open Settings on your phone',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                '2. Go to Apps → My Pi',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                '3. Tap Battery',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                '4. Change from "Optimized" to "Unrestricted"',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: const Text(
                  '⚠️ Without this change, notifications will NEVER appear at the scheduled time.',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('I\'ll Do It Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Manual Action Required',
                'Please follow the steps to disable battery optimization',
                duration: const Duration(seconds: 5),
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('OK, Got It'),
          ),
        ],
      ),
    );
  }

  Future<void> _loadPendingNotifications() async {
    setState(() => _isLoading = true);
    try {
      final notificationService = Get.find<NotificationService>();
      final pending = await notificationService.getPendingNotifications();
      setState(() {
        _pendingNotifications = pending;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      Get.snackbar('Error', 'Failed to load notifications: $e');
    }
  }

  Future<void> _testImmediateNotification() async {
    try {
      final notificationService = Get.find<NotificationService>();
      await notificationService.showNotification(
        id: DateTime.now().millisecondsSinceEpoch.hashCode.abs(),
        title: '🧪 Test Notification',
        body: 'If you see this, notifications are working!',
      );
      Get.snackbar(
        'Success',
        'Test notification sent!',
        backgroundColor: Colors.green[100],
        colorText: Colors.green[900],
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to send test notification: $e');
    }
  }

  Future<void> _testCourseReminderNotification() async {
    try {
      final notificationService = Get.find<NotificationService>();
      await notificationService.showCourseReminderNotification(
        id: DateTime.now().millisecondsSinceEpoch.hashCode.abs(),
        courseName: 'Test Course',
        classroom: 'Room 101',
        classTime: '2:30 PM',
      );
      Get.snackbar(
        'Success',
        'Course reminder test sent!',
        backgroundColor: Colors.green[100],
        colorText: Colors.green[900],
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to send course reminder: $e');
    }
  }

  Future<void> _scheduleTestIn10Seconds() async {
    try {
      final notificationService = Get.find<NotificationService>();
      final scheduledTime = DateTime.now().add(const Duration(seconds: 10));

      print('📱 Scheduling test notification for: $scheduledTime');

      await notificationService.scheduleNotification(
        id: 12345, // Use a fixed simple ID for testing
        title: '⏰ 10-Second Test',
        body: 'This notification was scheduled 10 seconds ago',
        scheduledDate: scheduledTime,
      );

      Get.snackbar(
        'Success',
        'Notification scheduled for 10 seconds from now. Keep screen on and watch!',
        backgroundColor: Colors.blue[100],
        colorText: Colors.blue[900],
        duration: const Duration(seconds: 12),
      );

      await _loadPendingNotifications();
    } catch (e) {
      print('❌ Error scheduling: $e');
      Get.snackbar('Error', 'Failed to schedule notification: $e');
    }
  }

  Future<void> _scheduleTestIn30Seconds() async {
    try {
      final notificationService = Get.find<NotificationService>();
      final scheduledTime = DateTime.now().add(const Duration(seconds: 30));

      await notificationService.scheduleNotification(
        id: DateTime.now().millisecondsSinceEpoch.hashCode.abs(),
        title: '⏰ Scheduled Test',
        body: 'This notification was scheduled 30 seconds ago',
        scheduledDate: scheduledTime,
      );

      Get.snackbar(
        'Success',
        'Notification scheduled for 30 seconds from now',
        backgroundColor: Colors.blue[100],
        colorText: Colors.blue[900],
        duration: const Duration(seconds: 5),
      );

      await _loadPendingNotifications();
    } catch (e) {
      Get.snackbar('Error', 'Failed to schedule notification: $e');
    }
  }

  Future<void> _cancelAllNotifications() async {
    try {
      final notificationService = Get.find<NotificationService>();
      await notificationService.cancelAllNotifications();
      Get.snackbar(
        'Success',
        'All notifications cancelled',
        backgroundColor: Colors.orange[100],
        colorText: Colors.orange[900],
      );
      await _loadPendingNotifications();
    } catch (e) {
      Get.snackbar('Error', 'Failed to cancel notifications: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Debugger'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPendingNotifications,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Critical battery optimization warning
                  if (_pendingNotifications.isNotEmpty)
                    Card(
                      color: Colors.red[50],
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.battery_alert,
                                  color: Colors.red[700],
                                  size: 32,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Scheduled notifications not appearing?',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.red[900],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'If your test notifications show "Success" but never appear, '
                              'Android battery optimization is blocking them.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.red[900],
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: _showBatteryOptimizationInstructions,
                              icon: const Icon(Icons.help_outline),
                              label: const Text('How to Fix This'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red[700],
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (_pendingNotifications.isNotEmpty)
                    const SizedBox(height: 16),

                  // Permission status
                  Card(
                    color: _hasExactAlarmPermission == true
                        ? Colors.green[50]
                        : Colors.red[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _hasExactAlarmPermission == true
                                    ? Icons.check_circle
                                    : Icons.warning,
                                color: _hasExactAlarmPermission == true
                                    ? Colors.green[700]
                                    : Colors.red[700],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Exact Alarm Permission',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _hasExactAlarmPermission == true
                                      ? Colors.green[700]
                                      : Colors.red[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _hasExactAlarmPermission == true
                                ? '✅ Permission granted - Course reminders will work'
                                : '❌ Permission not granted - Please enable to receive reminders',
                            style: const TextStyle(fontSize: 13),
                          ),
                          if (_hasExactAlarmPermission == false) ...[
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: _requestExactAlarmPermission,
                              icon: const Icon(Icons.settings),
                              label: const Text('Grant Permission'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange[600],
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Test buttons
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Test Notifications',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _testImmediateNotification,
                            icon: const Icon(Icons.notification_add),
                            label: const Text('Send Test Notification Now'),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: _testCourseReminderNotification,
                            icon: const Icon(Icons.school),
                            label: const Text('Test Course Reminder Now'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple[400],
                              foregroundColor: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: _scheduleTestIn10Seconds,
                            icon: const Icon(Icons.timer_10),
                            label: const Text('Schedule Test in 10 Seconds'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal[400],
                              foregroundColor: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: _scheduleTestIn30Seconds,
                            icon: const Icon(Icons.schedule),
                            label: const Text('Schedule Test in 30 Seconds'),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: _cancelAllNotifications,
                            icon: const Icon(Icons.cancel),
                            label: const Text('Cancel All Notifications'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[400],
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Pending notifications list
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Pending Notifications',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Chip(
                                label: Text('${_pendingNotifications.length}'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (_pendingNotifications.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(32),
                              child: Center(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.notifications_off,
                                      size: 64,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'No pending notifications',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            ..._pendingNotifications
                                .map(
                                  (notification) => Card(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: ListTile(
                                      leading: const Icon(
                                        Icons.notifications_active,
                                      ),
                                      title: Text(
                                        notification.title ?? 'No title',
                                      ),
                                      subtitle: Text(
                                        notification.body ?? 'No body',
                                      ),
                                      trailing: Text(
                                        'ID: ${notification.id}',
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Info card
                  Card(
                    color: Colors.blue[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.blue[700]),
                              const SizedBox(width: 8),
                              Text(
                                'Debugging Tips',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            '1. Make sure notification permissions are granted\n'
                            '2. Grant "Exact Alarm" permission (Android 12+)\n'
                            '3. Check if "Do Not Disturb" is enabled\n'
                            '4. Verify app battery optimization is disabled\n'
                            '5. For course notifications, class time must be in the future\n'
                            '6. Check console logs for scheduling details',
                            style: TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
