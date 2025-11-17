import 'package:json_annotation/json_annotation.dart';
import 'package:log_custom_printer/log_custom_printer.dart';

part 'logger_json_list.g.dart';

/// A serializable list of logger objects of a specific type.
///
/// This class is used to serialize and deserialize lists of log entries,
/// where each entry is a subclass of [LoggerObjectBase] (such as [ErrorLog],
/// [DebugLog], [WarningLog], or [InfoLog]). The [type] field indicates the
/// type of log entries contained in [loggerJson].
///
/// Use [fromJson] to create an instance from a JSON map, and [toJson] to
/// convert the instance back to JSON.
///
/// Fields:
/// - [type]: The type of log entries in the list (e.g., "ErrorLog").
/// - [loggerJson]: The list of log entry objects.
@JsonSerializable(createFactory: false)
class LoggerJsonList {
  String type;

  List<LoggerObjectBase> loggerJson = [];

  /// Limite máximo de logs armazenados na lista.
  final int maxLogEntries = 100;

  LoggerJsonList({required this.type});
  factory LoggerJsonList.fromJson(Map<String, dynamic> json) {
    final String type = json['type'] as String;
    final LoggerJsonList loggerJsonList = LoggerJsonList(type: type);
    final list = json['loggerJson'] as List;
    for (final element in list) {
      if (element is Map<String, dynamic>) {
        final factory = _logTypeFactories[type];
        assert(factory != null, "Unknown logger type: $type");
        final LoggerObjectBase ob = factory!(element);
        loggerJsonList.addLogger(ob);
      }
    }
    return loggerJsonList;
  }
  void addLogger(LoggerObjectBase logger) {
    if (loggerJson.length > maxLogEntries) {
      loggerJson.removeLast();
    }
    loggerJson.insert(0, logger);
  }

  Map<String, dynamic> toJson() => _$LoggerJsonListToJson(this);
}
