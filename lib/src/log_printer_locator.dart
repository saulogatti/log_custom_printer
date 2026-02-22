import 'package:get_it/get_it.dart';
import 'package:log_custom_printer/src/config_log.dart';
import 'package:log_custom_printer/src/log_printers/log_simple_print.dart';
import 'package:log_custom_printer/src/log_printers/log_with_color_print.dart';

/// Resolve o [LogPrinterBase] registrado no get_it.
///
/// Usado internamente por [LoggerObjectBase.sendLog] para obter a
/// impressora de logs configurada via injeção de dependência.
///
/// Lança [StateError] se [LogPrinterBase] não estiver registrado.
/// Chame [registerLogPrinter] no startup da aplicação antes de usar logs.
LogPrinterBase resolveLogPrinter() {
  final getIt = GetIt.instance;
  if (!getIt.isRegistered<LogPrinterBase>()) {
    throw StateError(
      'LogPrinterBase não está registrado. '
      'Chame registerLogPrinter() no startup (ex: main()) antes de usar logs.',
    );
  }
  return getIt<LogPrinterBase>();
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
void registerLogPrinter(LogPrinterBase printer, {GetIt? getIt}) {
  final locator = getIt ?? GetIt.instance;
  if (locator.isRegistered<LogPrinterBase>()) {
    locator.unregister<LogPrinterBase>();
  }
  locator.registerSingleton<LogPrinterBase>(printer);
}

/// Registra uma impressora com formatação colorida.
///
/// Atalho para [registerLogPrinter] com [LogWithColorPrint].
void registerLogPrinterColor({ConfigLog? config, GetIt? getIt}) {
  registerLogPrinter(LogWithColorPrint(config: config ?? const ConfigLog()), getIt: getIt);
}

/// Registra uma impressora simples (sem cores).
///
/// Atalho para [registerLogPrinter] com [LogSimplePrint].
void registerLogPrinterSimple({ConfigLog? config, GetIt? getIt}) {
  registerLogPrinter(LogSimplePrint(config: config ?? const ConfigLog()), getIt: getIt);
}
