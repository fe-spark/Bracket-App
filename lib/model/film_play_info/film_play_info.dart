import 'package:json_annotation/json_annotation.dart';

import 'data.dart';

part 'film_play_info.g.dart';

@JsonSerializable()
class FilmPlayInfo {
  int? code;
  Data? data;
  String? msg;

  FilmPlayInfo({this.code, this.data, this.msg});

  factory FilmPlayInfo.fromJson(Map<String, dynamic> json) {
    return _$FilmPlayInfoFromJson(json);
  }

  Map<String, dynamic> toJson() => _$FilmPlayInfoToJson(this);
}
