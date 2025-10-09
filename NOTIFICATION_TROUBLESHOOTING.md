# Notification Troubleshooting Guide

## Problem: Notifications Scheduled but Not Appearing

If you see this in the console logs:

```
✅ Exact alarm permission already granted
✅ Scheduled reminder for stuff on Friday at 8:35 PM (Reminder: 15 min before)
✅ Notifications scheduled for stuff
```

But the notification doesn't appear at the scheduled time, the issue is **NOT with your code** - it's with Android system settings blocking the notifications.

## Quick Diagnosis

### Step 1: Test Immediate Notifications

1. Open the **Notification Debug Page** in your app
2. Tap **"Send Test Notification Now"**
3. Then tap **"Test Course Reminder Now"**

**Result:**
- ✅ **If you see both notifications:** System is blocking scheduled notifications
- ❌ **If you see NO notifications:** Permission or channel issue
- ⚠️ **If you see test but not course reminder:** Channel-specific issue

### Step 2: Check Pending Notifications

In the Notification Debug Page:
- Look at the "Pending Notifications" count
- If it shows your scheduled notifications, they're in the system queue
- If the count matches what you expect, the issue is delivery, not scheduling

### Step 3: Wait for Scheduled Test

1. Tap **"Schedule Test in 30 Seconds"**
2. Keep the phone unlocked and screen on
3. Wait 30 seconds

**Result:**
- ✅ **If notification appears:** Your course reminders should work too
- ❌ **If NO notification:** Android is blocking all scheduled notifications

## Common Issues & Solutions

### Issue 1: Battery Optimization Blocking Notifications

**Symptom:** Notifications work when app is open, but not when closed

**Solution:**
1. Go to **Settings** → **Apps** → **My Pi**
2. Tap **Battery** or **Battery optimization**
3. Select **Unrestricted** or **Not optimized**
4. Restart the app

**Why:** Android's battery saver can prevent apps from waking up to show notifications.

### Issue 2: Do Not Disturb Mode

**Symptom:** No notifications during certain hours or at all

**Solution:**
1. Swipe down from the top of your screen
2. Check if **Do Not Disturb** (moon icon) is enabled
3. If enabled, either:
   - Disable it, OR
   - Go to **Settings** → **Sound & vibration** → **Do Not Disturb**
   - Add **My Pi** to the exceptions list

**Why:** DND mode silences all notifications by default.

### Issue 3: Notification Channel Disabled

**Symptom:** Some notifications work, but not course reminders

**Solution:**
1. Go to **Settings** → **Apps** → **My Pi** → **Notifications**
2. Find **"Class Reminders"** channel
3. Make sure it's **enabled** and set to **"Alerting"** (not "Silent")
4. Check that **importance** is set to **High** or **Urgent**

**Why:** Android allows users to disable specific notification categories.

### Issue 4: App Not Allowed to Run in Background

**Symptom:** Notifications only work when app is open

**Solution:**
1. Go to **Settings** → **Apps** → **My Pi**
2. Tap **Permissions** → **Special app access**
3. Enable **"Run in background"** or **"Background activity"**
4. For Samsung devices: **Settings** → **Apps** → **My Pi** → **Battery** → **Allow background activity**

**Why:** Some Android skins (Samsung, Xiaomi, Oppo) aggressively restrict background apps.

### Issue 5: Manufacturer-Specific Battery Optimization

**For Xiaomi/MIUI Devices:**
1. Go to **Settings** → **Apps** → **Manage apps** → **My Pi**
2. Tap **Battery saver** → Select **No restrictions**
3. Enable **Autostart**
4. Go to **Settings** → **Apps** → **Permissions** → **Autostart**
5. Enable autostart for **My Pi**

**For Samsung Devices:**
1. Go to **Settings** → **Apps** → **My Pi** → **Battery**
2. Select **Unrestricted**
3. Go to **Settings** → **Device care** → **Battery** → **Background usage limits**
4. Make sure **My Pi** is NOT in "Sleeping apps" or "Deep sleeping apps"

**For Huawei Devices:**
1. Go to **Settings** → **Apps** → **My Pi** → **Battery**
2. Set to **Manual management**
3. Enable all options (Background activity, Auto-launch, Secondary launch)

**For Oppo/ColorOS Devices:**
1. Go to **Settings** → **Battery** → **Power saving** → **My Pi**
2. Enable **Background freeze OFF**
3. Go to **Settings** → **Privacy** → **Permission manager** → **Autostart**
4. Enable autostart for **My Pi**

### Issue 6: Notification History Shows Delivery

**Check if notifications were delivered but dismissed:**

1. Go to **Settings** → **Notifications** → **Notification history**
2. Find **My Pi** notifications
3. Check if your course reminders appear there

**If they appear:**
- They were delivered but you might have missed them
- Check if sound/vibration is enabled
- Increase notification importance

**If they don't appear:**
- Android blocked them before delivery
- Follow battery optimization fixes above

## Testing Procedure

### Test 1: Immediate Notification (Basic Permissions)

```dart
// In Notification Debug Page
Tap "Send Test Notification Now"
```

**Expected:** Notification appears within 1 second

**If it fails:**
- Check notification permission: Settings → Apps → My Pi → Notifications
- Reinstall the app and grant permissions

