import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:log_custom_printer/log_custom_printer.dart';
import 'package:log_custom_printer/src/cache/logger_cache.dart';
import 'package:log_custom_printer/src/log_helpers/logger_json_list.dart';

export 'package:log_custom_printer/src/log_helpers/logger_notifier.dart';

bool debugEnable = true;

enum EnumLoggerType { error, debug, warning, info }

final class LogDisplayHandler {
  static LogDisplayHandler? _logger;

  final Map<EnumLoggerType, LoggerJsonList?> _loggerJsonList = {};

  LoggerNotifier notifier = LoggerNotifier();
  factory LogDisplayHandler() {
    _logger ??= LogDisplayHandler._private();
    return _logger!;
  }
  LogDisplayHandler._private() {
    LoggerCache().futureInit.then((_) => _loadAll());

    FlutterError.onError = (FlutterErrorDetails details) {
      final error = ErrorLog(details.exceptionAsString(), details.stack ?? StackTrace.current);
      error.sendLog();
    };
    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      final err = ErrorLog(error.toString(), stack);
      err.sendLog();
      return true; // Prevents the default error handling.
    };
  }

  void clearAll() {
    for (final type in EnumLoggerType.values) {
      clearList(type: type);
    }
  }

  void clearList({required EnumLoggerType type, int index = -1}) {
    if (_loggerJsonList.containsKey(type)) {
      final loggerList = _loggerJsonList[type]!;
      if (index != -1) {
        loggerList.loggerJson.removeAt(index);
      } else {
        loggerList.loggerJson.clear();
      }
      _toFileTemp(type.name, loggerList);
      notifier.changeListLog(_loggerJsonList);
    }
  }

  List<LoggerObjectBase> getLogsType(EnumLoggerType enumLoggerType) {
    if (_loggerJsonList.containsKey(enumLoggerType)) {
      return _loggerJsonList[enumLoggerType]!.loggerJson;
    } else {
      final json = LoggerCache().getLogResp(enumLoggerType.name);
      if (json != null) {
        final LoggerJsonList loggerList = LoggerJsonList.fromJson(json);
        _loggerJsonList[enumLoggerType] = loggerList;
        return loggerList.loggerJson;
      }
    }
    return [];
  }

  void logObject(LoggerObjectBase logger) {
    if (debugEnable || logger is ErrorLog) {
      final separator = logger.getColor().call("=-=-=-=-=-=-=-=-=-=-=--==-=-=-=-=-=-=-=-=-=-=-=-=-=-");
      final time = logger.getColor().call(logger.logCreationDate.onlyTime());
      final start = logger.getStartLog();
      final List<String> messageLog = [" ", separator];
      if (logger is ErrorLog) {
        // _printMessage("$start ${logger.message} ", stack: logger.stackTrace);
        messageLog.add(logger.getMessage());
        // _toFileLog(logger);
      } else {
        messageLog.add(logger.getColor().call(logger.message));
      }
      // if (logger.showStackTrace) {
      //   final ss = logger.getStackTrace();

      //   messageLog.add(separator);
      //   messageLog.add(ss);
      // }

      messageLog.add(separator);

      final String log = "$time ${messageLog.join("\n")}";
      _toFileLog(logger);
      dev.log(log, name: start);
    }

    // final bool saveLog = debugEnable || logger is LoggerError;
    // if (saveLog) {
    //   _toFileLog(logger);
    // }
  }

  // Future<void> shareFile(String path) async {
  //   try {
  //     final ShareResult result = await SharePlus.instance.share(
  //       ShareParams(files: [XFile(path)]),
  //     );
  //     _printMessage(result);
  //   } catch (error, stack) {
  //     _printMessage(error, stack: stack);
  //   }
  // }

  // void shareLogs({required EnumLoggerType type}) {
  //   final path = _getNameFile(type.name);
  //   if (path != null) {
  //     shareFile(path);
  //   }/Users/saulo.gatti/Documents/Desenvolvimento/projetos/pessoal/LogRocket/sem_t_tulo_workspace/dart_tool
  // }

  void _loadAll() {
    for (final enumLoggerType in EnumLoggerType.values) {
      try {
        if (enumLoggerType == EnumLoggerType.error) {
          continue;
        }

        LoggerJsonList? loggerList = _loggerJsonList[enumLoggerType];
        if (loggerList == null) {
          final json = LoggerCache().getLogResp(enumLoggerType.name);
          if (json != null) {
            loggerList = LoggerJsonList.fromJson(json);
            _loggerJsonList[enumLoggerType] = loggerList;
          }
        }
      } catch (err, stack) {
        _printMessage(err, stack: stack);
      }
    }
    notifier.changeListLog(_loggerJsonList);
  }

  void _printMessage(Object message, {StackTrace? stack}) {
    if (debugEnable || stack != null) {
      String log = message.toString();
      if (stack != null) {
        log = log + stack.toString();
      }
      // ignore: avoid_print
      print(log);
    }
  }

  // ignore: unused_element
  void _toFileLog(LoggerObjectBase logJ) {
    try {
      LoggerJsonList? loggerList = _loggerJsonList[logJ.enumLoggerType];
      if (loggerList == null) {
        final json = LoggerCache().getLogResp(logJ.enumLoggerType.name);
        if (json != null) {
          loggerList = LoggerJsonList.fromJson(json);
        }
        loggerList ??= LoggerJsonList(type: logJ.runtimeType.toString());
      }

      loggerList.addLogger(logJ);
      _loggerJsonList[logJ.enumLoggerType] = loggerList;
      _toFileTemp(logJ.enumLoggerType.name, loggerList);
      notifier.changeListLog(_loggerJsonList);
    } catch (err, stack) {
      _printMessage(err.toString(), stack: stack);
    }
  }

  void _toFileTemp(String fileName, Object respData) {
    try {
      final path = LoggerCache().getNameFile(fileName);
      final File file = File(path);
      final spaces = ' ' * 2;
      file.createSync();
      final jj = JsonEncoder.withIndent(spaces).convert(respData);
      file.writeAsStringSync(jj);
    } catch (e, stack) {
      _printMessage(e.toString(), stack: stack);
    }
  }
}

extension LoggerEnum on LoggerObjectBase {
  EnumLoggerType get enumLoggerType {
    if (this is ErrorLog) return EnumLoggerType.error;
    if (this is WarningLog) return EnumLoggerType.warning;
    if (this is InfoLog) return EnumLoggerType.info;
    return EnumLoggerType.debug;
  }
}
