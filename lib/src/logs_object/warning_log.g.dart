// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'warning_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WarningLog _$WarningLogFromJson(Map<String, dynamic> json) =>
    WarningLog(json['message'] as String)
      ..className = json['className'] as String
      ..creationDateTime = DateTime.parse(json['creationDateTime'] as String);

Map<String, dynamic> _$WarningLogToJson(WarningLog instance) =>
    <String, dynamic>{
      'className': instance.className,
      'message': instance.message,
      'creationDateTime': instance.creationDateTime.toIso8601String(),
    };
