import 'dart:developer' as dev;

import 'package:log_custom_printer/log_custom_printer.dart';
import 'package:log_custom_printer/src/cache/logger_cache.dart';
import 'package:log_custom_printer/src/log_helpers/enum_logger_type.dart';
import 'package:log_custom_printer/src/log_helpers/logger_json_list.dart';

export 'package:log_custom_printer/src/log_helpers/logger_notifier.dart';

/// Gerencia a exibição e armazenamento de logs em toda a aplicação.
///
/// Esta classe implementa o padrão Singleton para garantir uma instância única
/// e centralizada de manipulação de logs. É responsável por coletar, armazenar,
/// limpar e notificar ouvintes sobre eventos de log de diferentes tipos (error,
/// debug, warning, info). Também configura o tratamento global de erros do Flutter
/// e da plataforma, interagindo com cache e notificadores de log.
///
/// {@category Utilities}
///
/// Exemplo de uso:
/// ```dart
/// final handler = LogDisplayHandler();
///
/// // Obter logs de um tipo específico
/// final errorLogs = handler.getLogsType(EnumLoggerType.error);
///
/// // Limpar logs de um tipo
/// handler.clearList(type: EnumLoggerType.debug);
///
/// // Limpar todos os logs
/// handler.clearAll();
/// ```
///
/// **Nota:** Esta classe configura automaticamente handlers globais de erro
/// para capturar exceções não tratadas no Flutter e na plataforma.
final class LogDisplayHandler extends LogPrinterBase {
  static LogDisplayHandler? _logger;

  final Map<EnumLoggerType, LoggerJsonList?> _loggerJsonList = {};

  LoggerNotifier notifier = LoggerNotifier();

  LoggerCache? _loggerCache;
  factory LogDisplayHandler(ConfigLog configLog) {
    _logger ??= LogDisplayHandler._private(configLog);
    return _logger!;
  }
  LogDisplayHandler._private(ConfigLog configLog) : super(config: configLog) {
    if (configLog.saveLogFilePath.isNotEmpty) {
      _loggerCache = LoggerCache(configLog.saveLogFilePath);
      _loggerCache!.futureInit.then((_) => _loadAll());
    }
  }

  /// Limpa todos os logs de todas as categorias.
  void clearAll() {
    for (final type in EnumLoggerType.values) {
      clearList(type: type);
    }
  }

  /// Limpa os logs de um tipo específico ou todos os logs se o índice for -1.
  /// Se um índice específico for fornecido, apenas o log nesse índice será removido.
  void clearList({required EnumLoggerType type, int index = -1}) {
    if (_loggerJsonList.containsKey(type)) {
      final loggerList = _loggerJsonList[type]!;
      if (index != -1) {
        assert(index >= 0 && index < loggerList.loggerJson.length, "Índice fora do intervalo");
        loggerList.loggerJson.removeAt(index);
      } else {
        loggerList.loggerJson.clear();
      }
      _loggerCache?.writeLogToFile(type.name, loggerList);
      notifier.changeListLog(_loggerJsonList);
    }
  }

  List<LoggerObjectBase> getLogsType(EnumLoggerType enumLoggerType) {
    if (_loggerJsonList.containsKey(enumLoggerType)) {
      return _loggerJsonList[enumLoggerType]!.loggerJson;
    } else {
      final json = _loggerCache?.getLogResp(enumLoggerType.name);
      if (json != null) {
        final LoggerJsonList loggerList = LoggerJsonList.fromJson(json);
        _loggerJsonList[enumLoggerType] = loggerList;
        return loggerList.loggerJson;
      }
    }
    return [];
  }

  @override
  void printLog(LoggerObjectBase log) {
    if (configLog.enableLog || log is ErrorLog) {
      final separator = log.getColor().call("=-=-=-=-=-=-=-=-=-=-=--==-=-=-=-=-=-=-=-=-=-=-=-=-=-");
      final time = log.getColor().call(log.logCreationDate.onlyTime());
      final start = log.getStartLog();
      final List<String> messageLog = [" ", separator];
      if (log is ErrorLog) {
        // _printMessage("$start ${logger.message} ", stack: logger.stackTrace);
        messageLog.add(log.getMessage());
        // _toFileLog(logger);
      } else {
        messageLog.add(log.getColor().call(log.message));
      }
      // if (logger.showStackTrace) {
      //   final ss = logger.getStackTrace();

      //   messageLog.add(separator);
      //   messageLog.add(ss);
      // }

      messageLog.add(separator);

      final String logStr = "$time ${messageLog.join("\n")}";
      _toFileLog(log);
      dev.log(logStr, name: start);
    }
  }

  void _loadAll() {
    for (final enumLoggerType in EnumLoggerType.values) {
      try {
        LoggerJsonList? loggerList = _loggerJsonList[enumLoggerType];
        if (loggerList == null) {
          final json = _loggerCache?.getLogResp(enumLoggerType.name);
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
    if (configLog.enableLog || stack != null) {
      String log = message.toString();
      if (stack != null) {
        log = log + stack.toString();
      }
      // ignore: avoid_print
      print(log);
    }
  }

  void _toFileLog(LoggerObjectBase logJ) {
    try {
      LoggerJsonList? loggerList = _loggerJsonList[logJ.enumLoggerType];
      if (loggerList == null) {
        final json = _loggerCache?.getLogResp(logJ.enumLoggerType.name);
        if (json != null) {
          loggerList = LoggerJsonList.fromJson(json);
        }
        loggerList ??= LoggerJsonList(type: logJ.runtimeType.toString());
      }
      loggerList.maxLogEntries = configLog.maxLogEntriesInFile;
      loggerList.addLogger(logJ);
      _loggerJsonList[logJ.enumLoggerType] = loggerList;
      _loggerCache?.writeLogToFile(logJ.enumLoggerType.name, loggerList);
      notifier.changeListLog(_loggerJsonList);
    } catch (err, stack) {
      _printMessage(err.toString(), stack: stack);
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
