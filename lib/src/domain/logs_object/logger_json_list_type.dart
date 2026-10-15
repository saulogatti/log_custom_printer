import 'package:json_annotation/json_annotation.dart';
import 'package:log_custom_printer/log_custom_printer.dart';
import 'package:log_custom_printer/src/data/cache/logger_cache_repository_impl.dart';
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
          // JSON is stored newest first, so append to keep the same order.
          loggerJsonList._appendOlderLogger(constructor(element));
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
    if (_loggerEntries.length >= valueMaxNumberOfEntries) {
      _loggerEntries.removeAt(valueMaxNumberOfEntries - 1);
    }
    _loggerEntries.insert(0, logger);
  }

  /// Adds a list of log entries at the beginning of the list.
  void addLoggerList(List<LoggerObjectBase> logger) {
    for (final element in logger) {
      addLogger(element);
    }
  }

  /// Merges [loggers] (newest first) into this list.
  ///
  /// Both lists are interleaved by [LoggerObjectBase.logCreationDate] so the result stays newest
  /// first; on equal dates existing entries come first. Only the newest
  /// [valueMaxNumberOfEntries] entries are kept.
  void mergeLoggerList(List<LoggerObjectBase> loggers) {
    final current = List<LoggerObjectBase>.from(_loggerEntries);
    _loggerEntries.clear();
    var i = 0;
    var j = 0;
    while (_loggerEntries.length < valueMaxNumberOfEntries &&
        (i < current.length || j < loggers.length)) {
      final takeCurrent =
          j >= loggers.length ||
          (i < current.length && !current[i].logCreationDate.isBefore(loggers[j].logCreationDate));
      _loggerEntries.add(takeCurrent ? current[i++] : loggers[j++]);
    }
  }

  /// Appends [logger] at the end (oldest position) unless the list is full.
  void _appendOlderLogger(LoggerObjectBase logger) {
    if (_loggerEntries.length < valueMaxNumberOfEntries) {
      _loggerEntries.add(logger);
    }
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
