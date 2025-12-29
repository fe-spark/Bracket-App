import '/plugins.dart';
import 'package:flutter/foundation.dart';

class SearchStore with ChangeNotifier, DiagnosticableTreeMixin {
  final preferenceKey = 'searchStore';

  List<String> get data =>
      PreferenceUtil.getStringList(preferenceKey, defaultValue: []);

  void addSearchRecord(String str) async {
    List<String> newList = [
      ...{
        ...{str, ...data}
      }
    ];
    List<String> cutList =
        newList.sublist(0, newList.length >= 30 ? 30 : newList.length);

    await PreferenceUtil.setStringList(preferenceKey, cutList);
    notifyListeners();
  }

  clearStore() async {
    await PreferenceUtil.remove(preferenceKey);
    notifyListeners();
  }

  void removeSearchRecord(String str) async {
    List<String> currentList = List<String>.from(data);
    currentList.remove(str);
    await PreferenceUtil.setStringList(preferenceKey, currentList);
    notifyListeners();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty(preferenceKey, data));
  }
}
