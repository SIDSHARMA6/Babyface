import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'hive_service.dart';
import 'firebase_service.dart';

/// Theme configuration model
class ThemeConfig {
  final String id;
  final String name;
  final String description;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final Color backgroundColor;
  final Color surfaceColor;
  final Color errorColor;
  final String emoji;
  final bool isCustom;
  final DateTime createdAt;
  final DateTime updatedAt;

  ThemeConfig({
    required this.id,
    required this.name,
    required this.description,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.backgroundColor,
    required this.surfaceColor,
    required this.errorColor,
    required this.emoji,
    required this.isCustom,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'primaryColor': primaryColor.value,
      'secondaryColor': secondaryColor.value,
      'accentColor': accentColor.value,
      'backgroundColor': backgroundColor.value,
      'surfaceColor': surfaceColor.value,
      'errorColor': errorColor.value,
      'emoji': emoji,
      'isCustom': isCustom,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ThemeConfig.fromMap(Map<String, dynamic> map) {
    return ThemeConfig(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      primaryColor: Color(map['primaryColor'] ?? 0xFF6B9D),
      secondaryColor: Color(map['secondaryColor'] ?? 0xFF9D6B),
      accentColor: Color(map['accentColor'] ?? 0xFF6B9D),
      backgroundColor: Color(map['backgroundColor'] ?? 0xFFFFFFFF),
      surfaceColor: Color(map['surfaceColor'] ?? 0xFFFFFFFF),
      errorColor: Color(map['errorColor'] ?? 0xFFE53E3E),
      emoji: map['emoji'] ?? '🎨',
      isCustom: map['isCustom'] ?? false,
      createdAt:
          DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  ThemeConfig copyWith({
    String? id,
    String? name,
    String? description,
    Color? primaryColor,
    Color? secondaryColor,
    Color? accentColor,
    Color? backgroundColor,
    Color? surfaceColor,
    Color? errorColor,
    String? emoji,
    bool? isCustom,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ThemeConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      accentColor: accentColor ?? this.accentColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      surfaceColor: surfaceColor ?? this.surfaceColor,
      errorColor: errorColor ?? this.errorColor,
      emoji: emoji ?? this.emoji,
      isCustom: isCustom ?? this.isCustom,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Dynamic theme service
class DynamicThemeService {
  static final DynamicThemeService _instance = DynamicThemeService._internal();
  factory DynamicThemeService() => _instance;
  DynamicThemeService._internal();

  final HiveService _hiveService = HiveService();
  final FirebaseService _firebaseService = FirebaseService();
  static const String _boxName = 'dynamic_themes_box';
  static const String _themesKey = 'themes';
  static const String _currentThemeKey = 'current_theme';

  /// Get dynamic theme service instance
  static DynamicThemeService get instance => _instance;

  /// Get current theme
  Future<ThemeConfig> getCurrentTheme() async {
    try {
      await _hiveService.ensureBoxOpen(_boxName);
      final data = _hiveService.retrieve(_boxName, _currentThemeKey);

      if (data != null) {
        return ThemeConfig.fromMap(Map<String, dynamic>.from(data));
      }

      // Return default theme if none exists
      return _getDefaultTheme();
    } catch (e) {
      developer.log('❌ [DynamicThemeService] Error getting current theme: $e');
      return _getDefaultTheme();
    }
  }

  /// Set current theme
  Future<bool> setCurrentTheme(ThemeConfig theme) async {
    try {
      await _hiveService.ensureBoxOpen(_boxName);
      await _hiveService.store(_boxName, _currentThemeKey, theme.toMap());

      // Sync to Firebase
      await _saveThemeToFirebase(theme);

      developer.log('✅ [DynamicThemeService] Theme set: ${theme.name}');
      return true;
    } catch (e) {
      developer.log('❌ [DynamicThemeService] Error setting theme: $e');
      return false;
    }
  }

  /// Get all available themes
  Future<List<ThemeConfig>> getAllThemes() async {
    try {
      await _hiveService.ensureBoxOpen(_boxName);
      final data = _hiveService.retrieve(_boxName, _themesKey);

      if (data != null) {
        return (data as List)
            .map((item) => ThemeConfig.fromMap(Map<String, dynamic>.from(item)))
            .toList();
      }

      // Return default themes if none exist
      return await _createDefaultThemes();
    } catch (e) {
      developer.log('❌ [DynamicThemeService] Error getting themes: $e');
      return await _createDefaultThemes();
    }
  }

  /// Add custom theme
  Future<bool> addCustomTheme(ThemeConfig theme) async {
    try {
      await _hiveService.ensureBoxOpen(_boxName);
      final themes = await getAllThemes();
      themes.add(theme);

      await _hiveService.store(
          _boxName, _themesKey, themes.map((t) => t.toMap()).toList());

      // Sync to Firebase
      await _saveThemeToFirebase(theme);

      developer.log('✅ [DynamicThemeService] Custom theme added: ${theme.name}');
      return true;
    } catch (e) {
      developer.log('❌ [DynamicThemeService] Error adding custom theme: $e');
      return false;
    }
  }

  /// Update theme
  Future<bool> updateTheme(ThemeConfig theme) async {
    try {
      final themes = await getAllThemes();
      final index = themes.indexWhere((t) => t.id == theme.id);

      if (index != -1) {
        themes[index] = theme;
        await _hiveService.store(
            _boxName, _themesKey, themes.map((t) => t.toMap()).toList());

        // Sync to Firebase
        await _saveThemeToFirebase(theme);

        developer.log('✅ [DynamicThemeService] Theme updated: ${theme.name}');
        return true;
      }

      return false;
    } catch (e) {
      developer.log('❌ [DynamicThemeService] Error updating theme: $e');
      return false;
    }
  }

  /// Delete custom theme
  Future<bool> deleteCustomTheme(String themeId) async {
    try {
      await _hiveService.ensureBoxOpen(_boxName);
      final themes = await getAllThemes();
      themes.removeWhere((theme) => theme.id == themeId && theme.isCustom);

      await _hiveService.store(
          _boxName, _themesKey, themes.map((t) => t.toMap()).toList());

      // Sync to Firebase
      await _deleteThemeFromFirebase(themeId);

      developer.log('✅ [DynamicThemeService] Custom theme deleted: $themeId');
      return true;
    } catch (e) {
      developer.log('❌ [DynamicThemeService] Error deleting custom theme: $e');
      return false;
    }
  }

  /// Create default themes
  Future<List<ThemeConfig>> _createDefaultThemes() async {
    final defaultThemes = [
      ThemeConfig(
        id: 'pink_romance',
        name: 'Pink Romance',
        description: 'Classic romantic pink theme',
        primaryColor: const Color(0xFF6B9D9D),
        secondaryColor: const Color(0xFF9D6B9D),
        accentColor: const Color(0xFF6B9D9D),
        backgroundColor: const Color(0xFFFFFFFF),
        surfaceColor: const Color(0xFFFFFFFF),
        errorColor: const Color(0xFFE53E3E),
        emoji: '💕',
        isCustom: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ThemeConfig(
        id: 'sunset_love',
        name: 'Sunset Love',
        description: 'Warm sunset colors for cozy moments',
        primaryColor: const Color(0xFFFF6B35),
        secondaryColor: const Color(0xFFFF9F43),
        accentColor: const Color(0xFFFF6B35),
        backgroundColor: const Color(0xFFFFF8F0),
        surfaceColor: const Color(0xFFFFFFFF),
        errorColor: const Color(0xFFE53E3E),
        emoji: '🌅',
        isCustom: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ThemeConfig(
        id: 'ocean_breeze',
        name: 'Ocean Breeze',
        description: 'Calm ocean blues for peaceful vibes',
        primaryColor: const Color(0xFF4ECDC4),
        secondaryColor: const Color(0xFF45B7D1),
        accentColor: const Color(0xFF4ECDC4),
        backgroundColor: const Color(0xFFF0FDFF),
        surfaceColor: const Color(0xFFFFFFFF),
        errorColor: const Color(0xFFE53E3E),
        emoji: '🌊',
        isCustom: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ThemeConfig(
        id: 'lavender_dreams',
        name: 'Lavender Dreams',
        description: 'Soft purple tones for dreamy moments',
        primaryColor: const Color(0xFF9B59B6),
        secondaryColor: const Color(0xFF8E44AD),
        accentColor: const Color(0xFF9B59B6),
        backgroundColor: const Color(0xFFF8F0FF),
        surfaceColor: const Color(0xFFFFFFFF),
        errorColor: const Color(0xFFE53E3E),
        emoji: '💜',
        isCustom: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ThemeConfig(
        id: 'forest_green',
        name: 'Forest Green',
        description: 'Natural green tones for growth and harmony',
        primaryColor: const Color(0xFF27AE60),
        secondaryColor: const Color(0xFF2ECC71),
        accentColor: const Color(0xFF27AE60),
        backgroundColor: const Color(0xFFF0FFF4),
        surfaceColor: const Color(0xFFFFFFFF),
        errorColor: const Color(0xFFE53E3E),
        emoji: '🌿',
        isCustom: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ThemeConfig(
        id: 'golden_hour',
        name: 'Golden Hour',
        description: 'Luxurious gold tones for special moments',
        primaryColor: const Color(0xFFFFD700),
        secondaryColor: const Color(0xFFFFA500),
        accentColor: const Color(0xFFFFD700),
        backgroundColor: const Color(0xFFFFFDF0),
        surfaceColor: const Color(0xFFFFFFFF),
        errorColor: const Color(0xFFE53E3E),
        emoji: '✨',
        isCustom: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    // Save default themes
    await _hiveService.ensureBoxOpen(_boxName);
    await _hiveService.store(
        _boxName, _themesKey, defaultThemes.map((t) => t.toMap()).toList());

    return defaultThemes;
  }

  /// Get default theme
  ThemeConfig _getDefaultTheme() {
    return ThemeConfig(
      id: 'pink_romance',
      name: 'Pink Romance',
      description: 'Classic romantic pink theme',
      primaryColor: const Color(0xFF6B9D9D),
      secondaryColor: const Color(0xFF9D6B9D),
      accentColor: const Color(0xFF6B9D9D),
      backgroundColor: const Color(0xFFFFFFFF),
      surfaceColor: const Color(0xFFFFFFFF),
      errorColor: const Color(0xFFE53E3E),
      emoji: '💕',
      isCustom: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Save theme to Firebase
  Future<void> _saveThemeToFirebase(ThemeConfig theme) async {
    try {
      await _firebaseService.saveToFirestore(
        collection: 'user_themes',
        documentId: theme.id,
        data: theme.toMap(),
      );
    } catch (e) {
      developer.log('❌ [DynamicThemeService] Error saving theme to Firebase: $e');
    }
  }

  /// Delete theme from Firebase
  Future<void> _deleteThemeFromFirebase(String themeId) async {
    try {
      await _firebaseService.deleteFromFirestore(
        collection: 'user_themes',
        documentId: themeId,
      );
    } catch (e) {
      developer.log('❌ [DynamicThemeService] Error deleting theme from Firebase: $e');
    }
  }

  /// Clear all themes
  Future<void> clearAllThemes() async {
    try {
      await _hiveService.ensureBoxOpen(_boxName);
      await _hiveService.delete(_boxName, _themesKey);
      await _hiveService.delete(_boxName, _currentThemeKey);
      developer.log('✅ [DynamicThemeService] All themes cleared');
    } catch (e) {
      developer.log('❌ [DynamicThemeService] Error clearing themes: $e');
    }
  }
}

/// Theme extension for easy access
extension ThemeConfigExtension on ThemeConfig {
  ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: backgroundColor,
        error: errorColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
      ),
      cardTheme: CardTheme(
        color: surfaceColor,
        elevation: 2,
      ),
    );
  }
}
