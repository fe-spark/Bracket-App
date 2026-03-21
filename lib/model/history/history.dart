import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';

part 'history.g.dart';

@JsonSerializable()
class History {
  int? id;
  int? timeStamp;
  String? name;
  String? picture;

  History({this.id, this.timeStamp, this.name, this.picture});

  factory History.fromJson(Map<String, dynamic> json) {
    return _$HistoryFromJson(json);
  }

  Map<String, dynamic> toJson() => _$HistoryToJson(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    if (other is! History) return false;
    final mapEquals = const DeepCollectionEquality().equals;
    return mapEquals(other.toJson(), toJson());
  }

  @override
  int get hashCode => id.hashCode ^ timeStamp.hashCode ^ name.hashCode;
}
