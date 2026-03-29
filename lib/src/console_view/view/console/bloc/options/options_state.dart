import 'package:log_custom_printer/src/console_view/domain/models/console_options.dart';

class ErrorOptionsState extends OptionsState {
  final String message;

  ErrorOptionsState(this.message);
}

class InitialOptionsState extends OptionsState {}

class LoadedOptionsState extends OptionsState {
  final ConsoleOptions options;

  LoadedOptionsState(this.options);
}

class LoadingOptionsState extends OptionsState {}

sealed class OptionsState {}
