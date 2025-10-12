// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'info_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InfoLog _$InfoLogFromJson(Map<String, dynamic> json) =>
    InfoLog(json['message'] as String)
      ..className = json['className'] as String
      ..creationDateTime = DateTime.parse(json['creationDateTime'] as String);

Map<String, dynamic> _$InfoLogToJson(InfoLog instance) => <String, dynamic>{
  'className': instance.className,
  'message': instance.message,
  'creationDateTime': instance.creationDateTime.toIso8601String(),
};
