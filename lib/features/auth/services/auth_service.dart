import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../../../core/base_service.dart';
import '../../../shared/services/firebase_service.dart';
import '../models/user_model.dart';
import '../exceptions/auth_exceptions.dart';

class AuthService extends BaseService {
  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService._internal();

  AuthService._internal();

  factory AuthService() => instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  // Get current user
  User? get currentFirebaseUser => _auth.currentUser;

  // Check if user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;

  // Check if current user's email is verified
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  @override
  void onInit() {
    super.onInit();
    debugPrint('AuthService initialized');
  }

  // Email/Password Authentication
  Future<UserModel?> signInWithEmailAndPassword({
    required String email,
    required String password,
    bool requireEmailVerification = true,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user != null) {
        // Check email verification if required
        if (requireEmailVerification && !credential.user!.emailVerified) {
          throw const EmailNotVerifiedException();
        }

        final userModel = UserModel.fromFirebaseUser(credential.user!);
        await _updateUserInFirestore(userModel);
        return userModel;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw const AuthException(
        'An unexpected error occurred during sign in',
        'unknown',
      );
    }
  }

  Future<UserModel?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    bool sendEmailVerification = true,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user != null) {
        // Update display name
        await credential.user!.updateDisplayName(name);

        // Send email verification if requested
        if (sendEmailVerification && !credential.user!.emailVerified) {
          await credential.user!.sendEmailVerification();
        }

        final userModel = UserModel.fromFirebaseUser(
          credential.user!,
        ).copyWith(name: name);

        await _createUserInFirestore(userModel);
        return userModel;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw const AuthException(
        'An unexpected error occurred during registration',
        'unknown',
      );
    }
  }

  // Google Sign-In
  Future<UserModel?> signInWithGoogle() async {
    try {
      debugPrint('🔄 Starting Google Sign-In process...');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        debugPrint('ℹ️ Google Sign-In cancelled by user');
        return null; // User canceled the sign-in
      }

      debugPrint('✅ Google account selected: ${googleUser.email}');
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        debugPrint('❌ Failed to get Google authentication tokens');
        throw const AuthException(
          'Failed to get authentication tokens from Google',
          'google-auth-tokens-failed',
        );
      }

      debugPrint('✅ Google authentication tokens obtained');
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      debugPrint('🔄 Signing in with Firebase...');
      final authResult = await _auth.signInWithCredential(credential);

      if (authResult.user != null) {
        debugPrint(
          '✅ Firebase authentication successful: ${authResult.user!.email}',
        );
        final userModel = UserModel.fromFirebaseUser(authResult.user!);

        // Create or update user in Firestore
        if (authResult.additionalUserInfo?.isNewUser == true) {
          debugPrint('🆕 New user detected, creating Firestore document');
          await _createUserInFirestore(userModel);
        } else {
          debugPrint('👤 Existing user detected, updating Firestore document');
          await _updateUserInFirestore(userModel);
        }

        debugPrint('✅ Google Sign-In completed successfully');
        return userModel;
      }

      debugPrint('❌ Firebase authentication failed - no user returned');
      throw const AuthException(
        'Firebase authentication failed',
        'firebase-auth-failed',
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Firebase Auth Exception: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('❌ Google sign-in error: $e');
      throw const AuthException(
        'Google sign-in failed. Please try again.',
        'google-signin-failed',
      );
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
    } catch (e) {
      debugPrint('Sign out error: $e');
      throw const AuthException('Failed to sign out', 'signout-failed');
    }
  }

  // Password reset
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw const AuthException(
        'Failed to send password reset email',
        'password-reset-failed',
      );
    }
  }

  // Email verification
  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      } else if (user == null) {
        throw const AuthException('No user signed in', 'no-user');
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw const AuthException(
        'Failed to send email verification',
        'email-verification-failed',
      );
    }
  }

  // Check and reload user to get latest email verification status
  Future<bool> checkEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.reload();
        return user.emailVerified;
      }
      return false;
    } catch (e) {
      debugPrint('Error checking email verification: $e');
      return false;
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Delete user data from Firestore
        if (Get.isRegistered<FirebaseService>()) {
          await Get.find<FirebaseService>().deleteDocument('users', user.uid);
        }

        // Delete Firebase Auth account
        await user.delete();
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw const AuthException(
        'Failed to delete account',
        'delete-account-failed',
      );
    }
  }

  // Private helper methods
  Future<void> _createUserInFirestore(UserModel user) async {
    try {
      if (Get.isRegistered<FirebaseService>()) {
        final firestore = FirebaseFirestore.instance;
        // Use user.id as document ID to match Firestore security rules
        await firestore.collection('users').doc(user.id).set(user.toJson());
        debugPrint('✅ User created in Firestore: ${user.email}');
      }
    } catch (e) {
      debugPrint('Error creating user in Firestore: $e');
      // Don't rethrow - Firestore sync is optional, auth succeeded
    }
  }

  Future<void> _updateUserInFirestore(UserModel user) async {
    try {
      if (Get.isRegistered<FirebaseService>()) {
        final firebaseService = Get.find<FirebaseService>();
        await firebaseService.updateDocument('users', user.id, {
          ...user.toJson(),
          'lastSignIn': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      debugPrint('Error updating user in Firestore: $e');
    }
  }

  AuthException _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return const UserNotFoundException();
      case 'wrong-password':
        return const WrongPasswordException();
      case 'email-already-in-use':
        return const EmailAlreadyInUseException();
      case 'weak-password':
        return const WeakPasswordException();
      case 'invalid-email':
        return const InvalidEmailException();
      case 'user-disabled':
        return const UserDisabledException();
      case 'too-many-requests':
        return const TooManyRequestsException();
      case 'invalid-credential':
        return const InvalidCredentialException();
      case 'network-request-failed':
        return const NetworkException();
      case 'requires-recent-login':
        return const RequiresRecentLoginException();
      default:
        debugPrint('Unknown auth error: ${e.code} - ${e.message}');
        return AuthException(
          e.message ?? 'An authentication error occurred.',
          e.code,
        );
    }
  }
}
