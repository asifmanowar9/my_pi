import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../shared/widgets/main_scaffold.dart';
import '../../features/home/home_screen.dart';
import '../../features/courses/courses_screen.dart';
import '../../features/assignments/assignments_screen.dart';
import '../../features/grades/grades_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../shared/widgets/splash_screen.dart';
import '../../features/auth/pages/login_page.dart';
import '../../features/auth/pages/register_page.dart';
import '../../features/auth/pages/welcome_page.dart';
import '../../features/auth/pages/forgot_password_page.dart';
import '../../shared/widgets/notification_debug_page.dart';

class AppRoutes {
  // Route names
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String welcome = '/welcome';
  static const String forgotPassword = '/forgot-password';
  static const String main = '/main';
  static const String home = '/home';
  static const String courses = '/courses';
  static const String assignments = '/assignments';
  static const String grades = '/grades';
  static const String profile = '/profile';
  static const String settings = '/settings';

  // Course related routes
  static const String courseDetail = '/course/:courseId';
  static const String courseAssignments = '/course/:courseId/assignments';
  static const String courseGrades = '/course/:courseId/grades';

  // Assignment related routes
  static const String assignmentDetail = '/assignment/:assignmentId';
  static const String assignmentSubmission = '/assignment/:assignmentId/submit';

  // Grade related routes
  static const String gradeDetail = '/grade/:gradeId';
  static const String transcript = '/transcript';

  // Profile related routes
  static const String editProfile = '/profile/edit';
  static const String changePassword = '/profile/password';
  static const String notifications = '/profile/notifications';
  static const String notificationDebug = '/debug/notifications';

