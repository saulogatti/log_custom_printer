import 'package:flutter/material.dart';
import 'package:log_custom_printer/src/widgets/console_widget.dart';

/// Tela de console para exibir logs usando o log_custom_printer.
class ConsoleView extends StatelessWidget {
  final VoidCallback onClose;
  const ConsoleView({super.key, required this.onClose});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Console'),
        leading: IconButton(icon: const Icon(Icons.close), onPressed: onClose),
      ),
      body: ConsoleProvider(),
    );
  }
}
