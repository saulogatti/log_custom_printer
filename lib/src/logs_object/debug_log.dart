import 'package:json_annotation/json_annotation.dart';
import 'package:log_custom_printer/src/logs_object/logger_object.dart';
import 'package:log_custom_printer/src/utils/logger_ansi_color.dart';

part 'debug_log.g.dart';

@JsonSerializable()
class DebugLog extends LoggerObjectBase {
  DebugLog(super.message, {super.creationDateTime, super.className});

  factory DebugLog.fromJson(Map<String, dynamic> json) =>
      _$DebugLogFromJson(json);

  @override
  LoggerAnsiColor getColor() {
    return LoggerAnsiColor(enumAnsiColors: EnumAnsiColors.cyan);
  }

  @override
  Map<String, dynamic> toJson() => _$DebugLogToJson(this);
}
