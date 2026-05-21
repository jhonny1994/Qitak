import 'dart:ui';

import 'package:flutter/material.dart';

const _arabicFontFamily = 'Cairo';
const _latinFontFamily = 'Inter';

@immutable
class QitakThemeTokens extends ThemeExtension<QitakThemeTokens> {
  const QitakThemeTokens({
    required this.panel,
    required this.panelMuted,
    required this.panelStrong,
    required this.stroke,
    required this.glow,
    required this.success,
    required this.warning,
    required this.info,
    required this.maxContentWidth,
    required this.screenPadding,
    required this.panelRadius,
    required this.chipRadius,
    required this.fieldRadius,
  });

  final Color panel;
  final Color panelMuted;
  final Color panelStrong;
  final Color stroke;
  final Color glow;
  final Color success;
  final Color warning;
  final Color info;
  final double maxContentWidth;
  final double screenPadding;
  final double panelRadius;
  final double chipRadius;
  final double fieldRadius;

  @override
  QitakThemeTokens copyWith({
    Color? panel,
    Color? panelMuted,
    Color? panelStrong,
    Color? stroke,
    Color? glow,
    Color? success,
    Color? warning,
    Color? info,
    double? maxContentWidth,
    double? screenPadding,
    double? panelRadius,
    double? chipRadius,
    double? fieldRadius,
  }) {
    return QitakThemeTokens(
      panel: panel ?? this.panel,
      panelMuted: panelMuted ?? this.panelMuted,
      panelStrong: panelStrong ?? this.panelStrong,
      stroke: stroke ?? this.stroke,
      glow: glow ?? this.glow,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      maxContentWidth: maxContentWidth ?? this.maxContentWidth,
      screenPadding: screenPadding ?? this.screenPadding,
      panelRadius: panelRadius ?? this.panelRadius,
      chipRadius: chipRadius ?? this.chipRadius,
      fieldRadius: fieldRadius ?? this.fieldRadius,
    );
  }

  @override
  QitakThemeTokens lerp(ThemeExtension<QitakThemeTokens>? other, double t) {
    if (other is! QitakThemeTokens) {
      return this;
    }

    return QitakThemeTokens(
      panel: Color.lerp(panel, other.panel, t) ?? panel,
      panelMuted: Color.lerp(panelMuted, other.panelMuted, t) ?? panelMuted,
      panelStrong: Color.lerp(panelStrong, other.panelStrong, t) ?? panelStrong,
      stroke: Color.lerp(stroke, other.stroke, t) ?? stroke,
      glow: Color.lerp(glow, other.glow, t) ?? glow,
      success: Color.lerp(success, other.success, t) ?? success,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      info: Color.lerp(info, other.info, t) ?? info,
      maxContentWidth:
          lerpDouble(maxContentWidth, other.maxContentWidth, t) ??
          maxContentWidth,
      screenPadding:
          lerpDouble(screenPadding, other.screenPadding, t) ?? screenPadding,
      panelRadius: lerpDouble(panelRadius, other.panelRadius, t) ?? panelRadius,
      chipRadius: lerpDouble(chipRadius, other.chipRadius, t) ?? chipRadius,
      fieldRadius: lerpDouble(fieldRadius, other.fieldRadius, t) ?? fieldRadius,
    );
  }
}

extension QitakThemeX on BuildContext {
  QitakThemeTokens get qitakTokens =>
      Theme.of(this).extension<QitakThemeTokens>()!;
}

class AppTheme {
  static ThemeData dark({Locale? locale}) {
    const background = Color(0xFF0F1117);
    const surface = Color(0xFF1A1D27);
    const surfaceMuted = Color(0xFF1E2129);
    const surfaceStrong = Color(0xFF22262F);
    const primary = Color(0xFF7BBF2E);
    const secondary = Color(0xFFFFB347);
    const error = Color(0xFFF87171);

    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.dark,
          surface: surface,
        ).copyWith(
          primary: primary,
          primaryContainer: const Color(0xFF1A2E0D),
          onPrimaryContainer: const Color(0xFFEAF5D6),
          secondary: secondary,
          secondaryContainer: const Color(0xFF3D2800),
          onSecondaryContainer: const Color(0xFFFFE9C8),
          surface: surface,
          error: error,
        );

