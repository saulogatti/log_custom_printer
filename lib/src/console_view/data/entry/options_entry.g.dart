// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'options_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DateRangeEpochEntry _$DateRangeEpochEntryFromJson(Map<String, dynamic> json) =>
    DateRangeEpochEntry(
      start: (json['start'] as num).toInt(),
      end: (json['end'] as num).toInt(),
    );

Map<String, dynamic> _$DateRangeEpochEntryToJson(
  DateRangeEpochEntry instance,
) => <String, dynamic>{'start': instance.start, 'end': instance.end};

OptionsEntry _$OptionsEntryFromJson(Map<String, dynamic> json) => OptionsEntry(
  selectedOption: OptionItemEntry.fromJson(
    json['selectedOption'] as Map<String, dynamic>,
  ),
  selectedDateTimeRange: json['selectedDateTimeRange'] == null
      ? null
      : DateRangeEpochEntry.fromJson(
          json['selectedDateTimeRange'] as Map<String, dynamic>,
        ),
  isDateTimeFilterEnabled: json['isDateTimeFilterEnabled'] as bool? ?? false,
);

Map<String, dynamic> _$OptionsEntryToJson(OptionsEntry instance) =>
    <String, dynamic>{
      'selectedOption': instance.selectedOption.toJson(),
      'selectedDateTimeRange': instance.selectedDateTimeRange?.toJson(),
      'isDateTimeFilterEnabled': instance.isDateTimeFilterEnabled,
    };
