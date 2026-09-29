import 'package:json_annotation/json_annotation.dart';
import 'package:log_custom_printer/log_custom_printer.dart' show ConfigLog;
import 'package:log_custom_printer/src/config_log.dart' show ConfigLog;
import 'package:log_custom_printer/src/domain/logs_object/logger_object.dart';
import 'package:log_custom_printer/src/utils/logger_ansi_color.dart';
import 'package:log_custom_printer/src/utils/stack_trace_extensions.dart';

part 'error_log.g.dart';

/// Error log with red formatting and stack trace support.
///
/// Always processed regardless of [ConfigLog.enableLog].
///
/// {@category Log Types}
@JsonSerializable()
class ErrorLog(
  super.message,

  /// Stack trace associated with the error.
  @StackTraceConverter() final StackTrace stackTrace, {
  super.createdAt,
  super.typeClass,
}) extends LoggerObjectBase {
  /// Creates an instance from JSON.
  factory ErrorLog.fromJson(Map<String, dynamic> json) => _$ErrorLogFromJson(json);

  @override
  bool get alwaysPrint => true;

  @override
  LoggerAnsiColor getColor() {
    return const LoggerAnsiColor(enumAnsiColors: EnumAnsiColors.red);
  }

  @override
  String getMessage({bool withColor = true}) {
    final str = stackTrace.stackInMap(100);
    final color = getColor();
    final strMessage = super
        .getMessage(withColor: withColor)
        .split('\n')
        .map((e) => withColor ? color.call(e) : e)
        .toList();

    for (final entry in str.entries) {
      if (withColor) {
        strMessage.add(color.call('${entry.key} = ${entry.value}'));
      } else {
        strMessage.add('${entry.key} = ${entry.value}');
      }
    }

    return strMessage.join('\n\t');
  }

  @override
  Map<String, dynamic> toJson() => _$ErrorLogToJson(this);
}

/// JSON converter for [StackTrace] values.
///
/// {@category Utilities}
class const StackTraceConverter() implements JsonConverter<StackTrace, String> {
  @override
  /// Rebuilds a [StackTrace] from [json] text.
  StackTrace fromJson(String json) {
    return StackTrace.fromString(json);
  }

  @override
  /// Serializes [object] to string JSON value.
  String toJson(StackTrace object) {
    return object.toString();
  }
}
