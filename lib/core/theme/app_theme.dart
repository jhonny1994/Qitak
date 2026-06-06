import 'dart:ui';

import 'package:flutter/material.dart';

const _arabicFontFamily = 'Cairo';
const _latinFontFamily = 'Inter';

@immutable
class QitakThemeTokens extends ThemeExtension<QitakThemeTokens> {
  const QitakThemeTokens({
    required this.page,
    required this.section,
    required this.object,
    required this.raised,
    required this.stroke,
    required this.strokeStrong,
    required this.success,
    required this.warning,
    required this.info,
    required this.maxContentWidth,
    required this.screenPadding,
    required this.spacingSm,
    required this.spacingMd,
    required this.spacingLg,
    required this.objectRadius,
    required this.fieldRadius,
    required this.sheetRadius,
    required this.panel,
    required this.panelMuted,
    required this.panelStrong,
    required this.glow,
    required this.panelRadius,
    required this.chipRadius,
  });

  final Color page;
  final Color section;
  final Color object;
  final Color raised;
  final Color panel;
  final Color panelMuted;
  final Color panelStrong;
  final Color stroke;
  final Color strokeStrong;
  final Color glow;
  final Color success;
  final Color warning;
  final Color info;
  final double maxContentWidth;
  final double screenPadding;
  final double spacingSm;
  final double spacingMd;
  final double spacingLg;
  final double objectRadius;
  final double sheetRadius;
  final double panelRadius;
  final double chipRadius;
  final double fieldRadius;

  @override
  QitakThemeTokens copyWith({
    Color? page,
    Color? section,
    Color? object,
    Color? raised,
    Color? panel,
    Color? panelMuted,
    Color? panelStrong,
    Color? stroke,
    Color? strokeStrong,
    Color? glow,
    Color? success,
    Color? warning,
    Color? info,
    double? maxContentWidth,
    double? screenPadding,
    double? spacingSm,
    double? spacingMd,
    double? spacingLg,
    double? objectRadius,
    double? sheetRadius,
    double? panelRadius,
    double? chipRadius,
    double? fieldRadius,
  }) {
    return QitakThemeTokens(
      page: page ?? this.page,
      section: section ?? this.section,
      object: object ?? this.object,
      raised: raised ?? this.raised,
      stroke: stroke ?? this.stroke,
      strokeStrong: strokeStrong ?? this.strokeStrong,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      maxContentWidth: maxContentWidth ?? this.maxContentWidth,
      screenPadding: screenPadding ?? this.screenPadding,
      spacingSm: spacingSm ?? this.spacingSm,
      spacingMd: spacingMd ?? this.spacingMd,
      spacingLg: spacingLg ?? this.spacingLg,
      objectRadius: objectRadius ?? this.objectRadius,
      fieldRadius: fieldRadius ?? this.fieldRadius,
      sheetRadius: sheetRadius ?? this.sheetRadius,
      panel: panel ?? this.panel,
      panelMuted: panelMuted ?? this.panelMuted,
      panelStrong: panelStrong ?? this.panelStrong,
      glow: glow ?? this.glow,
      panelRadius: panelRadius ?? this.panelRadius,
      chipRadius: chipRadius ?? this.chipRadius,
    );
  }

