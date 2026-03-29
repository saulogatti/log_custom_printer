import 'package:flutter/material.dart';

class DateSelectWidget extends StatelessWidget {
  final String label;

  final DateTime? selectedDate;
  final ValueChanged<DateTime?> onDateSelected;
  const DateSelectWidget({
    required this.label,
    required this.selectedDate,
    required this.onDateSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
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
    );
  }
}
