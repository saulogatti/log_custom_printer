import 'package:flutter/material.dart';

class DateSelectWidget extends StatelessWidget {
  final String label;

  final DateTime? selectedDate;
  final ValueChanged<DateTimeRange?> onDateSelected;
  const DateSelectWidget({
    required this.label,
    required this.selectedDate,
    required this.onDateSelected,
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
                initialDateRange: selectedDate != null
                    ? DateTimeRange(start: selectedDate!, end: selectedDate!)
                    : null,
              );
              onDateSelected(picked);
            },
            child: Text(
              selectedDate != null
                  ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                  : 'Selecionar',
            ),
          ),
        ],
      ),
    );
  }
}
