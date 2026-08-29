import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

/// Custom Theme Extension allowing clean access to ZenFlow's specific surface & accent tokens
class ZenColors extends ThemeExtension<ZenColors> {
  final Color canvas;
  final Color surface;
  final Color card;
  final Color elevated;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color subtleFill;
  final Color accent;
  final Color accentSoft;
  final Color accentLightBg;
  final Color accentLightBorder;
  final bool isDark;

  const ZenColors({
    required this.canvas,
    required this.surface,
    required this.card,
    required this.elevated,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.subtleFill,
    required this.accent,
    required this.accentSoft,
    required this.accentLightBg,
    required this.accentLightBorder,
    required this.isDark,
  });

  @override
  ZenColors copyWith({
    Color? canvas,
    Color? surface,
    Color? card,
    Color? elevated,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? subtleFill,
    Color? accent,
    Color? accentSoft,
    Color? accentLightBg,
    Color? accentLightBorder,
    bool? isDark,
  }) {
    return ZenColors(
      canvas: canvas ?? this.canvas,
      surface: surface ?? this.surface,
      card: card ?? this.card,
      elevated: elevated ?? this.elevated,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      subtleFill: subtleFill ?? this.subtleFill,
      accent: accent ?? this.accent,
      accentSoft: accentSoft ?? this.accentSoft,
      accentLightBg: accentLightBg ?? this.accentLightBg,
      accentLightBorder: accentLightBorder ?? this.accentLightBorder,
      isDark: isDark ?? this.isDark,
    );
  }

