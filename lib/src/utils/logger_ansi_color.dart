import 'package:json_annotation/json_annotation.dart';

part 'logger_ansi_color.g.dart';

/// {@template enum_colors}
/// ANSI color enum for terminal text formatting.
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

  /// ANSI background color code.
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

  /// ANSI foreground color code.
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

/// ANSI color helper for log messages.
///
/// {@category Utilities}
@JsonSerializable()
class LoggerAnsiColor {
  /// ANSI escape sequence prefix.
  static const ansiEsc = '\x1B[';

  /// ANSI reset sequence.
  static const ansiDefault = '${ansiEsc}0m';

  /// Selected ANSI color.
  final EnumAnsiColors enumAnsiColors;

  /// Class constructor.
  const LoggerAnsiColor({required this.enumAnsiColors});

  /// Creates an instance from JSON.
  factory LoggerAnsiColor.fromJson(Map<String, dynamic> json) => _$LoggerAnsiColorFromJson(json);

  /// Applies ANSI color to [msg].
  String call(String msg) {
    // ignore: unnecessary_brace_in_string_interps
    return '${this}$msg$ansiDefault';
  }

  /// Converts the instance to JSON.
  Map<String, dynamic> toJson() => _$LoggerAnsiColorToJson(this);

  /// Returns ANSI text color sequence.
  @override
  String toString() {
    final int fg = enumAnsiColors.getFgColor();
    return '$ansiEsc${fg}m';
  }
}
