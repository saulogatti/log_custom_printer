import 'package:flutter/material.dart';
import 'package:log_custom_printer/src/console_view/domain/models/option_item.dart';

/// Widget de lista selecionável de opções.
///
/// Exibe cada [OptionItem] de [options] como um [ListTile]. Ao tocar em
/// um item, [onOptionSelected] é chamado com a opção correspondente.
class SelectOptionWidget extends StatelessWidget {
  /// Lista de opções a exibir.
  final List<OptionItem> options;

  /// Callback invocado quando o usuário seleciona uma opção.
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
