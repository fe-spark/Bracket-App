import 'package:json_annotation/json_annotation.dart';

part 'video_source.g.dart';

@JsonSerializable()
class VideoSource {
  List<String>? source;
  String? actived;

  VideoSource({this.source, this.actived});

  factory VideoSource.fromJson(Map<String, dynamic> json) {
    return _$VideoSourceFromJson(json);
  }

  Map<String, dynamic> toJson() => _$VideoSourceToJson(this);
}
