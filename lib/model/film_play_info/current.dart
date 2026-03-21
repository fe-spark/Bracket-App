import 'package:json_annotation/json_annotation.dart';

part 'current.g.dart';

@JsonSerializable()
class Current {
  String? episode;
  String? link;

  Current({this.episode, this.link});

  factory Current.fromJson(Map<String, dynamic> json) {
    return _$CurrentFromJson(json);
  }

  Map<String, dynamic> toJson() => _$CurrentToJson(this);
}
