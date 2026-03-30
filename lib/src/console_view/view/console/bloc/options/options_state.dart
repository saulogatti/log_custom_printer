import 'package:log_custom_printer/src/console_view/domain/models/console_options.dart';

/// Estado base selado para o [OptionsBloc].
sealed class OptionsState {}

/// Estado inicial das opções, antes de qualquer carregamento.
class InitialOptionsState extends OptionsState {}

/// Estado de carregamento: opções estão sendo buscadas/persistidas.
class LoadingOptionsState extends OptionsState {}

/// Estado de sucesso: [options] contém as preferências atuais do console.
class LoadedOptionsState extends OptionsState {
  /// Opções de configuração carregadas.
  final ConsoleOptions options;

  LoadedOptionsState(this.options);
}

/// Estado de erro ao tentar carregar ou salvar as opções.
class ErrorOptionsState extends OptionsState {
  /// Descrição do erro ocorrido.
  final String message;

  ErrorOptionsState(this.message);
}
