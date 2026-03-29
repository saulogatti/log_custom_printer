import 'package:flutter/material.dart';
import 'package:log_custom_printer/src/console_view/domain/models/message_log.dart';

/// Widget para exibir um log individual em um card.
class LogCardWidget extends StatelessWidget {
  final MessageLog messageLog;
  const LogCardWidget({super.key, required this.messageLog});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(messageLog.title),
        subtitle: Text(messageLog.message),
      ),
    );
  }
}
