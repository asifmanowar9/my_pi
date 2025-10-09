# Database Schema Fix Guide

## Problem
The database schema was missing required columns (`start_date`, `end_date`, `duration_months`, `status`) causing the error:
```
no such column: start_date in "UPDATE courses SET..."
```

## Solution Applied
Updated the database schema to include ALL required columns:
- start_date
- end_date  
- duration_months
- status
- schedule_days
- class_time
- reminder_minutes

## How to Apply the Fix

### Option 1: Uninstall and Reinstall (Recommended - Fresh Start)

**This will delete all existing data!**

1. **Stop the app** if it's running

2. **Uninstall the app** from your device/emulator:
   ```cmd
   flutter clean
   adb uninstall com.example.my_pi
   ```
   *(Replace `com.example.my_pi` with your actual package name from `android/app/build.gradle.kts`)*

3. **Install fresh**:
   ```cmd
   flutter run
   ```

4. **Test**: Create a new course with schedule information - it should work!

### Option 2: Force Database Upgrade (Keeps Data)

**This keeps existing data but may have issues if schema is severely broken**

Run this in your terminal:

```cmd
flutter run
```

Then trigger a hot restart (press 'R' in terminal or 'Shift+R' in IDE).

The migration should automatically run and add missing columns.

### Option 3: Clear App Data (Android Only)

1. On your Android device/emulator:
   - Go to **Settings** → **Apps** → **My Pi**
   - Tap **Storage** → **Clear Data**

2. Restart the app:
   ```cmd
   flutter run
   ```

## Verify the Fix

After applying any option, verify by:

1. **Create a new course** with complete information
2. **Add schedule details**:
   - Select class days
   - Set class time
   - Choose reminder duration
3. **Tap "Update"** on an existing course
4. **Check console** - should see:
   ```
   ✅ Courses table schema upgrade completed
   ✅ Course updated successfully
   ```

## What Was Changed

### Database Version
- **Before**: Version 7
- **After**: Version 8

### Columns Added to `courses` Table
1. `start_date` (TEXT) - Course start date
2. `end_date` (TEXT) - Course end date
3. `duration_months` (INTEGER) - Course duration
4. `status` (TEXT) - Course status (active/completed/upcoming)
5. `schedule_days` (TEXT) - Weekdays for class (1-7, comma-separated)
6. `class_time` (TEXT) - Class time in HH:mm format
7. `reminder_minutes` (INTEGER) - Reminder duration (10 or 15 minutes)

### Migration Strategy
The migration now:
1. Runs `_addCoursesTableColumns()` which checks for and adds ANY missing columns
2. This ensures all columns exist regardless of which version you're upgrading from
3. Safe to run multiple times (checks if column exists before adding)

## Troubleshooting

### Still seeing "no such column" error?

1. **Check database version in logs**:
   Look for: `🔄 Database upgrade: vX → vY`

2. **Force delete database** (use with caution - deletes ALL data):
   ```cmd
   adb shell run-as com.example.my_pi rm -rf /data/data/com.example.my_pi/databases
   ```

3. **Check for typos** in column names in your code

### Migration not running?

- The migration only runs when `oldVersion < newVersion`
- If you're already on version 8, uninstall and reinstall

## Prevention

Going forward, all new installations will have the complete schema from the start (see `_onCreate` method).
