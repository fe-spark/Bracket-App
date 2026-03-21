import 'package:json_annotation/json_annotation.dart';

import 'data.dart';

part 'film_classify_search.g.dart';

@JsonSerializable()
class FilmClassifySearch {
  int? code;
  Data? data;
  String? msg;

  FilmClassifySearch({this.code, this.data, this.msg});

  factory FilmClassifySearch.fromJson(Map<String, dynamic> json) {
    return _$FilmClassifySearchFromJson(json);
  }

  Map<String, dynamic> toJson() => _$FilmClassifySearchToJson(this);
}
