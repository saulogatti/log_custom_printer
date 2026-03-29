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
          switch (state) {
            case ErrorOptionsState():
              return Center(
                child: Text('Erro ao carregar opções: ${(state).message}'),
              );
            case InitialOptionsState():
            case LoadingOptionsState():
              return const Center(child: CircularProgressIndicator());
            case LoadedOptionsState():
              final options = state.options;
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        DateSelectWidget(
                          label: "Seleciona Data",
                          selectedDate: options.selectedDate,
                          onDateSelected: (date) {
                            // Lógica para lidar com a data selecionada
                            context.read<OptionsBloc>().selectDate(date);
                          },
                        ),
                        TimeRangeSelectWidget(
                          initialDateTimeRange: options.selectedTimeRange,
                          label: 'Selecionar intervalo de horário',
                          onTimeRangeSelected: (range) {
                            // Lógica para lidar com o intervalo selecionado
                            context.read<OptionsBloc>().selectTimeRange(range);
                          },
                        ),
                      ],
                    ),
                  ),
                  SelectOptionWidget(
                    options: options.options,
                    onOptionSelected: (option) =>
                        context.read<OptionsBloc>().selectOption(option),
                  ),
                ],
              );
          }
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    context.read<OptionsBloc>().loadOptions();
  }
}
