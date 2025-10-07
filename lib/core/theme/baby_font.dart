import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Baby-themed font system with responsive text sizing
class BabyFont {
  // Font families (using Handcaps as primary font)
  static const String primaryFont = 'Handcaps';
  static const String secondaryFont = 'Handcaps';
  static const String systemFont = 'System';

  // Fallback font families
  static const List<String> primaryFontFallback = [
    'Handcaps',
    'Roboto',
    'Arial'
  ];
  static const List<String> secondaryFontFallback = [
    'Handcaps',
    'Roboto',
    'Arial'
  ];

  /// Helper method to create TextStyle with fallback fonts
  static TextStyle _createTextStyle({
    required String fontFamily,
    required List<String> fontFamilyFallback,
    required double fontSize,
    required FontWeight fontWeight,
    double? height,
    double? letterSpacing,
    FontStyle? fontStyle,
    TextDecoration? decoration,
    Color? color,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
      fontStyle: fontStyle,
      decoration: decoration,
      color: color,
    );
  }

  // Font weights
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;

  // Additional font styles
  static TextStyle get heading1 => _createTextStyle(
        fontFamily: primaryFont,
        fontFamilyFallback: primaryFontFallback,
        fontSize: 32.sp,
        fontWeight: bold,
        height: 1.2,
      );

  static TextStyle get heading3 => _createTextStyle(
        fontFamily: primaryFont,
        fontFamilyFallback: primaryFontFallback,
        fontSize: 24.sp,
        fontWeight: semiBold,
        height: 1.3,
      );

  static TextStyle get headingM => _createTextStyle(
        fontFamily: primaryFont,
        fontFamilyFallback: primaryFontFallback,
        fontSize: 20.sp,
        fontWeight: semiBold,
        height: 1.3,
      );

  static TextStyle get headingS => _createTextStyle(
        fontFamily: primaryFont,
        fontFamilyFallback: primaryFontFallback,
        fontSize: 18.sp,
        fontWeight: semiBold,
        height: 1.3,
      );

  static TextStyle get headingL => _createTextStyle(
        fontFamily: primaryFont,
        fontFamilyFallback: primaryFontFallback,
        fontSize: 28.sp,
        fontWeight: bold,
        height: 1.2,
      );

  static TextStyle get body1 => _createTextStyle(
        fontFamily: primaryFont,
        fontFamilyFallback: primaryFontFallback,
        fontSize: 16.sp,
        fontWeight: regular,
        height: 1.5,
      );

  static TextStyle get body2 => _createTextStyle(
        fontFamily: primaryFont,
        fontFamilyFallback: primaryFontFallback,
        fontSize: 14.sp,
        fontWeight: regular,
        height: 1.4,
      );

  static TextStyle get bodyL => _createTextStyle(
        fontFamily: primaryFont,
        fontFamilyFallback: primaryFontFallback,
        fontSize: 18.sp,
        fontWeight: regular,
        height: 1.5,
      );

  static TextStyle get bodyM => _createTextStyle(
        fontFamily: primaryFont,
        fontFamilyFallback: primaryFontFallback,
        fontSize: 16.sp,
        fontWeight: regular,
        height: 1.5,
      );

  static TextStyle get bodyS => _createTextStyle(
        fontFamily: primaryFont,
        fontFamilyFallback: primaryFontFallback,
        fontSize: 14.sp,
        fontWeight: regular,
        height: 1.4,
      );

  static TextStyle get caption => _createTextStyle(
        fontFamily: primaryFont,
        fontFamilyFallback: primaryFontFallback,
        fontSize: 12.sp,
        fontWeight: regular,
        height: 1.3,
      );

  /// Display text styles (large headings)
  static TextStyle get displayLarge => TextStyle(
        fontFamily: secondaryFont,
        fontFamilyFallback: secondaryFontFallback,
        fontSize: 32.sp,
        fontWeight: extraBold,
        height: 1.2,
        letterSpacing: -0.5,
      );

  static TextStyle get displayMedium => _createTextStyle(
        fontFamily: secondaryFont,
        fontFamilyFallback: secondaryFontFallback,
        fontSize: 28.sp,
        fontWeight: bold,
        height: 1.2,
        letterSpacing: -0.25,
      );

  static TextStyle get displaySmall => _createTextStyle(
        fontFamily: secondaryFont,
        fontFamilyFallback: secondaryFontFallback,
        fontSize: 24.sp,
        fontWeight: bold,
        height: 1.3,
      );

  /// Headline text styles
  static TextStyle get headlineLarge => TextStyle(
        fontFamily: primaryFont,
        fontSize: 22.sp,
        fontWeight: semiBold,
        height: 1.3,
      );

  static TextStyle get headlineMedium => TextStyle(
        fontFamily: primaryFont,
        fontSize: 20.sp,
        fontWeight: semiBold,
        height: 1.3,
      );

  static TextStyle get headlineSmall => TextStyle(
        fontFamily: primaryFont,
        fontSize: 18.sp,
        fontWeight: semiBold,
        height: 1.4,
      );

