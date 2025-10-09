# Exact Alarm Permission Fix

## Problem

When trying to schedule course reminder notifications, the app was failing with this error:

```
❌ Failed to schedule notifications for flights: 
PlatformException(exact_alarms_not_permitted, Exact alarms are not permitted, null, null)
```

Even though the notification scheduling logic was correct and the times were calculated properly, Android was blocking the notifications.

## Root Cause

Starting with **Android 12 (API level 31)**, apps need special permission to schedule **exact alarms**. This is a security feature to prevent apps from abusing battery by scheduling too many precise alarms.

Our course reminder notifications use `AndroidScheduleMode.exactAllowWhileIdle` to ensure they trigger at the exact time (e.g., 10 minutes before class), which requires this permission.

## Solution

### 1. Added Permissions to AndroidManifest.xml

**File:** `android/app/src/main/AndroidManifest.xml`

```xml
<!-- Permissions for notifications -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.USE_EXACT_ALARM"/>
```

- `POST_NOTIFICATIONS`: Required for showing notifications (Android 13+)
- `SCHEDULE_EXACT_ALARM`: Allows scheduling exact alarms (user-revocable)
- `USE_EXACT_ALARM`: Alternative exact alarm permission (non-revocable for certain use cases)

### 2. Updated NotificationService

**File:** `lib/shared/services/notification_service.dart`

#### Added Permission Check Method

```dart
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

  final bool? canSchedule = await androidImplementation.canScheduleExactNotifications();
  return canSchedule ?? false;
}
```

#### Added Permission Request Method

```dart
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
      print('❌ Exact alarm permission denied. Notifications may not work as expected.');
    }
  } else {
    print('✅ Exact alarm permission already granted');
  }
}
```

#### Updated Permission Initialization

```dart
Future<void> _requestPermissions() async {
  final AndroidFlutterLocalNotificationsPlugin? androidImplementation = ...;

  // Request notification permission
  await androidImplementation?.requestNotificationsPermission();
  
  // Request exact alarm permission (required for Android 12+)
  await androidImplementation?.requestExactAlarmsPermission();

  // ... iOS permissions ...
}
```

#### Updated scheduleCourseReminders Method

```dart
Future<void> scheduleCourseReminders({...}) async {
  // Check and request exact alarm permission if needed
  await ensureExactAlarmPermission();
  
  // Verify permission is granted before proceeding
  final bool canSchedule = await canScheduleExactAlarms();
  if (!canSchedule) {
    print('❌ Cannot schedule notifications: Exact alarm permission not granted');
    print('💡 Please enable exact alarm permission in Settings > Apps > My Pi > Alarms & reminders');
    return;
  }

  // ... rest of scheduling logic ...
}
```

### 3. Updated Notification Debug Page

**File:** `lib/shared/widgets/notification_debug_page.dart`

Added a permission status card that:
- ✅ Shows green if permission is granted
- ❌ Shows red if permission is denied
- Provides a button to request permission
- Explains what the permission is for

## How It Works

1. **On App First Launch:**
   - When `NotificationService.initialize()` is called, it requests the exact alarm permission
   - Android shows a system dialog asking the user to allow exact alarms
   - User grants or denies the permission

2. **When Creating a Course with Schedule:**
   - `scheduleCourseReminders()` checks if exact alarm permission is granted
   - If not granted, it requests the permission again
   - If still denied, it logs an error and skips scheduling
   - If granted, it proceeds to schedule the notifications

3. **User Can Check Status:**
   - Open the Notification Debug Page (from your app's debug/settings menu)
   - See the permission status at the top
   - Use the "Grant Permission" button if needed

## Testing Steps

### 1. Clean Installation Test

```bash
# Uninstall the app to test fresh installation
flutter clean
flutter run
```

- App should request exact alarm permission on first launch
- Grant the permission when prompted
- Create a course with schedule
- Notification should be scheduled successfully

### 2. Permission Denied Test

- Go to Settings > Apps > My Pi > Alarms & reminders
- Turn OFF "Allow setting alarms and reminders"
- Try to create a course with schedule
- Should see error: "❌ Cannot schedule notifications: Exact alarm permission not granted"
- Use Notification Debug Page to re-request permission

### 3. Verification Test

Open Notification Debug Page:
- ✅ Should show "Permission granted - Course reminders will work"
- Create a test course:
  - Set class time to 5 minutes from now
  - Select today's weekday
  - Choose 2-minute reminder
- Wait for notification (should appear in 3 minutes)

## Console Logs to Look For

### Success:
```
✅ Exact alarm permission already granted
📅 Course: flights | Day: 5
   ⏰ Class time: 2025-10-03 14:40:00.000
   🔔 Reminder time: 2025-10-03 14:30:00.000
   🕐 Current time: 2025-10-03 14:27:02.718183
   ✓ Is in future: true
✅ Scheduled reminder for flights on Friday at 14:40
```

### Permission Not Granted:
```
⚠️ Exact alarm permission not granted. Requesting...
❌ Cannot schedule notifications: Exact alarm permission not granted
💡 Please enable exact alarm permission in Settings > Apps > My Pi > Alarms & reminders
```

## Manual Permission Settings

If the automatic request doesn't work, users can manually enable the permission:

1. Open **Settings** on Android device
2. Go to **Apps** → **My Pi** (or your app name)
3. Tap **Alarms & reminders**
4. Enable **Allow setting alarms and reminders**

## Why This Permission Is Needed

- **Exact Alarms:** Required to schedule notifications at precise times
- **Course Reminders:** Need to trigger exactly 10-15 minutes before class
- **Battery Optimization:** Android restricts exact alarms to save battery
- **User Control:** Users can revoke this permission in Settings

## Alternatives (Not Recommended)

If exact alarms are not critical, you could use inexact alarms:
- Change `AndroidScheduleMode.exactAllowWhileIdle` to `AndroidScheduleMode.inexactAllowWhileIdle`
- Notifications might be delayed by a few minutes
- No special permission required
- Not suitable for time-sensitive reminders like class schedules

## References

- [Android Exact Alarms Documentation](https://developer.android.com/about/versions/12/behavior-changes-12#exact-alarm-permission)
- [Flutter Local Notifications Plugin](https://pub.dev/packages/flutter_local_notifications)
- [SCHEDULE_EXACT_ALARM Permission](https://developer.android.com/reference/android/Manifest.permission#SCHEDULE_EXACT_ALARM)
