import 'package:flutter/material.dart' show DateTimeRange;
import 'package:log_custom_printer/src/console_view/domain/models/message_log.dart';
import 'package:log_custom_printer/src/domain/i_logger_cache_repository.dart';

/// Evento base selado para o [ConsoleBloc].
sealed class ConsoleEvent {
  const ConsoleEvent();
}

/// Solicita o carregamento (ou recarregamento) da lista de logs.
class ConsoleLoad extends ConsoleEvent {
  const ConsoleLoad();
}

/// Solicita a limpeza de todos os logs armazenados no cache.
class ConsoleClear extends ConsoleEvent {
  const ConsoleClear();
}

/// Filtra os logs pelo [type] especificado.
///
/// Se [type] já estiver selecionado, o evento é ignorado.
class ConsoleFilterByType extends ConsoleEvent {
  /// Tipo de log a ser usado como filtro.
  final LogType type;

  const ConsoleFilterByType(this.type);
}

/// Atualiza o filtro temporal com o intervalo e estado de ativação fornecidos.
///
/// O recarregamento é disparado apenas quando há mudança real em relação
/// ao estado anterior.
class ConsoleUpdateDateTimeFilter extends ConsoleEvent {
  /// Intervalo de data/hora para o filtro (nulo remove o intervalo).
  final DateTimeRange? dateTimeRange;

  /// Indica se o filtro temporal está ativo.
  final bool isDateTimeFilterEnabled;

  const ConsoleUpdateDateTimeFilter({
    required this.dateTimeRange,
    required this.isDateTimeFilterEnabled,
  });
}

/// Solicita a exportação dos logs no [format] especificado.
///
/// Quando [logType] é [LogType.all], exporta todos os tipos de log.
class ConsoleExportLogs extends ConsoleEvent {
  /// Tipo de log a exportar (use [LogType.all] para todos).
  final LogType logType;

  /// Formato do arquivo de exportação.
  final ExportFormat format;

  const ConsoleExportLogs({required this.logType, required this.format});
}
