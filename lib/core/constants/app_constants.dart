/// App-wide constants and configurations
class AppConstants {
  // App Info
  static const String appName = 'Future Baby';
  static const String packageName = 'com.anilkumar.futurebaby';
  static const String version = '1.0.0';

  // Image Processing
  static const int maxImageWidth = 1024;
  static const int maxImageHeight = 1024;
  static const int imageQuality = 85;

  // Generation Limits
  static const int maxGenerationsPerDay = 10;
  static const int maxHistoryItems = 100;

  // Animation Durations
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);

  // Storage Keys
  static const String avatarBoxKey = 'avatars';
  static const String babyResultBoxKey = 'baby_results';
  static const String settingsBoxKey = 'settings';
}
