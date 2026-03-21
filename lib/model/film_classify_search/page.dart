import 'package:json_annotation/json_annotation.dart';

part 'page.g.dart';

@JsonSerializable()
class Page {
  int? pageSize;
  int? current;
  int? pageCount;
  int? total;

  Page({this.pageSize, this.current, this.pageCount, this.total});

  factory Page.fromJson(Map<String, dynamic> json) => _$PageFromJson(json);

  Map<String, dynamic> toJson() => _$PageToJson(this);
}
