import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_theme.dart';
import 'responsive_utils.dart';
import 'baby_font.dart';

// Re-export ButtonType and ButtonSize from optimized_widget.dart
export '../../shared/widgets/optimized_widget.dart' show ButtonType, ButtonSize;

/// Theme extensions for performance optimizations
/// Follows master plan theme standards
extension ThemeExtensions on BuildContext {
  /// Get responsive theme data
  ResponsiveThemeData get responsiveTheme {
    return ResponsiveThemeData(
      theme: AppTheme(),
      responsive: ResponsiveData(
        isMobile: ResponsiveUtils.isMobile(this),
        isTablet: ResponsiveUtils.isTablet(this),
        isDesktop: ResponsiveUtils.isDesktop(this),
        screenWidth: ResponsiveUtils.screenWidth(this),
        screenHeight: ResponsiveUtils.screenHeight(this),
      ),
    );
  }

  // Responsive methods are defined in ResponsiveContext extension
}

/// Responsive theme data class
class ResponsiveThemeData {
  final AppTheme theme;
  final ResponsiveData responsive;

  const ResponsiveThemeData({
    required this.theme,
    required this.responsive,
  });

  /// Get spacing data
  ResponsiveSpacing get spacing => ResponsiveSpacing(responsive: responsive);

  /// Get text styles
  ResponsiveTextStyles get textStyles => ResponsiveTextStyles(responsive: responsive);

  /// Get colors
  ResponsiveColors get colors => ResponsiveColors(theme: theme);
}

/// Responsive spacing class
class ResponsiveSpacing {
  final ResponsiveData responsive;

  const ResponsiveSpacing({required this.responsive});

  EdgeInsets get padding => EdgeInsets.all(responsive.spacing);
  EdgeInsets get margin => EdgeInsets.all(responsive.spacing * 0.5);
  
  /// Small spacing value
  double get small => responsive.spacing * 0.5;
  
  /// Medium spacing value
  double get medium => responsive.spacing;
  
  /// Large spacing value
  double get large => responsive.spacing * 1.5;
}

/// Responsive text styles class
class ResponsiveTextStyles {
  final ResponsiveData responsive;

  const ResponsiveTextStyles({required this.responsive});

  double fontSize(double baseSize) => responsive.fontSize(baseSize);
  
  /// Get bodyL text style
  TextStyle get bodyL => BabyFont.bodyL;
  
  /// Get bodyS text style
  TextStyle get bodyS => BabyFont.bodyS;
  
  /// Get headingS text style
  TextStyle get headingS => BabyFont.headingS;
  
  /// Get bodyM text style
  TextStyle get bodyM => BabyFont.bodyM;
}

/// Responsive colors class
class ResponsiveColors {
  final AppTheme theme;

  const ResponsiveColors({required this.theme});

  Color get primary => AppTheme.primary;
  Color get secondary => AppTheme.secondary;
  Color get accent => AppTheme.accent;
}

/// Responsive data class
class ResponsiveData {
  final bool isMobile;
  final bool isTablet;
  final bool isDesktop;
  final double screenWidth;
  final double screenHeight;

  const ResponsiveData({
    required this.isMobile,
    required this.isTablet,
    required this.isDesktop,
    required this.screenWidth,
    required this.screenHeight,
  });

  /// Get responsive spacing
  double get spacing {
    if (isMobile) return 8.0;
    if (isTablet) return 12.0;
    return 16.0;
  }

  /// Get responsive font size
  double fontSize(double baseSize) {
    if (isMobile) return baseSize * 0.9;
    if (isTablet) return baseSize * 1.1;
    return baseSize * 1.2;
  }

  /// Get responsive radius
  double radius(double baseRadius) {
    if (isMobile) return baseRadius * 0.8;
    if (isTablet) return baseRadius * 1.1;
    return baseRadius * 1.3;
  }
}

/// Provider for responsive theme
final responsiveThemeProvider = Provider<ResponsiveThemeData>((ref) {
  throw UnimplementedError('ResponsiveThemeData must be provided');
});

/// Provider for responsive data
final responsiveProvider = Provider<ResponsiveData>((ref) {
  throw UnimplementedError('ResponsiveData must be provided');
});

/// Provider for theme
final themeProvider = Provider<AppTheme>((ref) {
  return AppTheme();
});
