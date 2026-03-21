import 'package:json_annotation/json_annotation.dart';

import 'list.dart';
import 'page.dart';
import 'params.dart';
import 'search.dart';
import 'title.dart';

part 'data.g.dart';

@JsonSerializable()
class Data {
  List<ListData>? list;
  Page? page;
  Params? params;
  Search? search;
  Title? title;

  Data({this.list, this.page, this.params, this.search, this.title});

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);

  Map<String, dynamic> toJson() => _$DataToJson(this);
}