  // Get all routes
  static List<GetPage> get routes => [
    // Splash screen
    GetPage(
      name: splash,
      page: () => const SplashScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // Auth pages
    GetPage(
      name: welcome,
      page: () => const WelcomePage(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: login,
      page: () => const LoginPage(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: register,
      page: () => const RegisterPage(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: forgotPassword,
      page: () => const ForgotPasswordPage(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // Main scaffold with nested navigation
    GetPage(
      name: main,
      page: () => const MainScaffold(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      children: [
        // Main tabs
        GetPage(
          name: home,
          page: () => const HomeScreen(),
          transition: Transition.noTransition,
        ),
        GetPage(
          name: courses,
          page: () => const CoursesScreen(),
          transition: Transition.noTransition,
        ),
        GetPage(
          name: assignments,
          page: () => const AssignmentsScreen(),
          transition: Transition.noTransition,
        ),
        GetPage(
          name: grades,
          page: () => const GradesScreen(),
          transition: Transition.noTransition,
        ),
        GetPage(
          name: profile,
          page: () => const ProfileScreen(),
          transition: Transition.noTransition,
        ),
      ],
    ),

    // Settings (full screen)
    GetPage(
      name: settings,
      page: () => const SettingsScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // Course related pages
    GetPage(
      name: courseDetail,
      page: () => CourseDetailScreen(courseId: Get.parameters['courseId']!),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: courseAssignments,
      page: () =>
          CourseAssignmentsScreen(courseId: Get.parameters['courseId']!),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: courseGrades,
      page: () => CourseGradesScreen(courseId: Get.parameters['courseId']!),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // Assignment related pages
    GetPage(
      name: assignmentDetail,
      page: () =>
          AssignmentDetailScreen(assignmentId: Get.parameters['assignmentId']!),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: assignmentSubmission,
      page: () => AssignmentSubmissionScreen(
        assignmentId: Get.parameters['assignmentId']!,
      ),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // Grade related pages
    GetPage(
      name: gradeDetail,
      page: () => GradeDetailScreen(gradeId: Get.parameters['gradeId']!),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: transcript,
      page: () => const TranscriptScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // Profile related pages
    GetPage(
      name: editProfile,
      page: () => const EditProfileScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: changePassword,
      page: () => const ChangePasswordScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: notifications,
      page: () => const NotificationsScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // Debug pages
    GetPage(
      name: notificationDebug,
      page: () => const NotificationDebugPage(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ];

  // Navigation helper methods
  static void toSplash() => Get.offAllNamed(splash);
  static void toWelcome() => Get.offAllNamed(welcome);
  static void toLogin() => Get.toNamed(login);
  static void toRegister() => Get.toNamed(register);
  static void toForgotPassword() => Get.toNamed(forgotPassword);
  static void toMain() => Get.offAllNamed(main);
  static void toSettings() => Get.toNamed(settings);

  // Course navigation
  static void toCourseDetail(String courseId) =>
      Get.toNamed(courseDetail.replaceAll(':courseId', courseId));

  static void toCourseAssignments(String courseId) =>
      Get.toNamed(courseAssignments.replaceAll(':courseId', courseId));

  static void toCourseGrades(String courseId) =>
      Get.toNamed(courseGrades.replaceAll(':courseId', courseId));

  // Assignment navigation
  static void toAssignmentDetail(String assignmentId) =>
      Get.toNamed(assignmentDetail.replaceAll(':assignmentId', assignmentId));

  static void toAssignmentSubmission(String assignmentId) => Get.toNamed(
    assignmentSubmission.replaceAll(':assignmentId', assignmentId),
  );

  // Grade navigation
  static void toGradeDetail(String gradeId) =>
      Get.toNamed(gradeDetail.replaceAll(':gradeId', gradeId));

  static void toTranscript() => Get.toNamed(transcript);

  // Profile navigation
  static void toEditProfile() => Get.toNamed(editProfile);
  static void toChangePassword() => Get.toNamed(changePassword);
  static void toNotifications() => Get.toNamed(notifications);

  // Debug navigation
  static void toNotificationDebug() => Get.toNamed(notificationDebug);

  // Deep link handling
  static String? handleDeepLink(String link) {
    // Remove domain and protocol if present
    final uri = Uri.parse(link);
    final path = uri.path;

    // Extract route and parameters
    if (path.startsWith('/course/')) {
      final segments = path.split('/');
      if (segments.length >= 3) {
        final courseId = segments[2];
        if (segments.length >= 4) {
          switch (segments[3]) {
            case 'assignments':
              return courseAssignments.replaceAll(':courseId', courseId);
            case 'grades':
              return courseGrades.replaceAll(':courseId', courseId);
          }
        }
        return courseDetail.replaceAll(':courseId', courseId);
      }
    }

    if (path.startsWith('/assignment/')) {
      final segments = path.split('/');
      if (segments.length >= 3) {
        final assignmentId = segments[2];
        if (segments.length >= 4 && segments[3] == 'submit') {
          return assignmentSubmission.replaceAll(':assignmentId', assignmentId);
        }
        return assignmentDetail.replaceAll(':assignmentId', assignmentId);
      }
    }

    if (path.startsWith('/grade/')) {
      final segments = path.split('/');
      if (segments.length >= 3) {
        final gradeId = segments[2];
        return gradeDetail.replaceAll(':gradeId', gradeId);
      }
    }

    // Handle main tab routes
    switch (path) {
      case home:
      case courses:
      case assignments:
      case grades:
      case profile:
      case settings:
      case transcript:
      case editProfile:
      case changePassword:
      case notifications:
        return path;
      default:
        return main; // Default to main page
    }
  }
}

// Placeholder screens (to be implemented)
class CourseDetailScreen extends StatelessWidget {
  final String courseId;

  const CourseDetailScreen({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Course $courseId')),
      body: Center(child: Text('Course Detail: $courseId')),
    );
  }
}

class CourseAssignmentsScreen extends StatelessWidget {
  final String courseId;

  const CourseAssignmentsScreen({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Course $courseId Assignments')),
      body: Center(child: Text('Course Assignments: $courseId')),
    );
  }
}

class CourseGradesScreen extends StatelessWidget {
  final String courseId;

  const CourseGradesScreen({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Course $courseId Grades')),
      body: Center(child: Text('Course Grades: $courseId')),
    );
  }
}

class AssignmentDetailScreen extends StatelessWidget {
  final String assignmentId;

  const AssignmentDetailScreen({super.key, required this.assignmentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Assignment $assignmentId')),
      body: Center(child: Text('Assignment Detail: $assignmentId')),
    );
  }
}

class AssignmentSubmissionScreen extends StatelessWidget {
  final String assignmentId;

  const AssignmentSubmissionScreen({super.key, required this.assignmentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Submit Assignment $assignmentId')),
      body: Center(child: Text('Assignment Submission: $assignmentId')),
    );
  }
}

class GradeDetailScreen extends StatelessWidget {
  final String gradeId;

  const GradeDetailScreen({super.key, required this.gradeId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Grade $gradeId')),
      body: Center(child: Text('Grade Detail: $gradeId')),
    );
  }
}

class TranscriptScreen extends StatelessWidget {
  const TranscriptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transcript')),
      body: const Center(child: Text('Academic Transcript')),
    );
  }
}

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: const Center(child: Text('Edit Profile Screen')),
    );
  }
}

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Change Password')),
      body: const Center(child: Text('Change Password Screen')),
    );
  }
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: const Center(child: Text('Notifications Screen')),
    );
  }
}
