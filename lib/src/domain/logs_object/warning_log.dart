import 'package:json_annotation/json_annotation.dart';
import 'package:log_custom_printer/src/domain/logs_object/logger_object.dart';
import 'package:log_custom_printer/src/utils/logger_ansi_color.dart';

part 'warning_log.g.dart';

/// Warning log message with green formatting.
///
/// {@category Log Types}
@JsonSerializable()
class WarningLog(super.message, {super.createdAt, super.typeClass}) extends LoggerObjectBase {
  /// Creates an instance from JSON.
  factory WarningLog.fromJson(Map<String, dynamic> json) => _$WarningLogFromJson(json);

  @override
  LoggerAnsiColor getColor() {
    return const LoggerAnsiColor(enumAnsiColors: EnumAnsiColors.green);
  }

  @override
  Map<String, dynamic> toJson() => _$WarningLogToJson(this);
}
