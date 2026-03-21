import 'package:json_annotation/json_annotation.dart';

import 'tags.dart';
import 'titles.dart';

part 'search.g.dart';

@JsonSerializable()
class Search {
  List<String>? sortList;
  Tags? tags;
  Titles? titles;

  Search({this.sortList, this.tags, this.titles});

  factory Search.fromJson(Map<String, dynamic> json) {
    return _$SearchFromJson(json);
  }

  Map<String, dynamic> toJson() => _$SearchToJson(this);
}
