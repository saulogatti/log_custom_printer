import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:log_custom_printer/src/console_view/domain/models/message_log.dart';
import 'package:log_custom_printer/src/console_view/view/console/bloc/console_bloc.dart';
import 'package:log_custom_printer/src/console_view/view/console/bloc/console_state.dart';

class ConsoleWidget extends StatelessWidget {
  const ConsoleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withAlpha(200),
      padding: const EdgeInsets.all(8.0),
      child: BlocBuilder<ConsoleBloc, ConsoleState>(
        builder: (context, state) {
          switch (state) {
            case ConsoleInitial():
            case ConsoleLoading():
              return const Center(child: CircularProgressIndicator());
            case ConsoleError():
              return Center(child: Text(state.message));
            case ConsoleLoaded():
              final snapshot = state.logs;
              return ListView.separated(
                itemCount: snapshot.length,
                separatorBuilder: (context, index) =>
                    const Divider(height: 4.0),
                itemBuilder: (context, index) {
                  final logObject = snapshot[index];
                  final logStyle = TextStyle(
                    color: logObject.type.color,
                    fontFamily: 'monospace',
                    fontSize: 12,
                  );
                  return ListTile(
                    dense: true,
                    title: Text(logObject.title, style: logStyle),
                    subtitle: Text(logObject.message, style: logStyle),
                    leading: Icon(logObject.type.icon, color: logStyle.color),
                    trailing: Text(index.toString(), style: logStyle),
                  );
                },
              );
          }
        },
      ),
    );
  }
}

extension LogTypeExtension on LogType {
  Color get color {
    switch (this) {
      case LogType.info:
        return Colors.blue;
      case LogType.warning:
        return Colors.yellow;
      case LogType.error:
        return Colors.red;
      case LogType.debug:
        return Colors.green;
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
    }
  }
}
