import 'package:log_custom_printer/src/console_view/domain/models/console_options.dart';

abstract interface class IOptionsRepository {
  void clearLogs();
  void exportLogs();
  ConsoleOptions getCurrentOptions();
  void selectDate(int start, int end);
  void selectOption(OptionItem option);
  void selectTimeRange(int start, int end);
}
