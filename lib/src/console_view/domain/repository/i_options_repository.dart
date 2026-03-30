import 'package:log_custom_printer/src/console_view/domain/models/console_options.dart';

abstract interface class IOptionsRepository {
  Future<ConsoleOptions> getCurrentOptions();
  Future<void> selectDateTimeRange(int start, int end);
  Future<void> selectOption(OptionItem option);
  Future<void> setDateTimeFilterEnabled(bool enabled);
}
