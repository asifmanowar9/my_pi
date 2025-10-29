import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../shared/services/storage_service.dart';

// Feature imports
import '../features/auth/pages/login_page.dart';
import '../features/auth/pages/register_page.dart';
import '../features/auth/pages/welcome_page.dart';
import '../features/auth/pages/forgot_password_page.dart';
import '../features/auth/controllers/auth_controller.dart';
import '../features/auth/services/auth_service.dart';
import '../features/debug/pages/database_viewer_page.dart';
import '../features/courses/pages/courses_page.dart';
import '../features/courses/pages/course_detail_page.dart';
import '../features/home/home_screen.dart';
import '../features/profile/pages/edit_profile_page.dart';
// import '../features/assignments/pages/assignments_page.dart';
// import '../features/grades/pages/grades_page.dart';

class Routes {
  // Route names
  static const String INITIAL = '/';
  static const String LOGIN = '/login';
  static const String REGISTER = '/register';
  static const String WELCOME = '/welcome';
  static const String HOME = '/home';
  static const String PROFILE = '/profile';
  static const String PROFILE_EDIT = '/profile/edit';
  static const String COURSES = '/courses';
  static const String COURSE_DETAIL = '/course-detail';
  static const String ASSIGNMENTS = '/assignments';
  static const String ASSIGNMENT_DETAIL = '/assignment-detail';
  static const String GRADES = '/grades';
  static const String SETTINGS = '/settings';
  static const String DATABASE_VIEWER = '/database-viewer';
  static const String FORGOT_PASSWORD = '/forgot-password';
}

class AppRoutes {
  // Route names (keeping both for compatibility)
  static const String initial = Routes.INITIAL;
  static const String login = Routes.LOGIN;
  static const String register = Routes.REGISTER;
  static const String welcome = Routes.WELCOME;
  static const String home = Routes.HOME;
  static const String profile = Routes.PROFILE;
  static const String profileEdit = Routes.PROFILE_EDIT;
  static const String courses = Routes.COURSES;
  static const String courseDetail = Routes.COURSE_DETAIL;
  static const String assignments = Routes.ASSIGNMENTS;
  static const String assignmentDetail = Routes.ASSIGNMENT_DETAIL;
  static const String grades = Routes.GRADES;
  static const String settings = Routes.SETTINGS;
  static const String databaseViewer = Routes.DATABASE_VIEWER;
  static const String forgotPassword = Routes.FORGOT_PASSWORD;

  // Route pages
  static final routes = [
    GetPage(name: Routes.INITIAL, page: () => const SplashPage()),
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.REGISTER,
      page: () => const RegisterPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.WELCOME,
      page: () => const WelcomePage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.FORGOT_PASSWORD,
      page: () => const ForgotPasswordPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.HOME,
      page: () => const HomeScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.PROFILE_EDIT,
      page: () => const EditProfilePage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.COURSES,
      page: () => const CoursesPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.COURSE_DETAIL,
      page: () {
        // Get course from arguments
        final course = Get.arguments;
        if (course != null) {
          return CourseDetailPage(course: course);
        }
        // Fallback - navigate back to courses
        Get.offNamed(Routes.COURSES);
        return const CoursesPage();
      },
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.ASSIGNMENTS,
      page: () => const AssignmentsPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.ASSIGNMENT_DETAIL,
      page: () => const AssignmentDetailPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.GRADES,
      page: () => const GradesPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.SETTINGS,
      page: () => const SettingsPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.DATABASE_VIEWER,
      page: () => const DatabaseViewerPage(),
      transition: Transition.rightToLeft,
    ),
  ];
}

// Temporary placeholder pages - replace with actual pages from features

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuthenticationState();
  }

  void _checkAuthenticationState() async {
    // Wait a bit for the splash screen effect
    await Future.delayed(const Duration(seconds: 2));

    try {
      // AuthController should already be initialized in main.dart
      // Just wait a bit more for Firebase Auth to restore state
      await Future.delayed(const Duration(milliseconds: 500));

      // Check if auth service is available
      if (Get.isRegistered<StorageService>()) {
        final storageService = Get.find<StorageService>();

        // Check if this is the first time opening the app
        final isFirstLaunch = storageService.read('isFirstLaunch') ?? true;

        if (isFirstLaunch) {
          // Mark that the app has been launched before
          storageService.write('isFirstLaunch', false);
          // Show welcome page for first-time users
          Get.offNamed(Routes.WELCOME);
        } else {
          // Check authentication state from local storage first
          final isLoggedIn = storageService.read('isLoggedIn') ?? false;
          final isGuest = storageService.read('isGuest') ?? false;
          final hasExplicitlyLoggedOut =
              storageService.read('hasLoggedOut') ?? false;

          // If user has explicitly logged out, ignore Firebase state and go to login
          if (hasExplicitlyLoggedOut) {
            // Clear the logout flag and ensure clean state
            storageService.write('hasLoggedOut', false);
            storageService.write('isLoggedIn', false);
            storageService.write('isGuest', false);
            storageService.remove('userId');

            // Force Firebase signout to be sure
            try {
              if (Get.isRegistered<AuthService>()) {
                final authService = Get.find<AuthService>();
                await authService.signOut();
              }
            } catch (e) {
              debugPrint('Error during forced signout: $e');
            }

            Get.offNamed(Routes.LOGIN);
            return;
          }

          // Check Firebase Auth state only if no explicit logout occurred
          bool firebaseAuthenticated = false;
          try {
            if (Get.isRegistered<AuthService>()) {
              final authService = Get.find<AuthService>();
              firebaseAuthenticated = authService.isAuthenticated;
            }
          } catch (e) {
            debugPrint('Error checking Firebase auth: $e');
          }

          // Only consider user logged in if both local storage AND Firebase agree
          // This prevents auto-login after logout
          if ((isLoggedIn && firebaseAuthenticated) || isGuest) {
            // User is properly authenticated or in guest mode
            Get.offNamed(Routes.HOME);
          } else {
            // User is not properly authenticated, clear any stale state
            if (isLoggedIn && !firebaseAuthenticated) {
              // Clear stale local state
              storageService.write('isLoggedIn', false);
              storageService.remove('userId');
            }
            Get.offNamed(Routes.LOGIN);
          }
        }
      } else {
        // Fallback to welcome if storage service is not available
        Get.offNamed(Routes.WELCOME);
      }
    } catch (e) {
      debugPrint('Error checking authentication: $e');
      Get.offNamed(Routes.WELCOME);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.school, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 32),

            // App Name
            Text(
              'My Pi',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
            const SizedBox(height: 8),

            Text(
              'Student Assistant App',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),

            const SizedBox(height: 48),

            // Loading indicator
            CircularProgressIndicator(color: Colors.blue.shade600),
          ],
        ),
      ),
    );
  }
}

class AssignmentsPage extends StatelessWidget {
  const AssignmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assignments')),
      body: const Center(child: Text('Assignments Page - To be implemented')),
    );
  }
}

class AssignmentDetailPage extends StatelessWidget {
  const AssignmentDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assignment Detail')),
      body: const Center(
        child: Text('Assignment Detail Page - To be implemented'),
      ),
    );
  }
}

class GradesPage extends StatelessWidget {
  const GradesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Grades')),
      body: const Center(child: Text('Grades Page - To be implemented')),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(child: Text('Settings Page - To be implemented')),
    );
  }
}
