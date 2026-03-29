import 'package:log_custom_printer/src/console_view/domain/models/message_log.dart';

class ConsoleError extends ConsoleState {
  final String message;
  const ConsoleError({required this.message});
}

class ConsoleInitial extends ConsoleState {
  const ConsoleInitial();
}

class ConsoleLoaded extends ConsoleState {
  final List<MessageLog> logs;
  const ConsoleLoaded({required this.logs});
}

class ConsoleLoading extends ConsoleState {
  const ConsoleLoading();
}

sealed class ConsoleState {
  const ConsoleState();
}
