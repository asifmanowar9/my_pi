import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:my_pi/features/auth/exceptions/auth_exceptions.dart';

void main() {
  group('AuthService Tests', () {
    setUp(() {
      // Initialize GetX for testing
      Get.testMode = true;
    });

    tearDown(() {
      Get.reset();
    });

    // Note: Singleton and Firebase-dependent tests are skipped because
    // they require Firebase initialization which is complex in unit tests.
    // These should be tested in integration tests instead.

    group('Exception Classes', () {
      test('AuthException should have correct message and code', () {
        const exception = AuthException('Test message', 'test-code');

        expect(exception.message, equals('Test message'));
        expect(exception.code, equals('test-code'));
        expect(exception.toString(), equals('AuthException: Test message'));
      });

      test('EmailNotVerifiedException should have correct properties', () {
        const exception = EmailNotVerifiedException();

        expect(
          exception.message,
          equals('Please verify your email address before signing in.'),
        );
        expect(exception.code, equals('email-not-verified'));
      });

      test('WeakPasswordException should have correct properties', () {
        const exception = WeakPasswordException();

        expect(
          exception.message,
          equals('Password is too weak. Please choose a stronger password.'),
        );
        expect(exception.code, equals('weak-password'));
      });

      test('UserNotFoundException should have correct properties', () {
        const exception = UserNotFoundException();

        expect(
          exception.message,
          equals('No account found with this email address.'),
        );
        expect(exception.code, equals('user-not-found'));
      });

      test('EmailAlreadyInUseException should have correct properties', () {
        const exception = EmailAlreadyInUseException();

        expect(
          exception.message,
          equals('An account already exists with this email address.'),
        );
        expect(exception.code, equals('email-already-in-use'));
      });

      test('InvalidEmailException should have correct properties', () {
        const exception = InvalidEmailException();

        expect(
          exception.message,
          equals('Please enter a valid email address.'),
        );
        expect(exception.code, equals('invalid-email'));
      });

      test('WrongPasswordException should have correct properties', () {
        const exception = WrongPasswordException();

        expect(
          exception.message,
          equals('Incorrect password. Please try again.'),
        );
        expect(exception.code, equals('wrong-password'));
      });

      test('NetworkException should have correct properties', () {
        const exception = NetworkException();

        expect(
          exception.message,
          equals('Network error. Please check your connection and try again.'),
        );
        expect(exception.code, equals('network-error'));
      });

      test('TooManyRequestsException should have correct properties', () {
        const exception = TooManyRequestsException();

        expect(
          exception.message,
          equals('Too many failed attempts. Please try again later.'),
        );
        expect(exception.code, equals('too-many-requests'));
      });

      test('UserDisabledException should have correct properties', () {
        const exception = UserDisabledException();

        expect(
          exception.message,
          equals('This account has been disabled. Please contact support.'),
        );
        expect(exception.code, equals('user-disabled'));
      });

      test('InvalidCredentialException should have correct properties', () {
        const exception = InvalidCredentialException();

        expect(exception.message, equals('Invalid email or password.'));
        expect(exception.code, equals('invalid-credential'));
      });

      test('RequiresRecentLoginException should have correct properties', () {
        const exception = RequiresRecentLoginException();

        expect(
          exception.message,
          equals('Please sign in again to complete this action.'),
        );
        expect(exception.code, equals('requires-recent-login'));
      });
    });

    // Integration tests with Firebase initialization should be created separately
    // for testing the actual AuthService functionality with Firebase
  });
}
