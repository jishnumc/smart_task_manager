/// Base exception class for the application.
abstract class AppException implements Exception {
  const AppException(this.message, [this.code]);

  final String message;
  final String? code;

  @override
  String toString() => message;
}

/// Authentication specific exceptions.
class AuthException extends AppException {
  const AuthException(super.message, [super.code]);

  factory AuthException.fromFirebaseAuthCode(String code, [String? message]) {
    switch (code) {
      case 'user-not-found':
        return const AuthException('No account found with this email address.', 'user-not-found');
      case 'wrong-password':
        return const AuthException('Incorrect password. Please try again.', 'wrong-password');
      case 'invalid-credential':
        return const AuthException('Invalid email or password. Please check your credentials.', 'invalid-credential');
      case 'email-already-in-use':
        return const AuthException('An account already exists for this email address.', 'email-already-in-use');
      case 'invalid-email':
        return const AuthException('Please enter a valid email address.', 'invalid-email');
      case 'weak-password':
        return const AuthException('Password is too weak. Please use at least 6 characters.', 'weak-password');
      case 'user-disabled':
        return const AuthException('This user account has been disabled.', 'user-disabled');
      case 'too-many-requests':
        return const AuthException('Too many failed attempts. Please try again later.', 'too-many-requests');
      case 'network-request-failed':
        return const AuthException('Network error. Please check your internet connection.', 'network-request-failed');
      default:
        return AuthException(message ?? 'Authentication failed. Please try again.', code);
    }
  }
}

/// Server / Database exceptions (Firestore / REST API).
class ServerException extends AppException {
  const ServerException(super.message, [super.code]);
}

/// Network connectivity exceptions.
class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection', super.code = 'NO_INTERNET']);
}

/// Cache & local database exceptions.
class CacheException extends AppException {
  const CacheException(super.message, [super.code]);
}
