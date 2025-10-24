// packages/media_repository/lib/src/exceptions/media_exception.dart

/// Custom exception for media repository errors
class MediaException implements Exception {
  MediaException(this.message);
  final String message;

  @override
  String toString() => 'MediaException: $message';
}