# Course Notification Reminder Feature

## Overview
This feature allows users to set up class schedules with automatic notification reminders before each class starts.

## Implementation Date
October 3, 2025

## Features Implemented

### 1. **Schedule Configuration**
- **Class Days Selection**: Users can select which days of the week their course has classes (Monday-Sunday)
- **Class Time**: Time picker to set when the class starts (24-hour format stored, 12-hour format displayed)
- **Reminder Duration**: Dropdown to choose notification timing (10 or 15 minutes before class)
- **Classroom Information**: Displayed in notifications to help users know where to go

### 2. **Notification System**
- **Recurring Weekly Notifications**: Automatically scheduled for each selected weekday
- **Smart Scheduling**: Only schedules notifications for future class times
- **Classroom Display**: Shows classroom location in notification body
- **Auto-Update**: Notifications are automatically updated when course schedule changes
- **Auto-Cancel**: Notifications are automatically cancelled when course is deleted

### 3. **User Interface**
- **Weekday Chips**: Interactive filter chips for day selection (M, T, W, T, F, S, S)
- **Time Picker**: Material Design time picker for class time selection
- **Reminder Dropdown**: Easy selection between 10 or 15 minute reminders
- **Visual Feedback**: Selected days are highlighted with theme colors

## Files Modified

### Models
- **`course_model.dart`**: Added fields
  - `scheduleDays` (List<int>): Days of week (1-7, Mon-Sun)
  - `classTime` (String): Class time in "HH:mm" format
  - `reminderMinutes` (int): Minutes before class to notify
  - Helper methods: `scheduleDaysText`, `classTimeText`, `reminderText`, `hasSchedule`

### Database
- **`database_helper_clean.dart`**: 
  - Version upgraded from 7 to 8
  - Added columns: `schedule_days`, `class_time`, `reminder_minutes`
  - Created migration method `_addScheduleNotificationColumns()`

### Controllers
- **`course_controller.dart`**: Added
  - Observable fields: `_selectedDays`, `_classTime`, `_reminderMinutes`
  - Methods: `toggleWeekday()`, `setClassTime()`, `setReminderMinutes()`
  - Notification integration: `_scheduleNotificationsForCourse()`, `_cancelNotificationsForCourse()`
  - Updated: `createCourse()`, `updateCourse()`, `deleteCourse()`
  - Updated: `_buildCourseFromForm()`, `selectCourseForEditing()`, `clearForm()`

- **`course_assignment_controller.dart`**: Fixed
  - Removed alias import, directly using `DatabaseHelper`

### Services
- **`notification_service.dart`**: Added
  - `scheduleCourseReminders()`: Schedule recurring weekly notifications
  - `cancelCourseReminders()`: Cancel all notifications for a course
  - `_getNextWeekday()`: Calculate next occurrence of a weekday
  - `_generateCourseNotificationId()`: Generate unique IDs per course/day
  - `_scheduleCourseReminder()`: Schedule individual notification with proper formatting

### UI
- **`add_course_page.dart`**: Added
  - "Class Schedule & Reminders" section
  - `_buildWeekdaySelector()`: Weekday chip selector
  - `_buildTimeField()`: Time picker field
  - `_buildReminderDropdown()`: Reminder duration dropdown
  - `_selectClassTime()`: Time picker dialog handler
  - `_formatTime()`: 12-hour time formatting

### Constants
- **`app_constants.dart`**: Added
  - `courseReminderChannelId`: 'course_reminder_notifications'

## Database Schema

### Courses Table (New Columns)
```sql
schedule_days TEXT,        -- Comma-separated weekday numbers (1-7)
class_time TEXT,           -- Format: "HH:mm" (24-hour)
reminder_minutes INTEGER   -- 10 or 15
```

## Notification Format

### Notification Title
```
📚 Class Starting Soon
```

### Notification Body
```
{Course Name} at {Time in 12h format} in {Classroom}
```

### Example
```
Title: 📚 Class Starting Soon
Body: Introduction to Computer Science at 10:30 AM in Room 101
```

