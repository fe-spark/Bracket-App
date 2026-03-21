import 'package:json_annotation/json_annotation.dart';

part 'download_list.g.dart';

@JsonSerializable()
class DownloadList {
  String? episode;
  String? link;

  DownloadList({this.episode, this.link});

  factory DownloadList.fromJson(Map<String, dynamic> json) {
    return _$DownloadListFromJson(json);
  }

  Map<String, dynamic> toJson() => _$DownloadListToJson(this);
}
