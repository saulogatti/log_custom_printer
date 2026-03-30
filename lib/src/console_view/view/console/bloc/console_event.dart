import 'package:flutter/material.dart' show DateTimeRange;
import 'package:log_custom_printer/src/console_view/domain/models/message_log.dart';
import 'package:log_custom_printer/src/domain/i_logger_cache_repository.dart';

class ConsoleClear extends ConsoleEvent {
  const ConsoleClear();
}

sealed class ConsoleEvent {
  const ConsoleEvent();
}

class ConsoleExportLogs extends ConsoleEvent {
  final LogType logType;
  final ExportFormat format;

  const ConsoleExportLogs({required this.logType, required this.format});
}

class ConsoleFilterByType extends ConsoleEvent {
  final LogType type;

  const ConsoleFilterByType(this.type);
}

class ConsoleLoad extends ConsoleEvent {
  const ConsoleLoad();
}

class ConsoleUpdateDateTimeFilter extends ConsoleEvent {
  final DateTimeRange? dateTimeRange;
  final bool isDateTimeFilterEnabled;

  const ConsoleUpdateDateTimeFilter({
    required this.dateTimeRange,
    required this.isDateTimeFilterEnabled,
  });
}
