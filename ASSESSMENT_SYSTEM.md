# Assessment System - Complete Implementation

## Overview
The assessment system provides a comprehensive way to track all types of assessments (quizzes, labs, midterm, presentation, final exam, and assignments) for each course. Each assessment has its own due date, reminder notification, and grade input. The system automatically calculates the overall GPA based on all graded assessments.

## Features

### 1. Assessment Types
Six types of assessments are supported:
- 📝 **Quiz** (10% weight) - Can have multiple quizzes
- 🧪 **Lab Report** (10% weight) - Can have multiple lab reports  
- 📚 **Midterm Exam** (25% weight) - Single midterm
- 🎤 **Presentation** (5% weight) - Single presentation
- 📖 **Final Exam** (35% weight) - Single final exam
- 📄 **Assignment** (15% weight) - Can have multiple assignments

### 2. Individual Assessment Features
Each assessment includes:
- **Title and Description** - Custom name and details
- **Due Date & Time** - Specific deadline
- **Reminder Notification** - Scheduled alerts (15 min, 30 min, 1 hr, 2 hr, 1 day, 2 days before)
- **Marks Entry** - Obtained marks and maximum marks
- **Completion Status** - Track whether completed
- **Percentage Calculation** - Automatic percentage from marks

### 3. Automatic GPA Calculation
The system automatically calculates:
- **Type Averages** - Average percentage for each assessment type (e.g., average of all quizzes)
- **Weighted GPA** - Uses predefined weights for each assessment type
- **Letter Grade** - Converts percentage to letter grade (A+, A, A-, etc.)
- **Overall Percentage** - Combined score across all assessment types
- **Status** - Performance status (Excellent, Very Good, Good, etc.)

### 4. Notification System
- Automatic reminders scheduled for each assessment
- Customizable reminder time (15 minutes to 2 days before)
- Uses exact alarm scheduling for precise timing
- Integrated with Android notification system

## Database Schema

### Assessments Table (Version 10)
```sql
CREATE TABLE assessments (
  id TEXT PRIMARY KEY,
  course_id TEXT NOT NULL,
  type TEXT NOT NULL,  -- quiz, labReport, midterm, presentation, finalExam, assignment
  title TEXT NOT NULL,
  description TEXT,
  due_date TEXT NOT NULL,
  reminder_minutes INTEGER,
  marks REAL,
  max_marks REAL,
  is_completed INTEGER DEFAULT 0,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  FOREIGN KEY (course_id) REFERENCES courses (id) ON DELETE CASCADE
)
```

## Files Created/Modified

### New Files
1. **lib/features/courses/models/assessment_model.dart**
   - Unified model for all assessment types
   - AssessmentType enum with all types
   - Extension methods for display names, icons, and weights
   - Percentage calculation and status checks

2. **lib/features/courses/controllers/assessment_controller.dart**
   - GetX controller with reactive state management
   - CRUD operations for assessments
   - Notification scheduling integration
   - Statistics calculation

3. **lib/features/courses/pages/add_assessment_page.dart**
   - Comprehensive form for adding/editing assessments
   - Assessment type selector with chips
   - Date/time pickers
   - Reminder dropdown
   - Marks input fields

4. **lib/features/courses/services/grade_calculation_service.dart**
   - GPA calculation logic
   - Weighted average calculation
   - Grade conversion (percentage to GPA and letter grade)
   - Type breakdown and completion tracking

### Modified Files
1. **lib/core/database/database_helper_clean.dart**
   - Upgraded to version 10
   - Added assessments table
   - Added CRUD methods for assessments

2. **lib/features/courses/pages/course_detail_page.dart**
   - Added assessments section
   - Added overall grade section
   - Integrated AssessmentController
   - Display assessments grouped by type
   - Show calculated GPA from all assessments

## User Interface

