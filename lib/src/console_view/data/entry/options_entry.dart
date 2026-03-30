// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart' show DateTimeRange;
import 'package:json_annotation/json_annotation.dart';
import 'package:log_custom_printer/src/console_view/data/entry/option_item_entry.dart';
import 'package:log_custom_printer/src/console_view/domain/models/console_options.dart';

part 'options_entry.g.dart';

const _copyWithNotSet = Object();

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
/// - [selectedDateTimeRange] usa pares de `int` (start/end)
///   para facilitar serialização JSON.
/// - [isDateTimeFilterEnabled] define se o range salvo deve ser aplicado.
@JsonSerializable(explicitToJson: true)
class OptionsEntry {
  final OptionItemEntry selectedOption;
  final DateRangeEpochEntry? selectedDateTimeRange;
  final bool isDateTimeFilterEnabled;

  const OptionsEntry({
    required this.selectedOption,
    this.selectedDateTimeRange,
    this.isDateTimeFilterEnabled = false,
  });

  factory OptionsEntry.fromConsoleOptions(ConsoleOptions options) {
    return OptionsEntry(
      selectedOption: OptionItemEntry(
        title: options.option.title,
        description: options.option.description,
      ),
      selectedDateTimeRange: DateRangeEpochEntry.fromDateTimeRangeOrNull(
        options.selectedDateTimeRange,
      ),
      isDateTimeFilterEnabled: options.isDateTimeFilterEnabled,
    );
  }

  factory OptionsEntry.fromJson(Map<String, dynamic> json) =>
      _$OptionsEntryFromJson(json);

  OptionsEntry copyWith({
    OptionItemEntry? selectedOption,
    Object? selectedDateTimeRange = _copyWithNotSet,
    bool? isDateTimeFilterEnabled,
  }) {
    return OptionsEntry(
      selectedOption: selectedOption ?? this.selectedOption,
      selectedDateTimeRange: selectedDateTimeRange == _copyWithNotSet
          ? this.selectedDateTimeRange
          : selectedDateTimeRange as DateRangeEpochEntry?,
      isDateTimeFilterEnabled:
          isDateTimeFilterEnabled ?? this.isDateTimeFilterEnabled,
    );
  }

  ConsoleOptions toConsoleOptions() {
    return ConsoleOptions(
      option: OptionItem(
        title: selectedOption.title,
        description: selectedOption.description,
      ),
      selectedDateTimeRange: selectedDateTimeRange?.toDateTimeRange(),
      isDateTimeFilterEnabled: isDateTimeFilterEnabled,
    );
  }

  Map<String, dynamic> toJson() => _$OptionsEntryToJson(this);

  @override
  String toString() {
    return 'OptionsEntry('
        'option: $selectedOption, '
        'selectedDateTimeRange: $selectedDateTimeRange, '
        'isDateTimeFilterEnabled: $isDateTimeFilterEnabled'
        ')';
  }
}
