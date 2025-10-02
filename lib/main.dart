import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'firebase_options.dart';
import 'core/routes/app_routes.dart';
import 'core/controllers/navigation_controller.dart';
import 'shared/themes/app_theme.dart';
import 'shared/services/firebase_service.dart';
import 'shared/services/notification_service.dart';
import 'shared/services/storage_service.dart';
import 'shared/services/cloud_database_service.dart';
import 'core/database/database_helper_clean.dart' as DatabaseHelperClean;
import 'features/auth/services/auth_service.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/courses/services/course_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize GetStorage first
  await GetStorage.init();

  // Initialize Firebase with error handling
  await _initializeFirebase();

  // Initialize Services (but don't setup auth listener yet)
  await _initializeServices();

  runApp(const MyApp());
}

Future<void> _initializeFirebase() async {
  try {
    // Check if Firebase is already initialized
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint('Firebase initialized successfully');
    } else {
      debugPrint('Firebase already initialized');
    }
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
    // Continue without Firebase for development
  }
}

Future<void> _initializeServices() async {
  try {
    // Register Services
    Get.put(StorageService(), permanent: true);

    // Only initialize Firebase service if Firebase is available
    try {
      if (Firebase.apps.isNotEmpty) {
        Get.put(FirebaseService(), permanent: true);
        Get.put(AuthService(), permanent: true);
      }
    } catch (e) {
      debugPrint('Firebase service not available: $e');
    }

    // Initialize AuthController only once
    if (!Get.isRegistered<AuthController>()) {
      Get.put(AuthController(), permanent: true);
    }

    Get.put(NotificationService(), permanent: true);
    Get.put(DatabaseHelperClean.DatabaseHelper(), permanent: true);

    // Initialize Cloud Database Service if Firebase is available
    try {
      if (Firebase.apps.isNotEmpty) {
        Get.put(CloudDatabaseService(), permanent: true);
      }
    } catch (e) {
      debugPrint('Cloud database service not available: $e');
    }

    // Initialize CourseService
    Get.put(CourseService(), permanent: true);

    // Initialize Theme Controller
    Get.put(ThemeController(), permanent: true);

    // Initialize Navigation Controller
    Get.put(NavigationController(), permanent: true);

    // Initialize Notification Service
    await Get.find<NotificationService>().initialize();
  } catch (e) {
    debugPrint('Error initializing services: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'My Pi - Student Assistant',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: Get.find<ThemeController>().theme,
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.routes,
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
      onReady: () {
        // Setup Firebase auth listener after GetMaterialApp is ready
        _setupFirebaseAuthListener();
      },
    );
  }

  void _setupFirebaseAuthListener() {
    try {
      if (Get.isRegistered<FirebaseService>()) {
        Get.find<FirebaseService>().setupAuthListener();
      }
    } catch (e) {
      debugPrint('Error setting up Firebase auth listener: $e');
    }
  }
}
