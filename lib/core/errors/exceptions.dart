class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AuthException extends AppException {
  const AuthException([super.message = 'Authentication error']);
}

class ServerException extends AppException {
  const ServerException([super.message = 'Server error']);
}

class CacheException extends AppException {
  const CacheException([super.message = 'Cache error']);
}

class ValidationException extends AppException {
  const ValidationException([super.message = 'Validation error']);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = 'Unauthorized']);
}
