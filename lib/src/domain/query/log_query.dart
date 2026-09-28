import 'package:log_custom_printer/src/domain/log_helpers/enum_logger_type.dart';

/// Query parameters for log filtering and sorting.
///
/// {@category Query}
class LogQuery {
  /// Optional set of log types to include.
  final Set<EnumLoggerType>? types;

  /// Inclusive start date filter.
  final DateTime? start;

  /// Exclusive end date filter.
  final DateTime? end;

  /// Optional sort field.
  final LogSortField? sortField;

  /// Optional sort direction.
  final SortDirection? sortDirection;

  /// Creates a query with optional filter/sort criteria.
  const LogQuery({this.types, this.start, this.end, this.sortField, this.sortDirection});
}

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
