import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../services/auth_service.dart';
import '../exceptions/auth_exceptions.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/database/database_helper_clean.dart';
import '../../courses/services/course_service.dart';
import '../../courses/controllers/assessment_controller.dart';

class AuthController extends GetxController {
  static AuthController get instance => Get.find();

  final AuthService _authService = AuthService.instance;
  final GetStorage _storage = GetStorage();

  // 1. Reactive user state with Rx<User?>
  final Rx<User?> _user = Rx<User?>(null);
  User? get user => _user.value;
  bool get isAuthenticated => _user.value != null;

  // 2. Loading states for login, register, and signOut methods
  final RxBool _isLoading = false.obs;
  final RxBool _isSigningIn = false.obs;
  final RxBool _isRegistering = false.obs;
  final RxBool _isSigningOut = false.obs;

  bool get isLoading => _isLoading.value;
  bool get isSigningIn => _isSigningIn.value;
  bool get isRegistering => _isRegistering.value;
  bool get isSigningOut => _isSigningOut.value;

  // 3. Form validation controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> registerFormKey = GlobalKey<FormState>();

  // Password visibility for UI
  final RxBool _obscurePassword = true.obs;
  final RxBool _obscureConfirmPassword = true.obs;
  bool get obscurePassword => _obscurePassword.value;
  bool get obscureConfirmPassword => _obscureConfirmPassword.value;

  // Password strength validation
  final RxInt passwordStrength = 0.obs;

  // Additional loading states for UI compatibility
  final RxBool _isResettingPassword = false.obs;
  bool get isResettingPassword => _isResettingPassword.value;

  // Terms acceptance for registration
  final RxBool _acceptTerms = false.obs;
  bool get acceptTerms => _acceptTerms.value;
  set acceptTerms(bool value) => _acceptTerms.value = value;

  // Remember me functionality
  final RxBool _rememberMe = false.obs;
  bool get rememberMe => _rememberMe.value;
  set rememberMe(bool value) => _rememberMe.value = value;

