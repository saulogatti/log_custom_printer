/// Exibe as linhas de log em um terminal estilo console.
///
/// Utiliza texto monospace com uma coloração verde e fundo escuro.
library;

import 'package:flutter/material.dart';
import 'package:log_custom_printer/log_custom_printer.dart';
import 'package:log_custom_printer/src/widgets/view/console_model.dart';
import 'package:provider/provider.dart';

class ConsoleWidget extends StatelessWidget {
  const ConsoleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final logs = context.watch<ConsoleModel>().logs;
    return ValueListenableBuilder<List<LoggerObjectBase>>(
      valueListenable: logs,
      builder: (context, snapshot, _) {
        return Container(
          color: Colors.black.withAlpha(200),
          padding: const EdgeInsets.all(8.0),
          child: ListView.separated(
            itemCount: snapshot.length,
            separatorBuilder: (context, index) => const Divider(height: 4.0),
            itemBuilder: (context, index) {
              final logObject = snapshot[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      logObject.getStartLog(false),
                      style: TextStyle(
                        color: logObject.getColor().enumAnsiColors.toColor(),
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      logObject.getMessage(false),
                      style: TextStyle(
                        color: logObject.getColor().enumAnsiColors.toColor(),
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
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
