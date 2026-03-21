import 'package:json_annotation/json_annotation.dart';

import 'data.dart';

part 'search_film.g.dart';

@JsonSerializable()
class SearchFilm {
  int? code;
  Data? data;
  String? msg;

  SearchFilm({this.code, this.data, this.msg});

  factory SearchFilm.fromJson(Map<String, dynamic> json) {
    return _$SearchFilmFromJson(json);
  }

  Map<String, dynamic> toJson() => _$SearchFilmToJson(this);
}
