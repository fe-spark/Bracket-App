import 'package:json_annotation/json_annotation.dart';

part 'params.g.dart';

@JsonSerializable()
class Params {
  @JsonKey(name: 'Area')
  String? area;
  @JsonKey(name: 'Category')
  String? category;
  @JsonKey(name: 'Language')
  String? language;
  @JsonKey(name: 'Pid')
  String? pid;
  @JsonKey(name: 'Plot')
  String? plot;
  @JsonKey(name: 'Sort')
  String? sort;
  @JsonKey(name: 'Year')
  String? year;

  Params({
    this.area,
    this.category,
    this.language,
    this.pid,
    this.plot,
    this.sort,
    this.year,
  });

  factory Params.fromJson(Map<String, dynamic> json) {
    return _$ParamsFromJson(json);
  }

  Map<String, dynamic> toJson() => _$ParamsToJson(this);
}
