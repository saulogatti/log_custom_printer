import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:log_custom_printer/src/console_view/view/console/bloc/options/options_bloc.dart';
import 'package:log_custom_printer/src/console_view/view/console/bloc/options/options_state.dart';
import 'package:log_custom_printer/src/console_view/view/widgets/date_select_widget.dart';
import 'package:log_custom_printer/src/console_view/view/widgets/select_option_widget.dart';
import 'package:log_custom_printer/src/console_view/view/widgets/time_range_select_widget.dart';

class ConsoleOptionsWidget extends StatefulWidget {
  const ConsoleOptionsWidget({super.key});

  @override
  State<ConsoleOptionsWidget> createState() => _ConsoleOptionsWidgetState();
}

class _ConsoleOptionsWidgetState extends State<ConsoleOptionsWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Opções do Console'),
        leading: BackButton(onPressed: () => Navigator.of(context).pop()),
      ),
      body: BlocBuilder<OptionsBloc, OptionsState>(
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () => context.read<OptionsBloc>().clearLogs(),
                      child: const Text('Limpar Logs'),
                    ),
                    ElevatedButton(
                      onPressed: () => context.read<OptionsBloc>().exportLogs(),
                      child: const Text('Exportar Logs'),
                    ),
                    DateSelectWidget(
                      label: "Seleciona Data",
                      // selectedDate: DateTime.now(),
                      onDateSelected: (date) {
                        print('Data selecionada: $date');
                      },
                    ),
                    TimeRangeSelectWidget(
                      initialDateTimeRange: DateTimeRange(
                        start: DateTime.now(),
                        end: DateTime.now(),
                      ),
                      label: 'Selecionar intervalo de horário',
                      onTimeRangeSelected: (range) {
                        // Lógica para lidar com o intervalo selecionado
                        print(
                          " Intervalo selecionado: ${range?.start} - ${range?.end}",
                        );
                      },
                    ),
                  ],
                ),
              ),
              SelectOptionWidget(
                options: (state as UpdatedOptionsState).options.options,
                onOptionSelected: (option) =>
                    context.read<OptionsBloc>().selectOption(option),
              ),
            ],
          );
        },
      ),
    );
  }
}
