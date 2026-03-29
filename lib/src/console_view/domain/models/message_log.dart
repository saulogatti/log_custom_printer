import 'package:log_custom_printer/log_custom_printer.dart';

enum LogType {
  info,
  warning,
  error,
  debug;

  EnumLoggerType toEnum() {
    switch (this) {
      case LogType.info:
        return EnumLoggerType.info;
      case LogType.warning:
        return EnumLoggerType.warning;
      case LogType.error:
        return EnumLoggerType.error;
      case LogType.debug:
        return EnumLoggerType.debug;
    }
  }
}

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