  @override
  ZenColors lerp(ThemeExtension<ZenColors>? other, double t) {
    if (other is! ZenColors) return this;
    return ZenColors(
      canvas: Color.lerp(canvas, other.canvas, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      card: Color.lerp(card, other.card, t)!,
      elevated: Color.lerp(elevated, other.elevated, t)!,
      border: Color.lerp(border, other.border, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      subtleFill: Color.lerp(subtleFill, other.subtleFill, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      accentLightBg: Color.lerp(accentLightBg, other.accentLightBg, t)!,
      accentLightBorder: Color.lerp(accentLightBorder, other.accentLightBorder, t)!,
      isDark: t < 0.5 ? isDark : other.isDark,
    );
  }
}

extension BuildContextZenColors on BuildContext {
  ZenColors get zenColors =>
      Theme.of(this).extension<ZenColors>() ??
      const ZenColors(
        canvas: AppColors.lightCanvas,
        surface: AppColors.lightSurface,
        card: AppColors.lightCard,
        elevated: AppColors.lightSurface,
        border: AppColors.lightBorder,
        textPrimary: AppColors.lightTextPrimary,
        textSecondary: AppColors.lightTextSecondary,
        textMuted: AppColors.lightMuted,
        subtleFill: AppColors.lightSubtleFill,
        accent: Color(0xFF1D70E8),
        accentSoft: Color(0xFFE2EEFC),
        accentLightBg: Color(0xFFF5F9FE),
        accentLightBorder: Color(0xFFD7E7FA),
        isDark: false,
      );
}

class ZenFlowTheme {
  ZenFlowTheme._();

  static ThemeData lightTheme([AppAccentColor accentColor = AppAccentColor.blue]) {
    final palette = AppColors.accents[accentColor] ?? AppColors.accents[AppAccentColor.blue]!;
    final zenColors = ZenColors(
      canvas: AppColors.lightCanvas,
      surface: AppColors.lightSurface,
      card: AppColors.lightCard,
      elevated: AppColors.lightSurface,
      border: AppColors.lightBorder,
      textPrimary: AppColors.lightTextPrimary,
      textSecondary: AppColors.lightTextSecondary,
      textMuted: AppColors.lightMuted,
      subtleFill: AppColors.lightSubtleFill,
      accent: palette.base,
      accentSoft: palette.soft,
      accentLightBg: palette.lightBg,
      accentLightBorder: palette.lightBorder,
      isDark: false,
    );

    final colorScheme = ColorScheme.light(
      primary: palette.base,
      onPrimary: Colors.white,
      secondary: palette.soft,
      onSecondary: palette.base,
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightTextPrimary,
      error: AppColors.danger,
      onError: Colors.white,
      outline: AppColors.lightBorder,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.lightCanvas,
      extensions: [zenColors],
      textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.light().textTheme).copyWith(
        displayLarge: AppTextStyles.displayLarge(AppColors.lightTextPrimary),
        displayMedium: AppTextStyles.displayMedium(AppColors.lightTextPrimary),
        headlineLarge: AppTextStyles.headingLarge(AppColors.lightTextPrimary),
        headlineMedium: AppTextStyles.headingMedium(AppColors.lightTextPrimary),
        headlineSmall: AppTextStyles.headingSmall(AppColors.lightTextPrimary),
        bodyLarge: AppTextStyles.bodyLarge(AppColors.lightTextPrimary),
        bodyMedium: AppTextStyles.bodyMedium(AppColors.lightTextPrimary),
        bodySmall: AppTextStyles.bodySmall(AppColors.lightTextSecondary),
        labelLarge: AppTextStyles.labelLarge(AppColors.lightTextPrimary),
        labelMedium: AppTextStyles.labelMedium(AppColors.lightTextSecondary),
        labelSmall: AppTextStyles.labelSmall(AppColors.lightMuted),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: IconThemeData(color: AppColors.lightTextPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.base,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          textStyle: AppTextStyles.labelLarge(Colors.white),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.lightTextPrimary,
          minimumSize: const Size.fromHeight(48),
          side: const BorderSide(color: AppColors.lightBorder, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          textStyle: AppTextStyles.labelLarge(AppColors.lightTextPrimary),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: AppTextStyles.bodyMedium(AppColors.lightMuted),
        labelStyle: AppTextStyles.bodyMedium(AppColors.lightTextSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: palette.base, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.danger, width: 1),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.lightBorder,
        thickness: 1,
        space: 1,
      ),
    );
  }

  static ThemeData darkTheme([AppAccentColor accentColor = AppAccentColor.blue]) {
    final palette = AppColors.accents[accentColor] ?? AppColors.accents[AppAccentColor.blue]!;
    final zenColors = ZenColors(
      canvas: palette.darkCanvas,
      surface: palette.darkSurface,
      card: palette.darkSurface,
      elevated: palette.darkElevated,
      border: palette.darkBorder,
      textPrimary: AppColors.darkTextPrimary,
      textSecondary: AppColors.darkTextSecondary,
      textMuted: AppColors.darkMuted,
      subtleFill: palette.darkSoftFill,
      accent: palette.base,
      accentSoft: palette.darkSoftFill,
      accentLightBg: palette.darkSurface,
      accentLightBorder: palette.darkBorder,
      isDark: true,
    );

    final colorScheme = ColorScheme.dark(
      primary: palette.base,
      onPrimary: Colors.white,
      secondary: palette.darkSoftFill,
      onSecondary: palette.base,
      surface: palette.darkSurface,
      onSurface: AppColors.darkTextPrimary,
      error: AppColors.danger,
      onError: Colors.white,
      outline: palette.darkBorder,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: palette.darkCanvas,
      extensions: [zenColors],
      textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: AppTextStyles.displayLarge(AppColors.darkTextPrimary),
        displayMedium: AppTextStyles.displayMedium(AppColors.darkTextPrimary),
        headlineLarge: AppTextStyles.headingLarge(AppColors.darkTextPrimary),
        headlineMedium: AppTextStyles.headingMedium(AppColors.darkTextPrimary),
        headlineSmall: AppTextStyles.headingSmall(AppColors.darkTextPrimary),
        bodyLarge: AppTextStyles.bodyLarge(AppColors.darkTextPrimary),
        bodyMedium: AppTextStyles.bodyMedium(AppColors.darkTextPrimary),
        bodySmall: AppTextStyles.bodySmall(AppColors.darkTextSecondary),
        labelLarge: AppTextStyles.labelLarge(AppColors.darkTextPrimary),
        labelMedium: AppTextStyles.labelMedium(AppColors.darkTextSecondary),
        labelSmall: AppTextStyles.labelSmall(AppColors.darkMuted),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: IconThemeData(color: AppColors.darkTextPrimary),
      ),
      cardTheme: CardThemeData(
        color: palette.darkSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: palette.darkBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.base,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          textStyle: AppTextStyles.labelLarge(Colors.white),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkTextPrimary,
          minimumSize: const Size.fromHeight(48),
          side: BorderSide(color: palette.darkBorder, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          textStyle: AppTextStyles.labelLarge(AppColors.darkTextPrimary),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.darkSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: AppTextStyles.bodyMedium(AppColors.darkMuted),
        labelStyle: AppTextStyles.bodyMedium(AppColors.darkTextSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: palette.darkBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: palette.darkBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: palette.base, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.danger, width: 1),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: palette.darkSurface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: palette.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: palette.darkBorder, width: 1),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: palette.darkBorder,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
