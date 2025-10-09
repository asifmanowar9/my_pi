# New Grading System Documentation

## Overview
The application now uses a comprehensive grading system with automatic GPA calculation based on weighted assessment types.

## Assessment Types and Weights

### 1. Quiz (15% / 15 marks)
- **Total Weight:** 15%
- **Max Marks:** 15 per quiz
- **Number Allowed:** 1-4 quizzes
- **Calculation Logic:**
  - System takes the **best 2 scores** from all quizzes
  - Calculates the **average marks** from these best 2
  - Example:
    ```
    Quiz 1: 12/15 (80%)
    Quiz 2: 14/15 (93.3%)
    Quiz 3: 10/15 (66.7%)
    Quiz 4: 13/15 (86.7%)
    
    Best 2: Quiz 2 (14) and Quiz 4 (13)
    Average: (14 + 13) / 2 = 13.5 marks
    Final Quiz Score: 13.5/15
    ```

### 2. Midterm Exam (20% / 20 marks)
- **Total Weight:** 20%
- **Max Marks:** 20
- **Number Allowed:** 1
- **Calculation Logic:**
  - Direct marks used
  - Example: 17/20 = 17 marks

### 3. Assignment/Presentation (20% / 20 marks total)
- **Total Weight:** 20% (shared)
- **Max Marks:** Depends on what exists
- **Auto-Split Logic:**
  
  **Case 1: Only Assignment exists**
  - Assignment gets full 20 marks
  - Example: 18/20 = 18 marks

  **Case 2: Only Presentation exists**
  - Presentation gets full 20 marks
  - Example: 16/20 = 16 marks

  **Case 3: Both Assignment AND Presentation exist**
  - Each gets 10 marks max (auto-split)
  - System scales them proportionally
  - Example:
    ```
    Assignment: 18/20 → scaled to (18/20) × 10 = 9 marks
    Presentation: 16/20 → scaled to (16/20) × 10 = 8 marks
    Total: 9 + 8 = 17 marks out of 20
    ```

### 4. Final Exam (40% / 40 marks)
- **Total Weight:** 40%
- **Max Marks:** 40
- **Number Allowed:** 1
- **Calculation Logic:**
  - Direct marks used
  - Example: 35/40 = 35 marks

### 5. Attendance (5% / 5 marks)
- **Total Weight:** 5%
- **Max Marks:** 5
- **Number Allowed:** 1
- **Calculation Logic:**
  - Direct marks input (e.g., 4.5/5)
  - Example: 4.5/5 = 4.5 marks

## Final Grade Calculation

### Total Marks Calculation
```
Total = Quiz + Midterm + Assignment/Presentation + Final + Attendance
Max Total = 15 + 20 + 20 + 40 + 5 = 100 marks
```

### Example Full Calculation
```
Quiz: 13.5/15 (best 2 average)
Midterm: 17/20
Assignment: 18/20 (or 9/10 if presentation exists)
Presentation: 8/10 (only if both exist)
Final: 35/40
Attendance: 4.5/5

Total: 13.5 + 17 + 17 + 35 + 4.5 = 87 marks out of 100
Percentage: 87%
```

## GPA Scale (4.0 Scale)

| Percentage | GPA  | Letter Grade |
|------------|------|--------------|
| 90-100%    | 4.0  | A+           |
| 85-89%     | 3.7  | A            |
| 80-84%     | 3.3  | A-           |
| 77-79%     | 3.0  | B+           |
| 73-76%     | 2.7  | B            |
| 70-72%     | 2.3  | B-           |
| 67-69%     | 2.0  | C+           |
| 63-66%     | 1.7  | C            |
| 60-62%     | 1.3  | C-           |
| 57-59%     | 1.0  | D+           |
| 53-56%     | 0.7  | D            |
| 50-52%     | 0.7  | D-           |
| Below 50%  | 0.0  | F            |

## Status Classification

| Percentage | Status       |
|------------|--------------|
| 90-100%    | Excellent    |
| 80-89%     | Very Good    |
| 70-79%     | Good         |
| 60-69%     | Satisfactory |
| 50-59%     | Pass         |
| Below 50%  | Fail         |

## Features

### 1. Smart Default Max Marks
When adding a new assessment, the system automatically sets the max marks based on type:
- Quiz: 15
- Midterm: 20
- Assignment: 20
- Presentation: 20
- Final Exam: 40
- Attendance: 5

### 2. Automatic Calculations
- No manual weight input needed
- Quiz best-2 selection is automatic
- Assignment/Presentation split is automatic
- GPA and letter grade calculated in real-time

### 3. Flexible Input
- Add assessments at any time
- Can have 1-4 quizzes (system picks best 2)
- Can have assignment only, presentation only, or both
- Marks are optional (can add dates/reminders first)

### 4. Real-time Updates
- Overall grade updates as you add marks
- Progress tracking for assessment completion
- Visual indicators for grade status

## Testing Scenarios

### Scenario 1: Full Course with All Assessments
```
Quiz 1: 12/15
Quiz 2: 14/15
Quiz 3: 10/15
Quiz 4: 13/15
→ Best 2 average: 13.5/15

Midterm: 17/20
Assignment: 18/20
Final: 35/40
Attendance: 4.5/5

Total: 13.5 + 17 + 18 + 35 + 4.5 = 88/100
GPA: 3.7 (A)
```

### Scenario 2: Course with Both Assignment and Presentation
```
Quiz 1: 13/15
Quiz 2: 14/15
→ Best 2 average: 13.5/15

Midterm: 16/20
Assignment: 18/20 → scaled to 9/10
Presentation: 16/20 → scaled to 8/10
Final: 32/40
Attendance: 4/5

Total: 13.5 + 16 + 17 + 32 + 4 = 82.5/100
GPA: 3.3 (A-)
```

### Scenario 3: Partial Assessments (In Progress)
```
Quiz 1: 12/15
Midterm: 17/20

Total: 29/35 (only graded items)
Percentage: 82.86%
GPA: 3.3 (A-)
Note: Will normalize as more assessments are graded
```

## Implementation Files

### Modified Files:
1. `lib/features/courses/models/assessment_model.dart`
   - Removed `labReport` type
   - Added `attendance` type
   - Added `defaultMaxMarks` getter
   - Added `weight` getter

2. `lib/features/courses/services/grade_calculation_service.dart`
   - Implemented quiz best-2 average logic
   - Implemented assignment/presentation auto-split
   - Updated weight calculations
   - Added detailed breakdown

3. `lib/features/courses/pages/add_assessment_page.dart`
   - Auto-fill max marks based on type
   - Updated type selection chips
   - Removed lab report option

4. `lib/features/courses/pages/course_detail_page.dart`
   - Updated weight display
   - Dynamic type grouping

## Usage Guide

### Adding a Quiz
1. Go to Course Detail Page
2. Click "Add Assessment"
3. Select "📝 Quiz" type
4. Max marks auto-fills to 15
5. Enter title, marks (optional), due date
6. Save

### Adding Assignment/Presentation
- Add either one or both
- System automatically adjusts weights
- Each can be added independently

### Viewing Overall Grade
- Scroll to "Overall Grade" section
- Shows GPA, Letter Grade, and Percentage
- Displays status badge
- Shows assessment completion progress

## Notes

- The system is flexible and handles partial data
- Grades update in real-time as assessments are added
- Quiz best-2 logic only activates when 2+ quizzes exist
- Assignment/presentation split only happens when both exist
- All calculations are automatic - no manual intervention needed
