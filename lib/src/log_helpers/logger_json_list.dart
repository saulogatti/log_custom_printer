
import 'package:json_annotation/json_annotation.dart';
import 'package:log_custom_printer/log_custom_printer.dart';

part 'logger_json_list.g.dart';

@JsonSerializable(createFactory: false)
class LoggerJsonList {
  LoggerJsonList({required this.type});

  factory LoggerJsonList.fromJson(Map<String, dynamic> json) {
    final String type = json['type'] as String;
    final LoggerJsonList loggerJsonList = LoggerJsonList(type: type);
    final list = json['loggerJson'] as List;
    for (final element in list) {
      if (element is Map<String, dynamic>) {
        LoggerObjectBase? ob;
        if (type == "ErrorLog") {
          ob = ErrorLog.fromJson(element);
        } else if (type == "DebugLog") {
          ob = DebugLog.fromJson(element);
        } else if (type == "WarningLog") {
          ob = WarningLog.fromJson(element);
        } else if (type == "InfoLog") {
          ob = InfoLog.fromJson(element);
        }
        assert(ob != null, "Unknown logger type: $type");
        loggerJsonList.addLogger(ob!);
      }
    }
    return loggerJsonList;
  }
  String type;

  List<LoggerObjectBase>? loggerJson;

  void addLogger(LoggerObjectBase logger) {
    loggerJson ??= [];
    if (loggerJson!.length > 100) {
      loggerJson!.removeLast();
    }
    loggerJson!.insert(0, logger);
  }

  Map<String, dynamic> toJson() => _$LoggerJsonListToJson(this);
}
