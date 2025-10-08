import 'package:flutter/material.dart';

enum Season {
  spring,
  summer,
  autumn,
  winter,
}

class SeasonalThemeService {
  static Season getCurrentSeason() {
    final month = DateTime.now().month;
    switch (month) {
      case 3:
      case 4:
      case 5:
        return Season.spring;
      case 6:
      case 7:
      case 8:
        return Season.summer;
      case 9:
      case 10:
      case 11:
        return Season.autumn;
      case 12:
      case 1:
      case 2:
        return Season.winter;
      default:
        return Season.spring;
    }
  }

  static Color getRoadColor(Season season) {
    switch (season) {
      case Season.spring:
        return const Color(0xFF8FBC8F); // Light green
      case Season.summer:
        return const Color(0xFF87CEEB); // Sky blue
      case Season.autumn:
        return const Color(0xFFD2691E); // Chocolate
      case Season.winter:
        return const Color(0xFFB0C4DE); // Light steel blue
    }
  }

  static Color getRoadShadowColor(Season season) {
    switch (season) {
      case Season.spring:
        return const Color(0xFF6B8E6B); // Darker green
      case Season.summer:
        return const Color(0xFF5F9EA0); // Cadet blue
      case Season.autumn:
        return const Color(0xFFA0522D); // Sienna
      case Season.winter:
        return const Color(0xFF778899); // Light slate gray
    }
  }

  static Color getPinColor(Season season) {
    switch (season) {
      case Season.spring:
        return const Color(0xFFFFB6C1); // Light pink
      case Season.summer:
        return const Color(0xFFFFD700); // Gold
      case Season.autumn:
        return const Color(0xFFFF6347); // Tomato
      case Season.winter:
        return const Color(0xFFE6E6FA); // Lavender
    }
  }

  static Color getPinAccentColor(Season season) {
    switch (season) {
      case Season.spring:
        return const Color(0xFFFF69B4); // Hot pink
      case Season.summer:
        return const Color(0xFFFF8C00); // Dark orange
      case Season.autumn:
        return const Color(0xFFDC143C); // Crimson
      case Season.winter:
        return const Color(0xFF9370DB); // Medium purple
    }
  }

  static String getSeasonalEmoji(Season season) {
    switch (season) {
      case Season.spring:
        return '🌸';
      case Season.summer:
        return '☀️';
      case Season.autumn:
        return '🍂';
      case Season.winter:
        return '❄️';
    }
  }

  static String getSeasonalMessage(Season season) {
    switch (season) {
      case Season.spring:
        return 'Spring memories blooming along your journey';
      case Season.summer:
        return 'Summer adventures lighting up your path';
      case Season.autumn:
        return 'Autumn colors painting your love story';
      case Season.winter:
        return 'Winter warmth in your memory lane';
    }
  }

  static List<Color> getSeasonalGradientColors(Season season) {
    switch (season) {
      case Season.spring:
        return [
          const Color(0xFFE8F5E8), // Very light green
          const Color(0xFFF0FFF0), // Honeydew
          const Color(0xFFF5FFFA), // Mint cream
        ];
      case Season.summer:
        return [
          const Color(0xFFE0F6FF), // Light cyan
          const Color(0xFFF0F8FF), // Alice blue
          const Color(0xFFF5F5FF), // Ghost white
        ];
      case Season.autumn:
        return [
          const Color(0xFFFFF8DC), // Cornsilk
          const Color(0xFFFFFACD), // Lemon chiffon
          const Color(0xFFFFF5EE), // Seashell
        ];
      case Season.winter:
        return [
          const Color(0xFFF0F8FF), // Alice blue
          const Color(0xFFF5F5FF), // Ghost white
          const Color(0xFFFFFFFF), // White
        ];
    }
  }
}
