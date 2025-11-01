import 'package:log_custom_printer/src/logs_object/logger_object.dart';
import 'package:log_custom_printer/src/utils/logger_ansi_color.dart';
import 'package:json_annotation/json_annotation.dart';

part 'info_log.g.dart';

@JsonSerializable()
class InfoLog extends LoggerObjectBase {
  InfoLog(super.message, {super.typeClass}) : super();
  factory InfoLog.fromJson(Map<String, dynamic> json) =>
      _$InfoLogFromJson(json);
  @override
  LoggerAnsiColor getColor() {
    return LoggerAnsiColor(enumAnsiColors: EnumAnsiColors.white);
  }

  @override
  Map<String, dynamic> toJson() => _$InfoLogToJson(this);
}
