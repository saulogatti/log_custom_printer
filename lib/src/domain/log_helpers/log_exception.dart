/// Custom exception for log-domain failures.
///
/// {@category Utilities}
class LogException implements Exception {
  /// Creates a new exception with [message].
  LogException(this.message);

  /// Failure description.
  final String message;

  @override
  /// Human-readable exception string.
  String toString() => 'LogException: $message';
}
