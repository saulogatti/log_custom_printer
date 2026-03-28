import 'package:flutter/material.dart';
import 'package:log_custom_printer/src/log_printer_locator.dart';
import 'package:log_custom_printer/src/widgets/console_widget.dart';

/// TODO implementar exportação de logs em json ou txt, fazer ordenação por data, tipo de log.
/// Outras ideias: Fazer TAG que o usuário possa colocar para organizar os logs, implementar busca por texto, tag ou tipo de log. Pensar sobre permitir colocar tamanho do console para não atrapalhar a visualização do app, implementar filtros para mostrar apenas tipos específicos de logs, implementar funcionalidade de pausar/retomar a captura de logs, adicionar opção para limpar os logs diretamente do console, permitir salvar os logs em um arquivo local para análise posterior, implementar suporte para múltiplas abas de console para diferentes categorias de logs, adicionar funcionalidade de destacar logs importantes ou críticos, permitir personalização do tema do console (cores, fontes, etc.), implementar integração com serviços de monitoramento externos (como Sentry ou Loggly) para enviar os logs em tempo real.
///
/// Tela de console para exibir logs usando o log_custom_printer.
class ConsoleView extends StatelessWidget {
  final VoidCallback onClose;
  const ConsoleView({super.key, required this.onClose});
  @override
  Widget build(BuildContext context) {
    final log = fetchLogPrinterService().cacheRepository;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Console'),
        leading: IconButton(icon: const Icon(Icons.close), onPressed: onClose),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              log.getAllLogs();
            },
          ),
          IconButton(
            onPressed: () {
              log.clearLogs();
            },
            icon: Icon(Icons.clear_all),
          ),
          IconButton(
            onPressed: () {
              // TODO implementar exportação de logs em json ou txt
              log.getAllLogs();
            },
            icon: Icon(Icons.share),
          ),
        ],
      ),
      body: ConsoleProvider(),
    );
  }
}
