import 'package:flutter/material.dart';

/// Theme Manager for Memory Journey Visualizer
/// Provides 3 complete romantic themes with color palettes and typography
class ThemeManager {
  static const String romanticSunset = 'romantic-sunset';
  static const String loveGarden = 'love-garden';
  static const String midnightRomance = 'midnight-romance';

  /// Get theme colors for a specific theme
  static Map<String, Color> getThemeColors(String theme) {
    switch (theme) {
      case romanticSunset:
        return _romanticSunsetColors;
      case loveGarden:
        return _loveGardenColors;
      case midnightRomance:
        return _midnightRomanceColors;
      default:
        return _romanticSunsetColors;
    }
  }

  /// Get theme gradients for backgrounds
  static Map<String, LinearGradient> getThemeGradients(String theme) {
    switch (theme) {
      case romanticSunset:
        return _romanticSunsetGradients;
      case loveGarden:
        return _loveGardenGradients;
      case midnightRomance:
        return _midnightRomanceGradients;
      default:
        return _romanticSunsetGradients;
    }
  }

  /// Get theme typography
  static Map<String, TextStyle> getThemeTypography(String theme) {
    switch (theme) {
      case romanticSunset:
        return _romanticSunsetTypography;
      case loveGarden:
        return _loveGardenTypography;
      case midnightRomance:
        return _midnightRomanceTypography;
      default:
        return _romanticSunsetTypography;
    }
  }

  /// Get all available themes
  static List<ThemeInfo> getAllThemes() {
    return [
      ThemeInfo(
        id: romanticSunset,
        name: 'Romantic Sunset',
        description: 'Warm golden hour with soft rose tones',
        primaryColor: const Color(0xFFFF6B9D),
        previewColors: [
          const Color(0xFFFF6B9D),
          const Color(0xFFFFB347),
          const Color(0xFF2C3E50),
          const Color(0xFFDDA0DD),
        ],
      ),
      ThemeInfo(
        id: loveGarden,
        name: 'Love Garden',
        description: 'Fresh spring garden with gentle pastels',
        primaryColor: const Color(0xFFFFB6C1),
        previewColors: [
          const Color(0xFFFFB6C1),
          const Color(0xFF9CAF88),
          const Color(0xFF98FB98),
          const Color(0xFFD4A5A5),
        ],
      ),
      ThemeInfo(
        id: midnightRomance,
        name: 'Midnight Romance',
        description: 'Elegant evening with deep purples and gold',
        primaryColor: const Color(0xFF4B0082),
        previewColors: [
          const Color(0xFF4B0082),
          const Color(0xFFC0C0C0),
          const Color(0xFFE8B4B8),
          const Color(0xFF191970),
        ],
      ),
    ];
  }

  // Romantic Sunset Theme Colors
  static const Map<String, Color> _romanticSunsetColors = {
    'primary': Color(0xFFFF6B9D), // Soft Rose
    'secondary': Color(0xFFFFB347), // Golden Hour
    'accent': Color(0xFFDDA0DD), // Soft Lavender
    'background': Color(0xFF2C3E50), // Deep Twilight
    'surface': Color(0xFF34495E), // Lighter Twilight
    'text': Color(0xFFF8F8FF), // Pearl White
    'textSecondary': Color(0xFFBDC3C7), // Light Gray
    'road': Color(0xFFE74C3C), // Warm Red
    'roadHighlight': Color(0xFFFF6B9D), // Soft Rose
    'marker': Color(0xFFFF6B9D), // Soft Rose
    'markerGlow': Color(0xFFFF6B9D), // Soft Rose
    'particle': Color(0xFFFFB347), // Golden Hour
    'heart': Color(0xFFFF6B9D), // Soft Rose
    'sparkle': Color(0xFFFFFFFF), // White
    'shadow': Color(0x80000000), // Black with opacity
  };

  // Love Garden Theme Colors
  static const Map<String, Color> _loveGardenColors = {
    'primary': Color(0xFFFFB6C1), // Blush Pink
    'secondary': Color(0xFF9CAF88), // Sage Green
    'accent': Color(0xFF98FB98), // Soft Mint
    'background': Color(0xFFF0F8F0), // Light Green
    'surface': Color(0xFFFFFFFF), // White
    'text': Color(0xFF2C3E50), // Dark Blue-Gray
    'textSecondary': Color(0xFF7F8C8D), // Medium Gray
    'road': Color(0xFF9CAF88), // Sage Green
    'roadHighlight': Color(0xFF98FB98), // Soft Mint
    'marker': Color(0xFFFFB6C1), // Blush Pink
    'markerGlow': Color(0xFFFFB6C1), // Blush Pink
    'particle': Color(0xFF98FB98), // Soft Mint
    'heart': Color(0xFFFFB6C1), // Blush Pink
    'sparkle': Color(0xFF9CAF88), // Sage Green
    'shadow': Color(0x40000000), // Black with opacity
  };

