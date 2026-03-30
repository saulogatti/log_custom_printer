/// Item de opção exibido nas configurações do console visual.
///
/// Representa uma entrada selecionável na lista de opções, com um
/// [title] curto e uma [description] explicativa.
class OptionItem {
  /// Título curto da opção.
  final String title;

  /// Descrição detalhada da opção.
  final String description;

  /// Cria um [OptionItem] com [title] e [description] obrigatórios.
  OptionItem({required this.title, required this.description});
}
