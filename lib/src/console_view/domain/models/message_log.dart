import 'package:log_custom_printer/src/domain/log_helpers/enum_logger_type.dart';

enum LogType {
  info,
  warning,
  error,
  debug,
  all;

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
      case LogType.all:
        return EnumLoggerType.debug; // TODO: Implementar all
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
