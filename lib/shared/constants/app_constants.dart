import 'package:flutter/material.dart';

class AppConstants {
  // App Information
  static const String appName = 'My Pi';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Student Assistant App';

  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userDataKey = 'user_data';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language_code';

  // API Endpoints
  static const String baseUrl = 'https://your-api-base-url.com';
  static const String authEndpoint = '/auth';
  static const String coursesEndpoint = '/courses';
  static const String assignmentsEndpoint = '/assignments';
  static const String gradesEndpoint = '/grades';

  // Database Tables
  static const String usersTable = 'users';
  static const String coursesTable = 'courses';
  static const String assignmentsTable = 'assignments';
  static const String gradesTable = 'grades';

  // Assignment Status
  static const String assignmentPending = 'pending';
  static const String assignmentInProgress = 'in_progress';
  static const String assignmentCompleted = 'completed';
  static const String assignmentOverdue = 'overdue';

  // Grade Types
  static const String gradeTypeExam = 'exam';
  static const String gradeTypeQuiz = 'quiz';
  static const String gradeTypeAssignment = 'assignment';
  static const String gradeTypeProject = 'project';

  // Notification Channels
  static const String assignmentChannelId = 'assignment_notifications';
  static const String gradeChannelId = 'grade_notifications';
  static const String generalChannelId = 'general_notifications';
  static const String courseReminderChannelId = 'course_reminder_notifications';

  // Date Formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  static const String displayDateFormat = 'MMM dd, yyyy';
  static const String displayDateTimeFormat = 'MMM dd, yyyy HH:mm';

  // Validation
  static const int minPasswordLength = 6;
  static const int maxNameLength = 50;
  static const int maxDescriptionLength = 500;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration cacheTimeout = Duration(hours: 1);

  // File Sizes
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageFormats = ['jpg', 'jpeg', 'png', 'gif'];
  static const List<String> allowedDocumentFormats = [
    'pdf',
    'doc',
    'docx',
    'txt',
  ];

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultBorderRadius = 8.0;
  static const double cardElevation = 2.0;

  // Colors (Material 3 compatible)
  static const Color primaryColor = Color(0xFF6750A4);
  static const Color secondaryColor = Color(0xFF625B71);
  static const Color errorColor = Color(0xFFBA1A1A);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
}
