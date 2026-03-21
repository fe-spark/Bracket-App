import 'package:json_annotation/json_annotation.dart';

part 'plot.g.dart';

@JsonSerializable()
class Plot {
  @JsonKey(name: 'Name')
  String? name;
  @JsonKey(name: 'Value')
  String? value;

  Plot({this.name, this.value});

  factory Plot.fromJson(Map<String, dynamic> json) => _$PlotFromJson(json);

  Map<String, dynamic> toJson() => _$PlotToJson(this);
}
