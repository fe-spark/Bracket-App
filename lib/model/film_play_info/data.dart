import 'package:json_annotation/json_annotation.dart';

import 'current.dart';
import 'detail.dart';
import 'relate.dart';

part 'data.g.dart';

@JsonSerializable()
class Data {
  Current? current;
  int? currentEpisode;
  String? currentPlayFrom;
  Detail? detail;
  List<Relate>? relate;

  Data({
    this.current,
    this.currentEpisode,
    this.currentPlayFrom,
    this.detail,
    this.relate,
  });

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);

  Map<String, dynamic> toJson() => _$DataToJson(this);
}
