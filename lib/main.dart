import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'firebase_options.dart';
import 'core/routes.dart';
import 'shared/themes/app_theme.dart';
import 'shared/services/firebase_service.dart';
import 'shared/services/notification_service.dart';
import 'shared/services/storage_service.dart';
import 'core/database/database_helper.dart';

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
      }
    } catch (e) {
      debugPrint('Firebase service not available: $e');
    }

    Get.put(NotificationService(), permanent: true);
    Get.put(DatabaseHelper(), permanent: true);

    // Initialize Theme Controller
    Get.put(ThemeController(), permanent: true);

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
      initialRoute: AppRoutes.initial,
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
