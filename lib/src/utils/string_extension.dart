/// Conjunto de caracteres que não são permitidos em nomes de arquivos.
final regexFileName = RegExp(r'[<>:"/\\|?*]');

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
