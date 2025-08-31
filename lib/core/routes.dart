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
      page: () => const HomePage(),
      transition: Transition.fadeIn,
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
          // Check authentication state from both storage and Firebase
          final isLoggedIn = storageService.read('isLoggedIn') ?? false;
          final isGuest = storageService.read('isGuest') ?? false;

          // Double-check with Firebase Auth state if available
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

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Pi'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'profile') {
                // Navigate to profile
              } else if (value == 'settings') {
                // Navigate to settings
              } else if (value == 'database') {
                Get.toNamed(Routes.DATABASE_VIEWER);
              } else if (value == 'logout') {
                _showLogoutDialog(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person),
                    SizedBox(width: 8),
                    Text('Profile'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'database',
                child: Row(
                  children: [
                    Icon(Icons.storage),
                    SizedBox(width: 8),
                    Text('Database Viewer'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome section - Reactive to user changes
            FutureBuilder<Map<String, dynamic>>(
              future: _getUserInfo(),
              builder: (context, snapshot) {
                Map<String, dynamic> userInfo =
                    snapshot.data ?? {'isGuest': true, 'userName': ''};
                bool isGuest = userInfo['isGuest'] ?? true;
                String userName = userInfo['userName'] ?? '';

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isGuest ? Icons.explore : Icons.waving_hand,
                              color: isGuest
                                  ? Colors.blue.shade600
                                  : Colors.orange.shade600,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                isGuest
                                    ? 'Welcome, Guest!'
                                    : userName.isNotEmpty
                                    ? 'Welcome back, $userName!'
                                    : 'Welcome back!',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isGuest
                              ? 'Exploring in guest mode. Create an account to save your progress!'
                              : 'Ready to continue your learning journey?',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                        if (isGuest) ...[
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () => _navigateToCreateAccount(),
                            icon: const Icon(Icons.person_add, size: 16),
                            label: const Text('Create Account'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Quick Actions
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildFeatureCard(
                    icon: Icons.book,
                    title: 'Courses',
                    subtitle: 'View your courses',
                    color: Colors.blue,
                    onTap: () {
                      Get.toNamed(Routes.COURSES);
                    },
                  ),
                  _buildFeatureCard(
                    icon: Icons.assignment,
                    title: 'Assignments',
                    subtitle: 'Check assignments',
                    color: Colors.green,
                    onTap: () {
                      Get.snackbar(
                        'Coming Soon',
                        'Assignments feature will be available soon!',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                  ),
                  _buildFeatureCard(
                    icon: Icons.grade,
                    title: 'Grades',
                    subtitle: 'View your grades',
                    color: Colors.purple,
                    onTap: () {
                      Get.snackbar(
                        'Coming Soon',
                        'Grades feature will be available soon!',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                  ),
                  _buildFeatureCard(
                    icon: Icons.schedule,
                    title: 'Schedule',
                    subtitle: 'Your timetable',
                    color: Colors.orange,
                    onTap: () {
                      Get.snackbar(
                        'Coming Soon',
                        'Schedule feature will be available soon!',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              try {
                if (Get.isRegistered<StorageService>()) {
                  final storageService = Get.find<StorageService>();
                  bool isGuest = storageService.read('isGuest') ?? false;
                  bool hasSeenWelcome =
                      storageService.read('hasSeenWelcome') ?? false;

                  // Clear all authentication data (use same keys as AuthController)
                  storageService.write('isLoggedIn', false);
                  storageService.write('isGuest', false);
                  storageService.remove('user');
                  storageService.remove('userId');

                  // Navigate based on whether user has seen welcome page
                  String targetRoute = hasSeenWelcome
                      ? Routes.LOGIN
                      : Routes.WELCOME;
                  Get.offAllNamed(targetRoute);

                  // Show appropriate message
                  Get.snackbar(
                    'Success',
                    isGuest
                        ? 'Guest session ended'
                        : 'You have been logged out successfully',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                } else {
                  Get.offAllNamed(Routes.LOGIN);
                }
              } catch (e) {
                Get.offAllNamed(Routes.LOGIN);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> _getUserInfo() async {
    try {
      // Check guest mode first
      if (Get.isRegistered<StorageService>()) {
        final storageService = Get.find<StorageService>();
        bool isGuest = storageService.read('isGuest') ?? false;

        if (isGuest) {
          return {'isGuest': true, 'userName': ''};
        }
      }

      // Ensure AuthController is initialized
      AuthController authController;
      if (Get.isRegistered<AuthController>()) {
        authController = Get.find<AuthController>();
      } else {
        authController = Get.put(AuthController(), permanent: true);
        // Wait a bit for initialization
        await Future.delayed(const Duration(milliseconds: 300));
      }

      final user = authController.user;

      if (user != null) {
        String userName = user.displayName ?? '';

        // If no display name, try to get name from email (first part before @)
        if (userName.isEmpty && user.email != null) {
          userName = user.email!.split('@').first;
        }

        print(
          'User found: ${user.email}, Display name: ${user.displayName}, Username: $userName',
        );
        return {'isGuest': false, 'userName': userName};
      } else {
        print('No user found in AuthController');
      }

      return {'isGuest': false, 'userName': ''};
    } catch (e) {
      print('Error in _getUserInfo: $e');
      return {'isGuest': false, 'userName': ''};
    }
  }

  void _navigateToCreateAccount() async {
    try {
      if (Get.isRegistered<StorageService>()) {
        final storageService = Get.find<StorageService>();
        bool hasSeenWelcome = storageService.read('hasSeenWelcome') ?? false;

        // Navigate based on whether user has seen welcome page
        if (hasSeenWelcome) {
          Get.offAllNamed(Routes.REGISTER);
        } else {
          Get.offAllNamed(Routes.WELCOME);
        }
      } else {
        Get.offAllNamed(Routes.REGISTER);
      }
    } catch (e) {
      Get.offAllNamed(Routes.REGISTER);
    }
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
