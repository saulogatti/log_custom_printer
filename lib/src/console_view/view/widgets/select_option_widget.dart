import 'package:flutter/material.dart';

class OptionItem {
  final String title;
  final String description;
  OptionItem({required this.title, required this.description});
}

class SelectOptionWidget extends StatelessWidget {
  final List<OptionItem> options;
  final void Function(OptionItem) onOptionSelected;
  const SelectOptionWidget({
    required this.options,
    required this.onOptionSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SliverList.separated(
      itemBuilder: (context, index) {
        final option = options[index];
        return ListTile(
          title: Text(option.title),
          subtitle: Text(option.description),
          onTap: () => onOptionSelected(option),
        );
      },
      separatorBuilder: (context, index) => const Divider(),
      itemCount: options.length,
    );
  }
}
