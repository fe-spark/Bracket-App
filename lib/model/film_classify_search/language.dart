import 'package:json_annotation/json_annotation.dart';

part 'language.g.dart';

@JsonSerializable()
class Language {
  @JsonKey(name: 'Name')
  String? name;
  @JsonKey(name: 'Value')
  String? value;

  Language({this.name, this.value});

  factory Language.fromJson(Map<String, dynamic> json) {
    return _$LanguageFromJson(json);
  }

  Map<String, dynamic> toJson() => _$LanguageToJson(this);
}
