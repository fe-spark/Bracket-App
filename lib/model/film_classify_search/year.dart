import 'package:json_annotation/json_annotation.dart';

part 'year.g.dart';

@JsonSerializable()
class Year {
  @JsonKey(name: 'Name')
  String? name;
  @JsonKey(name: 'Value')
  String? value;

  Year({this.name, this.value});

  factory Year.fromJson(Map<String, dynamic> json) => _$YearFromJson(json);

  Map<String, dynamic> toJson() => _$YearToJson(this);
}
