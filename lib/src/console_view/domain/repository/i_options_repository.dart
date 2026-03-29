import 'package:log_custom_printer/src/console_view/domain/models/console_options.dart';

abstract interface class IOptionsRepository {
  ConsoleOptions getCurrentOptions();
  void selectDate(int start, int end);
  void selectOption(OptionItem option);
  void selectTimeRange(int start, int end);
}
