import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';

part 'hot.g.dart';

@JsonSerializable()
class Hot {
  @JsonKey(name: 'ID')
  final int? id;
  @JsonKey(name: 'CreatedAt')
  final String? createdAt;
  @JsonKey(name: 'UpdatedAt')
  final String? updatedAt;
  @JsonKey(name: 'DeletedAt')
  final dynamic deletedAt;
  final int? mid;
  final int? cid;
  final int? pid;
  final String? name;
  final String? subTitle;
  @JsonKey(name: 'CName')
  final String? cName;
  final String? classTag;
  final String? area;
  final String? language;
  final int? year;
  final String? initial;
  // final int? score;
  final int? updateStamp;
  final int? hits;
  final String? state;
  final String? remarks;
  final int? releaseStamp;

  const Hot({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.mid,
    this.cid,
    this.pid,
    this.name,
    this.subTitle,
    this.cName,
    this.classTag,
    this.area,
    this.language,
    this.year,
    this.initial,
    // this.score,
    this.updateStamp,
    this.hits,
    this.state,
    this.remarks,
    this.releaseStamp,
  });

  @override
  String toString() {
    return 'Hot(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, mid: $mid, cid: $cid, pid: $pid, name: $name, subTitle: $subTitle, cName: $cName, classTag: $classTag, area: $area, language: $language, year: $year, initial: $initial, updateStamp: $updateStamp, hits: $hits, state: $state, remarks: $remarks, releaseStamp: $releaseStamp)';
  }

  factory Hot.fromJson(Map<String, dynamic> json) => _$HotFromJson(json);

  Map<String, dynamic> toJson() => _$HotToJson(this);

  Hot copyWith({
    int? id,
    String? createdAt,
    String? updatedAt,
    dynamic deletedAt,
    int? mid,
    int? cid,
    int? pid,
    String? name,
    String? subTitle,
    String? cName,
    String? classTag,
    String? area,
    String? language,
    int? year,
    String? initial,
    int? score,
    int? updateStamp,
    int? hits,
    String? state,
    String? remarks,
    int? releaseStamp,
  }) {
    return Hot(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      mid: mid ?? this.mid,
      cid: cid ?? this.cid,
      pid: pid ?? this.pid,
      name: name ?? this.name,
      subTitle: subTitle ?? this.subTitle,
      cName: cName ?? this.cName,
      classTag: classTag ?? this.classTag,
      area: area ?? this.area,
      language: language ?? this.language,
      year: year ?? this.year,
      initial: initial ?? this.initial,
      // score: score ?? this.score,
      updateStamp: updateStamp ?? this.updateStamp,
      hits: hits ?? this.hits,
      state: state ?? this.state,
      remarks: remarks ?? this.remarks,
      releaseStamp: releaseStamp ?? this.releaseStamp,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    if (other is! Hot) return false;
    final mapEquals = const DeepCollectionEquality().equals;
    return mapEquals(other.toJson(), toJson());
  }

  @override
  int get hashCode =>
      id.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode ^
      deletedAt.hashCode ^
      mid.hashCode ^
      cid.hashCode ^
      pid.hashCode ^
      name.hashCode ^
      subTitle.hashCode ^
      cName.hashCode ^
      classTag.hashCode ^
      area.hashCode ^
      language.hashCode ^
      year.hashCode ^
      initial.hashCode ^
      updateStamp.hashCode ^
      hits.hashCode ^
      state.hashCode ^
      remarks.hashCode ^
      releaseStamp.hashCode;
}
