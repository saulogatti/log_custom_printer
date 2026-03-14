/// Exibe as linhas de log em um terminal estilo console.
///
/// Utiliza texto monospace com uma coloração verde e fundo escuro.
library;

import 'package:flutter/material.dart';
import 'package:log_custom_printer/log_custom_printer.dart';
import 'package:log_custom_printer/src/widgets/card_log_object.dart';
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
          child: ListView.builder(
            itemCount: snapshot.length,
            itemBuilder: (context, index) {
              return CardLogObject(loggerObject: snapshot[index]);
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
