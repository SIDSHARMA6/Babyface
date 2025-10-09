import 'package:flutter/material.dart';

/// Typography Manager for Memory Journey Visualizer
/// Implements custom romantic fonts and typography system
class TypographyManager {
  static const String _loveScriptFont = 'LoveScript';
  static const String _romanceSansFont = 'RomanceSans';
  static const String _whisperFont = 'Whisper';
  static const String _tenderRoundedFont = 'TenderRounded';
  static const String _elegantMonoFont = 'ElegantMono';
  static const String _softSansFont = 'SoftSans';

  /// Memory Titles - Flowing, romantic script
  static TextStyle memoryTitle({
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontFamily: _loveScriptFont,
      fontSize: fontSize ?? 20.0,
      color: color ?? Colors.black,
      fontWeight: fontWeight ?? FontWeight.w400,
      letterSpacing: letterSpacing ?? 0.5,
      height: height ?? 1.2,
      shadows: [
        Shadow(
          blurRadius: 2.0,
          color: Colors.black.withValues(alpha: 0.3),
          offset: const Offset(0, 1),
        ),
      ],
    );
  }

  /// Journey Title - Elegant, rounded sans-serif
  static TextStyle journeyTitle({
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontFamily: _romanceSansFont,
      fontSize: fontSize ?? 32.0,
      color: color ?? Colors.black,
      fontWeight: fontWeight ?? FontWeight.w600,
      letterSpacing: letterSpacing ?? 0.8,
      height: height ?? 1.1,
      shadows: [
        Shadow(
          blurRadius: 3.0,
          color: Colors.black.withValues(alpha: 0.2),
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  /// Emotion Labels - Delicate, handwritten style
  static TextStyle emotionLabel({
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontFamily: _whisperFont,
      fontSize: fontSize ?? 14.0,
      color: color ?? Colors.black87,
      fontWeight: fontWeight ?? FontWeight.w300,
      letterSpacing: letterSpacing ?? 1.2,
      height: height ?? 1.3,
      fontStyle: FontStyle.italic,
    );
  }

  /// Memory Descriptions - Friendly, readable
  static TextStyle memoryDescription({
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontFamily: _tenderRoundedFont,
      fontSize: fontSize ?? 16.0,
      color: color ?? Colors.black87,
      fontWeight: fontWeight ?? FontWeight.w400,
      letterSpacing: letterSpacing ?? 0.3,
      height: height ?? 1.4,
    );
  }

  /// Dates & Times - Clean, structured
  static TextStyle dateTime({
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontFamily: _elegantMonoFont,
      fontSize: fontSize ?? 12.0,
      color: color ?? Colors.black54,
      fontWeight: fontWeight ?? FontWeight.w500,
      letterSpacing: letterSpacing ?? 0.8,
      height: height ?? 1.2,
    );
  }

  /// UI Labels - Modern, accessible
  static TextStyle uiLabel({
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontFamily: _softSansFont,
      fontSize: fontSize ?? 14.0,
      color: color ?? Colors.black87,
      fontWeight: fontWeight ?? FontWeight.w500,
      letterSpacing: letterSpacing ?? 0.2,
      height: height ?? 1.3,
    );
  }

  /// Button Text - Romantic, elegant
  static TextStyle buttonText({
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontFamily: _romanceSansFont,
      fontSize: fontSize ?? 16.0,
      color: color ?? Colors.white,
      fontWeight: fontWeight ?? FontWeight.w600,
      letterSpacing: letterSpacing ?? 0.5,
      height: height ?? 1.2,
      shadows: [
        Shadow(
          blurRadius: 1.0,
          color: Colors.black.withValues(alpha: 0.3),
          offset: const Offset(0, 1),
        ),
      ],
    );
  }

  /// Caption Text - Small, subtle
  static TextStyle caption({
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontFamily: _softSansFont,
      fontSize: fontSize ?? 10.0,
      color: color ?? Colors.black38,
      fontWeight: fontWeight ?? FontWeight.w400,
      letterSpacing: letterSpacing ?? 0.5,
      height: height ?? 1.2,
    );
  }

  /// Overlay Text - High contrast, readable
  static TextStyle overlayText({
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontFamily: _romanceSansFont,
      fontSize: fontSize ?? 18.0,
      color: color ?? Colors.white,
      fontWeight: fontWeight ?? FontWeight.w600,
      letterSpacing: letterSpacing ?? 0.3,
      height: height ?? 1.2,
      shadows: [
        Shadow(
          blurRadius: 2.0,
          color: Colors.black.withValues(alpha: 0.7),
          offset: const Offset(0, 1),
        ),
        Shadow(
          blurRadius: 4.0,
          color: Colors.black.withValues(alpha: 0.5),
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  /// Get responsive font size based on screen size
  static double getResponsiveFontSize(
    double baseSize,
    BuildContext context, {
    double? maxSize,
    double? minSize,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth / 375.0; // Base width for mobile
    final scaledSize = baseSize * scaleFactor;

    if (maxSize != null && scaledSize > maxSize) return maxSize;
    if (minSize != null && scaledSize < minSize) return minSize;

    return scaledSize;
  }

  /// Get theme-appropriate text color
  static Color getThemeTextColor(String theme, {bool isPrimary = true}) {
    switch (theme) {
      case 'romantic-sunset':
        return isPrimary ? const Color(0xFF2C3E50) : const Color(0xFF7F8C8D);
      case 'love-garden':
        return isPrimary ? const Color(0xFF2D5016) : const Color(0xFF5D6B47);
      case 'midnight-romance':
        return isPrimary ? const Color(0xFFE8B4B8) : const Color(0xFFB8A8AA);
      default:
        return isPrimary ? Colors.black87 : Colors.black54;
    }
  }

  /// Get theme-appropriate accent color
  static Color getThemeAccentColor(String theme) {
    switch (theme) {
      case 'romantic-sunset':
        return const Color(0xFFFF6B9D);
      case 'love-garden':
        return const Color(0xFF9CAF88);
      case 'midnight-romance':
        return const Color(0xFF4B0082);
      default:
        return const Color(0xFFFF6B9D);
    }
  }

  /// Create text style with theme colors
  static TextStyle themedText(
    String theme,
    TextStyle Function() baseStyle, {
    bool isPrimary = true,
    bool useAccent = false,
  }) {
    final base = baseStyle();
    final color = useAccent
        ? getThemeAccentColor(theme)
        : getThemeTextColor(theme, isPrimary: isPrimary);

    return base.copyWith(color: color);
  }

  /// Get font family name for debugging
  static String getFontFamily(String style) {
    switch (style) {
      case 'memoryTitle':
        return _loveScriptFont;
      case 'journeyTitle':
        return _romanceSansFont;
      case 'emotionLabel':
        return _whisperFont;
      case 'memoryDescription':
        return _tenderRoundedFont;
      case 'dateTime':
        return _elegantMonoFont;
      case 'uiLabel':
      case 'buttonText':
      case 'overlayText':
        return _softSansFont;
      default:
        return _softSansFont;
    }
  }

  /// Check if custom fonts are available
  static bool areCustomFontsAvailable() {
    // In a real implementation, you would check if the font files are loaded
    // For now, we'll return true and fall back to system fonts
    return true;
  }

  /// Get fallback font family
  static String getFallbackFontFamily(String style) {
    switch (style) {
      case 'memoryTitle':
      case 'emotionLabel':
        return 'cursive';
      case 'journeyTitle':
      case 'buttonText':
      case 'overlayText':
        return 'serif';
      case 'memoryDescription':
      case 'uiLabel':
      case 'caption':
        return 'sans-serif';
      case 'dateTime':
        return 'monospace';
      default:
        return 'sans-serif';
    }
  }
}