### Course Detail Page Layout
```
1. Course Header (gradient banner with name, code, status, credits)
2. Course Progress (timeline showing start/end dates, progress bar)
3. Description Card
4. Course Details (teacher, classroom, schedule)
5. Sync Information
6. **Assessments Section** ⭐ NEW
   - Grouped by type (Quizzes, Labs, Midterm, etc.)
   - Each assessment shows: title, due date, marks (if graded), completion status
   - Add buttons for each assessment type
   - Tap to edit assessment
7. **Overall Grade Section** ⭐ NEW
   - GPA, Letter Grade, and Percentage display
   - Status badge (Excellent, Good, etc.)
   - Completion percentage (how many types are graded)
   - Grade breakdown by type with weights
```

### Add Assessment Page
```
1. Assessment Type Selector (horizontal scrolling chips)
2. Title Field (required)
3. Description Field (optional)
4. Due Date Card (date and time pickers)
5. Reminder Card (dropdown: 15min, 30min, 1hr, 2hr, 1day, 2days)
6. Marks Card (obtained/maximum marks fields)
7. Completion Toggle (mark as completed)
8. Save Button (with validation)
```

## Grade Calculation Formula

### Individual Assessment Percentage
```
Percentage = (Marks Obtained / Maximum Marks) × 100
```

### Type Average
```
Type Average = Sum of all percentages for type / Number of graded assessments of type
```

### Weighted GPA
```
Weighted GPA = (
  (Quiz Avg × 10%) +
  (Lab Avg × 10%) +
  (Midterm × 25%) +
  (Presentation × 5%) +
  (Final Exam × 35%) +
  (Assignment Avg × 15%)
) / Total Weight of Graded Types
```

### GPA Scale (4.0 scale)
- 90-100%: 4.0 (A+)
- 85-89%: 3.7 (A)
- 80-84%: 3.3 (A-)
- 77-79%: 3.0 (B+)
- 73-76%: 2.7 (B)
- 70-72%: 2.3 (B-)
- 67-69%: 2.0 (C+)
- 63-66%: 1.7 (C)
- 60-62%: 1.3 (C-)
- 57-59%: 1.0 (D+)
- 53-56%: 0.7 (D)
- 50-52%: 0.5 (D-)
- Below 50%: 0.0 (F)

## Usage Flow

### Adding an Assessment
1. Open a course detail page
2. Scroll to "Assessments" section
3. Tap "Add [Type]" button (e.g., "Add Quiz")
4. Fill in assessment details (title, description, due date, reminder)
5. Optionally enter marks if already graded
6. Tap "Save"
7. Notification reminder is automatically scheduled

### Viewing Grades
1. Scroll to "Overall Grade" section in course detail
2. See overall GPA, letter grade, and percentage
3. View breakdown by assessment type
4. Check completion percentage

### Editing an Assessment
1. Tap on an assessment card
2. Modify any fields (marks, due date, etc.)
3. Tap "Save"
4. Notification reminder is automatically rescheduled

### Marking as Complete
1. Tap the checkbox on an assessment card
2. Assessment is marked complete
3. Optionally add marks to record grade

## Migration Notes

### Database Migration
- Automatically upgrades from version 9 to version 10
- Creates assessments table with proper foreign key constraints
- Previous course_grades table remains for backward compatibility

### Notification Service
- Uses AndroidScheduleMode.exactAllowWhileIdle for precise timing
- Requires exact alarm permission (already requested in app)
- Notifications include course name and assessment title

## Testing Checklist

- [ ] Add quiz assessment with reminder
- [ ] Add multiple assessments of same type
- [ ] Add assessments of all types
- [ ] Enter marks for assessments
- [ ] Verify GPA calculation
- [ ] Check notification scheduling
- [ ] Test editing assessments
- [ ] Verify reminder rescheduling
- [ ] Mark assessments as complete
- [ ] View grade breakdown
- [ ] Check completion percentage

## Next Steps

1. **Test the complete flow**:
   - Add assessments of different types
   - Enter marks and verify GPA calculation
   - Check that notifications are scheduled

2. **Optional enhancements**:
   - Export grades as PDF report
   - Grade trends graph
   - Comparison with class average
   - Custom weight configuration per course

3. **Data migration** (if needed):
   - Migrate existing assignment data to assessment table
   - Update old notification references

## Support

If you encounter any issues:
1. Check database version (should be 10)
2. Verify exact alarm permission is granted
3. Check notification channel settings
4. Review assessment controller logs
