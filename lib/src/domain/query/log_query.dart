import '../log_helpers/enum_logger_type.dart';

/// Formato de exportação de logs.
///
/// {@category Query}
enum ExportFormat {
  /// Exporta como JSON (array de objetos).
  json,

  /// Exporta como texto legível (uma linha por log).
  txt,
}

/// Parâmetros de consulta para filtro, ordenação e exportação de logs.
///
/// Todos os campos são opcionais. Quando omitidos, nenhum filtro ou ordenação
/// é aplicado ao conjunto de resultados.
///
/// Exemplo:
/// ```dart
/// final query = LogQuery(
///   types: {EnumLoggerType.error, EnumLoggerType.warning},
///   start: DateTime(2024, 1, 1),
///   end: DateTime(2024, 2, 1),
///   sortField: LogSortField.date,
///   sortDirection: SortDirection.desc,
/// );
/// ```
///
/// {@category Query}
class LogQuery {

  /// Cria um objeto de consulta com filtros e ordenação opcionais.
  const LogQuery({
    this.types,
    this.start,
    this.end,
    this.sortField,
    this.sortDirection = SortDirection.asc,
  });
  /// Conjunto de tipos de log para filtrar. `null` ou vazio retorna todos os tipos.
  final Set<EnumLoggerType>? types;

  /// Limite inferior do intervalo de data (inclusivo). `null` = sem limite inferior.
  final DateTime? start;

  /// Limite superior do intervalo de data (exclusivo). `null` = sem limite superior.
  final DateTime? end;

  /// Campo pelo qual os resultados serão ordenados. `null` = sem ordenação.
  final LogSortField? sortField;

  /// Direção de ordenação. Ignorado quando [sortField] é `null`.
  ///
  /// Padrão: [SortDirection.asc].
  final SortDirection sortDirection;
}

/// Campo de ordenação de logs.
///
/// {@category Query}
enum LogSortField {
  /// Ordena pela data de criação do log.
  date,

  /// Ordena pela severidade do tipo do log.
  ///
  /// Ordem crescente de severidade: `debug < info < warning < error`.
  type,
}

/// Direção de ordenação.
///
/// {@category Query}
enum SortDirection {
  /// Ordenação crescente (menor → maior / mais antigo → mais recente).
  asc,

  /// Ordenação decrescente (maior → menor / mais recente → mais antigo).
  desc,
}
