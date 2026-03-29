import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:log_custom_printer/log_custom_printer.dart';
import 'package:log_custom_printer/src/console_view/domain/models/message_log.dart';
import 'package:log_custom_printer/src/console_view/domain/repository/i_options_repository.dart';
import 'package:log_custom_printer/src/console_view/domain/repository/message_repository.dart';
import 'package:log_custom_printer/src/console_view/view/console/bloc/console_bloc.dart';
import 'package:log_custom_printer/src/console_view/view/console/bloc/console_event.dart';
import 'package:log_custom_printer/src/console_view/view/console/bloc/options/options_bloc.dart';
import 'package:log_custom_printer/src/console_view/view/console/console_options_widget.dart';
import 'package:log_custom_printer/src/console_view/view/widgets/log_card_widget.dart';

import 'console_widget.dart';

class ConsoleProvider extends StatelessWidget {
  final MessageRepository messageRepository;
  final IOptionsRepository optionsRepository;
  const ConsoleProvider({
    required this.messageRepository,
    required this.optionsRepository,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ConsoleBloc>(
          create: (context) =>
              ConsoleBloc(messageRepository: messageRepository),
        ),
        BlocProvider(
          create: (context) =>
              OptionsBloc(optionsRepository: optionsRepository),
        ),
      ],
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

// TODO Remover classe de teste
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
  LogType _selectedLogType = LogType.debug;

  @override
  Widget build(BuildContext context) {
    final consoleBloc = context.read<OptionsBloc>();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      extendBodyBehindAppBar: true,
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
                  builder: (context) => BlocProvider.value(
                    value: consoleBloc,
                    child: const ConsoleOptionsWidget(),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: const SafeArea(
        bottom: true,
        minimum: EdgeInsets.only(bottom: 50),
        child: ConsoleWidget(),
      ),
      bottomSheet: SegmentedButton(
        expandedInsets: const EdgeInsets.all(8),
        segments: [
          ButtonSegment(
            value: LogType.debug,
            label: const Text('Debug'),
            icon: Icon(LogType.debug.icon, color: LogType.debug.color),
          ),
          ButtonSegment(
            value: LogType.info,
            label: const Text('Info'),
            icon: Icon(LogType.info.icon, color: LogType.info.color),
          ),
          ButtonSegment(
            value: LogType.warning,
            label: const Text('Warning'),
            icon: Icon(LogType.warning.icon, color: LogType.warning.color),
          ),
          ButtonSegment(
            value: LogType.error,
            label: const Text('Error'),
            icon: Icon(LogType.error.icon, color: LogType.error.color),
          ),
        ],
        selected: {_selectedLogType},
        onSelectionChanged: (value) {
          context.read<ConsoleBloc>().add(ConsoleFilterByType(value.first));
          _selectedLogType = value.first;
          setState(() {});
        },
      ),
    );
  }

  // TODO Remover método de teste
  Future<void> _sendLogsForTest() async {
    final testeLog = TesteLog();
    await testeLog.enviarLogs();
  }
}
