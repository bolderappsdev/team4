/// Base exception class for data layer errors.
///
/// Exceptions are thrown in the data layer and converted to Failures
/// in the repository implementation.
class AppException implements Exception {
  final String message;

  AppException([this.message = 'An error occurred']);

  @override
  String toString() => message;
}

/// Server-side exception (API errors, Firebase errors, etc.).
class ServerException extends AppException {
  ServerException([String message = 'Server error']) : super(message);
}

/// Network connection exception.
class NetworkException extends AppException {
  NetworkException([String message = 'No internet connection'])
      : super(message);
}

/// Local cache exception.
class CacheException extends AppException {
  CacheException([String message = 'Cache error']) : super(message);
}

/// Authentication exception.
class AuthException extends AppException {
  AuthException([String message = 'Authentication failed']) : super(message);
}


/// Permission exception.
class PermissionException extends AppException {
  PermissionException([String message = 'Permission denied']) : super(message);
}

/// Resource not found exception.
class NotFoundException extends AppException {
  NotFoundException([String message = 'Resource not found']) : super(message);
}