  @override
  QitakThemeTokens lerp(ThemeExtension<QitakThemeTokens>? other, double t) {
    if (other is! QitakThemeTokens) {
      return this;
    }

    return QitakThemeTokens(
      page: Color.lerp(page, other.page, t) ?? page,
      section: Color.lerp(section, other.section, t) ?? section,
      object: Color.lerp(object, other.object, t) ?? object,
      raised: Color.lerp(raised, other.raised, t) ?? raised,
      stroke: Color.lerp(stroke, other.stroke, t) ?? stroke,
      strokeStrong:
          Color.lerp(strokeStrong, other.strokeStrong, t) ?? strokeStrong,
      success: Color.lerp(success, other.success, t) ?? success,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      info: Color.lerp(info, other.info, t) ?? info,
      maxContentWidth:
          lerpDouble(maxContentWidth, other.maxContentWidth, t) ??
          maxContentWidth,
      screenPadding:
          lerpDouble(screenPadding, other.screenPadding, t) ?? screenPadding,
      spacingSm: lerpDouble(spacingSm, other.spacingSm, t) ?? spacingSm,
      spacingMd: lerpDouble(spacingMd, other.spacingMd, t) ?? spacingMd,
      spacingLg: lerpDouble(spacingLg, other.spacingLg, t) ?? spacingLg,
      objectRadius:
          lerpDouble(objectRadius, other.objectRadius, t) ?? objectRadius,
      fieldRadius: lerpDouble(fieldRadius, other.fieldRadius, t) ?? fieldRadius,
      sheetRadius: lerpDouble(sheetRadius, other.sheetRadius, t) ?? sheetRadius,
      panel: Color.lerp(panel, other.panel, t) ?? panel,
      panelMuted: Color.lerp(panelMuted, other.panelMuted, t) ?? panelMuted,
      panelStrong: Color.lerp(panelStrong, other.panelStrong, t) ?? panelStrong,
      glow: Color.lerp(glow, other.glow, t) ?? glow,
      panelRadius: lerpDouble(panelRadius, other.panelRadius, t) ?? panelRadius,
      chipRadius: lerpDouble(chipRadius, other.chipRadius, t) ?? chipRadius,
    );
  }
}

extension QitakThemeX on BuildContext {
  QitakThemeTokens get qitakTokens =>
      Theme.of(this).extension<QitakThemeTokens>()!;
}

class AppTheme {
  static ThemeData dark({Locale? locale}) {
    const page = Color(0xFF101216);
    const section = Color(0xFF101216);
    const object = Color(0xFF191C22);
    const raised = Color(0xFF20242B);
    const stroke = Color(0xFF2A2E36);
    const strokeStrong = Color(0xFF414751);
    const primary = Color(0xFF7BBF2E);
    const secondary = Color(0xFFFFB347);
    const error = Color(0xFFF87171);

    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.dark,
          surface: object,
        ).copyWith(
          primary: primary,
          primaryContainer: const Color(0xFF1A2E0D),
          onPrimaryContainer: const Color(0xFFEAF5D6),
          secondary: secondary,
          secondaryContainer: const Color(0xFF3D2800),
          onSecondaryContainer: const Color(0xFFFFE9C8),
          surface: object,
          surfaceContainer: section,
          surfaceContainerHighest: raised,
          error: error,
        );

    const tokens = QitakThemeTokens(
      page: page,
      section: section,
      object: object,
      raised: raised,
      stroke: stroke,
      strokeStrong: strokeStrong,
      success: Color(0xFF34E4B4),
      warning: Color(0xFFFFCB57),
      info: Color(0xFF60A5FA),
      maxContentWidth: 760,
      screenPadding: 20,
      spacingSm: 8,
      spacingMd: 16,
      spacingLg: 24,
      objectRadius: 20,
      fieldRadius: 16,
      sheetRadius: 28,
      panel: object,
      panelMuted: section,
      panelStrong: raised,
      glow: Colors.transparent,
      panelRadius: 20,
      chipRadius: 16,
    );

