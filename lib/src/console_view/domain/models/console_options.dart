import 'package:flutter/material.dart';
import 'package:log_custom_printer/src/console_view/domain/models/option_item.dart';

export 'option_item.dart';

/// Opções de configuração da tela de console.
///
/// Regras:
/// - [selectedDateTimeRange] representa um único intervalo de data/hora.
/// - Quando [isDateTimeFilterEnabled] é `false`, o intervalo salvo é ignorado
///   pelo filtro da lista (mas permanece persistido).
/// - Um intervalo é válido quando `end.difference(start) > Duration.zero`.
class ConsoleOptions {
  OptionItem option;
  DateTimeRange? selectedDateTimeRange;
  bool isDateTimeFilterEnabled;
  List<OptionItem> options;

  ConsoleOptions({
    required this.option,
    this.selectedDateTimeRange,
    this.isDateTimeFilterEnabled = false,
    this.options = const [],
  });

  factory ConsoleOptions.empty() {
    final now = DateTime.now();
    return ConsoleOptions(
      option: OptionItem(title: "Default", description: "Default option"),
      selectedDateTimeRange: DateTimeRange(
        start: now,
        end: now.add(const Duration(hours: 1)),
      ),
      isDateTimeFilterEnabled: false,
      options: [],
    );
  }

  /// Indica se o intervalo atual é válido para aplicação de filtro temporal.
  bool get hasValidDateTimeRange {
    final range = selectedDateTimeRange;
    if (range == null) {
      return false;
    }
    return range.end.difference(range.start).inMilliseconds > 0;
  }

  ConsoleOptions copyWith({
    OptionItem? option,
    DateTimeRange? selectedDateTimeRange,
    bool? isDateTimeFilterEnabled,
    List<OptionItem>? options,
  }) {
    return ConsoleOptions(
      option: option ?? this.option,
      selectedDateTimeRange:
          selectedDateTimeRange ?? this.selectedDateTimeRange,
      isDateTimeFilterEnabled:
          isDateTimeFilterEnabled ?? this.isDateTimeFilterEnabled,
      options: options ?? this.options,
    );
  }
}
