class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({this.message = 'Server Error', this.statusCode});
}

class CacheException implements Exception {
  final String message;
  const CacheException({this.message = 'Cache Error'});
}

class AuthException implements Exception {
  final String message;
  const AuthException({this.message = 'Authentication failed'});
}
