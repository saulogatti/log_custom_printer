class ConsoleClear extends ConsoleEvent {
  const ConsoleClear();
}

sealed class ConsoleEvent {
  const ConsoleEvent();
}

class ConsoleLoad extends ConsoleEvent {
  const ConsoleLoad();
}