    final textTheme = _textThemeForLocale(
      ThemeData(brightness: Brightness.dark).textTheme,
      locale: locale,
      color: const Color(0xFFECEEF3),
    );
    final buttonLabelStyle = _buttonTextStyle(textTheme);
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: tokens.page,
      canvasColor: tokens.section,
      brightness: Brightness.dark,
      textTheme: textTheme,
      visualDensity: const VisualDensity(horizontal: -0.3, vertical: -0.3),
      appBarTheme: const AppBarTheme(
        backgroundColor: page,
        foregroundColor: Color(0xFFECEEF3),
        iconTheme: IconThemeData(color: Color(0xFFECEEF3)),
        actionsIconTheme: IconThemeData(color: Color(0xFFECEEF3)),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: tokens.raised,
        modalBackgroundColor: tokens.raised,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(tokens.sheetRadius),
          ),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: tokens.raised,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.sheetRadius),
          side: BorderSide(color: tokens.stroke),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: tokens.raised,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.fieldRadius),
          side: BorderSide(color: tokens.stroke),
        ),
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: const WidgetStatePropertyAll(raised),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          side: WidgetStatePropertyAll(BorderSide(color: tokens.stroke)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(tokens.fieldRadius),
            ),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: tokens.object,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.objectRadius),
          side: BorderSide(color: tokens.stroke),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: tokens.object,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.fieldRadius),
          borderSide: BorderSide(color: tokens.stroke),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.fieldRadius),
          borderSide: BorderSide(color: tokens.stroke),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.fieldRadius),
          borderSide: const BorderSide(color: primary, width: 1.2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.fieldRadius),
          borderSide: const BorderSide(color: error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.fieldRadius),
          borderSide: const BorderSide(color: error, width: 1.2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(tokens.fieldRadius),
          ),
          textStyle: buttonLabelStyle.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.secondaryContainer,
          foregroundColor: colorScheme.onSecondaryContainer,
          elevation: 0,
          minimumSize: const Size(0, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(tokens.fieldRadius),
          ),
          textStyle: buttonLabelStyle.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(tokens.fieldRadius),
          ),
          side: BorderSide(color: tokens.strokeStrong),
          textStyle: buttonLabelStyle,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(textStyle: buttonLabelStyle),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: tokens.section,
        side: BorderSide(color: tokens.stroke),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.chipRadius),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: tokens.object,
        surfaceTintColor: Colors.transparent,
        indicatorColor: colorScheme.primaryContainer,
        labelTextStyle: WidgetStatePropertyAll(buttonLabelStyle),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: tokens.page,
        indicatorColor: colorScheme.primaryContainer,
        selectedIconTheme: IconThemeData(color: colorScheme.onPrimaryContainer),
        unselectedIconTheme: IconThemeData(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: tokens.object,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dividerTheme: DividerThemeData(
        color: tokens.stroke,
        thickness: 1,
        space: 1,
      ),
      extensions: const [tokens],
    );
    return base;
  }

  static ThemeData light({Locale? locale}) {
    const page = Color(0xFFF6F5F1);
    const section = Color(0xFFF6F5F1);
    const object = Color(0xFFFFFFFF);
    const raised = Color(0xFFFCFBF8);
    const stroke = Color(0xFFE2E1DC);
    const strokeStrong = Color(0xFFC7C6C0);
    const primary = Color(0xFF5B9A1E);
    const secondary = Color(0xFFF77F00);
    const error = Color(0xFFEF4444);

    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: primary,
        ).copyWith(
          primary: primary,
          primaryContainer: const Color(0xFFEDF5E0),
          onPrimaryContainer: const Color(0xFF203807),
          secondary: secondary,
          secondaryContainer: const Color(0xFFFFF0DD),
          onSecondaryContainer: const Color(0xFF5A2F00),
          surface: object,
          surfaceContainer: section,
          surfaceContainerHighest: raised,
          error: error,
        );

    const tokens = QitakThemeTokens(
      page: page,
      section: section,
      object: object,
      raised: raised,
      stroke: stroke,
      strokeStrong: strokeStrong,
      success: Color(0xFF06D6A0),
      warning: Color(0xFFFFB627),
      info: Color(0xFF3B82F6),
      maxContentWidth: 760,
      screenPadding: 20,
      spacingSm: 8,
      spacingMd: 16,
      spacingLg: 24,
      objectRadius: 20,
      fieldRadius: 16,
      sheetRadius: 28,
      panel: object,
      panelMuted: section,
      panelStrong: raised,
      glow: Colors.transparent,
      panelRadius: 20,
      chipRadius: 16,
    );

    final textTheme = _textThemeForLocale(
      ThemeData(brightness: Brightness.light).textTheme,
      locale: locale,
      color: const Color(0xFF1A1C21),
    );
    final buttonLabelStyle = _buttonTextStyle(textTheme);
    final base = dark(locale: locale).copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: tokens.page,
      canvasColor: tokens.section,
      brightness: Brightness.light,
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: page,
        foregroundColor: Color(0xFF1A1C21),
        iconTheme: IconThemeData(color: Color(0xFF1A1C21)),
        actionsIconTheme: IconThemeData(color: Color(0xFF1A1C21)),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: tokens.raised,
        modalBackgroundColor: tokens.raised,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(tokens.sheetRadius),
          ),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: tokens.raised,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.sheetRadius),
          side: BorderSide(color: tokens.stroke),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: tokens.raised,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.fieldRadius),
          side: BorderSide(color: tokens.stroke),
        ),
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: const WidgetStatePropertyAll(raised),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          side: WidgetStatePropertyAll(BorderSide(color: tokens.stroke)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(tokens.fieldRadius),
            ),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: tokens.object,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.objectRadius),
          side: BorderSide(color: tokens.stroke),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: tokens.object,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.fieldRadius),
          borderSide: BorderSide(color: tokens.stroke),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.fieldRadius),
          borderSide: BorderSide(color: tokens.stroke),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.fieldRadius),
          borderSide: const BorderSide(color: primary, width: 1.2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.fieldRadius),
          borderSide: const BorderSide(color: error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.fieldRadius),
          borderSide: const BorderSide(color: error, width: 1.2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(tokens.fieldRadius),
          ),
          textStyle: buttonLabelStyle.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.secondaryContainer,
          foregroundColor: colorScheme.onSecondaryContainer,
          elevation: 0,
          minimumSize: const Size(0, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(tokens.fieldRadius),
          ),
          textStyle: buttonLabelStyle.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(tokens.fieldRadius),
          ),
          side: BorderSide(color: tokens.strokeStrong),
          textStyle: buttonLabelStyle,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(textStyle: buttonLabelStyle),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: tokens.section,
        side: BorderSide(color: tokens.stroke),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.chipRadius),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: tokens.object,
        surfaceTintColor: Colors.transparent,
        indicatorColor: colorScheme.primaryContainer,
        labelTextStyle: WidgetStatePropertyAll(buttonLabelStyle),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: tokens.page,
        indicatorColor: colorScheme.primaryContainer,
        selectedIconTheme: IconThemeData(color: colorScheme.onPrimaryContainer),
        unselectedIconTheme: IconThemeData(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: tokens.object,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dividerTheme: DividerThemeData(
        color: tokens.stroke,
        thickness: 1,
        space: 1,
      ),
      extensions: const [tokens],
    );
    return base;
  }

  static TextTheme _textThemeForLocale(
    TextTheme base, {
    required Locale? locale,
    required Color color,
  }) {
    final usesArabic = locale?.languageCode == 'ar';
    final fontFamily = usesArabic ? _arabicFontFamily : _latinFontFamily;
    final textTheme = base.apply(bodyColor: color, displayColor: color);

    return _withFontFamily(
      textTheme,
      fontFamily: fontFamily,
      fallback: usesArabic
          ? const [_latinFontFamily, 'Segoe UI', 'Tahoma', 'Arial']
          : const [_arabicFontFamily, 'Segoe UI', 'Arial', 'Tahoma'],
    );
  }

  static TextTheme _withFontFamily(
    TextTheme textTheme, {
    required String fontFamily,
    required List<String> fallback,
  }) {
    TextStyle? withFontFamily(TextStyle? style) => style?.copyWith(
      fontFamily: fontFamily,
      fontFamilyFallback: fallback,
    );

    return textTheme.copyWith(
      displayLarge: withFontFamily(textTheme.displayLarge),
      displayMedium: withFontFamily(textTheme.displayMedium),
      displaySmall: withFontFamily(textTheme.displaySmall),
      headlineLarge: withFontFamily(textTheme.headlineLarge),
      headlineMedium: withFontFamily(textTheme.headlineMedium),
      headlineSmall: withFontFamily(textTheme.headlineSmall),
      titleLarge: withFontFamily(textTheme.titleLarge),
      titleMedium: withFontFamily(textTheme.titleMedium),
      titleSmall: withFontFamily(textTheme.titleSmall),
      bodyLarge: withFontFamily(textTheme.bodyLarge),
      bodyMedium: withFontFamily(textTheme.bodyMedium),
      bodySmall: withFontFamily(textTheme.bodySmall),
      labelLarge: withFontFamily(textTheme.labelLarge),
      labelMedium: withFontFamily(textTheme.labelMedium),
      labelSmall: withFontFamily(textTheme.labelSmall),
    );
  }

  static TextStyle _buttonTextStyle(TextTheme textTheme) {
    return textTheme.labelLarge ?? const TextStyle();
  }
}
