import 'package:flutter/material.dart';
import 'package:log_custom_printer/src/console_view/view/widgets/date_select_widget.dart';
import 'package:log_custom_printer/src/console_view/view/widgets/select_option_widget.dart';
import 'package:log_custom_printer/src/console_view/view/widgets/time_range_select_widget.dart';

class ConsoleOptions {
  final VoidCallback? onClearLogs;

  final VoidCallback? onExportLogs;
  List<OptionItem> options = [];

  void Function(OptionItem) onSelectedOption;
  ConsoleOptions({
    required this.onSelectedOption,
    this.onClearLogs,
    this.onExportLogs,
    this.options = const [],
  });
}

class ConsoleOptionsWidget extends StatefulWidget {
  final ConsoleOptions option;
  const ConsoleOptionsWidget({required this.option, super.key});

  @override
  State<ConsoleOptionsWidget> createState() => _ConsoleOptionsWidgetState();
}

class _ConsoleOptionsWidgetState extends State<ConsoleOptionsWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Opções do Console'),
        leading: BackButton(onPressed: () => Navigator.of(context).pop()),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: widget.option.onClearLogs,
                  child: Text('Limpar Logs'),
                ),
                ElevatedButton(
                  onPressed: widget.option.onExportLogs,
                  child: Text('Exportar Logs'),
                ),
                DateSelectWidget(
                  label: "Seleciona Data",
                  selectedDate: DateTime.now(),
                  onDateSelected: (date) {
                    print('Data selecionada: $date');
                  },
                ),
                TimeRangeSelectWidget(
                  initialStartDateTime: DateTime.now(),
                  initialEndDateTime: DateTime.now(),
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
            options: widget.option.options,
            onOptionSelected: widget.option.onSelectedOption,
          ),
        ],
      ),
    );
  }
}