  // Midnight Romance Theme Colors
  static const Map<String, Color> _midnightRomanceColors = {
    'primary': Color(0xFF4B0082), // Deep Purple
    'secondary': Color(0xFFC0C0C0), // Silver
    'accent': Color(0xFFE8B4B8), // Rose Gold
    'background': Color(0xFF191970), // Midnight Blue
    'surface': Color(0xFF2C2C54), // Dark Purple
    'text': Color(0xFFF8F8FF), // Pearl White
    'textSecondary': Color(0xFFBDC3C7), // Light Gray
    'road': Color(0xFF4B0082), // Deep Purple
    'roadHighlight': Color(0xFFE8B4B8), // Rose Gold
    'marker': Color(0xFFE8B4B8), // Rose Gold
    'markerGlow': Color(0xFFE8B4B8), // Rose Gold
    'particle': Color(0xFFC0C0C0), // Silver
    'heart': Color(0xFFE8B4B8), // Rose Gold
    'sparkle': Color(0xFFFFFFFF), // White
    'shadow': Color(0x80000000), // Black with opacity
  };

  // Romantic Sunset Gradients
  static const Map<String, LinearGradient> _romanticSunsetGradients = {
    'background': LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF2C3E50),
        Color(0xFF34495E),
        Color(0xFF2C3E50),
      ],
    ),
    'road': LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFFFF6B9D),
        Color(0xFFE74C3C),
        Color(0xFFFF6B9D),
      ],
    ),
    'marker': LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFFF6B9D),
        Color(0xFFFFB347),
      ],
    ),
  };

  // Love Garden Gradients
  static const Map<String, LinearGradient> _loveGardenGradients = {
    'background': LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFF0F8F0),
        Color(0xFFFFFFFF),
        Color(0xFFF0F8F0),
      ],
    ),
    'road': LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFF9CAF88),
        Color(0xFF98FB98),
        Color(0xFF9CAF88),
      ],
    ),
    'marker': LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFFFB6C1),
        Color(0xFF9CAF88),
      ],
    ),
  };

  // Midnight Romance Gradients
  static const Map<String, LinearGradient> _midnightRomanceGradients = {
    'background': LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF191970),
        Color(0xFF2C2C54),
        Color(0xFF191970),
      ],
    ),
    'road': LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFF4B0082),
        Color(0xFFE8B4B8),
        Color(0xFF4B0082),
      ],
    ),
    'marker': LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFE8B4B8),
        Color(0xFFC0C0C0),
      ],
    ),
  };

  // Romantic Sunset Typography
  static const Map<String, TextStyle> _romanticSunsetTypography = {
    'title': TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w300,
      color: Color(0xFFF8F8FF),
      letterSpacing: 1.2,
    ),
    'subtitle': TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w400,
      color: Color(0xFFBDC3C7),
      letterSpacing: 0.8,
    ),
    'memoryTitle': TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Color(0xFFF8F8FF),
      letterSpacing: 0.5,
    ),
    'memoryDate': TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: Color(0xFFBDC3C7),
      letterSpacing: 0.3,
    ),
    'button': TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Color(0xFFF8F8FF),
      letterSpacing: 0.5,
    ),
  };

  // Love Garden Typography
  static const Map<String, TextStyle> _loveGardenTypography = {
    'title': TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w300,
      color: Color(0xFF2C3E50),
      letterSpacing: 1.2,
    ),
    'subtitle': TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w400,
      color: Color(0xFF7F8C8D),
      letterSpacing: 0.8,
    ),
    'memoryTitle': TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Color(0xFF2C3E50),
      letterSpacing: 0.5,
    ),
    'memoryDate': TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: Color(0xFF7F8C8D),
      letterSpacing: 0.3,
    ),
    'button': TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Color(0xFF2C3E50),
      letterSpacing: 0.5,
    ),
  };

  // Midnight Romance Typography
  static const Map<String, TextStyle> _midnightRomanceTypography = {
    'title': TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w300,
      color: Color(0xFFF8F8FF),
      letterSpacing: 1.2,
    ),
    'subtitle': TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w400,
      color: Color(0xFFBDC3C7),
      letterSpacing: 0.8,
    ),
    'memoryTitle': TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Color(0xFFF8F8FF),
      letterSpacing: 0.5,
    ),
    'memoryDate': TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: Color(0xFFBDC3C7),
      letterSpacing: 0.3,
    ),
    'button': TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Color(0xFFF8F8FF),
      letterSpacing: 0.5,
    ),
  };
}

/// Theme information class
class ThemeInfo {
  final String id;
  final String name;
  final String description;
  final Color primaryColor;
  final List<Color> previewColors;

  const ThemeInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.primaryColor,
    required this.previewColors,
  });
}
