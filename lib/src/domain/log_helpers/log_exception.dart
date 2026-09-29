/// Custom exception for log-domain failures.
///
/// {@category Utilities}
class LogException(
  /// Failure description.
  final String message,
) implements Exception {
  @override
  /// Human-readable exception string.
  String toString() => 'LogException: $message';
}
