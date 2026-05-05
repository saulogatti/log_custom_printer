import 'package:log_custom_printer/src/data/cache/logger_cache_repository_impl.dart';
import 'package:log_custom_printer/src/domain/i_logger_cache_repository.dart';
import 'package:log_custom_printer/src/domain/log_helpers/enum_logger_type.dart';
import 'package:log_custom_printer/src/domain/logs_object/logger_object.dart';
import 'package:log_custom_printer/src/domain/query/log_filter_engine.dart';
import 'package:log_custom_printer/src/domain/query/log_query.dart';
import 'package:log_custom_printer/src/domain/query/log_sort_engine.dart';

/// Serviço de persistência e consulta de logs.
///
/// Encapsula operações de armazenamento, recuperação, limpeza e busca
/// sobre o repositório de logs configurado.
///
/// Quando [logOutputHandler] está definido, operações que alteram o estado
/// do cache notificam o consumidor com a lista de logs atualizada.
///
/// {@category Utilities}
final class LoggerPersistenceService {
  final ILoggerCacheRepository _cacheRepository;

  /// Callback opcional para observar mudanças na coleção persistida.
  ///
  /// Recebe a lista de logs atual após operações de escrita/limpeza.
  void Function(List<LoggerObjectBase>)? logOutputHandler;

  final LogFilterEngine _filterEngine;

  final LogSortEngine _sortEngine;

  /// Cria o serviço com um [cacheRepository] customizado.
  ///
  /// Quando omitido, usa [LoggerCacheRepositoryImpl] como implementação padrão.
  ///
  /// Os parâmetros [filterEngine] e [sortEngine] são opcionais e permitem
  /// injetar implementações customizadas (útil em testes). Quando omitidos,
  /// usam as implementações padrão constantes da biblioteca.
  LoggerPersistenceService({
    ILoggerCacheRepository? cacheRepository,
    LogFilterEngine filterEngine = const LogFilterEngine(),
    LogSortEngine sortEngine = const LogSortEngine(),
  }) : _cacheRepository = cacheRepository ?? LoggerCacheRepositoryImpl(),
       _filterEngine = filterEngine,
       _sortEngine = sortEngine;

  /// Adiciona uma entrada de log ao repositório.
  ///
  /// Se [logOutputHandler] estiver definido, busca os logs atualizados e
  /// dispara o callback ao final da operação.
  Future<void> addLog(LoggerObjectBase log) async {
    await _cacheRepository.addLog(log);
    if (logOutputHandler != null) {
      final logs = await _cacheRepository.getAllLogs();
      logOutputHandler?.call(logs);
    }
  }

  /// Remove todas as entradas de log do repositório.
  ///
  /// Notifica imediatamente [logOutputHandler] com lista vazia e, em seguida,
  /// executa a limpeza no repositório.
  Future<void> clearLogs() async {
    logOutputHandler?.call([]);
    await _cacheRepository.clearLogs();
  }

  /// Remove entradas de log de um tipo específico.
  ///
  /// Após a remoção, notifica [logOutputHandler] com o estado atualizado,
  /// quando o callback estiver definido.
  Future<void> clearLogsByType(EnumLoggerType type) async {
    await _cacheRepository.clearLogsByType(type);
    if (logOutputHandler != null) {
      final logs = await _cacheRepository.getAllLogs();
      logOutputHandler?.call(logs);
    }
  }

  /// Recupera todas as entradas de log armazenadas.
  Future<List<LoggerObjectBase>> getAllLogs() async {
    final logs = await _cacheRepository.getAllLogs();
    return logs;
  }

  /// Recupera entradas de log filtradas por tipo.
  Future<List<LoggerObjectBase>> getLogsByType(EnumLoggerType type) async {
    final logs = await _cacheRepository.getLogsByType(type);
    return logs;
  }

  /// Consulta os logs aplicando filtros, ordenação e retornando a lista resultante.
  ///
  /// A pipeline é: `getAllLogs → filter(query) → sort(query)`.
  ///
  /// Quando [query] não possui filtros nem ordenação definidos, equivale a
  /// chamar [getAllLogs] diretamente.
  Future<List<LoggerObjectBase>> queryLogs(LogQuery query) async {
    final allLogs = await getAllLogs();
    final filtered = _filterEngine.apply(allLogs, query);
    return _sortEngine.apply(filtered, query);
  }

  /// Busca logs criados dentro do intervalo de datas especificado.
  ///
  /// O filtro é aplicado ao campo `logCreationDate` para encontrar entradas
  /// criadas entre [start] (inclusivo) e [end] (exclusivo).
  Future<List<LoggerObjectBase>> searchLogByCreated({
    required DateTime start,
    required DateTime end,
  }) async {
    final allLogs = await _cacheRepository.getAllLogs();
    return allLogs
        .where(
          (log) =>
              !log.logCreationDate.isBefore(start) &&
              log.logCreationDate.isBefore(end),
        )
        .toList();
  }

  /// Busca logs com o runtimeType especificado.
  ///
  /// O filtro é aplicado ao campo `className` para retornar apenas entradas
  /// que correspondam exatamente ao [runtimeType] informado.
  Future<List<LoggerObjectBase>> searchLogByRuntimeType(
    String runtimeType,
  ) async {
    final allLogs = await _cacheRepository.getAllLogs();
    return allLogs.where((log) => log.className == runtimeType).toList();
  }

  /// Busca logs que contenham a tag especificada.
  Future<List<LoggerObjectBase>> searchLogByTag(String tag) async {
    final allLogs = await _cacheRepository.getAllLogs();
    final tagRegex = RegExp(r'\b' + RegExp.escape(tag) + r'\b');
    return allLogs.where((log) => tagRegex.hasMatch(log.tag)).toList();
  }
}
