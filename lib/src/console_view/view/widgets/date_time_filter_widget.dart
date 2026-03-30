import 'package:flutter/material.dart';
import 'package:log_custom_printer/src/console_view/view/widgets/date_select_widget.dart';
import 'package:log_custom_printer/src/console_view/view/widgets/time_range_select_widget.dart';

/// Callback executado quando o filtro temporal for alterado.
///
/// - [dateTimeRange] é o intervalo unificado data/hora.
/// - [isEnabled] define se o filtro deve ser aplicado imediatamente.
typedef DateTimeFilterChanged =
    void Function(DateTimeRange? dateTimeRange, bool isEnabled);

/// Componente único para configuração de filtro por data/hora no console.
///
/// O componente mantém uma única fonte de entrada para intervalo temporal e
/// um checkbox para ativar/desativar o filtro.
class DateTimeFilterWidget extends StatelessWidget {
  final DateTimeRange? selectedDateTimeRange;
  final bool isEnabled;
  final DateTimeFilterChanged onChanged;

  const DateTimeFilterWidget({
    required this.selectedDateTimeRange,
    required this.isEnabled,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filtro de data e hora',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              value: isEnabled,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text('Ativar filtro imediatamente'),
              onChanged: (value) {
                onChanged(selectedDateTimeRange, value ?? false);
              },
            ),
            const SizedBox(height: 4),
            DateSelectWidget(
              label: 'Selecionar intervalo de data',
              selectedDate: selectedDateTimeRange,
              onDateSelected: (dateRange) {
                final merged = _mergeDateRange(
                  dateRange,
                  selectedDateTimeRange,
                );
                if (merged == null) {
                  return;
                }
                if (!_isValidDateTimeRange(merged)) {
                  _showInvalidRangeFeedback(context);
                  return;
                }
                onChanged(merged, true);
              },
            ),
            const SizedBox(height: 8),
            TimeRangeSelectWidget(
              label: 'Selecionar intervalo de horário',
              initialDateTimeRange: selectedDateTimeRange,
              onTimeRangeSelected: (timeRange) {
                final merged = _mergeTimeRange(
                  timeRange,
                  selectedDateTimeRange,
                );
                if (merged == null) {
                  return;
                }
                if (!_isValidDateTimeRange(merged)) {
                  _showInvalidRangeFeedback(context);
                  return;
                }
                onChanged(merged, true);
              },
            ),
          ],
        ),
      ),
    );
  }

  bool _isValidDateTimeRange(DateTimeRange range) {
    return range.end.difference(range.start).inMilliseconds > 0;
  }

  DateTimeRange? _mergeDateRange(
    DateTimeRange? selectedDate,
    DateTimeRange? currentDateTimeRange,
  ) {
    if (selectedDate == null) {
      return currentDateTimeRange;
    }

    final now = DateTime.now();
    final currentStart = currentDateTimeRange?.start ?? now;
    final currentEnd =
        currentDateTimeRange?.end ?? now.add(const Duration(hours: 1));

    return DateTimeRange(
      start: DateTime(
        selectedDate.start.year,
        selectedDate.start.month,
        selectedDate.start.day,
        currentStart.hour,
        currentStart.minute,
        currentStart.second,
      ),
      end: DateTime(
        selectedDate.end.year,
        selectedDate.end.month,
        selectedDate.end.day,
        currentEnd.hour,
        currentEnd.minute,
        currentEnd.second,
      ),
    );
  }

  DateTimeRange? _mergeTimeRange(
    DateTimeRange? selectedTimeRange,
    DateTimeRange? currentDateTimeRange,
  ) {
    if (selectedTimeRange == null) {
      return currentDateTimeRange;
    }

    final now = DateTime.now();
    final baseStart = currentDateTimeRange?.start ?? now;
    final baseEnd =
        currentDateTimeRange?.end ?? now.add(const Duration(hours: 1));

    return DateTimeRange(
      start: DateTime(
        baseStart.year,
        baseStart.month,
        baseStart.day,
        selectedTimeRange.start.hour,
        selectedTimeRange.start.minute,
        selectedTimeRange.start.second,
      ),
      end: DateTime(
        baseEnd.year,
        baseEnd.month,
        baseEnd.day,
        selectedTimeRange.end.hour,
        selectedTimeRange.end.minute,
        selectedTimeRange.end.second,
      ),
    );
  }

  void _showInvalidRangeFeedback(BuildContext context) {
    const message =
        'Data/hora final inválida. Ela deve ser maior que a data/hora inicial.';

    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text(message)));
  }
}
