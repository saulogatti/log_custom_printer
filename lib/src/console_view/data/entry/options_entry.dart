// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart' show DateTimeRange;
import 'package:json_annotation/json_annotation.dart';
import 'package:log_custom_printer/src/console_view/data/entry/option_item_entry.dart';
import 'package:log_custom_printer/src/console_view/domain/models/console_options.dart';

part 'options_entry.g.dart';

/// Intervalo de datas/horas representado por epoch em milissegundos.
@JsonSerializable(explicitToJson: true)
class DateRangeEpochEntry {
  final int start;
  final int end;

  const DateRangeEpochEntry({required this.start, required this.end});

  factory DateRangeEpochEntry.fromDateTimeRange(DateTimeRange range) {
    return DateRangeEpochEntry(
      start: range.start.millisecondsSinceEpoch,
      end: range.end.millisecondsSinceEpoch,
    );
  }

  factory DateRangeEpochEntry.fromJson(Map<String, dynamic> json) =>
      _$DateRangeEpochEntryFromJson(json);

  DateTimeRange toDateTimeRange() {
    return DateTimeRange(
      start: DateTime.fromMillisecondsSinceEpoch(start),
      end: DateTime.fromMillisecondsSinceEpoch(end),
    );
  }

  Map<String, dynamic> toJson() => _$DateRangeEpochEntryToJson(this);

  @override
  String toString() => 'DateRangeEpochEntry(start: $start, end: $end)';

  static DateRangeEpochEntry? fromDateTimeRangeOrNull(DateTimeRange? range) {
    if (range == null) {
      return null;
    }
    return DateRangeEpochEntry.fromDateTimeRange(range);
  }
}

/// Representa o snapshot serializável de [ConsoleOptions].
///
/// Regras de persistência:
/// - [selectedDate] e [selectedTimeRange] usam pares de `int` (start/end)
///   para facilitar serialização JSON.
@JsonSerializable(explicitToJson: true)
class OptionsEntry {
  final OptionItemEntry selectedOption;
  final DateRangeEpochEntry? selectedDate;
  final DateRangeEpochEntry? selectedTimeRange;

  const OptionsEntry({
    required this.selectedOption,
    this.selectedDate,
    this.selectedTimeRange,
  });

  factory OptionsEntry.fromConsoleOptions(ConsoleOptions options) {
    return OptionsEntry(
      selectedOption: OptionItemEntry(
        title: options.option.title,
        description: options.option.description,
      ),
      selectedDate: DateRangeEpochEntry.fromDateTimeRangeOrNull(
        options.selectedDate,
      ),
      selectedTimeRange: DateRangeEpochEntry.fromDateTimeRangeOrNull(
        options.selectedTimeRange,
      ),
    );
  }

  factory OptionsEntry.fromJson(Map<String, dynamic> json) =>
      _$OptionsEntryFromJson(json);

  OptionsEntry copyWith({
    OptionItemEntry? selectedOption,
    DateRangeEpochEntry? selectedDate,
    DateRangeEpochEntry? selectedTimeRange,
  }) {
    return OptionsEntry(
      selectedOption: selectedOption ?? this.selectedOption,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTimeRange: selectedTimeRange ?? this.selectedTimeRange,
    );
  }

  ConsoleOptions toConsoleOptions() {
    return ConsoleOptions(
      option: OptionItem(
        title: selectedOption.title,
        description: selectedOption.description,
      ),
      selectedDate: selectedDate?.toDateTimeRange(),
      selectedTimeRange: selectedTimeRange?.toDateTimeRange(),
    );
  }

  Map<String, dynamic> toJson() => _$OptionsEntryToJson(this);

  @override
  String toString() {
    return 'OptionsEntry('
        'option: $selectedOption, '
        'selectedDate: $selectedDate, '
        'selectedTimeRange: $selectedTimeRange'
        ')';
  }
}
