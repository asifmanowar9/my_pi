import 'package:get/get.dart';
import 'package:flutter/material.dart';

// Feature imports will be added here as features are created
// import '../features/auth/pages/login_page.dart';
// import '../features/auth/pages/register_page.dart';
// import '../features/courses/pages/courses_page.dart';
// import '../features/assignments/pages/assignments_page.dart';
// import '../features/grades/pages/grades_page.dart';

class AppRoutes {
  // Route names
  static const String initial = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String courses = '/courses';
  static const String courseDetail = '/course-detail';
  static const String assignments = '/assignments';
  static const String assignmentDetail = '/assignment-detail';
  static const String grades = '/grades';
  static const String settings = '/settings';

  // Route pages
  static final routes = [
    GetPage(name: initial, page: () => const SplashPage()),
    GetPage(
      name: login,
      page: () => const LoginPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: register,
      page: () => const RegisterPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: home,
      page: () => const HomePage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: courses,
      page: () => const CoursesPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: courseDetail,
      page: () => const CourseDetailPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: assignments,
      page: () => const AssignmentsPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: assignmentDetail,
      page: () => const AssignmentDetailPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: grades,
      page: () => const GradesPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: settings,
      page: () => const SettingsPage(),
      transition: Transition.rightToLeft,
    ),
  ];
}

// Temporary placeholder pages - replace with actual pages from features

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school, size: 100),
            SizedBox(height: 16),
            Text(
              'My Pi',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text('Student Assistant App'),
          ],
        ),
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: const Center(child: Text('Login Page - To be implemented')),
    );
  }
}

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: const Center(child: Text('Register Page - To be implemented')),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: const Center(child: Text('Home Page - To be implemented')),
    );
  }
}

class CoursesPage extends StatelessWidget {
  const CoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Courses')),
      body: const Center(child: Text('Courses Page - To be implemented')),
    );
  }
}

class CourseDetailPage extends StatelessWidget {
  const CourseDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Course Detail')),
      body: const Center(child: Text('Course Detail Page - To be implemented')),
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