  // 4. Error handling
  final RxString _errorMessage = ''.obs;
  String get errorMessage => _errorMessage.value;
  String get error => _errorMessage.value; // UI compatibility
  bool get hasError => _errorMessage.value.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    _initializeAuth();
    _loadSavedCredentials();
  }

  void _initializeAuth() {
    // Listen to auth state changes
    _authService.authStateChanges.listen((User? user) {
      _user.value = user;
      if (user != null) {
        // Only set logged in if user is not in the process of signing out
        if (!_isSigningOut.value) {
          // Save user data to local database
          _saveUserToDatabase(user);
          // 5. Remember login state with GetStorage
          _storage.write('isLoggedIn', true);
          _storage.write('userId', user.uid);
          // Clear any previous logout flag
          _storage.write('hasLoggedOut', false);
        }
      } else {
        _storage.write('isLoggedIn', false);
        _storage.remove('userId');
      }
    });

    // Check if user was previously logged in
    final wasLoggedIn = _storage.read('isLoggedIn') ?? false;
    if (wasLoggedIn && _authService.currentFirebaseUser != null) {
      _user.value = _authService.currentFirebaseUser;
      // Also save to database if user was already logged in
      if (_user.value != null) {
        _saveUserToDatabase(_user.value!);

        // Trigger sync for existing authenticated user with delay
        print('🔄 User already authenticated, scheduling data sync...');
        _enableCloudBackup();

        // Schedule sync after all services are initialized
        Future.delayed(const Duration(seconds: 2), () {
          _syncUnsyncedDataToCloud();
        });
      }
    }
  }

  // Save user data to local SQLite database
  Future<void> _saveUserToDatabase(User firebaseUser) async {
    try {
      final dbHelper = DatabaseHelper();
      final userData = {
        'id': firebaseUser.uid,
        'email': firebaseUser.email ?? '',
        'name': firebaseUser.displayName ?? 'User',
        'profile_picture': firebaseUser.photoURL,
      };

      await dbHelper.insertOrUpdateUser(userData);
      print('✅ User saved to local database: ${firebaseUser.email}');

      // Migrate any existing anonymous data to this user
      await _migrateAnonymousDataToUser(firebaseUser.uid);
    } catch (e) {
      print('❌ Error saving user to database: $e');
    }
  }

  // Migrate existing anonymous data to the authenticated user
  Future<void> _migrateAnonymousDataToUser(String userId) async {
    try {
      final dbHelper = DatabaseHelper();
      final db = await dbHelper.database;

      // Check if there are any courses without user_id (anonymous data)
      final anonymousCourses = await db.query(
        'courses',
        where: 'user_id IS NULL OR user_id = ""',
      );

      if (anonymousCourses.isNotEmpty) {
        print(
          '🔄 Migrating ${anonymousCourses.length} anonymous courses to user: $userId',
        );

        // Update courses to associate with the authenticated user
        await db.update('courses', {
          'user_id': userId,
          'updated_at': DateTime.now().toIso8601String(),
        }, where: 'user_id IS NULL OR user_id = ""');

        // Also migrate any associated assignments and assessments
        for (final course in anonymousCourses) {
          // Note: assignments and assessments are linked by course_id,
          // so they automatically become associated with the user through the course
          print('  ✅ Migrated course: ${course['name']} (${course['id']})');
        }

        print('✅ Anonymous data migration completed');
      } else {
        print('ℹ️ No anonymous data to migrate');
      }
    } catch (e) {
      print('❌ Error migrating anonymous data: $e');
      // Don't throw - this is not critical, user can still use the app
    }
  }

  // 2. Login method with loading state
  Future<void> login() async {
    _isSigningIn.value = true;
    _clearError();

    try {
      final userModel = await _authService.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
        requireEmailVerification: false,
      );

      if (userModel != null) {
        print('✅ Login successful: ${userModel.email}');

        // Show success message and navigate immediately
        _showSuccessMessage('Welcome back!');
        _navigateAfterAuth();

        // Run background tasks without blocking navigation
        _performBackgroundLoginTasks();
      } else {
        print('❌ Login returned null user');
        _handleError('Login failed - please try again');
      }
    } catch (e) {
      // 4. Error handling with user-friendly messages
      _handleError(e);
    } finally {
      _isSigningIn.value = false;
    }
  }

  // 2. Register method with loading state
  Future<void> register() async {
    if (!registerFormKey.currentState!.validate()) return;

    _isRegistering.value = true;
    _clearError();

    try {
      print('🔄 Starting registration...');
      final userModel = await _authService.registerWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
        name: nameController.text.trim(),
        sendEmailVerification: true,
      );

      if (userModel != null) {
        print('✅ Registration successful: ${userModel.email}');

        // Show success message and navigate immediately
        _showSuccessMessage('Account created successfully!');
        _navigateAfterAuth();

        // Run background tasks without blocking navigation
        _performBackgroundLoginTasks();
      } else {
        print('❌ Registration returned null user');
        _handleError('Registration failed - please try again');
      }
    } catch (e) {
      print('❌ Registration error: $e');
      // 4. Error handling with user-friendly messages
      _handleError(e);
    } finally {
      _isRegistering.value = false;
    }
  }

  // 6. Google Sign-In integration
  Future<void> signInWithGoogle() async {
    _isLoading.value = true;
    _clearError();

    try {
      print('🔄 Starting Google Sign-In...');
      final userModel = await _authService.signInWithGoogle();

      if (userModel != null) {
        print('✅ Google Sign-In successful: ${userModel.email}');

        // Show success message and navigate immediately
        _showSuccessMessage('Signed in with Google successfully!');

        // Navigate immediately for better UX
        _navigateAfterAuth();

        // Do background operations after navigation
        _performBackgroundLoginTasks();
      } else {
        print('❌ Google Sign-In returned null user');
        _handleError('Google Sign-In was cancelled or failed');
      }
    } catch (e) {
      print('❌ Google Sign-In error: $e');
      // 4. Error handling with user-friendly messages
      _handleError(e);
    } finally {
      _isLoading.value = false;
    }
  }

  // 2. SignOut method with loading state
  Future<void> signOut() async {
    _isSigningOut.value = true;
    _clearError();

    try {
      // Clear user state first
      _user.value = null;

      // Set explicit logout flag to prevent auto-login on app restart
      _storage.write('hasLoggedOut', true);

      // Clear stored login state
      _storage.write('isLoggedIn', false);
      _storage.remove('userId');

      // Clear any guest state as well
      _storage.write('isGuest', false);

      // Clear saved credentials if not remembering
      if (!_rememberMe.value) {
        await _clearSavedCredentials();
      }

      // Sign out from Firebase Auth (this will trigger the auth state listener)
      await _authService.signOut();

      // Clear assessment data when user logs out
      if (Get.isRegistered<AssessmentController>()) {
        final assessmentController = Get.find<AssessmentController>();
        assessmentController.assessments.clear();
      }

      // Clear form data
      _clearForms();

      // Force navigation to login and clear all previous routes
      Get.offAllNamed(AppRoutes.login);

      _showSuccessMessage('Signed out successfully');
    } catch (e) {
      // 4. Error handling with user-friendly messages
      _handleError(e);
    } finally {
      _isSigningOut.value = false;
    }
  }

  // 3. Form validation for email
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  // 3. Form validation for password
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    // Check for required character types
    bool hasUpperCase = value.contains(RegExp(r'[A-Z]'));
    bool hasLowerCase = value.contains(RegExp(r'[a-z]'));
    bool hasNumbers = value.contains(RegExp(r'[0-9]'));
    bool hasSpecialCharacters = value.contains(
      RegExp(r'[!@#$%^&*(),.?":{}|<>]'),
    );

    List<String> missing = [];
    if (!hasUpperCase) missing.add('uppercase letter');
    if (!hasLowerCase) missing.add('lowercase letter');
    if (!hasNumbers) missing.add('number');
    if (!hasSpecialCharacters) missing.add('special character');

    if (missing.isNotEmpty) {
      return 'Password must contain: ${missing.join(', ')}';
    }

    return null;
  }

  // 3. Form validation for name
  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  // Password strength checking methods
  void checkPasswordStrength(String password) {
    int strength = 0;

    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[a-z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;

    passwordStrength.value = strength;
  }

  String getStrengthLabel(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return 'Very Weak';
      case 2:
        return 'Weak';
      case 3:
        return 'Fair';
      case 4:
        return 'Good';
      case 5:
        return 'Strong';
      default:
        return 'Unknown';
    }
  }

  Color getStrengthColor(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.yellow;
      case 4:
        return Colors.lightGreen;
      case 5:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // UI Compatibility methods for existing pages

  // Password visibility toggles
  void togglePasswordVisibility() {
    _obscurePassword.value = !_obscurePassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    _obscureConfirmPassword.value = !_obscureConfirmPassword.value;
  }

  // Method aliases for UI compatibility
  Future<void> signInWithEmailAndPassword() async {
    // Validation is handled in UI layer, proceed with login
    await login();
  }

  Future<void> registerWithEmailAndPassword() async {
    await register();
  }

  // Confirm password validation
  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  // Password reset method
  Future<void> resetPassword() async {
    if (emailController.text.isEmpty) {
      _handleError('Please enter your email address');
      return;
    }

    _isResettingPassword.value = true;
    _clearError();

    try {
      await _authService.resetPassword(emailController.text.trim());
      _showSuccessMessage('Password reset email sent successfully');
    } catch (e) {
      _handleError(e);
    } finally {
      _isResettingPassword.value = false;
    }
  }

  // Change password method
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    if (_user.value == null) {
      throw Exception('User is not authenticated');
    }

    try {
      // Re-authenticate user with current password
      final credential = EmailAuthProvider.credential(
        email: _user.value!.email!,
        password: currentPassword,
      );

      await _user.value!.reauthenticateWithCredential(credential);

      // Update password
      await _user.value!.updatePassword(newPassword);

      // Sign out user after password change for security
      await signOut();
    } catch (e) {
      if (e.toString().contains('wrong-password')) {
        throw Exception('Current password is incorrect');
      } else if (e.toString().contains('weak-password')) {
        throw Exception('New password is too weak');
      } else if (e.toString().contains('requires-recent-login')) {
        throw Exception(
          'Please sign out and sign in again before changing password',
        );
      } else {
        throw Exception('Failed to change password: ${e.toString()}');
      }
    }
  }

  // Continue as guest - navigate to home page without authentication
  void continueAsGuest() {
    try {
      // Set guest mode in storage
      _storage.write('isGuest', true);
      _storage.write('isLoggedIn', false);
      // Clear any previous logout flag
      _storage.write('hasLoggedOut', false);
      // Mark that user has passed welcome page
      _storage.write('hasSeenWelcome', true);

      // Navigate to main screen (bottom navigation)
      Get.offAllNamed('/main');

      // Show success message
      Get.snackbar(
        'Guest Mode',
        'You can explore the app without an account',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      _handleError('Failed to continue as guest: ${e.toString()}');
    }
  }

  // Navigate to login from welcome page
  void goToLoginFromWelcome() {
    try {
      // Mark that user has passed welcome page
      _storage.write('isFirstLaunch', false);
      Get.toNamed(AppRoutes.login);
    } catch (e) {
      _handleError('Navigation failed: ${e.toString()}');
    }
  }

  // Navigate to register from welcome page
  void goToRegisterFromWelcome() {
    try {
      // Mark that user has passed welcome page
      _storage.write('isFirstLaunch', false);
      Get.toNamed(AppRoutes.register);
    } catch (e) {
      _handleError('Navigation failed: ${e.toString()}');
    }
  }

  // Debug method to reset first launch flag (for testing)
  void resetFirstLaunchFlag() {
    try {
      _storage.write('isFirstLaunch', true);
      Get.snackbar(
        'Debug',
        'First launch flag reset. Restart the app to see welcome page again.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      _handleError('Failed to reset first launch flag: ${e.toString()}');
    }
  }

  // 4. Error handling with user-friendly messages
  void _handleError(dynamic error) {
    String message;
    if (error is AuthException) {
      message = error.message;
    } else if (error is Exception) {
      message = error.toString();
    } else {
      message = error.toString();
    }

    // Handle common Firebase Auth error codes
    if (message.contains('user-not-found')) {
      message = 'No account found with this email address.';
    } else if (message.contains('wrong-password') ||
        message.contains('invalid-credential')) {
      message = 'Invalid email or password. Please check your credentials.';
    } else if (message.contains('user-disabled')) {
      message = 'This account has been disabled.';
    } else if (message.contains('too-many-requests')) {
      message = 'Too many failed attempts. Please try again later.';
    } else if (message.contains('network')) {
      message = 'Network error. Please check your internet connection.';
    } else if (message.contains('email-already-in-use')) {
      message = 'Email is already registered.';
    } else if (message.contains('weak-password')) {
      message = 'Password is too weak.';
    } else if (message.contains('invalid-email')) {
      message = 'Invalid email address.';
    }

    _errorMessage.value = message;
    Get.snackbar(
      'Login Failed',
      message,
      backgroundColor: Colors.red.shade700,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 4),
    );
  }

  void _clearError() {
    _errorMessage.value = '';
  }

  void _showSuccessMessage(String message) {
    Get.snackbar(
      'Welcome!',
      message,
      backgroundColor: Colors.green.shade700,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }

  // 7. Navigation handling after authentication
  void _navigateAfterAuth() {
    try {
      // Clear any errors before navigation
      _clearError();
      print('🔄 Navigating to main screen...');

      // Navigate directly to main scaffold
      try {
        Get.offAllNamed(AppRoutes.main);
        print('✅ Navigation to main screen completed');
      } catch (e) {
        print('❌ Navigation error: $e');
        // Fallback: try direct navigation to splash and let it redirect
        try {
          Get.offAllNamed(AppRoutes.splash);
          print('✅ Fallback navigation to splash successful');
        } catch (fallbackError) {
          print('❌ Fallback navigation failed: $fallbackError');
          _handleError('Navigation failed. Please restart the app.');
        }
      }
    } catch (e) {
      print('❌ Navigation setup error: $e');
      _handleError('Navigation failed: ${e.toString()}');
    }
  }

  // 8. Cloud backup enablement after successful login
  Future<void> _enableCloudBackup() async {
    try {
      // Enable cloud backup features
      _storage.write('cloudBackupEnabled', true);
      debugPrint('Cloud backup enabled for user: ${user?.uid}');
    } catch (e) {
      debugPrint('Failed to enable cloud backup: $e');
    }
  }

  // Background operations after login for better UX
  Future<void> _performBackgroundLoginTasks() async {
    // Perform these operations in background without blocking UI
    Future.microtask(() async {
      try {
        print('🔄 Starting background login tasks...');

        // Clear any previous user's data FIRST before any sync operations
        if (Get.isRegistered<AssessmentController>()) {
          final assessmentController = Get.find<AssessmentController>();
          assessmentController.assessments.clear();
          print('🗑️ Cleared previous user assessment data from controller');
        }

        // Save credentials if remember me is checked
        if (_rememberMe.value) {
          await _saveCredentials();
        } else {
          await _clearSavedCredentials();
        }

        // Enable cloud backup
        await _enableCloudBackup();

        // Sync ONLY current user's unsynced data to cloud
        await _syncUnsyncedDataToCloud();

        print('✅ Background login tasks completed');
      } catch (e) {
        print('❌ Background login tasks failed: $e');
        // Don't show error to user as these are background operations
      }
    });
  }

  // Remember me functionality methods
  Future<void> _saveCredentials() async {
    try {
      final email = emailController.text.trim();
      final password = passwordController.text;

      // Hash the password for security
      final bytes = utf8.encode(password + email); // Adding email as salt
      final digest = sha256.convert(bytes);
      final passwordHash = digest.toString();

      _storage.write('saved_email', email);
      _storage.write('saved_password_hash', passwordHash);
      _storage.write('remember_me', true);
      print('✅ Credentials saved for remember me (password hashed)');
    } catch (e) {
      print('❌ Failed to save credentials: $e');
    }
  }

  Future<void> _loadSavedCredentials() async {
    try {
      final savedEmail = _storage.read('saved_email') ?? '';
      final savedPasswordHash = _storage.read('saved_password_hash') ?? '';
      final shouldRemember = _storage.read('remember_me') ?? false;

      if (shouldRemember &&
          savedEmail.isNotEmpty &&
          savedPasswordHash.isNotEmpty) {
        emailController.text = savedEmail;
        // Note: We don't restore the actual password for security
        // The user will need to re-enter it, but the email will be pre-filled
        _rememberMe.value = true;
        print(
          '✅ Email loaded from remember me (password requires re-entry for security)',
        );
      }
    } catch (e) {
      print('❌ Failed to load saved credentials: $e');
    }
  }

  // Check if user should be auto-logged in
  bool shouldAutoLogin() {
    final savedEmail = _storage.read('saved_email') ?? '';
    final savedPasswordHash = _storage.read('saved_password_hash') ?? '';
    final shouldRemember = _storage.read('remember_me') ?? false;
    return shouldRemember &&
        savedEmail.isNotEmpty &&
        savedPasswordHash.isNotEmpty;
  }

  // Clear form fields for registration mode
  void clearFormFieldsForRegistration() {
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    nameController.clear();
    _rememberMe.value = false;
    passwordStrength.value = 0;
    print('✅ Form fields cleared for registration mode');
  }

  Future<void> _clearSavedCredentials() async {
    try {
      _storage.remove('saved_email');
      _storage.remove('saved_password_hash');
      _storage.remove('remember_me');
      print('✅ Saved credentials cleared');
    } catch (e) {
      print('❌ Failed to clear saved credentials: $e');
    }
  }

  /// Sync unsynced data to cloud after authentication
  Future<void> _syncUnsyncedDataToCloud() async {
    try {
      print('🔄 Starting sync of unsynced data to cloud...');

      // Get and sync unsynced courses
      if (Get.isRegistered<CourseService>()) {
        final courseService = Get.find<CourseService>();
        print('📚 CourseService found, triggering sync...');
        await courseService.syncToCloud();
        print('✅ Unsynced courses sync completed');
      } else {
        print('⚠️ CourseService not registered, skipping course sync');
      }

      // Get and sync unsynced assessments
      if (Get.isRegistered<AssessmentController>()) {
        final assessmentController = Get.find<AssessmentController>();
        print('📋 AssessmentController found, triggering sync...');
        await assessmentController.syncUnsyncedAssessments();
        print('✅ Unsynced assessments sync completed');
      } else {
        print(
          '⚠️ AssessmentController not registered, skipping assessment sync',
        );
      }
    } catch (e) {
      print('⚠️ Failed to sync unsynced data to cloud: $e');
      // Don't throw error as this is a background operation
    }
  }

  void _clearForms() {
    // Only clear forms if not remembering credentials
    if (!_rememberMe.value) {
      emailController.clear();
      passwordController.clear();
    }
    nameController.clear();
    confirmPasswordController.clear();
  }

  @override
  void onClose() {
    // Safely dispose controllers
    try {
      emailController.dispose();
    } catch (e) {
      // Controller already disposed
    }
    try {
      passwordController.dispose();
    } catch (e) {
      // Controller already disposed
    }
    try {
      nameController.dispose();
    } catch (e) {
      // Controller already disposed
    }
    try {
      confirmPasswordController.dispose();
    } catch (e) {
      // Controller already disposed
    }
    super.onClose();
  }
}
