import 'package:flutter/material.dart';
import 'package:log_custom_printer/src/domain/logs_object/logger_object.dart';

/// Widget para exibir um log individual em um card.
class LogCardWidget extends StatelessWidget {
  final LoggerObjectBase loggerObject;
  const LogCardWidget({super.key, required this.loggerObject});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(loggerObject.getStartLog(false)),
        subtitle: Text(loggerObject.getMessage(false)),
      ),
    );
  }
}
