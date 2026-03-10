import 'package:flutter/foundation.dart';

class PlayVideoIdsStore with ChangeNotifier {
  int _originIndex = 0;
  int? _teleplayIndex = 0;
  int? _startAt = 0;

  int get originIndex => _originIndex;

  int? get teleplayIndex => _teleplayIndex;

  int? get startAt => _startAt;

  void setVideoInfo(int? num,
      {required int? teleplayIndex, required int? startAt}) {
    _originIndex = num ?? 0;
    _teleplayIndex = teleplayIndex;
    _startAt = startAt ?? 0;

    notifyListeners();
  }
}
