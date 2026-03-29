import 'package:log_custom_printer/src/data/cache/logger_cache_repository_impl.dart';
import 'package:log_custom_printer/src/domain/i_logger_cache_repository.dart';
import 'package:log_custom_printer/src/domain/log_helpers/enum_logger_type.dart';
import 'package:log_custom_printer/src/domain/logs_object/logger_object.dart';
import 'package:log_custom_printer/src/log_printer_service.dart';

/// Interface para repositório de cache de logs.
///
/// Define as operações básicas para armazenamento, recuperação e limpeza de logs.
/// Caso queira personalizar o armazenamento dos logs (ex: usar um banco de dados local,
/// SharedPreferences, etc.), implemente esta interface e forneça a implementação
/// personalizada para o [LogPrinterService] via [registerLogPrinter].
///
/// {@category Utilities}
final class LoggerPersistenceService {
  final ILoggerCacheRepository _cacheRepository;
  void Function(List<LoggerObjectBase>)? logOutputHandler;
  LoggerPersistenceService({ILoggerCacheRepository? cacheRepository})
    : _cacheRepository = cacheRepository ?? LoggerCacheRepositoryImpl();

  /// Adiciona uma entrada de log ao repositório.
  Future<void> addLog(LoggerObjectBase log) async {
    await _cacheRepository.addLog(log);
    if (logOutputHandler != null) {
      final logs = await _cacheRepository.getAllLogs();
      logOutputHandler?.call(logs);
    }
  }

  /// Remove todas as entradas de log do repositório.
  Future<void> clearLogs() async {
    logOutputHandler?.call([]);
    await _cacheRepository.clearLogs();
  }

  /// Remove entradas de log de um tipo específico.
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
}
