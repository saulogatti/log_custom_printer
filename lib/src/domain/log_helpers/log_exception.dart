class LogException implements Exception {
  final String message;
  LogException(this.message);

  @override
  String toString() => 'LogException: $message';
}
