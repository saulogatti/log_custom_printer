import 'package:log_custom_printer/src/console_view/domain/models/message_log.dart';

class ConsoleClear extends ConsoleEvent {
  const ConsoleClear();
}

sealed class ConsoleEvent {
  const ConsoleEvent();
}

class ConsoleLoad extends ConsoleEvent {
  const ConsoleLoad();
}
class ConsoleFilterByType extends ConsoleEvent {
  final LogType type;

  const ConsoleFilterByType(this.type);
}
