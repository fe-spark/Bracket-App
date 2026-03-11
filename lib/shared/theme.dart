import '/plugins.dart';

class ThemeProvider {
  final BuildContext context;
  final Color sourceColor;

  const ThemeProvider(this.context, this.sourceColor);

  ColorScheme colors(Brightness brightness) {
    var scheme = ColorScheme.fromSeed(
      seedColor: sourceColor,
      brightness: brightness,
    );
    // Force the primary color to be the exact source color
    // This prevents Dark Mode from using a "whitish" pastel version
    return scheme.copyWith(
      primary: sourceColor,
      onPrimary: Colors.white,
    );
  }

  ThemeData light() {
    final colorScheme = colors(Brightness.light);
    // Tonal Theme: Uses tinted surfaces derived from Brand Color
    return _baseTheme(colorScheme).copyWith(
      scaffoldBackgroundColor:
          const Color(0xFFF7F6FC), // Pale Lavender Background
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor:
            colorScheme.surface, // Tinted AppBar matches background
        foregroundColor: colorScheme.onSurface,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 4, // 增加阴影以"高亮"
        shadowColor: colorScheme.shadow.withValues(alpha: 0.05),
        color: Colors.white, // 纯白卡片
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24), // 更大圆角
          side: BorderSide.none,
        ),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        // Tinted Input
        // border/enabledBorder/focusedBorder properties handled in _baseTheme
      ),
    );
  }

  ThemeData dark() {
    final colorScheme = colors(Brightness.dark);
    return _baseTheme(colorScheme).copyWith(
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      // Dark Mode Cards need to be dark gray
      cardTheme: CardThemeData(
        elevation: 0,
        color: const Color(0xFF1C1C1E), // Apple Dark Gray
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide.none,
        ),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),
    );
  }

  ThemeData _baseTheme(ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true,
      splashFactory: NoSplash.splashFactory,
      colorScheme: colorScheme,
      brightness: colorScheme.brightness,
      primaryColor: colorScheme.primary,
      // Default Card Theme (overridden in light/dark for specific colors)
      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surfaceContainerLow,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide.none,
        ),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        iconColor: colorScheme.primary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
      ),
      dividerTheme: DividerThemeData(
        space: 1,
        thickness: 1,
        color:
            colorScheme.outlineVariant.withValues(alpha: 0.1), // Faint divider
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      chipTheme: ChipThemeData(
          backgroundColor:
              colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          labelStyle: TextStyle(color: colorScheme.onSurface),
          side: BorderSide.none,
          shape: const StadiumBorder()),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  ThemeData theme() {
    final brightness = MediaQuery.of(context).platformBrightness;
    return brightness == Brightness.light ? light() : dark();
  }
}
