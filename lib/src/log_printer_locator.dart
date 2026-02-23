import 'package:get_it/get_it.dart';
import 'package:log_custom_printer/src/cache/logger_cache_impl.dart';
import 'package:log_custom_printer/src/cache/logger_cache_repository.dart';
import 'package:log_custom_printer/src/config_log.dart';
import 'package:log_custom_printer/src/log_printer_service.dart';
import 'package:log_custom_printer/src/log_printers/log_simple_print.dart';
import 'package:log_custom_printer/src/log_printers/log_with_color_print.dart';

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
      'LogPrinterService não está registrado. '
      'Chame registerLogPrinter() no startup (ex: main()) antes de usar logs.',
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
///     LogWithColorPrint(config: ConfigLog(enableLog: true)),
///   );
///   runApp(MyApp());
/// }
/// ```
///
/// {@category Core}
LoggerCacheRepository registerLogPrinter(LogPrinterBase printer, {LoggerCacheRepository? cacheRepository}) {
  final locator = GetIt.instance;
  if (locator.isRegistered<LogPrinterService>()) {
    locator.unregister<LogPrinterService>();
  }
  locator.registerSingleton<LogPrinterService>(LogPrinterService(printer, cacheRepository: cacheRepository));
  return locator<LogPrinterService>().cacheRepository;
}

/// Registra uma impressora com formatação colorida.
///
/// Atalho para [registerLogPrinter] com [LogWithColorPrint].
///
/// [config]: Configuração de filtragem e habilitação.
/// [maxLogsInCache]: Número máximo de logs mantidos em cache.
/// [cacheFilePath]: Caminho opcional para persistência em arquivo.
///
/// {@category Core}
LoggerCacheRepository registerLogPrinterColor({
  ConfigLog? config,
  int maxLogsInCache = 100,
  String? cacheFilePath,
}) {
  return registerLogPrinter(
    LogWithColorPrint(config: config ?? const ConfigLog()),
    cacheRepository: LoggerCacheImpl(maxLogEntries: maxLogsInCache, saveLogFilePath: cacheFilePath),
  );
}

/// Registra uma impressora simples (sem cores).
///
/// Atalho para [registerLogPrinter] com [LogSimplePrint].
///
/// [config]: Configuração de filtragem e habilitação.
/// [maxLogsInCache]: Número máximo de logs mantidos em cache.
/// [cacheFilePath]: Caminho opcional para persistência em arquivo.
///
/// {@category Core}
LoggerCacheRepository registerLogPrinterSimple({
  ConfigLog? config,
  int maxLogsInCache = 100,
  String? cacheFilePath,
}) {
  return registerLogPrinter(
    LogSimplePrint(config: config ?? const ConfigLog()),
    cacheRepository: LoggerCacheImpl(maxLogEntries: maxLogsInCache, saveLogFilePath: cacheFilePath),
  );
}
