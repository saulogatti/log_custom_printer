import 'package:log_custom_printer/src/domain/log_helpers/enum_logger_type.dart';

/// Query parameters for log filtering and sorting.
///
/// {@category Query}

/// Constructor for LogQuery.
///
/// {@category Query}
/// [types] is the set of log types to include.
/// [start] is the inclusive start date filter.
/// [end] is the exclusive end date filter.
/// [sortField] is the optional sort field.
/// [sortDirection] is the optional sort direction.
///
/// New constructor Dart 3.13
class const LogQuery({
  /// Optional set of log types to include.
  final Set<EnumLoggerType>? types,

  /// Inclusive start date filter.
  final DateTime? start,

  /// Exclusive end date filter.
  final DateTime? end,

  /// Optional sort field.
  final LogSortField? sortField,

  /// Optional sort direction.
  final SortDirection? sortDirection,
});

/// Sort field options.
///
/// {@category Query}
enum LogSortField {
  /// Sort by creation date.
  date,

  /// Sort by severity type (`debug < info < warning < error`).
  type,
}

/// Sort direction.
///
/// {@category Query}
enum SortDirection {
  /// Ascending order.
  asc,

  /// Descending order.
  desc,
}
