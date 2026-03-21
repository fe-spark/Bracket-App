import 'package:flutter_native_splash/flutter_native_splash.dart';
import '/shared/theme.dart';
import '/plugins.dart';

void main() async {
  // 初始化插件前需调用初始化代码 runApp()函数之前
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight
  ]);

  // await SystemChrome.setPreferredOrientations(
  //     [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  /// 初始持久化数据
  await PreferenceUtil.getInstance();
  await Future.delayed(const Duration(seconds: 2));
  // PreferenceUtil.clear();

  watchConnectivity(null, () {
    FlutterNativeSplash.remove();
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ThemeStore>(
            create: (_) => ThemeStore(),
          ),
          ChangeNotifierProvider<UserStore>(
            create: (_) => UserStore(),
          ),
          ChangeNotifierProvider<SearchStore>(
            create: (_) => SearchStore(),
          ),
          ChangeNotifierProvider<HistoryStore>(
            create: (_) => HistoryStore(),
          ),
          ChangeNotifierProvider<VideoSourceStore>(
            create: (_) => VideoSourceStore(),
          ),
          ChangeNotifierProvider<PlayVideoIdsStore>(
            create: (_) => PlayVideoIdsStore(),
          ),
        ],
        child: const MyApp(),
      ),
    );
  });
}

class MyTheme {
  ThemeProvider? _provider;
  final BuildContext _context;
  final String _theme;

  ThemeData? get theme {
    if (_theme == ITheme.auto.value) {
      return _provider!.theme();
    }

    if (_theme == ITheme.dark.value) {
      return _provider!.dark();
    }

    if (_theme == ITheme.light.value) {
      return _provider!.light();
    }

    return null;
  }

  MyTheme(
    this._context,
    this._theme,
  ) {
    _provider = ThemeProvider(
      _context,
      Theme.of(_context).primaryColor,
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeStore = context.watch<ThemeStore>();

    SparkPxFit.initialize(context);

    return MaterialApp(
      title: 'Bracket',
      theme: MyTheme(context, themeStore.data!).theme,
      navigatorKey: MYRouter.navigatorKey,
      initialRoute: MYRouter.homePagePath,
      onGenerateRoute: MYRouter.generateRoute,
      onUnknownRoute: MYRouter.unknownRoute,
      builder: (context, widget) {
        return MediaQuery(
          //设置全局的文字的textScaleFactor为1.0，文字不再随系统设置改变
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(1.0)),
          child: widget!,
        );
      },
    );
  }
}
