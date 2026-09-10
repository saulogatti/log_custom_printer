import 'package:json_annotation/json_annotation.dart';
import 'package:log_custom_printer/src/domain/logs_object/logger_object.dart';
import 'package:log_custom_printer/src/utils/logger_ansi_color.dart';

part 'debug_log.g.dart';

/// Debug log message with yellow formatting.
///
/// {@category Log Types}
@JsonSerializable()
class DebugLog extends LoggerObjectBase {
  /// Creates a debug log.
  DebugLog(super.message, {super.createdAt, super.typeClass});

  /// Creates an instance from JSON.
  factory DebugLog.fromJson(Map<String, dynamic> json) => _$DebugLogFromJson(json);

  @override
  LoggerAnsiColor getColor() {
    return const LoggerAnsiColor(enumAnsiColors: EnumAnsiColors.yellow);
  }

  @override
  Map<String, dynamic> toJson() => _$DebugLogToJson(this);
}
