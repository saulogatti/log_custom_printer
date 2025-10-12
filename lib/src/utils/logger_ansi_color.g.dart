// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'logger_ansi_color.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoggerAnsiColor _$LoggerAnsiColorFromJson(Map<String, dynamic> json) =>
    LoggerAnsiColor(
      enumAnsiColors: $enumDecode(
        _$EnumAnsiColorsEnumMap,
        json['enumAnsiColors'],
      ),
    );

Map<String, dynamic> _$LoggerAnsiColorToJson(LoggerAnsiColor instance) =>
    <String, dynamic>{
      'enumAnsiColors': _$EnumAnsiColorsEnumMap[instance.enumAnsiColors]!,
    };

const _$EnumAnsiColorsEnumMap = {
  EnumAnsiColors.black: 'black',
  EnumAnsiColors.red: 'red',
  EnumAnsiColors.green: 'green',
  EnumAnsiColors.yellow: 'yellow',
  EnumAnsiColors.blue: 'blue',
  EnumAnsiColors.magenta: 'magenta',
  EnumAnsiColors.cyan: 'cyan',
  EnumAnsiColors.white: 'white',
};
