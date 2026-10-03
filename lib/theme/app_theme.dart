import 'package:flutter/material.dart';

import 'tokens.dart';

abstract final class AppTheme {
  static ThemeData light() => _build(SteadyColors.light, Brightness.light);
  static ThemeData dark() => _build(SteadyColors.dark, Brightness.dark);

  static ThemeData _build(SteadyColors c, Brightness brightness) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: c.primary,
      onPrimary: c.onPrimary,
      primaryContainer: c.primarySoft,
      onPrimaryContainer: c.ink,
      secondary: c.highlight,
      onSecondary: c.onHighlight,
      error: c.dangerFg,
      onError: c.surface,
      errorContainer: c.dangerBg,
      onErrorContainer: c.dangerFg,
      surface: c.surface,
      onSurface: c.ink,
      onSurfaceVariant: c.muted,
      surfaceContainerHighest: c.raised,
      outline: c.inputBorder,
      outlineVariant: c.line,
    );

    final textTheme = TextTheme(
      displayLarge: SteadyType.amountXl,
      headlineSmall: SteadyType.title,
      titleMedium: SteadyType.heading,
      bodyLarge: SteadyType.body,
      bodyMedium: SteadyType.body,
      bodySmall: SteadyType.caption,
      labelLarge: SteadyType.button,
      labelSmall: SteadyType.overline,
    ).apply(bodyColor: c.ink, displayColor: c.ink);

    final pill = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(SteadyRadius.pill),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.ground,
      fontFamily: SteadyFonts.body,
      textTheme: textTheme,
      extensions: [c],
      dividerTheme: DividerThemeData(color: c.lineSoft, thickness: 1, space: 1),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(SteadySize.buttonLarge),
          backgroundColor: c.primary,
          foregroundColor: c.onPrimary,
          disabledBackgroundColor: c.disabledBg,
          disabledForegroundColor: c.disabledFg,
          textStyle: SteadyType.button,
          shape: pill,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(SteadySize.buttonLarge),
          foregroundColor: c.ink,
          backgroundColor: c.surface,
          side: BorderSide(color: c.ink, width: 1.5),
          textStyle: SteadyType.button,
          shape: pill,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.primary,
          minimumSize: const Size(
            SteadySize.minTouchTarget,
            SteadySize.minTouchTarget,
          ),
          textStyle: SteadyType.caption.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.raised,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(SteadyRadius.xl),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: c.ink,
        contentTextStyle: SteadyType.body.copyWith(color: c.ground),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SteadyRadius.md),
        ),
      ),
    );
  }
}
