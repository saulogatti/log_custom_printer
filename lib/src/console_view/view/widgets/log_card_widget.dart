import 'package:flutter/material.dart';
import 'package:log_custom_printer/src/console_view/domain/models/message_log.dart';

/// Widget para exibir um log individual em um card.
class LogCardWidget extends StatelessWidget {
  final MessageLog messageLog;
  const LogCardWidget({required this.messageLog, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: Icon(messageLog.type.icon, color: messageLog.type.color),
        title: Text(
          messageLog.title,
          style: theme.titleLarge?.copyWith(color: messageLog.type.color),
        ),
        subtitle: Text(
          messageLog.message,
          style: theme.bodyMedium?.copyWith(color: messageLog.type.color),
        ),
      ),
    );
  }
}

extension LogTypeExtension on LogType {
  Color get color {
    switch (this) {
      case LogType.info:
        return Colors.white;
      case LogType.warning:
        return Colors.green;
      case LogType.error:
        return Colors.red;
      case LogType.debug:
        return Colors.yellow;
      case LogType.all:
        return Colors.black;
    }
  }

  IconData get icon {
    switch (this) {
      case LogType.info:
        return Icons.info;
      case LogType.warning:
        return Icons.warning;
      case LogType.error:
        return Icons.error;
      case LogType.debug:
        return Icons.bug_report;
      case LogType.all:
        return Icons.all_inclusive;
    }
  }
}
