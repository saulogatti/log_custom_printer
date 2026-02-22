final regexFileName = RegExp(r'[<>:"/\\|?*]');

extension StringExtension on String {
  /// Retorna a string formatada, removendo espaços em branco e convertendo para minúsculas.
  String get formattedName => trim().toLowerCase();

  /// Retorna uma versão sanitizada do nome do arquivo, substituindo caracteres inválidos por '_'.
  String get sanitizedFileName => replaceAll(regexFileName, '_');
}