    const tokens = QitakThemeTokens(
      panel: surface,
      panelMuted: surfaceMuted,
      panelStrong: surfaceStrong,
      stroke: Color(0xFF2A2E39),
      glow: Colors.transparent,
      success: Color(0xFF34E4B4),
      warning: Color(0xFFFFCB57),
      info: Color(0xFF60A5FA),
      maxContentWidth: 760,
      screenPadding: 20,
      panelRadius: 28,
      chipRadius: 16,
      fieldRadius: 18,
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
      scaffoldBackgroundColor: background,
      canvasColor: surface,
      brightness: Brightness.dark,
      textTheme: textTheme,
      visualDensity: const VisualDensity(horizontal: -0.3, vertical: -0.3),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: Color(0xFFECEEF3),
        iconTheme: IconThemeData(color: Color(0xFFECEEF3)),
        actionsIconTheme: IconThemeData(color: Color(0xFFECEEF3)),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.fieldRadius),
          side: const BorderSide(color: Color(0xFF2A2E39)),
        ),
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: const WidgetStatePropertyAll(surface),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          side: const WidgetStatePropertyAll(
            BorderSide(color: Color(0xFF2A2E39)),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(tokens.fieldRadius),
            ),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.panelRadius),
          side: const BorderSide(color: Color(0xFF2A2E39)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceMuted,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.fieldRadius),
          borderSide: const BorderSide(color: Color(0xFF2A2E39)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.fieldRadius),
          borderSide: const BorderSide(color: Color(0xFF2A2E39)),
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
            borderRadius: BorderRadius.circular(18),
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
            borderRadius: BorderRadius.circular(18),
          ),
          side: const BorderSide(color: Color(0x263F5568)),
          textStyle: buttonLabelStyle,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(textStyle: buttonLabelStyle),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceMuted,
        side: const BorderSide(color: Color(0xFF2A2E39)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.chipRadius),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF2A2E39),
        thickness: 1,
        space: 1,
      ),
      extensions: const [tokens],
    );
    return base;
  }

  static ThemeData light({Locale? locale}) {
    const background = Color(0xFFFAFBFD);
    const surface = Color(0xFFFFFFFF);
    const surfaceMuted = Color(0xFFF3F5F8);
    const surfaceStrong = Color(0xFFFFFFFF);
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
          surface: surface,
          error: error,
        );

    const tokens = QitakThemeTokens(
      panel: surface,
      panelMuted: surfaceMuted,
      panelStrong: surfaceStrong,
      stroke: Color(0xFFE8ECF1),
      glow: Color(0x145B9A1E),
      success: Color(0xFF06D6A0),
      warning: Color(0xFFFFB627),
      info: Color(0xFF3B82F6),
      maxContentWidth: 760,
      screenPadding: 20,
      panelRadius: 28,
      chipRadius: 16,
      fieldRadius: 18,
    );

    final textTheme = _textThemeForLocale(
      ThemeData(brightness: Brightness.light).textTheme,
      locale: locale,
      color: const Color(0xFF1A1C21),
    );
    final buttonLabelStyle = _buttonTextStyle(textTheme);
    final base = dark(locale: locale).copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      canvasColor: surface,
      brightness: Brightness.light,
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: Color(0xFF1A1C21),
        iconTheme: IconThemeData(color: Color(0xFF1A1C21)),
        actionsIconTheme: IconThemeData(color: Color(0xFF1A1C21)),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.fieldRadius),
          side: const BorderSide(color: Color(0xFFE8ECF1)),
        ),
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: const WidgetStatePropertyAll(surface),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          side: const WidgetStatePropertyAll(
            BorderSide(color: Color(0xFFE8ECF1)),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(tokens.fieldRadius),
            ),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.panelRadius),
          side: const BorderSide(color: Color(0xFFE8ECF1)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceMuted,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.fieldRadius),
          borderSide: const BorderSide(color: Color(0xFFE8ECF1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.fieldRadius),
          borderSide: const BorderSide(color: Color(0xFFE8ECF1)),
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
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE8ECF1),
        thickness: 1,
        space: 1,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
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
            borderRadius: BorderRadius.circular(18),
          ),
          side: const BorderSide(color: Color(0xFFE8ECF1)),
          textStyle: buttonLabelStyle,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(textStyle: buttonLabelStyle),
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
