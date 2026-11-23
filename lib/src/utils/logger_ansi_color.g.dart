// GENERATED CODE - DO NOT MODIFY BY HAND

// coverage:ignore-file
// ignore_for_file: document_ignores, unnecessary_null_checks, specify_nonobvious_property_types, cast_nullable_to_non_nullable

part of 'logger_ansi_color.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoggerAnsiColor _$LoggerAnsiColorFromJson(Map<String, dynamic> json) =>
    $checkedCreate('LoggerAnsiColor', json, ($checkedConvert) {
      final val = LoggerAnsiColor(
        enumAnsiColors: $checkedConvert(
          'enumAnsiColors',
          (v) => $enumDecode(_$EnumAnsiColorsEnumMap, v),
        ),
      );
      return val;
    });

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
