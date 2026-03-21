import 'package:json_annotation/json_annotation.dart';

part 'sort.g.dart';

@JsonSerializable()
class Sort {
  @JsonKey(name: 'Name')
  String? name;
  @JsonKey(name: 'Value')
  String? value;

  Sort({this.name, this.value});

  factory Sort.fromJson(Map<String, dynamic> json) => _$SortFromJson(json);

  Map<String, dynamic> toJson() => _$SortToJson(this);
}
