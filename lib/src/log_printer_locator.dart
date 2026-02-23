import 'package:get_it/get_it.dart';
import 'package:log_custom_printer/src/cache/logger_cache_repository.dart';
import 'package:log_custom_printer/src/config_log.dart';
import 'package:log_custom_printer/src/log_printer_service.dart';
import 'package:log_custom_printer/src/log_printers/log_simple_print.dart';
import 'package:log_custom_printer/src/log_printers/log_with_color_print.dart';

/// Resolve o [LogPrinterBase] registrado no get_it.
///
/// Usado internamente por [LoggerObjectBase.sendLog] para obter a
/// impressora de logs configurada via injeção de dependência.
///
/// Lança [StateError] se [LogPrinterBase] não estiver registrado.
/// Chame [registerLogPrinter] no startup da aplicação antes de usar logs.
/// Manter interna para evitar acoplamento direto dos objetos de log com o get_it, centralizando a resolução do printer aqui.

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
/// [getIt]: instância do GetIt (padrão: GetIt.instance).
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
LoggerCacheRepository registerLogPrinter(LogPrinterBase printer) {
  final locator = GetIt.instance;
  if (locator.isRegistered<LogPrinterService>()) {
    locator.unregister<LogPrinterService>();
  }
  locator.registerSingleton<LogPrinterService>(LogPrinterService(printer));
  return locator<LogPrinterService>().cacheRepository;
}

/// Registra uma impressora com formatação colorida.
///
/// Atalho para [registerLogPrinter] com [LogWithColorPrint].
LoggerCacheRepository registerLogPrinterColor({ConfigLog? config}) {
  return registerLogPrinter(LogWithColorPrint(config: config ?? const ConfigLog()));
}

/// Registra uma impressora simples (sem cores).
///
/// Atalho para [registerLogPrinter] com [LogSimplePrint].
LoggerCacheRepository registerLogPrinterSimple({ConfigLog? config}) {
  return registerLogPrinter(LogSimplePrint(config: config ?? const ConfigLog()));
}
