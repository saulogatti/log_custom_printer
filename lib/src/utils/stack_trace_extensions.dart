import 'package:log_custom_printer/src/utils/logger_ansi_color.dart';

/// Regex para detectar linhas de stack trace do browser.
final _browserStackTraceRegex = RegExp(r'^(?:package:)?(dart:\S+|\S+)');

/// Regex para detectar linhas de stack trace de dispositivo.
final _deviceStackTraceRegex = RegExp(r'#[0-9]+\s+(.+) \((\S+)\)');

/// Extension para formatação e manipulação de stack traces.
///
/// Fornece métodos para formatar stack traces de forma legível, filtrar
/// linhas irrelevantes (framework interno, Dart SDK) e converter para
/// estruturas de dados convenientes.
///
/// {@category Utilities}
///
/// Exemplo de uso:
/// ```dart
/// try {
///   // código que pode falhar
/// } catch (error, stackTrace) {
///   // Formatar stack trace com cor
///   final formatted = stackTrace.formatStackTrace(
///     LoggerAnsiColor(enumAnsiColors: EnumAnsiColors.red),
///     10, // máximo de linhas
///   );
///   
///   // Ou converter para Map
///   final map = stackTrace.stackInMap(8);
/// }
/// ```
extension StackTraceSdk on StackTrace {
  /// Formata o stack trace removendo linhas irrelevantes e aplicando cor opcional.
  ///
  /// [sdkLevel] é a cor ANSI a ser aplicada (opcional).
  /// [linesCount] é o número máximo de linhas a incluir.
  ///
  /// Retorna uma string formatada com o stack trace limpo e numerado.
  String formatStackTrace(LoggerAnsiColor? sdkLevel, int linesCount) {
    final List<String> lines = toString()
        .split('\n')
        .where(
          (line) =>
              !_discardDeviceStacktraceLine(line) &&
              line.isNotEmpty &&
              !_discardBrowserStacktraceLine(line),
        )
        .toList();
    final List<String> formatted = [];

    int stackTraceLength = lines.length;
    if (stackTraceLength > linesCount) {
      stackTraceLength = linesCount;
    }

    for (int count = 0; count < stackTraceLength; count++) {
      final line = lines[count].replaceFirst(RegExp(r'#\d+\s+'), '');
      if (sdkLevel != null) {
        formatted.add(sdkLevel.call('#$count $line'));
      } else {
        formatted.add('#$count $line');
      }
    }

    if (formatted.isEmpty) {
      return toString();
    } else {
      return formatted.join(' \n ');
    }
  }

  /// Converte o stack trace em um Map para fácil serialização.
  ///
  /// [linesCount] é o número máximo de linhas a incluir (padrão: 8).
  ///
  /// Retorna um Map onde as chaves são os números de linha (#0, #1, etc)
  /// e os valores são as descrições das linhas do stack trace.
  ///
  /// Exemplo de retorno:
  /// ```dart
  /// {
  ///   '#0': 'MinhaClasse.meuMetodo (package:meu_app/arquivo.dart:42:5)',
  ///   '#1': 'OutraClasse.outro (package:meu_app/outro.dart:10:12)',
  ///   // ...
  /// }
  /// ```
  Map<String, dynamic> stackInMap([int linesCount = 8]) {
    final Map<String, String> map = {};
    final List<String> lines = _getLines();
    final List<String> formatted = [];

    int stackTraceLength = lines.length;
    if (stackTraceLength > linesCount) {
      stackTraceLength = linesCount;
    }

    for (int count = 0; count < stackTraceLength; count++) {
      final line = lines[count].replaceFirst(RegExp(r'#\d+\s+'), '');
      map['#$count'] = line;
      formatted.add('#$count $line');
    }
    return map;
  }

  bool _discardBrowserStacktraceLine(String line) {
    final match = _browserStackTraceRegex.matchAsPrefix(line);
    if (match == null) {
      return false;
    }
    final segment = match.group(1)!;
    if (segment.startsWith('package:logger') ||
        segment.startsWith('dart:') ||
        !segment.startsWith("#")) {
      return true;
    }
    return false;
  }

  bool _discardDeviceStacktraceLine(String line) {
    final match = _deviceStackTraceRegex.matchAsPrefix(line);
    if (match == null) {
      return false;
    }
    final segment = match.group(2)!;
    if (segment.startsWith('package:logger') ||
        segment.startsWith('package:flutter') ||
        segment.startsWith('dart:')) {
      return true;
    }

    return false;
  }

  List<String> _getLines() {
    return toString().split('\n').where((line) {
      return line.isNotEmpty &&
          !_discardDeviceStacktraceLine(line) &&
          !_discardBrowserStacktraceLine(line);
    }).toList();
  }
}
