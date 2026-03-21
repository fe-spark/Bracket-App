import 'package:json_annotation/json_annotation.dart';

part 'play_list.g.dart';

@JsonSerializable()
class PlayItem {
  String? episode;
  String? link;

  PlayItem({this.episode, this.link});

  factory PlayItem.fromJson(Map<String, dynamic> json) {
    return _$PlayItemFromJson(json);
  }

  Map<String, dynamic> toJson() => _$PlayItemToJson(this);
}
