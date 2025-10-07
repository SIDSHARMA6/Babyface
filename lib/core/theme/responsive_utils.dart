import 'package:flutter/material.dart';

class ResponsiveUtils {
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }

  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  // Responsive font sizes
  static double responsiveFont(BuildContext context, double baseSize) {
    final width = screenWidth(context);
    if (width < mobileBreakpoint) {
      return baseSize * 0.9; // 90% for mobile
    } else if (width < tabletBreakpoint) {
      return baseSize * 1.1; // 110% for tablet
    } else {
      return baseSize * 1.2; // 120% for desktop
    }
  }

  // Responsive padding
  static EdgeInsets responsivePadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(16);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(24);
    } else {
      return const EdgeInsets.all(32);
    }
  }

  // Responsive margin
  static EdgeInsets responsiveMargin(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(8);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(12);
    } else {
      return const EdgeInsets.all(16);
    }
  }

  // Responsive border radius
  static double responsiveRadius(BuildContext context, double baseRadius) {
    if (isMobile(context)) {
      return baseRadius;
    } else if (isTablet(context)) {
      return baseRadius * 1.2;
    } else {
      return baseRadius * 1.4;
    }
  }

  // Grid cross axis count based on screen size
  static int getGridCrossAxisCount(BuildContext context) {
    if (isMobile(context)) {
      return 2;
    } else if (isTablet(context)) {
      return 3;
    } else {
      return 4;
    }
  }

  // Carousel height based on screen size
  static double getCarouselHeight(BuildContext context) {
    final height = screenHeight(context);
    if (isMobile(context)) {
      return height * 0.25; // 25% of screen height
    } else if (isTablet(context)) {
      return height * 0.3; // 30% of screen height
    } else {
      return height * 0.35; // 35% of screen height
    }
  }

  // Card height based on screen size
  static double getCardHeight(BuildContext context) {
    if (isMobile(context)) {
      return 120;
    } else if (isTablet(context)) {
      return 140;
    } else {
      return 160;
    }
  }

  // Responsive width percentage
  static double responsiveWidth(BuildContext context, double percentage) {
    return screenWidth(context) * (percentage / 100);
  }

  // Responsive height percentage
  static double responsiveHeight(BuildContext context, double percentage) {
    return screenHeight(context) * (percentage / 100);
  }

  // Responsive spacing
  static double responsiveSpacing(BuildContext context) {
    if (isMobile(context)) {
      return 8;
    } else if (isTablet(context)) {
      return 12;
    } else {
      return 16;
    }
  }

  // Helper methods for legacy compatibility
  static EdgeInsets padding(BuildContext context) {
    return responsivePadding(context);
  }

  static double responsive(BuildContext context, double baseSize) {
    return responsiveFont(context, baseSize);
  }
}

// Extension for easy access to responsive utilities
extension ResponsiveContext on BuildContext {
  bool get isMobile => ResponsiveUtils.isMobile(this);
  bool get isTablet => ResponsiveUtils.isTablet(this);
  bool get isDesktop => ResponsiveUtils.isDesktop(this);

  double get screenWidth => ResponsiveUtils.screenWidth(this);
  double get screenHeight => ResponsiveUtils.screenHeight(this);

  double responsiveFont(double baseSize) =>
      ResponsiveUtils.responsiveFont(this, baseSize);
  EdgeInsets get responsivePadding => ResponsiveUtils.responsivePadding(this);
  EdgeInsets get responsiveMargin => ResponsiveUtils.responsiveMargin(this);
  double responsiveRadius(double baseRadius) =>
      ResponsiveUtils.responsiveRadius(this, baseRadius);

  double responsiveWidth(double percentage) =>
      ResponsiveUtils.responsiveWidth(this, percentage);

  double responsiveHeight(double percentage) =>
      ResponsiveUtils.responsiveHeight(this, percentage);

  double get responsiveSpacing => ResponsiveUtils.responsiveSpacing(this);

  int get gridCrossAxisCount => ResponsiveUtils.getGridCrossAxisCount(this);
  double get carouselHeight => ResponsiveUtils.getCarouselHeight(this);
  double get cardHeight => ResponsiveUtils.getCardHeight(this);
}
