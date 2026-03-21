import '/plugins.dart';
// import '//utils/preference.dart';
import 'package:flutter/foundation.dart';

enum ITheme { auto, dark, light }

extension IThemeExtension on ITheme {
  String get value {
    switch (this) {
      case ITheme.dark:
        return "dark";
      case ITheme.light:
        return "light";
      default:
        return "auto";
    }
  }
}

// class FilmHistrory {}

class ThemeStore with ChangeNotifier, DiagnosticableTreeMixin {
  final preferenceKey = 'themeStore';

  String? get data =>
      PreferenceUtil.getString(preferenceKey, defaultValue: ITheme.auto.value);

  // ThemeStore(this.context) : super();

  // GlobalKey<NavigatorState> navigatorKey = MYRouter.navigatorKey;
  // BuildContext context = navigatorKey.currentState!.context;
  // ThemeData _theme = ThemeProvider(settings).theme(context);
  // ThemeData get theme => _theme;

  void setTheme(String theme) async {
    // _theme = theme;
    await PreferenceUtil.setString(preferenceKey, theme);
    notifyListeners();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty(preferenceKey, data));
  }
}
