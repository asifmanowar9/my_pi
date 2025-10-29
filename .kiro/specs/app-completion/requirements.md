# Requirements Document

## Introduction

This specification defines the requirements for completing the My Pi Student Assistant app, a comprehensive Flutter application that helps students manage their academic life including courses, assessments, notifications, and grade tracking. The app currently has a solid foundation with authentication, course management, assessment system, and notification features partially implemented.

## Glossary

- **My_Pi_App**: The Flutter-based student assistant mobile application
- **Assessment_System**: The grading and evaluation tracking component with weighted GPA calculation
- **Notification_Service**: The local notification system for class and assignment reminders
- **Course_Management**: The system for tracking courses, schedules, and academic information
- **Authentication_System**: Firebase-based user authentication with email/password and Google Sign-In
- **Data_Sync**: The hybrid local/cloud data storage system using SQLite and Firestore
- **Grade_Calculator**: The component that calculates weighted GPAs and letter grades
- **User_Interface**: The Flutter UI components and screens

## Requirements

### Requirement 1

**User Story:** As a student, I want a fully functional course management system, so that I can track all my academic courses with complete information.

#### Acceptance Criteria

1. WHEN a user creates a course, THE Course_Management SHALL store course name, code, teacher, classroom, schedule, and credits
2. WHEN a user sets class schedule, THE Notification_Service SHALL schedule recurring weekly reminders
3. WHEN a user views course details, THE My_Pi_App SHALL display all course information with assessment breakdown
4. WHEN a user edits course information, THE Data_Sync SHALL update both local and cloud storage
5. WHEN a user deletes a course, THE My_Pi_App SHALL remove all associated assessments and notifications

### Requirement 2

**User Story:** As a student, I want a complete assessment tracking system, so that I can monitor my grades and academic performance across all assessment types.

#### Acceptance Criteria

1. WHEN a user adds an assessment, THE Assessment_System SHALL support quiz, midterm, assignment, presentation, final exam, and attendance types
2. WHEN a user enters quiz grades, THE Grade_Calculator SHALL automatically select the best 2 scores for final calculation
3. WHEN a user has both assignment and presentation, THE Grade_Calculator SHALL automatically split the 20% weight between them
4. WHEN assessment marks are entered, THE Grade_Calculator SHALL calculate weighted GPA using the 4.0 scale
5. WHEN assessments are incomplete, THE My_Pi_App SHALL display current GPA based on completed assessments only

### Requirement 3

**User Story:** As a student, I want reliable notification reminders, so that I never miss classes or assignment due dates.

#### Acceptance Criteria

1. WHEN a user sets class schedule, THE Notification_Service SHALL schedule weekly recurring reminders
2. WHEN a user adds assessment due dates, THE Notification_Service SHALL schedule one-time reminder notifications
3. WHEN notification time arrives, THE My_Pi_App SHALL display notification with course name and relevant details
4. WHEN a user modifies schedules, THE Notification_Service SHALL cancel old notifications and schedule new ones
5. WHEN exact alarm permission is required, THE My_Pi_App SHALL request and handle permission appropriately

### Requirement 4

**User Story:** As a student, I want secure authentication and data synchronization, so that my academic data is safe and accessible across devices.

#### Acceptance Criteria

1. WHEN a user registers, THE Authentication_System SHALL create account with email verification
2. WHEN a user signs in with Google, THE Authentication_System SHALL authenticate using Firebase Google Sign-In
3. WHEN user data changes, THE Data_Sync SHALL synchronize between local SQLite and cloud Firestore
4. WHEN a user is offline, THE My_Pi_App SHALL function with local data and sync when connection returns
5. WHEN a user deletes account, THE Authentication_System SHALL remove all user data from both local and cloud storage

### Requirement 5

**User Story:** As a student, I want a polished and intuitive user interface, so that I can efficiently navigate and use all app features.

#### Acceptance Criteria

1. WHEN a user opens the app, THE User_Interface SHALL display a splash screen followed by appropriate home or login screen
2. WHEN a user navigates between screens, THE My_Pi_App SHALL provide smooth transitions and consistent navigation
3. WHEN a user interacts with forms, THE User_Interface SHALL provide real-time validation and helpful error messages
4. WHEN a user views data, THE User_Interface SHALL display information in organized, readable layouts with appropriate theming
5. WHEN a user performs actions, THE My_Pi_App SHALL provide loading states and success/error feedback

### Requirement 6

**User Story:** As a student, I want comprehensive grade analytics and reporting, so that I can understand my academic performance trends and progress.

#### Acceptance Criteria

1. WHEN a user views course grades, THE Grade_Calculator SHALL display overall GPA, letter grade, and percentage
2. WHEN a user has multiple courses, THE My_Pi_App SHALL calculate and display cumulative GPA across all courses
3. WHEN assessment data exists, THE User_Interface SHALL show grade breakdown by assessment type with visual indicators
4. WHEN a user views progress, THE My_Pi_App SHALL display completion percentage and missing assessments
5. WHEN grade calculations occur, THE Grade_Calculator SHALL use the documented weighted system with proper rounding

### Requirement 7

**User Story:** As a student, I want robust error handling and data validation, so that the app works reliably and protects my data integrity.

#### Acceptance Criteria

1. WHEN invalid data is entered, THE My_Pi_App SHALL display clear validation messages and prevent submission
2. WHEN network errors occur, THE My_Pi_App SHALL handle gracefully and provide offline functionality
3. WHEN database operations fail, THE Data_Sync SHALL implement retry logic and error recovery
4. WHEN authentication errors occur, THE Authentication_System SHALL provide specific, actionable error messages
5. WHEN app crashes or unexpected errors occur, THE My_Pi_App SHALL log errors and recover gracefully without data loss