import 'package:flutter/material.dart' show DateTimeRange;
import 'package:log_custom_printer/src/console_view/domain/models/message_log.dart';

class ConsoleClear extends ConsoleEvent {
  const ConsoleClear();
}

sealed class ConsoleEvent {
  const ConsoleEvent();
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
