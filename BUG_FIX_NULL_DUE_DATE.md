# Bug Fix: Null Check Error for Due Dates

## Issue
The app was crashing with a `Null check operator used on a null value` error when displaying assessments in the course detail page.

**Error Location**: `course_detail_page.dart:834`

**Stack Trace**:
```
CourseDetailPage._buildAssessmentCard
The following _TypeError was thrown building Obx:
Null check operator used on a null value
```

## Root Cause
The `AssessmentModel.dueDate` field is nullable (`DateTime?`), which means assessments can be created without a due date. However, the UI code was using the null-assertion operator (`!`) to format the due date without first checking if it was null:

```dart
Text(
  'Due: ${DateFormat('MMM dd, HH:mm').format(assessment.dueDate!)}',
  // ❌ This crashes if dueDate is null
)
```

## Solution
Added a null check before displaying the due date information:

```dart
if (assessment.dueDate != null) ...[
  const SizedBox(height: 4),
  Row(
    children: [
      Icon(Icons.calendar_today, ...),
      const SizedBox(width: 4),
      Text(
        'Due: ${DateFormat('MMM dd, HH:mm').format(assessment.dueDate!)}',
        // ✅ Now only accessed when not null
      ),
      if (isOverdue) ...[
        // Overdue badge
      ],
    ],
  ),
],
```

## Impact
- **Before**: App crashed when displaying assessments without due dates
- **After**: Assessments without due dates display normally (just don't show the due date row)

## Files Modified
- `lib/features/courses/pages/course_detail_page.dart` (line 809-862)
  - Wrapped due date display in null check condition
  - Title still displays even without due date
  - Due date and overdue badge only show when due date exists

## Why Due Dates Can Be Null
1. Database schema allows null: `due_date TEXT` (no `NOT NULL` constraint)
2. AddAssessmentPage allows creating assessments without due dates
3. This is intentional to support draft assessments or assessments without specific deadlines

## Testing
- ✅ Create assessment with due date - displays correctly
- ✅ Create assessment without due date - displays title only, no crash
- ✅ Edit assessment to add/remove due date - updates correctly
- ✅ Overdue badge only shows when due date exists and is past

## Prevention
To prevent similar issues in the future:
1. Always check nullable fields before using null-assertion operator
2. Use conditional rendering for optional UI elements
3. Consider using null-aware operators (`?.`) where appropriate
4. Test edge cases (null values, empty lists, etc.)

## Related Code
- `AssessmentModel.dueDate` - Declared as `DateTime?` (nullable)
- `AssessmentModel.isOverdue` - Already has null check: `if (dueDate == null || isCompleted) return false;`
- Database schema - `due_date TEXT` without `NOT NULL`

## Date: October 4, 2025