## How It Works

### 1. Creating a Course with Notifications
1. User fills in course details
2. User selects class days (e.g., Mon, Wed, Fri)
3. User sets class time (e.g., 10:30 AM)
4. User chooses reminder (10 or 15 minutes)
5. On save, notifications are scheduled for all selected days

### 2. Notification Scheduling Logic
- For each selected day, calculate next occurrence
- Subtract reminder minutes from class time
- Schedule recurring weekly notification
- Use `DateTimeComponents.dayOfWeekAndTime` for weekly recurrence

### 3. Updating a Course
- Old notifications are cancelled
- New notifications are scheduled with updated information
- User sees success message

### 4. Deleting a Course
- All notifications for the course are cancelled
- Database records are removed
- User sees confirmation

## Technical Details

### Weekday Numbering
- 1 = Monday
- 2 = Tuesday
- 3 = Wednesday
- 4 = Thursday
- 5 = Friday
- 6 = Saturday
- 7 = Sunday

### Time Format
- **Stored**: 24-hour format "HH:mm" (e.g., "14:30")
- **Displayed**: 12-hour format with AM/PM (e.g., "2:30 PM")

### Notification IDs
- Generated using: `(courseId.hashCode + dayOfWeek * 1000).abs() % 2147483647`
- Ensures unique ID for each course-day combination
- Allows selective cancellation by course

### Android Channel Configuration
```dart
AndroidNotificationChannel(
  'course_reminder_notifications',
  'Class Reminders',
  description: 'Notifications reminding you of upcoming classes',
  importance: Importance.high,
  priority: Priority.high,
)
```

## Testing Checklist

- [x] Create course with schedule information
- [x] Select multiple weekdays
- [x] Set class time
- [x] Choose reminder duration (10/15 mins)
- [x] Verify notification scheduled message in console
- [x] Edit course and update schedule
- [x] Verify old notifications cancelled and new ones scheduled
- [x] Delete course
- [x] Verify notifications cancelled
- [x] Create course without schedule (should work without errors)

## User Flow

### Adding Schedule to New Course
1. Tap "+" button on courses screen
2. Fill in course name, teacher, classroom
3. Fill in the text schedule field (existing field for display)
4. **NEW**: Scroll to "Class Schedule & Reminders"
5. **NEW**: Tap weekday chips to select class days
6. **NEW**: Tap time field to set class time
7. **NEW**: Select reminder duration from dropdown
8. Tap "Save"
9. See success message: "Course created successfully"
10. Notifications are scheduled in background

### Editing Schedule
1. Tap edit button on course card
2. Modify schedule fields
3. Tap "Update"
4. Old notifications cancelled, new ones scheduled

## Future Enhancements (Not Implemented)

- [ ] Multiple class times per day
- [ ] Different reminder times for different days
- [ ] Notification history/log
- [ ] Snooze functionality
- [ ] Custom notification sound per course
- [ ] Notification when class ends
- [ ] Integration with device calendar

## Dependencies

All required packages were already installed:
- `flutter_local_notifications: ^17.2.2`
- `timezone: ^0.9.4`
- `uuid: ^4.5.1`

## Notes

- Notifications require app to have notification permissions
- iOS requires additional Info.plist configuration
- Android 13+ requires explicit notification permission request
- Notifications persist across app restarts
- Uses `AndroidScheduleMode.exactAllowWhileIdle` for precise timing

## Console Output Examples

### Successful Scheduling
```
✅ Notifications scheduled for Introduction to Computer Science
✅ Scheduled reminder for Introduction to Computer Science on Monday at 10:30 AM (Reminder: 15 min before)
✅ Scheduled reminder for Introduction to Computer Science on Wednesday at 10:30 AM (Reminder: 15 min before)
```

### Course Without Complete Schedule
```
⚠️ Course Advanced Mathematics does not have complete schedule information
```

### Notification Cancellation
```
✅ Cancelled all reminders for course: abc123
```
