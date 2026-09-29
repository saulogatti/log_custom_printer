import 'package:json_annotation/json_annotation.dart';
import 'package:log_custom_printer/log_custom_printer.dart';
import 'package:log_custom_printer/src/domain/log_helpers/log_exception.dart';

part 'logger_json_list_type.g.dart';

@JsonSerializable(createFactory: false)
class LoggerJsonListType({
  /// Stored log type name.
  required var EnumLoggerType type,
}) {
  /// Constructor map for type-name-based deserialization.
  static final Map<EnumLoggerType, LoggerObjectBase Function(Map<String, dynamic>)>
  _typeConstructors = {
    EnumLoggerType.error: ErrorLog.fromJson,
    EnumLoggerType.debug: DebugLog.fromJson,
    EnumLoggerType.warning: WarningLog.fromJson,
    EnumLoggerType.info: InfoLog.fromJson,
  };

  /// Max number of stored entries.
  int maxLogEntries = 100;

  /// Internal entries list.
  final List<LoggerObjectBase> _loggerEntries = [];

  /// Creates an instance from JSON data.
  factory LoggerJsonListType.fromJson(Map<String, dynamic> json) {
    if (json['type'] == null || json['type'] is! String) {
      throw LogException('Logger type not found');
    }
    final type = EnumLoggerTypeExtension.fromString(json['type'] as String);
    final loggerJsonList = LoggerJsonListType(type: type);
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

  /// Adds a list of log entries at the beginning of the list.
  void addLoggerList(List<LoggerObjectBase> logger) {
    _loggerEntries.addAll(logger);
  }

  /// Converts the instance to JSON map.
  Map<String, dynamic> toJson() => _$LoggerJsonListTypeToJson(this);
}

extension EnumLoggerTypeExtension on EnumLoggerType {
  static EnumLoggerType fromString(String type) {
    if (type == 'ErrorLog') {
      return EnumLoggerType.error;
    } else if (type == 'DebugLog') {
      return EnumLoggerType.debug;
    } else if (type == 'WarningLog') {
      return EnumLoggerType.warning;
    } else if (type == 'InfoLog') {
      return EnumLoggerType.info;
    } else {
      return EnumLoggerType.values.byName(type);
    }
  }
}
