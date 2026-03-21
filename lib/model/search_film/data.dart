import 'package:json_annotation/json_annotation.dart';

import 'list.dart';
import 'page.dart';

part 'data.g.dart';

@JsonSerializable()
class Data {
  List<ListData>? list;
  Page? page;

  Data({this.list, this.page});

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);

  Map<String, dynamic> toJson() => _$DataToJson(this);
}
