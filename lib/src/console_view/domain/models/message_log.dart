enum LogType { info, warning, error, debug }

class MessageLog {
  MessageLog({
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
  });
  final String title;
  final String message;
  final DateTime timestamp;
  final LogType type;
}
