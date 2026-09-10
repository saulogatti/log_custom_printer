import 'package:get_it/get_it.dart';
import 'package:log_custom_printer/src/config_log.dart';
import 'package:log_custom_printer/src/data/cache/logger_cache_repository_impl.dart';
import 'package:log_custom_printer/src/data/cache/logger_persistence_service.dart';
import 'package:log_custom_printer/src/data/file_utils/file_manager_type.dart' show FileType;
import 'package:log_custom_printer/src/domain/i_logger_cache_repository.dart';
import 'package:log_custom_printer/src/domain/log_printers/log_simple_print.dart';
import 'package:log_custom_printer/src/domain/log_printers/log_with_color_print.dart';
import 'package:log_custom_printer/src/log_printer_service.dart';

export 'package:log_custom_printer/src/data/file_utils/file_manager_type.dart' show FileType;

/// Resolves the registered [LogPrinterService] from get_it.
///
/// Used internally by [LoggerObjectBase.sendLog] to obtain the configured log service.
///
/// If [LogPrinterService] is not registered yet, a default simple printer is registered.
/// You should still call [registerLogPrinter] at app startup to keep behavior explicit and predictable.
///
/// {@category Core}
LogPrinterService fetchLogPrinterService() {
  final getIt = GetIt.instance;
  if (!getIt.isRegistered<LogPrinterService>()) {
    registerLogPrinter(const LogSimplePrint(), config: const ConfigLog(enableLog: true));
  }
  return getIt<LogPrinterService>();
}

/// Registers a [LogPrinterBase] in get_it for dependency injection.
///
/// Call this during startup before any logging operation.
///
/// {@category Core}
LoggerPersistenceService registerLogPrinter(
  LogPrinterBase printer, {
  required ConfigLog config,
  ILoggerCacheRepository? cacheRepository,
}) {
  final locator = GetIt.instance;
  if (locator.isRegistered<LogPrinterService>()) {
    locator.unregister<LogPrinterService>();
  }
  locator.registerSingleton<LogPrinterService>(
    LogPrinterService(printer, cacheRepository: cacheRepository, configLog: config),
  );
  return locator<LogPrinterService>().cacheRepository;
}

/// Registers a color printer.
///
/// Convenience wrapper around [registerLogPrinter] with [LogWithColorPrint].
///
/// {@category Core}
LoggerPersistenceService registerLogPrinterColor({
  ConfigLog? config,
  int maxLogsInCache = 100,
  String? cacheFilePath,
  @Deprecated(
    'The fileType parameter has no effect and will be removed in future versions. File type is managed internally by LoggerCache.',
  )
  FileType fileType = FileType.json,
}) {
  return registerLogPrinter(
    const LogWithColorPrint(),
    cacheRepository: LoggerCacheRepositoryImpl(
      maxLogEntries: maxLogsInCache,
      directoryToSave: cacheFilePath,
    ),
    config: config ?? const ConfigLog(),
  );
}

/// Registers a simple non-colored printer.
///
/// Convenience wrapper around [registerLogPrinter] with [LogSimplePrint].
///
/// {@category Core}
LoggerPersistenceService registerLogPrinterSimple({
  ConfigLog? config,
  int maxLogsInCache = 100,
  String? cacheFilePath,
  @Deprecated(
    'The fileType parameter has no effect and will be removed in future versions. File type is managed internally by LoggerCache.',
  )
  FileType fileType = FileType.json,
}) {
  return registerLogPrinter(
    const LogSimplePrint(),
    cacheRepository: LoggerCacheRepositoryImpl(
      maxLogEntries: maxLogsInCache,
      directoryToSave: cacheFilePath,
    ),
    config: config ?? const ConfigLog(),
  );
}
