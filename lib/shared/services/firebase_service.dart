import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../../core/base_service.dart';
import 'storage_service.dart';

class FirebaseService extends BaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Reactive variables
  final Rx<User?> firebaseUser = Rx<User?>(null);
  final RxBool isLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    firebaseUser.value = _auth.currentUser;
    isLoggedIn.value = _auth.currentUser != null;
    debugPrint('FirebaseService initialized');
  }

  // Setup auth listener (called after GetMaterialApp is ready)
  void setupAuthListener() {
    try {
      _auth.authStateChanges().listen((User? user) {
        firebaseUser.value = user;
        isLoggedIn.value = user != null;

        // Check local storage for logout state to avoid auto-login after logout
        final storage = Get.find<StorageService>();
        final localLoggedIn = storage.read('isLoggedIn') ?? false;

        if (user == null) {
          debugPrint('User signed out');
          // Ensure local state is also cleared
          storage.write('isLoggedIn', false);
          storage.remove('userId');

          // Don't auto-navigate on auth state changes
          // Let the splash screen and manual logout handle navigation
        } else {
          debugPrint('User signed in: ${user.email}');

          // Only proceed with auto-login if local storage also says user is logged in
          // This prevents auto-login after an explicit logout
          if (localLoggedIn) {
            // Don't auto-navigate on auth state changes
            // Let the splash screen handle initial navigation
          } else {
            // User is authenticated in Firebase but not locally logged in
            // This means they logged out explicitly, so sign them out from Firebase too
            debugPrint(
              'Firebase user exists but local logout detected, signing out...',
            );
            _auth.signOut();
          }
        }
      });
    } catch (e) {
      debugPrint('Error setting up auth listener: $e');
    }
  }

  // Authentication Methods
  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<User?> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document in Firestore
      if (result.user != null) {
        await createUserDocument(result.user!);
      }

      return result.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential result = await _auth.signInWithCredential(
        credential,
      );

      // Create user document if first time
      if (result.additionalUserInfo?.isNewUser == true && result.user != null) {
        await createUserDocument(result.user!);
      }

      return result.user;
    } catch (e) {
      throw 'Google Sign-In failed: $e';
    }
  }

  Future<void> signOut() async {
    try {
      await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
    } catch (e) {
      throw 'Sign out failed: $e';
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Firestore Methods
  Future<void> createUserDocument(User user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName ?? '',
        'photoURL': user.photoURL ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'lastSignIn': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error creating user document: $e');
    }
  }

  Future<DocumentSnapshot> getUserDocument(String uid) async {
    return await _firestore.collection('users').doc(uid).get();
  }

  Future<void> updateUserDocument(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).update(data);
  }

  // Generic Firestore Methods
  Future<void> addDocument(String collection, Map<String, dynamic> data) async {
    await _firestore.collection(collection).add(data);
  }

  Future<void> updateDocument(
    String collection,
    String docId,
    Map<String, dynamic> data,
  ) async {
    await _firestore.collection(collection).doc(docId).update(data);
  }

  Future<void> deleteDocument(String collection, String docId) async {
    await _firestore.collection(collection).doc(docId).delete();
  }

  Future<QuerySnapshot> getCollection(String collection) async {
    return await _firestore.collection(collection).get();
  }

  Stream<QuerySnapshot> streamCollection(String collection) {
    return _firestore.collection(collection).snapshots();
  }

  // Error handling
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      default:
        return 'An authentication error occurred: ${e.message}';
    }
  }
}
