import 'package:flutter/material.dart';
import 'package:log_custom_printer/src/log_printer_locator.dart';
import 'package:log_custom_printer/src/widgets/console_widget.dart';
import 'package:log_custom_printer/src/widgets/view/console_model.dart';
import 'package:provider/provider.dart';

class ConsoleView extends StatelessWidget {
  const ConsoleView({super.key});
  @override
  Widget build(BuildContext context) {
    return Provider<ConsoleModel>(
      create: (_) => ConsoleModel(logPrinterService: fetchLogPrinterService()),
      child: ConsoleWidget(),
    );
  }
}
