import 'package:flutter/material.dart';

class DateSelectWidget extends StatelessWidget {
  final String label;

  final DateTimeRange? selectedDate;
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
              onDateSelected(picked);
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
