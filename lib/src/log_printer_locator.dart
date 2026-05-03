import 'package:get_it/get_it.dart';
import 'package:log_custom_printer/src/config_log.dart';
import 'package:log_custom_printer/src/data/cache/logger_cache_repository_impl.dart';
import 'package:log_custom_printer/src/data/cache/logger_persistence_service.dart';
import 'package:log_custom_printer/src/data/file_utils/file_manager_type.dart'
    show FileType;
import 'package:log_custom_printer/src/domain/i_logger_cache_repository.dart';
import 'package:log_custom_printer/src/domain/log_printers/log_simple_print.dart';
import 'package:log_custom_printer/src/domain/log_printers/log_with_color_print.dart';
import 'package:log_custom_printer/src/log_printer_service.dart';

export 'package:log_custom_printer/src/data/file_utils/file_manager_type.dart'
    show FileType;

/// Resolve o [LogPrinterService] registrado no get_it.
///
/// Usado internamente por [LoggerObjectBase.sendLog] para obter o
/// serviço de impressão de logs configurado via injeção de dependência.
///
/// Lança [StateError] se [LogPrinterService] não estiver registrado.
/// Chame [registerLogPrinter] no startup da aplicação antes de usar logs.
///
/// {@category Core}
LogPrinterService fetchLogPrinterService() {
  final getIt = GetIt.instance;
  if (!getIt.isRegistered<LogPrinterService>()) {
    throw StateError(
      'LogPrinterService não está registrado. Chame registerLogPrinter, '
      'registerLogPrinterColor ou registerLogPrinterSimple no startup '
      'antes de enviar logs.',
    );
  }
  return getIt<LogPrinterService>();
}

/// Registra o [LogPrinterBase] no get_it para injeção de dependência.
///
/// Deve ser chamado no startup da aplicação, antes de qualquer uso
/// de logs (sendLog, LoggerClassMixin, etc.).
///
/// [printer]: a impressora de logs a ser utilizada.
/// [cacheRepository]: repositório opcional para armazenamento de logs.
///
/// Exemplo:
/// ```dart
/// void main() {
///   registerLogPrinter(
///     const LogWithColorPrint(),
///     config: const ConfigLog(enableLog: true),
///   );
///   runApp(MyApp());
/// }
/// ```
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
    LogPrinterService(
      printer,
      cacheRepository: cacheRepository,
      configLog: config,
    ),
  );
  return locator<LogPrinterService>().cacheRepository;
}

/// Registra uma impressora com formatação colorida.
///
/// Atalho para [registerLogPrinter] com [LogWithColorPrint].
///
/// [config]: Configuração de filtragem e habilitação.
/// [maxLogsInCache]: Número máximo de logs mantidos em cache.
/// [cacheFilePath]: Caminho opcional para persistência em arquivo.
/// [fileType]: tipo de arquivo usado quando [cacheFilePath] estiver definido.
///
/// Exemplo:
/// ```dart
/// final persistence = registerLogPrinterColor(
///   config: const ConfigLog(enableLog: true),
///   maxLogsInCache: 200,
///   cacheFilePath: 'C:/temp',
///   fileType: FileType.json,
/// );
/// ```
///
/// {@category Core}
LoggerPersistenceService registerLogPrinterColor({
  ConfigLog? config,
  int maxLogsInCache = 100,
  String? cacheFilePath,
  FileType fileType = FileType.json,
}) {
  return registerLogPrinter(
    const LogWithColorPrint(),
    cacheRepository: LoggerCacheRepositoryImpl(
      maxLogEntries: maxLogsInCache,
      saveLogFilePath: cacheFilePath,
      fileType: fileType,
    ),
    config: config ?? const ConfigLog(),
  );
}

/// Registra uma impressora simples (sem cores).
///
/// Atalho para [registerLogPrinter] com [LogSimplePrint].
///
/// [config]: Configuração de filtragem e habilitação.
/// [maxLogsInCache]: Número máximo de logs mantidos em cache.
/// [cacheFilePath]: Caminho opcional para persistência em arquivo.
/// [fileType]: tipo de arquivo usado quando [cacheFilePath] estiver definido.
///
/// Exemplo:
/// ```dart
/// registerLogPrinterSimple(
///   config: const ConfigLog(enableLog: false),
///   maxLogsInCache: 100,
/// );
/// ```
///
/// {@category Core}
LoggerPersistenceService registerLogPrinterSimple({
  ConfigLog? config,
  int maxLogsInCache = 100,
  String? cacheFilePath,
  FileType fileType = FileType.json,
}) {
  return registerLogPrinter(
    const LogSimplePrint(),
    cacheRepository: LoggerCacheRepositoryImpl(
      maxLogEntries: maxLogsInCache,
      saveLogFilePath: cacheFilePath,
      fileType: fileType,
    ),
    config: config ?? const ConfigLog(),
  );
}
