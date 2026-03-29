import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:log_custom_printer/log_custom_printer.dart';
import 'package:log_custom_printer/src/console_view/domain/repository/message_repository.dart';
import 'package:log_custom_printer/src/console_view/view/console/bloc/console_bloc.dart';
import 'package:log_custom_printer/src/console_view/view/console/bloc/console_event.dart';

import 'console_widget.dart';

class ConsoleProvider extends StatelessWidget {
  final MessageRepository messageRepository;
  const ConsoleProvider({super.key, required this.messageRepository});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ConsoleBloc>(
      create: (context) => ConsoleBloc(messageRepository: messageRepository),
      child: const ConsoleView(),
    );
  }
}

/// TODO implementar exportação de logs em json ou txt, fazer ordenação por data, tipo de log.
/// Outras ideias: Fazer TAG que o usuário possa colocar para organizar os logs, implementar busca por texto, tag ou tipo de log. Pensar sobre permitir colocar tamanho do console para não atrapalhar a visualização do app, implementar filtros para mostrar apenas tipos específicos de logs, implementar funcionalidade de pausar/retomar a captura de logs, adicionar opção para limpar os logs diretamente do console, permitir salvar os logs em um arquivo local para análise posterior, implementar suporte para múltiplas abas de console para diferentes categorias de logs, adicionar funcionalidade de destacar logs importantes ou críticos, permitir personalização do tema do console (cores, fontes, etc.), implementar integração com serviços de monitoramento externos (como Sentry ou Loggly) para enviar os logs em tempo real.
///
/// Tela de console para exibir logs usando o log_custom_printer.
class ConsoleView extends StatefulWidget {
  final VoidCallback? onClose;

  const ConsoleView({super.key, this.onClose});

  @override
  State<ConsoleView> createState() => _ConsoleViewState();
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
        ],
      ),
      body: const ConsoleWidget(),
    );
  }

  void _sendLogsForTest() async {
    for (int i = 0; i < 100; i++) {
      DebugLog('Log $i').sendLog();
      await Future.delayed(const Duration(seconds: 1), () {});
    }
  }
}
