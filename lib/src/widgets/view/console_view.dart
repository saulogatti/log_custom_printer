import 'package:flutter/material.dart';
import 'package:log_custom_printer/src/log_printer_locator.dart';
import 'package:log_custom_printer/src/widgets/console_widget.dart';
import 'package:log_custom_printer/src/widgets/view/console_model.dart';
import 'package:provider/provider.dart';

/// Tela de console para exibir logs usando o log_custom_printer.
class ConsoleView extends StatelessWidget {
  final VoidCallback onClose;
  const ConsoleView({super.key, required this.onClose});
  @override
  Widget build(BuildContext context) {
    return Provider<ConsoleModel>(
      create: (_) => ConsoleModel(logPrinterService: fetchLogPrinterService()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Console'),
          leading: IconButton(icon: const Icon(Icons.close), onPressed: onClose),
        ),
        body: ConsoleWidget(),
      ),
    );
  }
}