### Test 2: Course Reminder Style (Channel-Specific)

```dart
// In Notification Debug Page
Tap "Test Course Reminder Now"
```

**Expected:** Notification with "📚 Class Starting Soon" appears immediately

**If it fails:**
- The "Class Reminders" channel is blocked
- Go to Settings → Apps → My Pi → Notifications → Class Reminders
- Enable and set to "Alerting" with High importance

### Test 3: Scheduled Notification (Exact Alarm)

```dart
// In Notification Debug Page
Tap "Schedule Test in 30 Seconds"
Keep phone unlocked, screen on
Wait 30 seconds
```

**Expected:** Notification appears after 30 seconds

**If it fails:**
- Exact alarm permission issue (should show in debug page)
- Battery optimization blocking scheduled tasks
- Follow battery optimization fixes above

### Test 4: Real Course Reminder

```dart
// In your app
1. Create a course with a schedule
2. Set class time to 5 minutes from now
3. Select today's weekday
4. Set reminder to 3 minutes before
5. Save the course
6. Keep phone unlocked
7. Wait 2 minutes (notification should appear)
```

**Expected:** Notification appears 3 minutes before class time

**If it fails but Test 3 passed:**
- Check console logs for scheduling errors
- Verify the course has scheduleDays, classTime, and reminderMinutes set
- Delete and recreate the course

## Debug Console Logs

### Successful Scheduling:
```
✅ Exact alarm permission already granted
📅 Course: stuff | Day: 5
   ⏰ Class time: 2025-10-03 20:35:00.000
   🔔 Reminder time: 2025-10-03 20:20:00.000
   🕐 Current time: 2025-10-03 20:17:07.147967
   ✓ Is in future: true
✅ Scheduled reminder for stuff on Friday at 8:35 PM (Reminder: 15 min before)
✅ Notifications scheduled for stuff
```

This means the notification IS scheduled correctly. If it doesn't appear, it's a system/battery issue.

### Permission Denied:
```
⚠️ Exact alarm permission not granted. Requesting...
❌ Cannot schedule notifications: Exact alarm permission not granted
```

Solution: Grant exact alarm permission via debug page or Settings.

### Time Already Passed:
```
   ⚠️ Skipped: Reminder time has already passed
```

Solution: Set class time further in the future (at least 5+ minutes).

## Nuclear Option: Complete Reset

If nothing else works:

1. **Uninstall the app completely**
   ```bash
   adb uninstall com.example.my_pi
   # or manually uninstall from phone
   ```

2. **Clear system notification cache**
   - Go to Settings → Apps → Show system apps
   - Find "Notification Manager Service"
   - Clear storage/cache (requires root or developer settings)

3. **Reinstall fresh**
   ```bash
   flutter clean
   flutter pub get
   flutter run --release
   ```

4. **Grant ALL permissions when prompted**
   - Notification permission
   - Exact alarm permission
   - Any other permissions

5. **Disable battery optimization immediately**
   - Settings → Apps → My Pi → Battery → Unrestricted

6. **Test with simple notification first**
   - Use debug page "Send Test Notification Now"
   - Then try scheduled notification
   - Finally try course reminder

## Known Working Configuration

**Tested on:** Google Pixel 6a, Android 13

**Required Settings:**
- ✅ Notification permission: Granted
- ✅ Exact alarm permission: Granted  
- ✅ Battery optimization: Unrestricted
- ✅ Background activity: Allowed
- ✅ Do Not Disturb: Disabled (or app in exceptions)
- ✅ Class Reminders channel: Enabled, High importance, Alerting

**Console output when working:**
```
✅ Exact alarm permission already granted
✅ Scheduled reminder for [Course] on [Day] at [Time]
✅ Notifications scheduled for [Course]
```

**Notification appears:** Exactly at [Class Time - Reminder Minutes]

## Still Not Working?

If you've tried everything above and notifications still don't work:

1. **Check Android version**
   - Go to Settings → About phone → Android version
   - Report the version (different versions have different restrictions)

2. **Check manufacturer**
   - Some manufacturers (Xiaomi, Oppo, Vivo) are very aggressive with battery saving
   - Search for "[Your Phone Brand] allow background notifications"

3. **Test on different device**
   - Try on a Google Pixel, OnePlus, or other stock Android device
   - This helps determine if it's manufacturer-specific

4. **Check logcat for errors**
   ```bash
   adb logcat | grep -i notification
   ```
   Look for any errors when the scheduled time arrives

5. **Enable verbose logging**
   - In your app, add more print statements
   - Log when notification should trigger
   - Check if the code even runs at scheduled time

## Alternative: Use AlarmManager Plugin

If flutter_local_notifications continues to have issues, consider using:
- `android_alarm_manager_plus` package
- Directly invoke AlarmManager for critical reminders
- More reliable for exact timing on problematic devices

## References

- [Android Battery Optimization](https://developer.android.com/topic/performance/power/power-details)
- [Android Notification Channels](https://developer.android.com/develop/ui/views/notifications/channels)
- [Don't Kill My App](https://dontkillmyapp.com/) - Manufacturer-specific guides
- [Flutter Local Notifications Issues](https://github.com/MaikuB/flutter_local_notifications/issues)
