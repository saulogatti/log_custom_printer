/// Custom exception for log-domain failures.
///
/// {@category Utilities}
class LogException implements Exception {
  /// Failure description.
  final String message;

  /// Creates a new exception with [message].
  LogException(this.message);

  @override
  /// Human-readable exception string.
  String toString() => 'LogException: $message';
}
