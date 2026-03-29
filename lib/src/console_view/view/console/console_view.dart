import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:log_custom_printer/log_custom_printer.dart';
import 'package:log_custom_printer/src/console_view/domain/repository/message_repository.dart';
import 'package:log_custom_printer/src/console_view/view/console/bloc/console_bloc.dart';
import 'package:log_custom_printer/src/console_view/view/console/bloc/console_event.dart';
import 'package:log_custom_printer/src/console_view/view/console/console_options_widget.dart';

import 'console_widget.dart';

class ConsoleProvider extends StatelessWidget {
  final MessageRepository messageRepository;
  const ConsoleProvider({required this.messageRepository, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ConsoleBloc>(
      create: (context) => ConsoleBloc(messageRepository: messageRepository),
      child: const ConsoleView(),
    );
  }
}

/// Tela de console para exibir logs usando o log_custom_printer.
class ConsoleView extends StatefulWidget {
  final VoidCallback? onClose;
  const ConsoleView({super.key, this.onClose});

  @override
  State<ConsoleView> createState() => _ConsoleViewState();
}

class TesteLog with LoggerClassMixin {
  Future<void> enviarLogs() async {
    for (int i = 0; i < 10; i++) {
      logDebug('Log $i');
      logWarning('Log de aviso $i');
      logInfo('Log de informação $i');
      await Future.delayed(const Duration(seconds: 1), () {});
    }
  }
}

class _ConsoleViewState extends State<ConsoleView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Console'),
        leading: widget.onClose != null
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: widget.onClose,
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ConsoleBloc>().add(const ConsoleLoad());
            },
          ),
          IconButton(
            onPressed: () {
              context.read<ConsoleBloc>().add(const ConsoleClear());
            },
            icon: const Icon(Icons.clear_all),
          ),
          IconButton(
            onPressed: () {
              // TODO implementar exportação de logs em json ou txt
              _sendLogsForTest();
            },
            icon: const Icon(Icons.share),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => const ConsoleOptionsWidget(),
                ),
              );
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: const ConsoleWidget(),
    );
  }

  void _sendLogsForTest() async {
    final testeLog = TesteLog();
    await testeLog.enviarLogs();
  }
}
