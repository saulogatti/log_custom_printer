import 'package:flutter/material.dart';

/// Widget para seleção de um intervalo de datas via [showDateRangePicker].
///
/// Exibe um [label] e um botão com o intervalo selecionado (ou "Selecionar"
/// se nenhum intervalo estiver definido). Ao confirmar, [onDateSelected] é
/// chamado com o novo [DateTimeRange].
class DateSelectWidget extends StatelessWidget {
  /// Rótulo exibido à esquerda do botão.
  final String label;

  /// Intervalo atualmente selecionado (nulo se nenhum).
  final DateTimeRange? selectedDate;

  /// Callback invocado quando o usuário confirma um novo intervalo de datas.
  final ValueChanged<DateTimeRange?> onDateSelected;
  const DateSelectWidget({
    required this.label,
    required this.onDateSelected,
    this.selectedDate,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Row(
        children: [
          Text(label),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () async {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2000, 1, 1, 0, 0, 0),
                lastDate: DateTime(2100, 12, 31, 23, 59, 59),
                initialDateRange: selectedDate,
              );
              if (picked != null) {
                onDateSelected(picked);
              }
            },
            child: Text(
              selectedDate != null
                  ? '${selectedDate!.start.day}/${selectedDate!.start.month}/${selectedDate!.start.year} - ${selectedDate!.end.day}/${selectedDate!.end.month}/${selectedDate!.end.year}'
                  : 'Selecionar',
            ),
          ),
        ],
      ),
    );
  }
}
