import 'package:json_annotation/json_annotation.dart';
import 'package:log_custom_printer/log_custom_printer.dart';
import 'package:log_custom_printer/src/domain/log_helpers/log_exception.dart';

part 'logger_json_list_type.g.dart';

@JsonSerializable(createFactory: false)
class LoggerJsonListType({
  /// Stored log type name.
  required var EnumLoggerType type,

  /// Maximum number of entries to store.
  /// Defaults to 100.
  final int valueMaxNumberOfEntries = _defaultMaxNumberOfEntries,
}) {
  static const int _defaultMaxNumberOfEntries = 100;

  /// Constructor map for type-name-based deserialization.
  static final Map<EnumLoggerType, LoggerObjectBase Function(Map<String, dynamic>)>
  _typeConstructors = {
    EnumLoggerType.error: ErrorLog.fromJson,
    EnumLoggerType.debug: DebugLog.fromJson,
    EnumLoggerType.warning: WarningLog.fromJson,
    EnumLoggerType.info: InfoLog.fromJson,
  };

  static const String _loggerJsonListKey = 'loggerJson';
  static const String _typeKey = 'type';
  static const String _valueMaxNumberOfEntriesKey = 'valueMaxNumberOfEntries';

  /// Internal entries list.
  final List<LoggerObjectBase> _loggerEntries = [];

  /// Creates an instance from JSON data.
  factory LoggerJsonListType.fromJson(Map<String, dynamic> json) {
    final typeJson = json[_typeKey];
    if (typeJson != null && typeJson is String) {
      final type = EnumLoggerTypeExtension.fromString(typeJson);
      final valueMaxNumberOfEntries =
          json[_valueMaxNumberOfEntriesKey] as int? ?? _defaultMaxNumberOfEntries;
      final loggerJsonList = LoggerJsonListType(
        type: type,
        valueMaxNumberOfEntries: valueMaxNumberOfEntries,
      );
      final list = json[_loggerJsonListKey] as List? ?? [];
      for (final element in list) {
        if (element is Map<String, dynamic>) {
          final constructor = _typeConstructors[type];
          if (constructor != null) {
            // JSON is stored newest first, so append to keep the same order.
            loggerJsonList._appendOlderLogger(constructor(element));
          }
        }
      }
      return loggerJsonList;
    }
    throw LogException('Logger type not found in JSON: $json');
  }

  /// Enum type of entries in this list.
  @JsonKey(includeFromJson: false, includeToJson: false)
  EnumLoggerType? get enumLoggerType =>
      _loggerEntries.isNotEmpty ? _loggerEntries.first.enumLoggerType : null;

  /// Public read-only entries list (newest first).
  @JsonKey(name: _loggerJsonListKey)
  List<LoggerObjectBase> get loggerEntries => List<LoggerObjectBase>.from(_loggerEntries);

  /// Adds a new log entry at the beginning of the list.
  void addLogger(LoggerObjectBase logger) {
    if (_loggerEntries.length >= valueMaxNumberOfEntries) {
      _loggerEntries.removeLast();
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

  void removeById(int id) {
    _loggerEntries.removeWhere((logger) => logger.idLog == id);
  }

  /// Converts the instance to JSON map.
  Map<String, dynamic> toJson() => _$LoggerJsonListTypeToJson(this);

  /// Appends [logger] at the end (oldest position) unless the list is full.
  void _appendOlderLogger(LoggerObjectBase logger) {
    if (_loggerEntries.length < valueMaxNumberOfEntries) {
      _loggerEntries.add(logger);
    }
  }
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
