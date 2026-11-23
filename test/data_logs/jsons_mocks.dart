import 'package:log_custom_printer/log_custom_printer.dart';
import 'package:log_custom_printer/src/domain/logs_object/logger_json_list_type.dart';

Map<String, dynamic> jsonTestDebug = loggerJsonListDebug.toJson();

final Map<String, dynamic> jsonTestError = loggerJsonListError.toJson();
final Map<String, dynamic> jsonTestInfo = loggerJsonListInfo.toJson();

final Map<String, dynamic> jsonTestWarning = loggerJsonListWarning.toJson();

final listDebugLogs = [
  DebugLog(
    'Enviando log de debug via ActionChip 1',
    typeClass: ExemploErrosState,
    createdAt: DateTime.now(),
  ),
  DebugLog(
    'Enviando log de debug via ActionChip 2',
    typeClass: ExemploErrosState,
    createdAt: DateTime.now(),
  ),
  DebugLog(
    'Enviando log de debug via ActionChip 3',
    typeClass: ExemploErrosState,
    createdAt: DateTime.now(),
  ),
];
final listErrorLogs = [
  ErrorLog(
    'Enviando log de error via ActionChip 1',
    typeClass: ExemploErrosState,
    createdAt: DateTime.now(),
    StackTrace.current,
    object: ExemploErrosState(),
  ),
  ErrorLog(
    'Enviando log de error via ActionChip 2',
    typeClass: ExemploErrosState,
    createdAt: DateTime.now(),
    StackTrace.current,
    object: ExemploErrosState(),
  ),
  ErrorLog(
    'Enviando log de error via ActionChip 3',
    typeClass: ExemploErrosState,
    createdAt: DateTime.now(),
    StackTrace.current,
    object: ExemploErrosState(),
  ),
];
final listInfoLogs = [
  InfoLog(
    'Enviando log de info via ActionChip 1',
    typeClass: ExemploErrosState,
    createdAt: DateTime.now(),
  ),
  InfoLog(
    'Enviando log de info via ActionChip 2',
    typeClass: ExemploErrosState,
    createdAt: DateTime.now(),
  ),
  InfoLog(
    'Enviando log de info via ActionChip 3',
    typeClass: ExemploErrosState,
    createdAt: DateTime.now(),
  ),
];
final listWarningLogs = [
  WarningLog(
    'Enviando log de warning via ActionChip 1',
    typeClass: ExemploErrosState,
    createdAt: DateTime.now(),
  ),
  WarningLog(
    'Enviando log de warning via ActionChip 2',
    typeClass: ExemploErrosState,
    createdAt: DateTime.now(),
  ),
  WarningLog(
    'Enviando log de warning via ActionChip 3',
    typeClass: ExemploErrosState,
    createdAt: DateTime.now(),
  ),
];
final loggerJsonListDebug = LoggerJsonListType(type: EnumLoggerType.debug)
  ..addLoggerList(listDebugLogs);
final loggerJsonListError = LoggerJsonListType(type: EnumLoggerType.error)
  ..addLoggerList(listErrorLogs);
final loggerJsonListInfo = LoggerJsonListType(type: EnumLoggerType.info)
  ..addLoggerList(listInfoLogs);
final loggerJsonListWarning = LoggerJsonListType(type: EnumLoggerType.warning)
  ..addLoggerList(listWarningLogs);
class ExemploErrosState;
