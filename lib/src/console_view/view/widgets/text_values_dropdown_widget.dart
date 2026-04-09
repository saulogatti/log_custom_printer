import 'package:flutter/material.dart';

/// Dropdown reutilizável para seleção de um valor textual em uma lista.
class TextValuesDropdownWidget extends StatelessWidget {
  final String label;
  final List<String> values;
  final String selectedValue;
  final ValueChanged<String> onChanged;

  const TextValuesDropdownWidget({
    required this.label,
    required this.values,
    required this.selectedValue,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label),
        const SizedBox(width: 8),
        DropdownButton<String>(
          value: selectedValue,
          items: values
              .map(
                (value) =>
                    DropdownMenuItem<String>(value: value, child: Text(value)),
              )
              .toList(),
          onChanged: (String? value) {
            if (value != null) onChanged(value);
          },
        ),
      ],
    );
  }
}
