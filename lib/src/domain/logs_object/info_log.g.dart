// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'info_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InfoLog _$InfoLogFromJson(Map<String, dynamic> json) =>
    InfoLog(json['message'] as String)
      ..className = json['className'] as String
      ..logCreationDate = DateTime.parse(json['logCreationDate'] as String);

Map<String, dynamic> _$InfoLogToJson(InfoLog instance) => <String, dynamic>{
  'className': instance.className,
  'message': instance.message,
  'logCreationDate': instance.logCreationDate.toIso8601String(),
};
