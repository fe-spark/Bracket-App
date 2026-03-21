import '/plugins.dart';
import '/views/home/index.dart';
import 'views/source.dart';
import '/views/splash.dart';
import '/views/unknown.dart';
import 'views/test.dart';
import 'views/theme/index.dart';
import 'views/detail/index.dart';
import 'views/history/index.dart';
import 'views/filter/index.dart';
import 'views/about/index.dart';
import 'views/feedback/index.dart';
// import 'views/test/index.dart';

class SparkRoute {
  bool? noAuth;
  Widget Function(BuildContext, {Map? arguments}) builder;

  SparkRoute({required this.builder, this.noAuth});
}

class MYRouter {
  static String homePagePath = '/';
  static String splashPagePath = '/splash_page';
  static String detailPagePath = '/detail_page';
  static String sourcePagePath = '/source_page';
  static String aboutPagePath = '/about_page';
  static String feedbackPagePath = '/feedback_page';
  static String unknownPagePath = '/unknown_page';
  static String settingPagePath = '/setting_page';
  static String themePagePath = '/theme_page';
  static String historyPagePath = '/history_page';
  static String filterPagePath = '/filter_page';
  static String testPagePath = '/test_page';

  static String get initialRoute => homePagePath;

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Map<String, SparkRoute> routeTables = {
    //启动页
    splashPagePath: SparkRoute(
      noAuth: true,
      builder: (_, {arguments}) => const SplashPage(),
    ),
    //登录
    sourcePagePath: SparkRoute(
      noAuth: false,
      builder: (_, {arguments}) => const LoginPage(),
    ),
    //首页
    homePagePath: SparkRoute(
      builder: (_, {arguments}) => const HomePage(),
    ),
    detailPagePath: SparkRoute(
      builder: (_, {arguments}) => DetailPage(arguments: arguments),
    ),
    // 筛选
    filterPagePath: SparkRoute(
      builder: (_, {arguments}) => FilterPage(arguments: arguments),
    ),

    //主题
    themePagePath: SparkRoute(
      builder: (_, {arguments}) => const ThemePage(),
    ),
    historyPagePath: SparkRoute(
      builder: (_, {arguments}) => const HistoryPage(),
    ),

    aboutPagePath: SparkRoute(
      builder: (_, {arguments}) => const AboutPage(),
    ),
    feedbackPagePath: SparkRoute(
      builder: (_, {arguments}) => const FeedbackPage(),
    ),
    testPagePath: SparkRoute(
      builder: (_, {arguments}) => const AutoFullscreenOrientationPage(),
    ),
    // 未知
    unknownPagePath:
        SparkRoute(builder: (_, {arguments}) => const UnknownPage()),
  };

  static MaterialPageRoute generateRoute<T extends Object>(
      RouteSettings settings) {
    MaterialPageRoute route = MaterialPageRoute(
      builder: (_) {
        Map? arguments = settings.arguments as Map?;
        final videoSourceStore = _.watch<VideoSourceStore>();

        String? name = settings.name;
        SparkRoute? routeData = routeTables[name];
        Widget Function(BuildContext, {Map? arguments})? builder =
            routeData?.builder;

        if (routeData?.noAuth != true) {
          if (videoSourceStore.data?.actived == null) {
            builder = routeTables[sourcePagePath]?.builder;
          }
        }

        builder ??= routeTables[unknownPagePath]?.builder;

        return builder!(_, arguments: arguments);
      },
      settings: settings,
    );

    return route;
  }

  static RouteFactory get unknownRoute => (settings) {
        return MaterialPageRoute(
          builder: (BuildContext _) => routeTables[unknownPagePath]!
              .builder(_, arguments: settings.arguments as Map?),
        );
      };
}
