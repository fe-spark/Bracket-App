import '/plugins.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

class ThemeProvider {
  BuildContext context;
  Color sourceColor;

  ThemeProvider(this.context, this.sourceColor);

  final pageTransitionsTheme = const PageTransitionsTheme(
    builders: <TargetPlatform, PageTransitionsBuilder>{
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    },
  );

  Color blend(Color targetColor) {
    return Color(
      Blend.harmonize(
        targetColor.value,
        sourceColor.value,
      ),
    );
  }

  Color source(Color? target) {
    Color source = sourceColor;
    if (target != null) {
      source = blend(target);
    }
    return source;
  }

  ColorScheme colors(Brightness brightness) {
    return ColorScheme.fromSeed(
      seedColor: sourceColor,
      brightness: brightness,
    );
  }

  // ShapeBorder get shapeMedium =>

  TextTheme textTheme(ColorScheme colors) {
    return const TextTheme().copyWith();
  }

  CardThemeData cardTheme(ColorScheme colors) {
    return CardTheme.of(context).copyWith(
      elevation: 10,
      color: colors.surface,
      shadowColor: Theme.of(context).primaryColor.withOpacity(0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: Theme.of(context).primaryColor.withOpacity(0.5),
          // width: 0,
          // strokeAlign: BorderSide.strokeAlignInside,
        ),
      ),
      clipBehavior: Clip.none,
    );
  }

  ListTileThemeData listTileTheme(ColorScheme colors) {
    return ListTileTheme.of(context).copyWith(
        // textColor: colors.inverseSurface,
        // shape: RoundedRectangleBorder(
        //   borderRadius: BorderRadius.circular(8),
        //   side: BorderSide(
        //     color: Theme.of(context).primaryColor.withOpacity(0.5),
        //     width: 4,
        //     // strokeAlign: BorderSide.strokeAlignOutside,
        //   ),
        // ),
        // selectedColor: colors.surface,
        );
  }

  AppBarTheme appBarTheme(ColorScheme colors) {
    return const AppBarTheme(
      elevation: 0,
      // backgroundColor: colors.inversePrimary,
      // foregroundColor: colors.surfaceTint,
    );
  }

  TabBarThemeData tabBarTheme(ColorScheme colors) {
    return TabBarThemeData(
      labelColor: colors.secondary,
      unselectedLabelColor: colors.onSurfaceVariant,
      indicator: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colors.secondary,
            width: 2,
          ),
        ),
      ),
    );
  }

  BottomAppBarThemeData bottomAppBarTheme(ColorScheme colors) {
    return BottomAppBarThemeData(
      color: colors.surface,
      elevation: 0,
    );
  }

  BottomNavigationBarThemeData bottomNavigationBarTheme(ColorScheme colors) {
    return BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      backgroundColor: colors.onSecondary,
      selectedItemColor: colors.onSurface,
      unselectedItemColor: colors.onSurfaceVariant,
      elevation: 0,
      landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
    );
  }

  NavigationRailThemeData navigationRailTheme(ColorScheme colors) {
    return const NavigationRailThemeData();
  }

  DrawerThemeData drawerTheme(ColorScheme colors) {
    return DrawerThemeData(
      backgroundColor: colors.surface,
    );
  }

  ThemeData light() {
    final selfColor = colors(Brightness.light);
    return ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.grey[100],
        colorScheme: selfColor,
        primaryColor: sourceColor,
        primaryColorDark: selfColor.background,
        pageTransitionsTheme: pageTransitionsTheme,
        appBarTheme: AppBarTheme.of(context).copyWith(
          elevation: 10,
          backgroundColor: Colors.grey[200],
        ),
        cardTheme: cardTheme(selfColor),
        listTileTheme: listTileTheme(selfColor),
        bottomAppBarTheme: bottomAppBarTheme(selfColor),
        bottomNavigationBarTheme: bottomNavigationBarTheme(selfColor),
        navigationRailTheme: navigationRailTheme(selfColor),
        tabBarTheme: tabBarTheme(selfColor),
        drawerTheme: drawerTheme(selfColor),
        dividerTheme: DividerTheme.of(context).copyWith(
          space: 8,
          color: Theme.of(context).primaryColor.withOpacity(0.5),
        ),
        chipTheme: ChipTheme.of(context).copyWith(
          shape: const RoundedRectangleBorder(
            side: BorderSide(
              color: Colors.transparent,
            ),
            borderRadius: BorderRadius.all(
              Radius.circular(8),
            ),
          ),
          elevation: 2,
        ),
        // scaffoldBackgroundColor: selfColor.background,
        snackBarTheme: const SnackBarThemeData().copyWith(
          behavior: SnackBarBehavior.floating,
        ),
        // ElevatedButton
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: sourceColor,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ));
  }

  ThemeData dark() {
    final selfColor = colors(Brightness.dark);
    return ThemeData.dark().copyWith(
      colorScheme: selfColor,
      primaryColor: sourceColor,
      pageTransitionsTheme: pageTransitionsTheme,
      appBarTheme: AppBarTheme.of(context).copyWith(
        elevation: 10,
        backgroundColor: Colors.black,
      ),
      cardTheme: cardTheme(selfColor),
      dividerTheme: DividerTheme.of(context).copyWith(
        color: Theme.of(context).primaryColor.withOpacity(0.5),
      ),
      chipTheme: ChipTheme.of(context).copyWith(
        shape: const RoundedRectangleBorder(
          side: BorderSide(
            color: Colors.transparent,
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(8),
          ),
        ),
        elevation: 2,
      ),
      listTileTheme: listTileTheme(selfColor),
      bottomAppBarTheme: bottomAppBarTheme(selfColor),
      bottomNavigationBarTheme: bottomNavigationBarTheme(selfColor),
      navigationRailTheme: navigationRailTheme(selfColor),
      tabBarTheme: tabBarTheme(selfColor),
      drawerTheme: drawerTheme(selfColor),
      // scaffoldBackgroundColor: selfColor.background,
      snackBarTheme: const SnackBarThemeData().copyWith(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  ThemeData theme() {
    final brightness = MediaQuery.of(context).platformBrightness;
    return brightness == Brightness.light ? light() : dark();
  }
}
