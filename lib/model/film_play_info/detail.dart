import 'package:json_annotation/json_annotation.dart';

import 'descriptor.dart';
import 'download_list.dart';
import 'list.dart';
import 'play_list.dart';

part 'detail.g.dart';

@JsonSerializable()
class Detail {
  int? id;
  int? cid;
  int? pid;
  String? name;
  String? picture;
  List<String>? playFrom;
  @JsonKey(name: 'DownFrom')
  String? downFrom;
  List<List<PlayItem>>? playList;
  List<List<DownloadList>>? downloadList;
  Descriptor? descriptor;
  List<ListData>? list;

  Detail({
    this.id,
    this.cid,
    this.pid,
    this.name,
    this.picture,
    this.playFrom,
    this.downFrom,
    this.playList,
    this.downloadList,
    this.descriptor,
    this.list,
  });

  factory Detail.fromJson(Map<String, dynamic> json) {
    return _$DetailFromJson(json);
  }

  Map<String, dynamic> toJson() => _$DetailToJson(this);
}
