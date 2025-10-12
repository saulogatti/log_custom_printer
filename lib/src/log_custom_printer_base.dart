import 'package:log_custom_printer/src/log_printers/log_simple_print.dart';
import 'package:log_custom_printer/src/logs_object/debug_log.dart';
import 'package:log_custom_printer/src/logs_object/logger_object.dart';

class LogCustomPrinterBase {
  static LogCustomPrinterBase? _instance;
  late LogPrinterBase _logPrinterBase;
  factory LogCustomPrinterBase({LogPrinterBase? logPrinterBase}) {
    _instance ??= LogCustomPrinterBase._internal();
    logPrinterBase ??= LogSimplePrint();
    _instance!._logPrinterBase = logPrinterBase;
    return _instance!;
  }
  LogCustomPrinterBase._internal();
  void logDebug(String message, {String? className}) {
    final log = DebugLog(message, className: className);
    _logPrinterBase.printLog(log);
  }
}

mixin LogPrinterBase {
  void printLog(LoggerObjectBase log);
}
class MessageLog {
  final String message;
  Type? typeClass;
  MessageLog(this.message, {this.typeClass});
}