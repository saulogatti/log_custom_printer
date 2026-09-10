import 'package:json_annotation/json_annotation.dart';
import 'package:log_custom_printer/src/domain/log_helpers/enum_logger_type.dart';
import 'package:log_custom_printer/src/domain/log_helpers/log_exception.dart';
import 'package:log_custom_printer/src/domain/log_helpers/logger_enum.dart';
import 'package:log_custom_printer/src/domain/logs_object/debug_log.dart';
import 'package:log_custom_printer/src/domain/logs_object/error_log.dart';
import 'package:log_custom_printer/src/domain/logs_object/info_log.dart';
import 'package:log_custom_printer/src/domain/logs_object/logger_object.dart';
import 'package:log_custom_printer/src/domain/logs_object/warning_log.dart';

part 'logger_json_list.g.dart';

/// Serializable list of logs for a single concrete log type.
///
/// {@category Utilities}
@JsonSerializable(createFactory: false)
class LoggerJsonList {
  /// Constructor map for type-name-based deserialization.
  static final Map<String, LoggerObjectBase Function(Map<String, dynamic>)> _typeConstructors = {
    'ErrorLog': ErrorLog.fromJson,
    'DebugLog': DebugLog.fromJson,
    'WarningLog': WarningLog.fromJson,
    'InfoLog': InfoLog.fromJson,
  };

  /// Stored log type name.
  String type;

  /// Internal entries list.
  final List<LoggerObjectBase> _loggerEntries = [];

  /// Max number of stored entries.
  @JsonKey(includeFromJson: false, includeToJson: false)
  int maxLogEntries = 100;

  /// Creates a list for [type].
  LoggerJsonList({required this.type, this.maxLogEntries = 100});

  /// Creates an instance from JSON data.
  factory LoggerJsonList.fromJson(Map<String, dynamic> json) {
    if (json['type'] == null || json['type'] is! String) {
      throw LogException('Logger type not found');
    }
    final String type = json['type'] as String;
    final LoggerJsonList loggerJsonList = LoggerJsonList(type: type);
    final list = json['loggerJson'] as List? ?? [];
    for (final element in list) {
      if (element is Map<String, dynamic>) {
        final constructor = _typeConstructors[type];
        if (constructor != null) {
          final ob = constructor(element);
          loggerJsonList.addLogger(ob);
        } else {
          throw LogException('Unknown logger type: $type');
        }
      }
    }
    return loggerJsonList;
  }

  /// Enum type of entries in this list.
  @JsonKey(includeFromJson: false, includeToJson: false)
  EnumLoggerType? get enumLoggerType =>
      _loggerEntries.isNotEmpty ? _loggerEntries.first.enumLoggerType : null;

  /// Public read-only entries list (newest first).
  @JsonKey(name: 'loggerJson')
  List<LoggerObjectBase> get loggerEntries => List<LoggerObjectBase>.from(_loggerEntries);

  /// Adds a new log entry at the beginning of the list.
  void addLogger(LoggerObjectBase logger) {
    if (_loggerEntries.length >= maxLogEntries) {
      _loggerEntries.removeLast();
    }
    _loggerEntries.insert(0, logger);
  }

  /// Converts the instance to JSON map.
  Map<String, dynamic> toJson() => _$LoggerJsonListToJson(this);
}
