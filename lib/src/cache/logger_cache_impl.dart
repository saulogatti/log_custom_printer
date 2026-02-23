import 'package:log_custom_printer/src/cache/logger_cache.dart';
import 'package:log_custom_printer/src/cache/logger_cache_repository.dart';
import 'package:log_custom_printer/src/log_helpers/enum_logger_type.dart';
import 'package:log_custom_printer/src/log_helpers/logger_enum.dart';
import 'package:log_custom_printer/src/log_helpers/logger_json_list.dart';
import 'package:log_custom_printer/src/logs_object/logger_object.dart';

/// Implementação concreta de [LoggerCacheRepository] usando armazenamento em memória
/// e opcionalmente em arquivo.
///
/// Mantém os logs organizados por tipo em memória usando [LoggerJsonList].
/// Se um [saveLogFilePath] for fornecido, também persiste os logs em disco
/// através da classe [LoggerCache].
///
/// {@category Utilities}
final class LoggerCacheImpl implements LoggerCacheRepository {
  /// Número máximo de entradas de log por tipo.
  final int maxLogEntries;

  /// Caminho base para salvar os arquivos de log (opcional).
  final String? saveLogFilePath;

  /// Gerenciador de persistência em arquivo.
  LoggerCache? _loggerCache;

  /// Mapa que armazena as listas de logs em memória por tipo.
  final Map<EnumLoggerType, LoggerJsonList?> _loggerJsonList = {};

  /// Future que rastreia a inicialização do cache persistente.
  Future<void>? _futureInitialization;

  /// Cria uma nova instância da implementação de cache.
  ///
  /// [maxLogEntries]: limite de logs mantidos em memória por tipo (padrão: 1000).
  /// [saveLogFilePath]: diretório base para persistência (se omitido, não salva em disco).
  LoggerCacheImpl({this.maxLogEntries = 1000, this.saveLogFilePath}) {
    if (saveLogFilePath != null) {
      _loggerCache = LoggerCache(saveLogFilePath!);
      _futureInitialization = initialize();
    }
  }

  @override
  Future<void> addLog(LoggerObjectBase log) async {
    LoggerJsonList? loggerList = _loggerJsonList[log.enumLoggerType];
    if (loggerList == null) {
      loggerList = LoggerJsonList(
        type: log.runtimeType.toString(),
        maxLogEntries: maxLogEntries,
      );
      _loggerJsonList[log.enumLoggerType] = loggerList;
    }
    loggerList.addLogger(log);
    if (_loggerCache != null) {
      // Garante que a inicialização do cache foi concluída antes de tentar escrever
      await _futureInitialization;
      await _loggerCache!.writeLogToFile(log.enumLoggerType.name, loggerList);
    }
  }

  @override
  Future<void> clearLogs() async {
    _loggerJsonList.clear();
    await _futureInitialization;
    await _loggerCache?.clearAll();
  }

  @override
  Future<void> clearLogsByType(EnumLoggerType type) async {
    _loggerJsonList.remove(type);
    await _futureInitialization;
    await _loggerCache?.clearLogByType(type.name);
  }

  @override
  Future<List<LoggerObjectBase>> getAllLogs() async {
    final List<LoggerObjectBase> allLogs = [];
    for (final loggerList in _loggerJsonList.values) {
      if (loggerList != null) {
        allLogs.addAll(loggerList.loggerEntries);
      }
    }
    return allLogs;
  }

  @override
  Future<List<LoggerObjectBase>> getLogsByType(EnumLoggerType type) async {
    final loggerList = _loggerJsonList[type];
    if (loggerList != null) {
      return (loggerList.loggerEntries);
    }
    return [];
  }

  /// Inicializa o repositório carregando logs persistidos anteriormente do disco.
  Future<void> initialize() async {
    if (_loggerCache != null) {
      await _loggerCache!.futureInitialization;
      final allLogs = await _loggerCache!.readAllLogs();
      if (allLogs != null) {
        _loggerJsonList.clear();
        _loggerJsonList.addAll(allLogs);
      }
    }
  }
}
