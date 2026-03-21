import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';

part 'movie.g.dart';

@JsonSerializable()
class Movie {
  final int? id;
  final int? cid;
  final int? pid;
  final String? name;
  final String? subTitle;
  final String? cName;
  final String? state;
  final String? picture;
  final String? actor;
  final String? director;
  final String? blurb;
  final String? remarks;
  final String? area;
  final String? year;

  const Movie({
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

  @override
  String toString() {
    return 'Movie(id: $id, cid: $cid, pid: $pid, name: $name, subTitle: $subTitle, cName: $cName, state: $state, picture: $picture, actor: $actor, director: $director, blurb: $blurb, remarks: $remarks, area: $area, year: $year)';
  }

  factory Movie.fromJson(Map<String, dynamic> json) => _$MovieFromJson(json);

  Map<String, dynamic> toJson() => _$MovieToJson(this);

  Movie copyWith({
    int? id,
    int? cid,
    int? pid,
    String? name,
    String? subTitle,
    String? cName,
    String? state,
    String? picture,
    String? actor,
    String? director,
    String? blurb,
    String? remarks,
    String? area,
    String? year,
  }) {
    return Movie(
      id: id ?? this.id,
      cid: cid ?? this.cid,
      pid: pid ?? this.pid,
      name: name ?? this.name,
      subTitle: subTitle ?? this.subTitle,
      cName: cName ?? this.cName,
      state: state ?? this.state,
      picture: picture ?? this.picture,
      actor: actor ?? this.actor,
      director: director ?? this.director,
      blurb: blurb ?? this.blurb,
      remarks: remarks ?? this.remarks,
      area: area ?? this.area,
      year: year ?? this.year,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    if (other is! Movie) return false;
    final mapEquals = const DeepCollectionEquality().equals;
    return mapEquals(other.toJson(), toJson());
  }

  @override
  int get hashCode =>
      id.hashCode ^
      cid.hashCode ^
      pid.hashCode ^
      name.hashCode ^
      subTitle.hashCode ^
      cName.hashCode ^
      state.hashCode ^
      picture.hashCode ^
      actor.hashCode ^
      director.hashCode ^
      blurb.hashCode ^
      remarks.hashCode ^
      area.hashCode ^
      year.hashCode;
}
