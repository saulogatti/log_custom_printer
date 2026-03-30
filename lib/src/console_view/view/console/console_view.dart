import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:log_custom_printer/src/console_view/application/application_injection.dart';
import 'package:log_custom_printer/src/console_view/domain/models/message_log.dart';
import 'package:log_custom_printer/src/console_view/domain/repository/i_options_repository.dart';
import 'package:log_custom_printer/src/console_view/domain/repository/message_repository.dart';
import 'package:log_custom_printer/src/console_view/view/console/bloc/console_bloc.dart';
import 'package:log_custom_printer/src/console_view/view/console/bloc/console_event.dart';
import 'package:log_custom_printer/src/console_view/view/console/bloc/console_state.dart';
import 'package:log_custom_printer/src/console_view/view/console/bloc/options/options_bloc.dart';
import 'package:log_custom_printer/src/console_view/view/console/bloc/options/options_state.dart';
import 'package:log_custom_printer/src/console_view/view/console/console_options_widget.dart';
import 'package:log_custom_printer/src/console_view/view/console/console_overlay.dart';
import 'package:log_custom_printer/src/console_view/view/widgets/log_card_widget.dart';
import 'package:log_custom_printer/src/domain/log_helpers/logger_class_mixin.dart';

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
  @override
  Widget build(BuildContext context) {
    final optionsBloc = context.read<OptionsBloc>();
    final consoleBloc = context.read<ConsoleBloc>();

    return BlocListener<OptionsBloc, OptionsState>(
      listenWhen: (previous, current) {
        if (current is! LoadedOptionsState) {
          return false;
        }

        if (previous is! LoadedOptionsState) {
          return true;
        }

        return previous.options.selectedDateTimeRange !=
                current.options.selectedDateTimeRange ||
            previous.options.isDateTimeFilterEnabled !=
                current.options.isDateTimeFilterEnabled;
      },
      listener: (context, state) {
        if (state is! LoadedOptionsState) {
          return;
        }

        consoleBloc.add(
          ConsoleUpdateDateTimeFilter(
            dateTimeRange: state.options.selectedDateTimeRange,
            isDateTimeFilterEnabled: state.options.isDateTimeFilterEnabled,
          ),
        );
      },
      child: Scaffold(
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
            BlocSelector<OptionsBloc, OptionsState, bool>(
              selector: (state) {
                if (state is! LoadedOptionsState) {
                  return false;
                }
                return state.options.isDateTimeFilterEnabled;
              },
              builder: (context, enabled) {
                final iconColor = enabled
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).iconTheme.color;

                return IconButton(
                  tooltip: enabled
                      ? 'Desativar filtro de data e hora'
                      : 'Ativar filtro de data e hora',
                  icon: Icon(
                    enabled ? Icons.filter_alt : Icons.filter_alt_off,
                    color: iconColor,
                  ),
                  onPressed: () {
                    context.read<OptionsBloc>().setDateTimeFilterEnabled(
                      !enabled,
                    );
                  },
                );
              },
            ),
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
                    builder: (context) => MultiBlocProvider(
                      providers: [
                        BlocProvider.value(value: optionsBloc),
                        BlocProvider.value(value: consoleBloc),
                      ],
                      child: const ConsoleOptionsWidget(),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.settings),
            ),
            IconButton(
              onPressed: () {
                ConsoleOverlayManager.show(
                  context,
                  appGetIt<MessageRepository>(),
                  const Size(300, 250),
                );
              },
              icon: const Icon(Icons.open_in_new),
            ),
            IconButton(
              onPressed: () {
                ConsoleOverlayManager.setSize(const Size(400, 260));
              },
              icon: const Icon(Icons.minimize),
            ),
            IconButton(
              onPressed: () {
                ConsoleOverlayManager.setSize(const Size(800, 520));
              },
              icon: const Icon(Icons.maximize),
            ),
          ],
        ),
        body: const SafeArea(
          bottom: true,
          minimum: EdgeInsets.only(bottom: 50),
          child: ConsoleWidget(),
        ),
        bottomSheet: BlocSelector<ConsoleBloc, ConsoleState, LogType>(
          selector: (state) => state.selectedLogType,
          builder: (context, selectedLogType) {
            return SegmentedButton(
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
                  icon: Icon(
                    LogType.warning.icon,
                    color: LogType.warning.color,
                  ),
                ),
                ButtonSegment(
                  value: LogType.error,
                  label: const Text('Error'),
                  icon: Icon(LogType.error.icon, color: LogType.error.color),
                ),
              ],
              selected: {selectedLogType},
              onSelectionChanged: (value) {
                context.read<ConsoleBloc>().add(
                  ConsoleFilterByType(value.first),
                );
              },
            );
          },
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    context.read<ConsoleBloc>().add(const ConsoleLoad());
    context.read<OptionsBloc>().loadOptions();
  }

  // TODO Remover método de teste
  Future<void> _sendLogsForTest() async {
    final testeLog = TesteLog();
    await testeLog.enviarLogs();
  }
}
