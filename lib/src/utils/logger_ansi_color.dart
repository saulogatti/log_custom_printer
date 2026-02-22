import 'package:json_annotation/json_annotation.dart';

part 'logger_ansi_color.g.dart';

/// {@template enum_colors}
/// Enumeração de cores ANSI disponíveis para formatação de texto em terminais.
///
/// Cores disponíveis:
/// ```dart
/// EnumAnsiColors.black;   // Preto
/// EnumAnsiColors.red;     // Vermelho
/// EnumAnsiColors.green;   // Verde
/// EnumAnsiColors.yellow;  // Amarelo
/// EnumAnsiColors.blue;    // Azul
/// EnumAnsiColors.magenta; // Magenta
/// EnumAnsiColors.cyan;    // Ciano
/// EnumAnsiColors.white;   // Branco
/// ```
///
/// Cada cor possui métodos para obter:
/// - Código ANSI para cor de fundo (`getBgColor`)
/// - Código ANSI para cor de texto (`getFgColor`)
/// - Cor equivalente no Flutter (`getWidgetColor`)
/// {@endtemplate}
enum EnumAnsiColors {
  black,
  red,
  green,
  yellow,
  blue,
  magenta,
  cyan,
  white;

  /// Retorna o código ANSI para a cor de fundo.
  int getBgColor() {
    switch (this) {
      case EnumAnsiColors.black:
        return 40;
      case EnumAnsiColors.red:
        return 41;
      case EnumAnsiColors.green:
        return 42;
      case EnumAnsiColors.yellow:
        return 43;
      case EnumAnsiColors.blue:
        return 44;
      case EnumAnsiColors.magenta:
        return 45;
      case EnumAnsiColors.cyan:
        return 46;
      case EnumAnsiColors.white:
        return 47;
    }
  }

  /// Retorna o código ANSI para a cor de texto.
  int getFgColor() {
    switch (this) {
      case EnumAnsiColors.black:
        return 30;
      case EnumAnsiColors.red:
        return 31;
      case EnumAnsiColors.green:
        return 32;
      case EnumAnsiColors.yellow:
        return 33;
      case EnumAnsiColors.blue:
        return 34;
      case EnumAnsiColors.magenta:
        return 35;
      case EnumAnsiColors.cyan:
        return 36;
      case EnumAnsiColors.white:
        return 37;
    }
  }
}

/// Classe para manipulação de cores ANSI em logs.
///
/// Esta classe permite formatar mensagens com cores ANSI para exibição em terminais.
///
/// Exemplo de uso:
/// ```dart
/// final loggerColor = LoggerAnsiColor(enumAnsiColors: EnumAnsiColors.red);
/// print(loggerColor('Mensagem em vermelho'));
/// ```
///
/// Para serialização/deserialização, utilize os métodos `toJson` e `fromJson`.
@JsonSerializable()
class LoggerAnsiColor {
  /// Sequência de controle ANSI para iniciar configurações no terminal.
  static const ansiEsc = '\x1B[';

  /// Código ANSI para resetar todas as configurações de cor no terminal.
  static const ansiDefault = '${ansiEsc}0m';

  /// Cor ANSI associada.
  final EnumAnsiColors enumAnsiColors;

  /// Construtor da classe.
  const LoggerAnsiColor({required this.enumAnsiColors});

  /// Cria uma instância a partir de um JSON.
  factory LoggerAnsiColor.fromJson(Map<String, dynamic> json) => _$LoggerAnsiColorFromJson(json);

  /// Aplica a cor ANSI à mensagem fornecida.
  ///
  /// Exemplo:
  /// ```dart
  /// final loggerColor = LoggerAnsiColor(enumAnsiColors: EnumAnsiColors.green);
  /// print(loggerColor('Mensagem em verde'));
  /// ```
  String call(String msg) {
    // ignore: unnecessary_brace_in_string_interps
    return '${this}$msg$ansiDefault';
  }

  /// Converte a instância para JSON.
  Map<String, dynamic> toJson() => _$LoggerAnsiColorToJson(this);

  /// Retorna a sequência ANSI para a cor de texto configurada.
  @override
  String toString() {
    final int fg = enumAnsiColors.getFgColor();
    return '$ansiEsc${fg}m';
  }
}
