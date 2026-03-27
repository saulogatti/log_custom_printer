import 'package:log_custom_printer/src/cache/logger_cache_impl.dart';

import '../log_helpers/enum_logger_type.dart';
import '../log_printer_service.dart';
import '../logs_object/logger_object.dart';

abstract interface class ILoggerCacheRepository {
  /// Adiciona uma entrada de log ao repositório.
  Future<void> addLog(LoggerObjectBase log);

  /// Remove todas as entradas de log do repositório.
  Future<void> clearLogs();

  /// Remove entradas de log de um tipo específico.
  Future<void> clearLogsByType(EnumLoggerType type);

  /// Recupera todas as entradas de log armazenadas.
  Future<List<LoggerObjectBase>> getAllLogs();

  /// Recupera entradas de log filtradas por tipo.
  Future<List<LoggerObjectBase>> getLogsByType(EnumLoggerType type);
}

/// Interface para repositório de cache de logs.
///
/// Define as operações básicas para armazenamento, recuperação e limpeza de logs.
/// Caso queira personalizar o armazenamento dos logs (ex: usar um banco de dados local,
/// SharedPreferences, etc.), implemente esta interface e forneça a implementação
/// personalizada para o [LogPrinterService] via [registerLogPrinter].
///
/// {@category Utilities}
final class LoggerCacheRepository {
  final ILoggerCacheRepository _cacheRepository;
  void Function(List<LoggerObjectBase>)? consoleModel;
  LoggerCacheRepository({ILoggerCacheRepository? cacheRepository})
    : _cacheRepository = cacheRepository ?? LoggerCacheImpl();

  /// Adiciona uma entrada de log ao repositório.
  Future<void> addLog(LoggerObjectBase log) async {
   
    await _cacheRepository.addLog(log);
    if (consoleModel != null) {
      final logs = await _cacheRepository.getAllLogs();
      consoleModel?.call(logs);
    }
  }

  /// Remove todas as entradas de log do repositório.
  Future<void> clearLogs() async {
    consoleModel?.call([]);
    await _cacheRepository.clearLogs();
  }

  /// Remove entradas de log de um tipo específico.
  Future<void> clearLogsByType(EnumLoggerType type) async {
    await _cacheRepository.clearLogsByType(type);
    if (consoleModel != null) {
      final logs = await _cacheRepository.getAllLogs();
      consoleModel?.call(logs);
    }
  }

  /// Recupera todas as entradas de log armazenadas.
  Future<List<LoggerObjectBase>> getAllLogs() async {
    final logs = await _cacheRepository.getAllLogs();
    consoleModel?.call(logs);
    return logs;
  }

  /// Recupera entradas de log filtradas por tipo.
  Future<List<LoggerObjectBase>> getLogsByType(EnumLoggerType type) async {
    final logs = await _cacheRepository.getLogsByType(type);
    consoleModel?.call(logs);
    return logs;
  }
}
