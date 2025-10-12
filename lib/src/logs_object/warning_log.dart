import 'package:json_annotation/json_annotation.dart';
import 'package:log_custom_printer/src/logs_object/logger_object.dart';
import 'package:log_custom_printer/src/utils/logger_ansi_color.dart';

part 'warning_log.g.dart';

@JsonSerializable()
class WarningLog extends LoggerObjectBase {
  WarningLog(super.message) : super();

  factory WarningLog.fromJson(Map<String, dynamic> json) =>
      _$WarningLogFromJson(json);

  @override
  LoggerAnsiColor getColor() {
    return LoggerAnsiColor(enumAnsiColors: EnumAnsiColors.yellow);
  }

  @override
  Map<String, dynamic> toJson() => _$WarningLogToJson(this);
}
