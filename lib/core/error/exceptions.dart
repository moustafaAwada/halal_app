/// Thrown when an unexpected error occurs in the data layer.
class ServerException implements Exception {
  const ServerException({this.message = 'Server error occurred'});

  final String message;
}

/// Thrown when local cache operations fail.
class CacheException implements Exception {
  const CacheException({this.message = 'Cache error occurred'});

  final String message;
}
