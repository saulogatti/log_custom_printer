import 'package:json_annotation/json_annotation.dart';
import 'package:log_custom_printer/src/config_log.dart';
import 'package:log_custom_printer/src/extensions/date_time_log_helper.dart';
import 'package:log_custom_printer/src/log_printer_locator.dart';
import 'package:log_custom_printer/src/utils/logger_ansi_color.dart';
import 'package:meta/meta.dart';

part 'logger_object.g.dart';

/// Base marker for log objects.
///
/// {@category Core}
sealed class LoggerObject {}

/// Base contract for log objects that can be printed and serialized.
///
/// {@category Core}
@JsonSerializable()
class LoggerObjectBase extends LoggerObject {
  /// Class/source that emitted the log.
  late String className;

  /// Tags attached to the log.
  @JsonKey(name: 'tagLog')
  final String tag;

  /// Main log message.
  @JsonKey(name: 'message')
  final String message;

  /// Creation time of this log.
  @JsonKey(name: 'logCreationDate')
  DateTime logCreationDate = DateTime.now();

  /// Creates a log object.
  LoggerObjectBase(this.message, {DateTime? createdAt, Type? typeClass, String? tag})
    : tag = tag ?? typeClass?.toString() ?? '',
      assert(
        message.isNotEmpty && message.trim().isNotEmpty,
        'Message cannot be empty or whitespace only',
      ) {
    logCreationDate = createdAt ?? DateTime.now();
    className = typeClass?.toString() ?? runtimeType.toString();
  }

  factory LoggerObjectBase.fromJson(Map<String, dynamic> json) => _$LoggerObjectBaseFromJson(json);

  /// When `true`, this log is processed even if [ConfigLog.enableLog] is `false`.
  bool get alwaysPrint => false;

  /// Formatted log header (runtime type + source class).
  String get _logHeader =>
      runtimeType.toString().toUpperCase() +
      (className.isNotEmpty ? ' - $className'.toUpperCase() : '');

  /// ANSI color/style for this log type.
  @mustBeOverridden
  LoggerAnsiColor getColor() => const LoggerAnsiColor(enumAnsiColors: EnumAnsiColors.white);

  /// Returns formatted message with optional ANSI color.
  String getMessage({bool withColor = true}) {
    final messageFormated = '${logCreationDate.logFullDateTime} $message';
    final formattedLine = withColor ? getColor().call(messageFormated) : messageFormated;

    return formattedLine;
  }

  /// Returns formatted log header with optional ANSI color.
  String getStartLog({bool withColor = true}) {
    if (withColor) {
      return getColor().call(_logHeader);
    }
    return _logHeader;
  }

  /// Sends the log using the configured service from [fetchLogPrinterService].
  @mustCallSuper
  void sendLog() {
    final logPrinterService = fetchLogPrinterService();

    logPrinterService.executePrint(this);
  }

  /// Serializes the log object into JSON.
  Map<String, dynamic> toJson() => _$LoggerObjectBaseToJson(this);

  @override
  String toString() {
    return getMessage();
  }
}
