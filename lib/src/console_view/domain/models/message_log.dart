enum LogType { info, warning, error, debug }

class MessageLog {
  final String title;
  final String message;
  final DateTime timestamp;
  final LogType type;
  MessageLog({
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
  });
}
