import 'package:flutter/material.dart';

class AppTheme {
  // Baby-themed colors
  static const Color primary = Color(0xFFFF6B81); // Cute pink
  static const Color secondary = Color(0xFF6BCBFF); // Soft blue
  static const Color accent = Color(0xFFFFE066); // Yellow spark
  static const Color scaffoldBackground = Color(0xFFFFFCF7); // Cream white

  // Legacy compatibility colors
  static const Color primaryPink = Color(0xFFFF6B81); // Same as primary
  static const Color textSecondary = Color(0xFF6B7280); // Gray text

  // Boy/Girl specific colors
  static const Color boyColor = Color(0xFF6BCBFF);
  static const Color girlColor = Color(0xFFFF6B81);

  // Additional theme colors
  static const Color primaryBlue = Color(0xFF6BCBFF); // Same as secondary
  static const Color textPrimary = Color(0xFF2D3748); // Dark text
  static const Color accentYellow = Color(0xFFFFE066); // Same as accent
  static const Color babyPink = Color(0xFFFF6B81); // Same as primary
  static const Color babyBlue = Color(0xFF6BCBFF); // Same as secondary
  static const Color babyYellow = Color(0xFFFFE066); // Same as accent
  static const Color softPeach = Color(0xFFFFB3BA);
  static const Color lavender = Color(0xFFE6E6FA);
  static const Color mintGreen = Color(0xFF98FB98);

  // Status colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Surface colors
  static const Color surfaceLight = Color(0xFFFFFCF7);
  static const Color backgroundLight = Color(0xFFFFFCF7);
  static const Color borderLight = Color(0xFFE5E7EB);

  // Spacing constants
  static const double smallSpacing = 8.0;
  static const double mediumSpacing = 16.0;
  static const double largeSpacing = 24.0;
  static const double extraLargeSpacing = 32.0;

  // Radius constants
  static const double smallRadius = 8.0;
  static const double mediumRadius = 12.0;
  static const double largeRadius = 16.0;
  static const double extraLargeRadius = 24.0;

  // Animation durations
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);

  // Animation curves
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve smoothCurve = Curves.easeOutCubic;
  static const Curve bouncyCurve = Curves.elasticOut;

  // Shadow definitions
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get mediumShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.15),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get strongShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];

  // Helper methods
  static EdgeInsets cardPadding(BuildContext context) {
    return const EdgeInsets.all(16.0);
  }

  static EdgeInsets get defaultCardPadding => const EdgeInsets.all(16.0);
  static Color get borderColor => borderLight;

  // Gradient colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFFFF8FA3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, Color(0xFF89D4FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, Color(0xFFFFB84D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primary,
      scaffoldBackgroundColor: scaffoldBackground,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: secondary,
        surface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Color(0xFF2D3748),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'BabyFont',
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2D3748),
        ),
        displayMedium: TextStyle(
          fontFamily: 'BabyFont',
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2D3748),
        ),
        headlineLarge: TextStyle(
          fontFamily: 'BabyFont',
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2D3748),
        ),
        headlineMedium: TextStyle(
          fontFamily: 'BabyFont',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2D3748),
        ),
        titleLarge: TextStyle(
          fontFamily: 'BabyFont',
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Color(0xFF2D3748),
        ),
        bodyLarge: TextStyle(
          fontFamily: 'BabyFont',
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: Color(0xFF2D3748),
        ),
        bodyMedium: TextStyle(
          fontFamily: 'BabyFont',
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: Color(0xFF4A5568),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      cardTheme: CardTheme(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: Colors.white,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      primaryColor: primary,
      scaffoldBackgroundColor: const Color(0xFF1A202C),
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: Color(0xFF2D3748),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'BabyFont',
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        displayMedium: TextStyle(
          fontFamily: 'BabyFont',
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'BabyFont',
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'BabyFont',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleLarge: TextStyle(
          fontFamily: 'BabyFont',
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'BabyFont',
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: Colors.white,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'BabyFont',
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: Color(0xFFE2E8F0),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      cardTheme: CardTheme(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: const Color(0xFF2D3748),
      ),
    );
  }
}
