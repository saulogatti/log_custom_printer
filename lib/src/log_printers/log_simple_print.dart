import 'dart:developer' as dev show log;

import 'package:log_custom_printer/log_custom_printer.dart';
import 'package:log_custom_printer/src/logs_object/logger_object.dart';

export 'package:log_custom_printer/src/log_custom_printer_base.dart';

class LogSimplePrint with LogPrinterBase {
  const LogSimplePrint();
  @override
  void printLog(LoggerObjectBase log) {
    final className = log.className;
    final message = log.getMessage(false);

    print('[$className] $message');
  }
}

class LogWithColorPrint with LogPrinterBase {
  const LogWithColorPrint();
  @override
  void printLog(LoggerObjectBase log) {
    final separator = log.getColor().call(
      "=-=-=-=-=-=-=-=-=-=-=--==-=-=-=-=-=-=-=-=-=-=-=-=-=-",
    );

    final start = log.getColor().call(log.className.toString().toUpperCase());
    final List<String> messageLog = [" ", separator];
    // if (log is ErrorLog) {
    //   // _printMessage("$start ${logger.message} ", stack: logger.stackTrace);
    //   messageLog.add(logger.getMessage());
    //   // _toFileLog(logger);
    // }
    // // if (logger.showStackTrace) {
    // //   final ss = logger.getStackTrace();

    // //   messageLog.add(separator);
    // //   messageLog.add(ss);
    // // }
    messageLog.add(log.getMessage());
    messageLog.add(separator);

    final String logFormated = messageLog.join("\n");

    dev.log(logFormated, name: start);
  }
}
