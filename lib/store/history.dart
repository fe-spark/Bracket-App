import 'package:flutter/foundation.dart';
// import '/model/date/date.dart';
import '/plugins.dart';

class HistoryStore with ChangeNotifier, DiagnosticableTreeMixin {
  final preferenceKey = 'historyStore';

  List get data {
    return PreferenceUtil.getMap<List>(preferenceKey) ?? [];
  }

  void clearStore() {
    PreferenceUtil.remove(preferenceKey);
    notifyListeners();
  }

  void addHistory(Map<String, dynamic> history) async {
    var newList = [history];

    for (var item in data) {
      if (item['id'] != history['id']) {
        newList.add(item);
      }
    }

    await PreferenceUtil.setMap(preferenceKey, newList);
    notifyListeners();
  }

  Future<void> deleteHistoryForId(int id) async {
    var newList = [];

    for (var item in data) {
      if (item['id'] != id) {
        newList.add(item);
      }
    }

    await PreferenceUtil.setMap(preferenceKey, newList);
    notifyListeners();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty(preferenceKey, data));
  }
}
