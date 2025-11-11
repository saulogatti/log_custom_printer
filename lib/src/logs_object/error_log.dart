import 'package:json_annotation/json_annotation.dart';
import 'package:log_custom_printer/src/logs_object/logger_object.dart';
import 'package:log_custom_printer/src/utils/logger_ansi_color.dart';
import 'package:log_custom_printer/src/utils/stack_trace_extensions.dart';

part 'error_log.g.dart';

@JsonSerializable()
class ErrorLog extends LoggerObjectBase {
  @StackTraceConverter()
  final StackTrace stackTrace;
  ErrorLog(super.message, this.stackTrace, {super.typeClass}) : super();
  factory ErrorLog.fromJson(Map<String, dynamic> json) =>
      _$ErrorLogFromJson(json);
  @override
  LoggerAnsiColor getColor() {
    return LoggerAnsiColor(enumAnsiColors: EnumAnsiColors.red);
  }

  @override
  String getMessage([bool withColor = true]) {
    final str = stackTrace.stackInMap(100);
    final color = getColor();
    final strMessage = super
        .getMessage(withColor)
        .split("\n")
        .map((e) => withColor ? color.call(e) : e)
        .toList();

    for (final element in str.keys) {
      if (withColor) {
        strMessage.add(color.call("$element = ${str[element]}"));
      } else {
        strMessage.add("$element = ${str[element]}");
      }
    }

    return strMessage.join("\n\t");
  }

  @override
  Map<String, dynamic> toJson() => _$ErrorLogToJson(this);
}

class StackTraceConverter implements JsonConverter<StackTrace, String> {
  const StackTraceConverter();

  @override
  StackTrace fromJson(String json) {
    // Implement your deserialization logic here
    return StackTrace.fromString(json);
  }

  @override
  String toJson(StackTrace object) {
    // Implemente sua lógica de serialização aqui
    return object.toString();
  }
}
