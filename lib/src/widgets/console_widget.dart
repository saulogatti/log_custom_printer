/// Exibe as linhas de log em um terminal estilo console.
///
/// Utiliza texto monospace com uma coloração verde e fundo escuro.
library;

import 'package:flutter/material.dart';
import 'package:log_custom_printer/log_custom_printer.dart';
import 'package:log_custom_printer/src/log_printer_locator.dart';
import 'package:log_custom_printer/src/widgets/view/console_model.dart';
import 'package:provider/provider.dart';

class ConsoleProvider extends StatelessWidget {
  const ConsoleProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableProvider<ConsoleModelNotifier>(
      create: (context) =>
          ConsoleModelNotifier(logPrinterService: fetchLogPrinterService()),
      child: ConsoleWidget(),
    );
  }
}

class ConsoleWidget extends StatelessWidget {
  const ConsoleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final logs = context.read<ConsoleModelNotifier>();
    return Container(
      color: Colors.black.withAlpha(200),
      padding: const EdgeInsets.all(8.0),
      child: ListenableBuilder(
        listenable: logs,
        builder: (context, child) {
          final snapshot = logs.logs;
          return ListView.separated(
            itemCount: snapshot.length,
            separatorBuilder: (context, index) => const Divider(height: 4.0),
            itemBuilder: (context, index) {
              final logObject = snapshot[index];
              final logStyle = TextStyle(
                color: logObject.getColor().enumAnsiColors.toColor(),
                fontFamily: 'monospace',
                fontSize: 12,
              );
              return ListTile(
                dense: true,
                title: Text(logObject.getStartLog(false), style: logStyle),
                subtitle: Text(logObject.getMessage(false), style: logStyle),
                leading: Icon(logObject.getIcon(), color: logStyle.color),
                trailing: Text(index.toString(), style: logStyle),
              );
            },
          );
        },
      ),
    );
  }
}

extension EnumColorExtension on EnumAnsiColors {
  Color toColor() {
    switch (this) {
      case EnumAnsiColors.black:
        return Colors.black;
      case EnumAnsiColors.red:
        return Colors.red;
      case EnumAnsiColors.green:
        return Colors.green;
      case EnumAnsiColors.yellow:
        return Colors.yellow;
      case EnumAnsiColors.blue:
        return Colors.blue;
      case EnumAnsiColors.magenta:
        return Colors.purple;
      case EnumAnsiColors.cyan:
        return Colors.cyan;
      case EnumAnsiColors.white:
        return Colors.white;
    }
  }
}

extension LoggerObjectBaseExtension on LoggerObject {
  IconData getIcon() {
    switch (this) {
      case DebugLog():
        return Icons.bug_report;
      case InfoLog():
        return Icons.info;
      case WarningLog():
        return Icons.warning;
      case ErrorLog():
        return Icons.error;
      case LoggerObjectBase():
        return Icons.description;
    }
  }
}