  /// Title text styles
  static TextStyle get titleLarge => TextStyle(
        fontFamily: primaryFont,
        fontSize: 16.sp,
        fontWeight: medium,
        height: 1.4,
      );

  static TextStyle get titleMedium => TextStyle(
        fontFamily: primaryFont,
        fontSize: 14.sp,
        fontWeight: medium,
        height: 1.4,
      );

  static TextStyle get titleSmall => TextStyle(
        fontFamily: primaryFont,
        fontSize: 12.sp,
        fontWeight: medium,
        height: 1.4,
      );

  /// Body text styles
  static TextStyle get bodyLarge => TextStyle(
        fontFamily: primaryFont,
        fontSize: 16.sp,
        fontWeight: regular,
        height: 1.5,
      );

  static TextStyle get bodyMedium => TextStyle(
        fontFamily: primaryFont,
        fontSize: 14.sp,
        fontWeight: regular,
        height: 1.5,
      );

  static TextStyle get bodySmall => TextStyle(
        fontFamily: primaryFont,
        fontSize: 12.sp,
        fontWeight: regular,
        height: 1.5,
      );

  /// Label text styles (buttons, chips, etc.)
  static TextStyle get labelLarge => TextStyle(
        fontFamily: primaryFont,
        fontSize: 14.sp,
        fontWeight: medium,
        height: 1.4,
        letterSpacing: 0.1,
      );

  static TextStyle get labelMedium => TextStyle(
        fontFamily: primaryFont,
        fontSize: 12.sp,
        fontWeight: medium,
        height: 1.4,
        letterSpacing: 0.5,
      );

  static TextStyle get labelSmall => TextStyle(
        fontFamily: primaryFont,
        fontSize: 10.sp,
        fontWeight: medium,
        height: 1.4,
        letterSpacing: 0.5,
      );

  /// Special baby-themed text styles
  static TextStyle get babyTitle => TextStyle(
        fontFamily: secondaryFont,
        fontSize: 28.sp,
        fontWeight: extraBold,
        height: 1.2,
        letterSpacing: 1.0,
      );

  static TextStyle get cuteButton => TextStyle(
        fontFamily: primaryFont,
        fontSize: 16.sp,
        fontWeight: semiBold,
        height: 1.2,
        letterSpacing: 0.5,
      );

  static TextStyle get playfulCaption => TextStyle(
        fontFamily: primaryFont,
        fontSize: 12.sp,
        fontWeight: medium,
        height: 1.3,
        letterSpacing: 0.3,
        fontStyle: FontStyle.italic,
      );

  /// Responsive text scaling based on screen size
  static double getScaleFactor() {
    final screenWidth = 1.sw;
    if (screenWidth > 600) {
      return 1.2; // Tablet scale
    } else if (screenWidth > 400) {
      return 1.0; // Phone scale
    } else {
      return 0.9; // Small phone scale
    }
  }

  /// Apply responsive scaling to any text style
  static TextStyle responsive(TextStyle style) {
    final scaleFactor = getScaleFactor();
    return style.copyWith(
      fontSize: (style.fontSize ?? 14.sp) * scaleFactor,
    );
  }

  /// Get text theme for Material Theme
  static TextTheme getTextTheme(Color primaryColor, Color onSurface) {
    return TextTheme(
      displayLarge: displayLarge.copyWith(color: primaryColor),
      displayMedium: displayMedium.copyWith(color: primaryColor),
      displaySmall: displaySmall.copyWith(color: primaryColor),
      headlineLarge: headlineLarge.copyWith(color: onSurface),
      headlineMedium: headlineMedium.copyWith(color: onSurface),
      headlineSmall: headlineSmall.copyWith(color: onSurface),
      titleLarge: titleLarge.copyWith(color: onSurface),
      titleMedium: titleMedium.copyWith(color: onSurface),
      titleSmall: titleSmall.copyWith(color: onSurface),
      bodyLarge: bodyLarge.copyWith(color: onSurface),
      bodyMedium: bodyMedium.copyWith(color: onSurface),
      bodySmall: bodySmall.copyWith(color: onSurface.withValues(alpha: 0.7)),
      labelLarge: labelLarge.copyWith(color: onSurface),
      labelMedium:
          labelMedium.copyWith(color: onSurface.withValues(alpha: 0.8)),
      labelSmall: labelSmall.copyWith(color: onSurface.withValues(alpha: 0.6)),
    );
  }

  /// Text styles for different contexts
  static TextStyle errorText = bodySmall.copyWith(
    color: const Color(0xFFFF3B30),
    fontWeight: medium,
  );

  static TextStyle successText = bodySmall.copyWith(
    color: const Color(0xFF34C759),
    fontWeight: medium,
  );

  static TextStyle warningText = bodySmall.copyWith(
    color: const Color(0xFFFF9500),
    fontWeight: medium,
  );

  static TextStyle linkText = bodyMedium.copyWith(
    color: const Color(0xFF007AFF),
    fontWeight: medium,
    decoration: TextDecoration.underline,
  );
}
