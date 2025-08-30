import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../../../core/routes.dart';

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
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> registerFormKey = GlobalKey<FormState>();

  // Password visibility for UI
  final RxBool _obscurePassword = true.obs;
  final RxBool _obscureConfirmPassword = true.obs;
  bool get obscurePassword => _obscurePassword.value;
  bool get obscureConfirmPassword => _obscureConfirmPassword.value;

  // Additional loading states for UI compatibility
  final RxBool _isResettingPassword = false.obs;
  bool get isResettingPassword => _isResettingPassword.value;

  // Terms acceptance for registration
  final RxBool _acceptTerms = false.obs;
  bool get acceptTerms => _acceptTerms.value;
  set acceptTerms(bool value) => _acceptTerms.value = value;

  // 4. Error handling
  final RxString _errorMessage = ''.obs;
  String get errorMessage => _errorMessage.value;
  String get error => _errorMessage.value; // UI compatibility
  bool get hasError => _errorMessage.value.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    _initializeAuth();
  }

  void _initializeAuth() {
    // Listen to auth state changes
    _authService.authStateChanges.listen((User? user) {
      _user.value = user;
      if (user != null) {
        // 5. Remember login state with GetStorage
        _storage.write('isLoggedIn', true);
        _storage.write('userId', user.uid);
      } else {
        _storage.write('isLoggedIn', false);
        _storage.remove('userId');
      }
    });

    // Check if user was previously logged in
    final wasLoggedIn = _storage.read('isLoggedIn') ?? false;
    if (wasLoggedIn && _authService.currentFirebaseUser != null) {
      _user.value = _authService.currentFirebaseUser;
    }
  }

  // 2. Login method with loading state
  Future<void> login() async {
    if (!loginFormKey.currentState!.validate()) return;

    _isSigningIn.value = true;
    _clearError();

    try {
      final userModel = await _authService.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
        requireEmailVerification: false,
      );

      if (userModel != null) {
        // 8. Cloud backup enablement after successful login
        await _enableCloudBackup();

        // 7. Navigation handling after authentication
        _navigateAfterAuth();

        _showSuccessMessage('Welcome back!');
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
      final userModel = await _authService.registerWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
        name: nameController.text.trim(),
        sendEmailVerification: true,
      );

      if (userModel != null) {
        // 8. Cloud backup enablement after successful login
        await _enableCloudBackup();

        // 7. Navigation handling after authentication
        _navigateAfterAuth();

        _showSuccessMessage('Account created successfully!');
      }
    } catch (e) {
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
      final userModel = await _authService.signInWithGoogle();

      if (userModel != null) {
        // 8. Cloud backup enablement after successful login
        await _enableCloudBackup();

        // 7. Navigation handling after authentication
        _navigateAfterAuth();

        _showSuccessMessage('Signed in with Google successfully!');
      }
    } catch (e) {
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
      await _authService.signOut();

      // Clear stored login state
      _storage.write('isLoggedIn', false);
      _storage.remove('userId');

      // Clear form data
      _clearForms();

      // 7. Navigation handling after authentication
      Get.offAllNamed(Routes.LOGIN);

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
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
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

  // Continue as guest - navigate to home page without authentication
  void continueAsGuest() {
    try {
      // Set guest mode in storage
      _storage.write('isGuest', true);
      _storage.write('isLoggedIn', false);
      // Mark that user has passed welcome page
      _storage.write('hasSeenWelcome', true);

      // Navigate to home page
      Get.offAllNamed(Routes.HOME);

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
      Get.toNamed(Routes.LOGIN);
    } catch (e) {
      _handleError('Navigation failed: ${e.toString()}');
    }
  }

  // Navigate to register from welcome page
  void goToRegisterFromWelcome() {
    try {
      // Mark that user has passed welcome page
      _storage.write('isFirstLaunch', false);
      Get.toNamed(Routes.REGISTER);
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
    String message = 'An unexpected error occurred';

    if (error.toString().contains('user-not-found')) {
      message = 'No account found with this email';
    } else if (error.toString().contains('wrong-password')) {
      message = 'Incorrect password';
    } else if (error.toString().contains('email-already-in-use')) {
      message = 'Email is already registered';
    } else if (error.toString().contains('weak-password')) {
      message = 'Password is too weak';
    } else if (error.toString().contains('invalid-email')) {
      message = 'Invalid email address';
    } else if (error.toString().contains('network-request-failed')) {
      message = 'Network error. Check your connection';
    }

    _errorMessage.value = message;
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _clearError() {
    _errorMessage.value = '';
  }

  void _showSuccessMessage(String message) {
    Get.snackbar(
      'Success',
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // 7. Navigation handling after authentication
  void _navigateAfterAuth() {
    Get.offAllNamed(Routes.HOME);
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

  void _clearForms() {
    emailController.clear();
    passwordController.clear();
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
