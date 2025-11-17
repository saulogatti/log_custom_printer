import 'package:flutter/material.dart';
import 'package:log_custom_printer/log_custom_printer.dart';
import 'package:log_custom_printer/src/cache/logger_cache.dart';
import 'package:log_custom_printer/src/log_helpers/logger_json_list.dart';

class LoggerNotifier with ChangeNotifier {
  final Map<EnumLoggerType, LoggerJsonList?> _loggerJsonList = {};

  void changeListLog(Map<EnumLoggerType, LoggerJsonList?> listLog) {
    _loggerJsonList.clear();
    _loggerJsonList.addAll(listLog);
    notifyListeners();
  }

  List<LoggerObjectBase> getLogsType(EnumLoggerType enumLoggerType) {
    if (_loggerJsonList.containsKey(enumLoggerType)) {
      return _loggerJsonList[enumLoggerType]!.loggerJson!;
    } else {
      final json = LoggerCache().getLogResp(enumLoggerType.name);
      if (json != null) {
        final LoggerJsonList loggerList = LoggerJsonList.fromJson(json);
        _loggerJsonList[enumLoggerType] = loggerList;
        return loggerList.loggerJson!;
      }
    }
    return [];
  }
}
