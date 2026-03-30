import 'package:flutter/rendering.dart' show debugPrint;
import 'package:log_custom_printer/src/console_view/data/datasource/options/options_console_data_source.dart';
import 'package:log_custom_printer/src/console_view/data/entry/option_item_entry.dart';
import 'package:log_custom_printer/src/console_view/data/entry/options_entry.dart';
import 'package:log_custom_printer/src/console_view/domain/models/console_options.dart';
import 'package:log_custom_printer/src/console_view/domain/repository/i_options_repository.dart';

class OptionsRepositoryImpl implements IOptionsRepository {
  final OptionsConsoleDataSource _dataSource;

  OptionsRepositoryImpl(this._dataSource);

  @override
  Future<ConsoleOptions> getCurrentOptions() async {
    try {
      final data = await _dataSource.getCurrentOptions();
      return data.toConsoleOptions();
    } on Exception catch (e) {
      // Handle exceptions, maybe log them
      debugPrint("Error fetching options: $e");
    }
    return ConsoleOptions.empty();
  }

  @override
  Future<void> selectDateTimeRange(int start, int end) async {
    OptionsEntry data = await _dataSource.getCurrentOptions();
    final hasValidRange = start > 0 && end > 0;
    data = data.copyWith(
      selectedDateTimeRange: hasValidRange
          ? DateRangeEpochEntry(start: start, end: end)
          : null,
    );
    if (hasValidRange) {
      data = data.copyWith(isDateTimeFilterEnabled: true);
    }
    _dataSource.saveOptions(data);
  }

  @override
  Future<void> selectOption(OptionItem option) async {
    OptionsEntry data = await _dataSource.getCurrentOptions();
    final OptionItemEntry updatedOption = OptionItemEntry(
      title: option.title,
      description: option.description,
    );

    data = data.copyWith(selectedOption: updatedOption);
    _dataSource.saveOptions(data);
  }

  @override
  Future<void> setDateTimeFilterEnabled(bool enabled) async {
    OptionsEntry data = await _dataSource.getCurrentOptions();
    data = data.copyWith(isDateTimeFilterEnabled: enabled);
    _dataSource.saveOptions(data);
  }
}
