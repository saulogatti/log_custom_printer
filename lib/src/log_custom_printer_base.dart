import 'package:log_custom_printer/src/log_printers/log_simple_print.dart';
import 'package:log_custom_printer/src/logs_object/debug_log.dart';
import 'package:log_custom_printer/src/logs_object/logger_object.dart';

class LogCustomPrinterBase {
  static LogCustomPrinterBase? _instance;
  late LogPrinterBase _logPrinterBase;

  /// Construtor de fábrica para criar uma instância singleton.
  /// permite fornecer uma impressora de logs customizada via [logPrinterCustom].
  factory LogCustomPrinterBase({LogPrinterBase? logPrinterCustom}) {
    _instance ??= LogCustomPrinterBase._internal(
      logPrinterCustom ??= LogSimplePrint(),
    );

    return _instance!;
  }

  /// Construtor de fábrica para criar uma instância com impressora que
  /// preserva cor/estilo ANSI.
  factory LogCustomPrinterBase.colorPrint() {
    return LogCustomPrinterBase(logPrinterCustom: LogWithColorPrint());
  }
  LogCustomPrinterBase._internal(this._logPrinterBase);

  /// Retorna a impressora de logs configurada.
  LogPrinterBase getLogPrinterBase() {
    return _logPrinterBase;
  }

  void logDebug(String message, {Type? typeClass}) {
    final log = DebugLog(message, typeClass: typeClass);
    _logPrinterBase.printLog(log);
  }
}

/// Mixin que define o contrato para impressoras de logs.
//// Implementações devem fornecer o método [printLog] que recebe um
/// [LoggerObjectBase] e o imprime/serializa conforme a lógica desejada.
mixin LogPrinterBase {
  void printLog(LoggerObjectBase log);
}
