/// Conjunto de caracteres que não são permitidos em nomes de arquivos.
/// Inclui caracteres proibidos em Windows/Unix e caracteres de controle/nulos.
final regexFileName = RegExp(r'[<>:"/\\|?*\x00-\x1F\x7F]');

/// Extensões utilitárias para a classe [String].
///
/// {@category Utilities}
extension StringExtension on String {
  /// Retorna a string formatada, removendo espaços em branco e convertendo para minúsculas.
  String get formattedName => trim().toLowerCase();

  /// Retorna uma versão sanitizada do nome do arquivo, substituindo caracteres inválidos por '_'.
  ///
  /// Útil para gerar nomes de arquivos de log seguros a partir de strings arbitrárias.
  String get sanitizedFileName => replaceAll(regexFileName, '_');
}
