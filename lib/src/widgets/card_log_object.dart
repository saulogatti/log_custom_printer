import 'package:flutter/material.dart';
import 'package:log_custom_printer/src/logs_object/logger_object.dart';

/// Widget para exibir um log individual em um card.
class CardLogObject extends StatelessWidget {
  final LoggerObjectBase loggerObject;
  const CardLogObject({super.key, required this.loggerObject});

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
