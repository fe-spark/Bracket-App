import '/model/film_play_info/play_list.dart';
import 'package:json_annotation/json_annotation.dart';

part 'list.g.dart';

@JsonSerializable()
class ListData {
  String? id;
  String? name;
  List<PlayItem>? linkList;

  ListData({this.id, this.name, this.linkList});

  factory ListData.fromJson(Map<String, dynamic> json) =>
      _$ListDataFromJson(json);

  Map<String, dynamic> toJson() => _$ListDataToJson(this);
}
