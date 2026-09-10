import 'package:json_annotation/json_annotation.dart';
import 'package:log_custom_printer/src/domain/logs_object/logger_object.dart';
import 'package:log_custom_printer/src/utils/logger_ansi_color.dart';

part 'info_log.g.dart';

/// Informational log message with white formatting.
///
/// {@category Log Types}
@JsonSerializable()
class InfoLog extends LoggerObjectBase {
  /// Creates an info log.
  InfoLog(super.message, {super.createdAt, super.typeClass});

  /// Creates an instance from JSON.
  factory InfoLog.fromJson(Map<String, dynamic> json) => _$InfoLogFromJson(json);

  @override
  LoggerAnsiColor getColor() {
    return const LoggerAnsiColor(enumAnsiColors: EnumAnsiColors.white);
  }

  @override
  Map<String, dynamic> toJson() => _$InfoLogToJson(this);
}
