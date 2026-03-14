import 'package:flutter/material.dart';
import 'package:log_custom_printer/log_custom_printer.dart';

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
