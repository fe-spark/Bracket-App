import 'package:json_annotation/json_annotation.dart';

part 'initial.g.dart';

@JsonSerializable()
class Initial {
  @JsonKey(name: 'Name')
  String? name;
  @JsonKey(name: 'Value')
  String? value;

  Initial({this.name, this.value});

  factory Initial.fromJson(Map<String, dynamic> json) {
    return _$InitialFromJson(json);
  }

  Map<String, dynamic> toJson() => _$InitialToJson(this);
}
