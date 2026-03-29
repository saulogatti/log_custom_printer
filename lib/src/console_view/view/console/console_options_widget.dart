import 'package:flutter/material.dart';
import 'package:log_custom_printer/src/console_view/view/widgets/date_select_widget.dart';
import 'package:log_custom_printer/src/console_view/view/widgets/select_option_widget.dart';

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
                TimeSelectWidget(
                  label: "Seleciona Hora",
                  selectedTime: TimeOfDay.now(),
                  onTimeSelected: (time) {
                    print('Hora selecionada: $time');
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
