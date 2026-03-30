import 'package:log_custom_printer/src/console_view/domain/models/message_log.dart';

/// Estado base selado para o [ConsoleBloc].
///
/// Todos os estados carregam [selectedLogType] como fonte única de verdade
/// para o filtro de tipo ativo.
sealed class ConsoleState {
  /// Tipo de log atualmente selecionado para filtragem.
  final LogType selectedLogType;

  const ConsoleState({required this.selectedLogType});
}

/// Estado inicial do console, antes de qualquer carregamento.
class ConsoleInitial extends ConsoleState {
  const ConsoleInitial({required super.selectedLogType});
}

/// Estado de carregamento: logs estão sendo buscados/filtrados.
class ConsoleLoading extends ConsoleState {
  const ConsoleLoading({required super.selectedLogType});
}

/// Estado de sucesso: [logs] contém as mensagens filtradas.
class ConsoleLoaded extends ConsoleState {
  /// Lista de mensagens de log já filtradas e ordenadas.
  final List<MessageLog> logs;
  const ConsoleLoaded({required this.logs, required super.selectedLogType});
}

/// Estado de erro ao tentar carregar ou filtrar os logs.
class ConsoleError extends ConsoleState {
  /// Descrição do erro ocorrido.
  final String message;
  const ConsoleError({required this.message, required super.selectedLogType});
}
