import 'package:log_custom_printer/src/console_view/domain/models/message_log.dart';

class ConsoleError extends ConsoleState {
  const ConsoleError({required this.message});
  final String message;
}

class ConsoleInitial extends ConsoleState {
  const ConsoleInitial();
}

class ConsoleLoaded extends ConsoleState {
  const ConsoleLoaded({required this.logs});
  final List<MessageLog> logs;
}

class ConsoleLoading extends ConsoleState {
  const ConsoleLoading();
}

sealed class ConsoleState {
  const ConsoleState();
}
