import 'package:log_custom_printer/src/config_log.dart';
import 'package:log_custom_printer/src/data/cache/logger_cache_repository_impl.dart';
import 'package:log_custom_printer/src/data/cache/logger_persistence_service.dart';
import 'package:log_custom_printer/src/domain/i_logger_cache_repository.dart';
import 'package:log_custom_printer/src/domain/logs_object/logger_object.dart';
import 'package:log_custom_printer/src/log_custom_printer_base.dart';

/// Central service responsible for log output and storage flow.
///
/// Applies configuration rules and delegates to [LogPrinterBase] and
/// [LoggerPersistenceService].
///
/// {@category Core}
final class LogPrinterService(
  /// Configured printer strategy.
  final LogPrinterBase logPrinter, {

  /// Global enable/filter configuration.
  required final ConfigLog configLog,
  ILoggerCacheRepository? cacheRepository,
}) {
  /// Internal cache/persistence service.
  final LoggerPersistenceService _loggerPersistenceService = LoggerPersistenceService(
    loggerPersistenceService: cacheRepository ?? LoggerCacheRepositoryImpl(maxLogEntries: 100),
  );

  /// Exposes the persistence service linked to this instance.
  LoggerPersistenceService get cacheRepository => _loggerPersistenceService;

  /// Executes log processing.
  ///
  /// If config allows it, the log is cached and printed.
  /// Logs with `alwaysPrint` bypass normal filtering.
  void executePrint(LoggerObjectBase log) {
    if (configLog.enableLog &&
        (configLog.onlyClasses.isEmpty || configLog.onlyClasses.contains(log.runtimeType))) {
      cacheRepository.addLog(log);
      logPrinter.printLog(log);
    } else if (log.alwaysPrint) {
      cacheRepository.addLog(log);
      logPrinter.printLog(log);
    }
  }
}
