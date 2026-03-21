import 'package:json_annotation/json_annotation.dart';

part 'relate.g.dart';

@JsonSerializable()
class Relate {
  int? id;
  int? cid;
  int? pid;
  String? name;
  String? subTitle;
  String? cName;
  String? state;
  String? picture;
  String? actor;
  String? director;
  String? blurb;
  String? remarks;
  String? area;
  String? year;

  Relate({
    this.id,
    this.cid,
    this.pid,
    this.name,
    this.subTitle,
    this.cName,
    this.state,
    this.picture,
    this.actor,
    this.director,
    this.blurb,
    this.remarks,
    this.area,
    this.year,
  });

  factory Relate.fromJson(Map<String, dynamic> json) {
    return _$RelateFromJson(json);
  }

  Map<String, dynamic> toJson() => _$RelateToJson(this);
}
