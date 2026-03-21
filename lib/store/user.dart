import 'package:flutter/foundation.dart';
import '/plugins.dart';

class UserStore with ChangeNotifier, DiagnosticableTreeMixin {
  final preferenceKey = 'userStore';

  User? get data {
    return PreferenceUtil.getMap(preferenceKey) != null
        ? User.fromJson(PreferenceUtil.getMap(preferenceKey))
        : null;
  }

  void clearStore() {
    PreferenceUtil.remove(preferenceKey);
    notifyListeners();
  }

  void setStore(Map<String, dynamic> data) async {
    await PreferenceUtil.setMap(preferenceKey, data);
    notifyListeners();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ObjectFlagProperty(preferenceKey, data));
  }
}
