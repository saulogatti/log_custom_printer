import 'package:flutter/material.dart';
import 'package:log_custom_printer/src/console_view/domain/models/option_item.dart';

export 'option_item.dart';

class ConsoleOptions {
  final OptionItem option;
  final DateTimeRange? selectedDate;
  final DateTimeRange? selectedTimeRange;
  final List<OptionItem> options;
  ConsoleOptions({
    required this.option,
    this.selectedDate,
    this.selectedTimeRange,
    this.options = const [],
  });

  ConsoleOptions copyWith({
    OptionItem? option,
    DateTimeRange? selectedDate,
    DateTimeRange? selectedTimeRange,
    List<OptionItem>? options,
    bool clearSelectedDate = false,
    bool clearSelectedTimeRange = false,
  }) {
    return ConsoleOptions(
      option: option ?? this.option,
      selectedDate: clearSelectedDate ? null : (selectedDate ?? this.selectedDate),
      selectedTimeRange: clearSelectedTimeRange
          ? null
          : (selectedTimeRange ?? this.selectedTimeRange),
      options: options ?? this.options,
    );
  }

  factory ConsoleOptions.empty() {
    return ConsoleOptions(
      option: OptionItem(title: "Default", description: "Default option"),
      selectedDate: DateTimeRange(
        start: DateTime.now(),
        end: DateTime.now().add(const Duration(days: 1)),
      ),
      selectedTimeRange: DateTimeRange(
        start: DateTime.now(),
        end: DateTime.now().add(const Duration(hours: 1)),
      ),
      options: [],
    );
  }
}
