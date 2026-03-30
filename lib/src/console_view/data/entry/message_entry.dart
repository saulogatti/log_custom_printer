import 'package:flutter/material.dart';
import 'package:log_custom_printer/src/console_view/domain/models/message_log.dart';
import 'package:log_custom_printer/src/domain/logs_object/debug_log.dart';
import 'package:log_custom_printer/src/domain/logs_object/error_log.dart';
import 'package:log_custom_printer/src/domain/logs_object/info_log.dart';
import 'package:log_custom_printer/src/domain/logs_object/logger_object.dart';
import 'package:log_custom_printer/src/domain/logs_object/warning_log.dart';
import 'package:log_custom_printer/src/utils/logger_ansi_color.dart';

class MessageEntry {

  MessageEntry({required this.loggerObjectBase});
  final LoggerObjectBase loggerObjectBase;

  MessageLog fromLoggerObjectBase() {
    final LogType level = getLogType(loggerObjectBase);

    return MessageLog(
      title: loggerObjectBase.getStartLog(false),
      message: loggerObjectBase.getMessage(false),
      timestamp: loggerObjectBase.logCreationDate,
      type: level,
    );
  }

  LogType getLogType(LoggerObjectBase loggerObjectBase) {
    switch (loggerObjectBase) {
      case InfoLog():
        return LogType.info;
      case WarningLog():
        return LogType.warning;
      case ErrorLog():
        return LogType.error;
      case DebugLog():
        return LogType.debug;
      default:
        return LogType.info;
    }
  }
}

extension EnumAnsiColorsExtension on EnumAnsiColors {
  Color get color {
    switch (this) {
      case EnumAnsiColors.black:
        return Colors.black;
      case EnumAnsiColors.red:
        return Colors.red;
      case EnumAnsiColors.green:
        return Colors.green;
      case EnumAnsiColors.yellow:
        return Colors.yellow;
      case EnumAnsiColors.blue:
        return Colors.blue;
      case EnumAnsiColors.magenta:
        return Colors.purple;
      case EnumAnsiColors.cyan:
        return Colors.cyan;
      case EnumAnsiColors.white:
        return Colors.white;
    }
  }
}
