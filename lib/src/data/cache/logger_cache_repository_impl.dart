import 'package:log_custom_printer/src/data/cache/logger_cache.dart';
import 'package:log_custom_printer/src/data/file_utils/file_manager_type.dart';
import 'package:log_custom_printer/src/domain/i_logger_cache_repository.dart';
import 'package:log_custom_printer/src/domain/log_helpers/enum_logger_type.dart';
import 'package:log_custom_printer/src/domain/log_helpers/logger_enum.dart';
import 'package:log_custom_printer/src/domain/logs_object/logger_json_list.dart';
import 'package:log_custom_printer/src/domain/logs_object/logger_object.dart';

/// Implementação concreta de [ILoggerCacheRepository] usando armazenamento em memória
/// e opcionalmente em arquivo.
///
/// Mantém os logs organizados por tipo em memória usando [LoggerJsonList].
/// Se um [directoryToSave] for fornecido, também persiste os logs em disco
/// através da classe [LoggerCache].
///
/// {@category Utilities}
final class LoggerCacheRepositoryImpl implements ILoggerCacheRepository {
  /// Número máximo de entradas de log por tipo.
  final int maxLogEntries;

  /// Caminho base para salvar os arquivos de log (opcional).
  final String? directoryToSave;

  /// Gerenciador de persistência em arquivo.
  LoggerCache? _loggerCache;

  /// Mapa que armazena as listas de logs em memória por tipo.
  final Map<EnumLoggerType, LoggerJsonList?> _loggerJsonList = {};

  /// Future que rastreia a inicialização do cache persistente.
  Future<void>? _futureInitialization;

  /// Cria uma nova instância da implementação de cache.
  ///
  /// [maxLogEntries]: limite de logs mantidos em memória por tipo (padrão: 1000).
  /// [directoryToSave]: diretório base para persistência (se omitido, não salva em disco).
  /// [fileType]: tipo de arquivo para persistência (padrão: [FileType.json]).
  LoggerCacheRepositoryImpl({
    this.maxLogEntries = 1000,
    this.directoryToSave,

  }) {
    if (directoryToSave != null) {
      _loggerCache = LoggerCache(
        directoryToSave!,
        fileManagerType: FileManager(),
      );
      _futureInitialization = _initialize();
    }
  }

  /// Adiciona [log] ao cache em memória e, quando configurado,
  /// persiste o estado atualizado em arquivo.
  ///
  /// Aguarda a inicialização do cache em disco antes de escrever,
  /// garantindo que o diretório de destino exista.
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

  /// Remove todos os logs do cache em memória.
  ///
  /// Se a persistência em arquivo estiver habilitada, também remove os
  /// arquivos físicos após a inicialização do cache.
  @override
  Future<void> clearLogs() async {
    _loggerJsonList.clear();
    await _futureInitialization;
    await _loggerCache?.clearAll();
  }

  /// Remove apenas os logs do [type] informado.
  ///
  /// A remoção é aplicada na memória e refletida no armazenamento em disco,
  /// quando habilitado.
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

  /// Retorna os logs em memória apenas do [type] solicitado.
  ///
  /// Retorna lista vazia quando não houver entradas desse tipo.
  @override
  Future<List<LoggerObjectBase>> getLogsByType(EnumLoggerType type) async {
    final loggerList = _loggerJsonList[type];
    if (loggerList != null) {
      return (loggerList.loggerEntries);
    }
    return [];
  }

  @override
  Future<void> importLogs(String content, ExportFormat format) {
    throw UnimplementedError();
  }

  /// Inicializa o repositório carregando logs persistidos anteriormente do disco.
  ///
  /// Quando houver dados válidos, o estado em memória é reconstruído para
  /// permitir consultas imediatas sem nova leitura dos arquivos.
  Future<void> _initialize() async {
    if (_loggerCache != null &&
        !_loggerCache!.futureInitialization.isCompleted) {
      await _loggerCache!.futureInitialization.future;
      final allLogs = await _loggerCache!.readAllLogs();
      if (allLogs != null) {
        _loggerJsonList.clear();
        _loggerJsonList.addAll(allLogs);
      }
    }
  }
}
