// Custom exception classes for authentication
class AuthException implements Exception {
  final String message;
  final String code;

  const AuthException(this.message, this.code);

  @override
  String toString() => 'AuthException: $message';
}

class EmailNotVerifiedException extends AuthException {
  const EmailNotVerifiedException()
    : super(
        'Please verify your email address before signing in.',
        'email-not-verified',
      );
}

class WeakPasswordException extends AuthException {
  const WeakPasswordException()
    : super(
        'Password is too weak. Please choose a stronger password.',
        'weak-password',
      );
}

class UserNotFoundException extends AuthException {
  const UserNotFoundException()
    : super('No account found with this email address.', 'user-not-found');
}

class EmailAlreadyInUseException extends AuthException {
  const EmailAlreadyInUseException()
    : super(
        'An account already exists with this email address.',
        'email-already-in-use',
      );
}

class InvalidEmailException extends AuthException {
  const InvalidEmailException()
    : super('Please enter a valid email address.', 'invalid-email');
}

class WrongPasswordException extends AuthException {
  const WrongPasswordException()
    : super('Incorrect password. Please try again.', 'wrong-password');
}

class NetworkException extends AuthException {
  const NetworkException()
    : super(
        'Network error. Please check your connection and try again.',
        'network-error',
      );
}

class TooManyRequestsException extends AuthException {
  const TooManyRequestsException()
    : super(
        'Too many failed attempts. Please try again later.',
        'too-many-requests',
      );
}

class UserDisabledException extends AuthException {
  const UserDisabledException()
    : super(
        'This account has been disabled. Please contact support.',
        'user-disabled',
      );
}

class InvalidCredentialException extends AuthException {
  const InvalidCredentialException()
    : super('Invalid email or password.', 'invalid-credential');
}

class RequiresRecentLoginException extends AuthException {
  const RequiresRecentLoginException()
    : super(
        'Please sign in again to complete this action.',
        'requires-recent-login',
      );
}
