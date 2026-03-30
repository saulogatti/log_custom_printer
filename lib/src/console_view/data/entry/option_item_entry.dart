import 'package:json_annotation/json_annotation.dart';
import 'package:log_custom_printer/src/console_view/domain/models/console_options.dart';

part 'option_item_entry.g.dart';

/// DTO serializável para [OptionItem], usado na persistência JSON das opções
/// do console ([OptionsEntry]).
@JsonSerializable()
class OptionItemEntry extends OptionItem {
  OptionItemEntry({required super.title, required super.description});

  factory OptionItemEntry.fromJson(Map<String, dynamic> json) =>
      _$OptionItemEntryFromJson(json);
  Map<String, dynamic> toJson() => _$OptionItemEntryToJson(this);
}
