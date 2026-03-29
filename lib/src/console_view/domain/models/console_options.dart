import 'package:flutter/material.dart';
import 'package:log_custom_printer/src/console_view/domain/models/option_item.dart';
export 'option_item.dart';
class ConsoleOptions {
   
  List<OptionItem> options = [];
  DateTimeRange? selectedDate;
  DateTimeRange? selectedTimeRange;
  
  ConsoleOptions({
     
    this.options = const [],
    this.selectedDate,
    this.selectedTimeRange,
  });
}
