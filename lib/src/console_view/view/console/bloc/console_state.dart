import 'package:log_custom_printer/src/console_view/domain/models/message_log.dart';

class ConsoleError extends ConsoleState {
  final String message;
  const ConsoleError({required this.message, required super.selectedLogType});
}

class ConsoleInitial extends ConsoleState {
  const ConsoleInitial({required super.selectedLogType});
}

class ConsoleLoaded extends ConsoleState {
  final List<MessageLog> logs;
  const ConsoleLoaded({required this.logs, required super.selectedLogType});
}

class ConsoleLoading extends ConsoleState {
  const ConsoleLoading({required super.selectedLogType});
}

sealed class ConsoleState {
  final LogType selectedLogType;

  const ConsoleState({required this.selectedLogType});
}
