import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'memory_model.dart';

/// Memory Journey Model for Hive storage
/// Follows the memory_visualize.md specification
@HiveType(typeId: 10)
class MemoryJourneyModel {
  @HiveField(0)
  final String journeyId;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String subtitle;

  @HiveField(3)
  final String theme;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final DateTime lastModified;

  @HiveField(6)
  final List<MemoryModel> memories;

  @HiveField(7)
  final MemoryJourneySettings settings;

  @HiveField(8)
  final MemoryJourneyExportSettings exportSettings;

  MemoryJourneyModel({
    required this.journeyId,
    required this.title,
    required this.subtitle,
    required this.theme,
    required this.createdAt,
    required this.lastModified,
    required this.memories,
    required this.settings,
    required this.exportSettings,
  });

  /// Convert to Map for Hive storage
  Map<String, dynamic> toMap() {
    return {
      'journeyId': journeyId,
      'title': title,
      'subtitle': subtitle,
      'theme': theme,
      'createdAt': createdAt.toIso8601String(),
      'lastModified': lastModified.toIso8601String(),
      'memories': memories.map((m) => m.toMap()).toList(),
      'settings': settings.toMap(),
      'exportSettings': exportSettings.toMap(),
    };
  }

  /// Create from Map
  factory MemoryJourneyModel.fromMap(Map<String, dynamic> map) {
    return MemoryJourneyModel(
      journeyId: map['journeyId'] ?? '',
      title: map['title'] ?? '',
      subtitle: map['subtitle'] ?? '',
      theme: map['theme'] ?? 'romantic-sunset',
      createdAt:
          DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      lastModified: DateTime.parse(
          map['lastModified'] ?? DateTime.now().toIso8601String()),
      memories: (map['memories'] as List<dynamic>?)
              ?.map((m) => MemoryModel.fromMap(m as Map<String, dynamic>))
              .toList() ??
          [],
      settings: MemoryJourneySettings.fromMap(map['settings'] ?? {}),
      exportSettings:
          MemoryJourneyExportSettings.fromMap(map['exportSettings'] ?? {}),
    );
  }

  /// Copy with method
  MemoryJourneyModel copyWith({
    String? journeyId,
    String? title,
    String? subtitle,
    String? theme,
    DateTime? createdAt,
    DateTime? lastModified,
    List<MemoryModel>? memories,
    MemoryJourneySettings? settings,
    MemoryJourneyExportSettings? exportSettings,
  }) {
    return MemoryJourneyModel(
      journeyId: journeyId ?? this.journeyId,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      theme: theme ?? this.theme,
      createdAt: createdAt ?? this.createdAt,
      lastModified: lastModified ?? this.lastModified,
      memories: memories ?? this.memories,
      settings: settings ?? this.settings,
      exportSettings: exportSettings ?? this.exportSettings,
    );
  }

  @override
  String toString() {
    return 'MemoryJourneyModel(journeyId: $journeyId, title: $title, memories: ${memories.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MemoryJourneyModel && other.journeyId == journeyId;
  }

  @override
  int get hashCode => journeyId.hashCode;
}

/// Memory Journey Settings
@HiveType(typeId: 11)
class MemoryJourneySettings {
  @HiveField(0)
  final double animationSpeed;

  @HiveField(1)
  final bool showLabels;

  @HiveField(2)
  final bool showDates;

  @HiveField(3)
  final bool showEmotions;

  @HiveField(4)
  final bool autoPlay;

  @HiveField(5)
  final bool loopAnimation;

  @HiveField(6)
  final String? backgroundMusic;

  @HiveField(7)
  final bool particleEffects;

  @HiveField(8)
  final bool depthOfField;

  @HiveField(9)
  final String theme;

  MemoryJourneySettings({
    this.animationSpeed = 1.0,
    this.showLabels = true,
    this.showDates = true,
    this.showEmotions = true,
    this.autoPlay = true,
    this.loopAnimation = false,
    this.backgroundMusic,
    this.particleEffects = true,
    this.depthOfField = true,
    this.theme = 'romantic-sunset',
  });

  Map<String, dynamic> toMap() {
    return {
      'animationSpeed': animationSpeed,
      'showLabels': showLabels,
      'showDates': showDates,
      'showEmotions': showEmotions,
      'autoPlay': autoPlay,
      'loopAnimation': loopAnimation,
      'backgroundMusic': backgroundMusic,
      'particleEffects': particleEffects,
      'depthOfField': depthOfField,
      'theme': theme,
    };
  }

  factory MemoryJourneySettings.fromMap(Map<String, dynamic> map) {
    return MemoryJourneySettings(
      animationSpeed: (map['animationSpeed'] ?? 1.0).toDouble(),
      showLabels: map['showLabels'] ?? true,
      showDates: map['showDates'] ?? true,
      showEmotions: map['showEmotions'] ?? true,
      autoPlay: map['autoPlay'] ?? true,
      loopAnimation: map['loopAnimation'] ?? false,
      backgroundMusic: map['backgroundMusic'],
      particleEffects: map['particleEffects'] ?? true,
      depthOfField: map['depthOfField'] ?? true,
      theme: map['theme'] ?? 'romantic-sunset',
    );
  }

  MemoryJourneySettings copyWith({
    double? animationSpeed,
    bool? showLabels,
    bool? showDates,
    bool? showEmotions,
    bool? autoPlay,
    bool? loopAnimation,
    String? backgroundMusic,
    bool? particleEffects,
    bool? depthOfField,
    String? theme,
  }) {
    return MemoryJourneySettings(
      animationSpeed: animationSpeed ?? this.animationSpeed,
      showLabels: showLabels ?? this.showLabels,
      showDates: showDates ?? this.showDates,
      showEmotions: showEmotions ?? this.showEmotions,
      autoPlay: autoPlay ?? this.autoPlay,
      loopAnimation: loopAnimation ?? this.loopAnimation,
      backgroundMusic: backgroundMusic ?? this.backgroundMusic,
      particleEffects: particleEffects ?? this.particleEffects,
      depthOfField: depthOfField ?? this.depthOfField,
      theme: theme ?? this.theme,
    );
  }
}

/// Memory Journey Export Settings
@HiveType(typeId: 12)
class MemoryJourneyExportSettings {
  @HiveField(0)
  final String videoQuality;

  @HiveField(1)
  final bool includeAudio;

  @HiveField(2)
  final bool watermark;

  @HiveField(3)
  final String duration;

  MemoryJourneyExportSettings({
    this.videoQuality = 'high',
    this.includeAudio = true,
    this.watermark = true,
    this.duration = 'auto',
  });

  Map<String, dynamic> toMap() {
    return {
      'videoQuality': videoQuality,
      'includeAudio': includeAudio,
      'watermark': watermark,
      'duration': duration,
    };
  }

  factory MemoryJourneyExportSettings.fromMap(Map<String, dynamic> map) {
    return MemoryJourneyExportSettings(
      videoQuality: map['videoQuality'] ?? 'high',
      includeAudio: map['includeAudio'] ?? true,
      watermark: map['watermark'] ?? true,
      duration: map['duration'] ?? 'auto',
    );
  }

  MemoryJourneyExportSettings copyWith({
    String? videoQuality,
    bool? includeAudio,
    bool? watermark,
    String? duration,
  }) {
    return MemoryJourneyExportSettings(
      videoQuality: videoQuality ?? this.videoQuality,
      includeAudio: includeAudio ?? this.includeAudio,
      watermark: watermark ?? this.watermark,
      duration: duration ?? this.duration,
    );
  }
}

/// Memory Journey Theme
@HiveType(typeId: 13)
class MemoryJourneyTheme {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String displayName;

  @HiveField(2)
  final Color primaryColor;

  @HiveField(3)
  final Color secondaryColor;

  @HiveField(4)
  final Color accentColor;

  @HiveField(5)
  final Color backgroundColor;

  @HiveField(6)
  final Color textColor;

  MemoryJourneyTheme({
    required this.name,
    required this.displayName,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.backgroundColor,
    required this.textColor,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'displayName': displayName,
      'primaryColor': primaryColor.value,
      'secondaryColor': secondaryColor.value,
      'accentColor': accentColor.value,
      'backgroundColor': backgroundColor.value,
      'textColor': textColor.value,
    };
  }

  factory MemoryJourneyTheme.fromMap(Map<String, dynamic> map) {
    return MemoryJourneyTheme(
      name: map['name'] ?? '',
      displayName: map['displayName'] ?? '',
      primaryColor: Color(map['primaryColor'] ?? 0xFF6B9D),
      secondaryColor: Color(map['secondaryColor'] ?? 0xFFB347),
      accentColor: Color(map['accentColor'] ?? 0x2C3E50),
      backgroundColor: Color(map['backgroundColor'] ?? 0x071428),
      textColor: Color(map['textColor'] ?? 0xF8F8FF),
    );
  }

  /// Predefined themes
  static final List<MemoryJourneyTheme> predefinedThemes = [
    MemoryJourneyTheme(
      name: 'romantic-sunset',
      displayName: 'Romantic Sunset',
      primaryColor: const Color(0xFFFF6B9D),
      secondaryColor: const Color(0xFFFFB347),
      accentColor: const Color(0xFF2C3E50),
      backgroundColor: const Color(0xFF071428),
      textColor: const Color(0xFFF8F8FF),
    ),
    MemoryJourneyTheme(
      name: 'love-garden',
      displayName: 'Love Garden',
      primaryColor: const Color(0xFFFFB6C1),
      secondaryColor: const Color(0xFF9CAF88),
      accentColor: const Color(0xFFD4A5A5),
      backgroundColor: const Color(0xFFFFF8DC),
      textColor: const Color(0xFF2C3E50),
    ),
    MemoryJourneyTheme(
      name: 'midnight-romance',
      displayName: 'Midnight Romance',
      primaryColor: const Color(0xFF4B0082),
      secondaryColor: const Color(0xFFC0C0C0),
      accentColor: const Color(0xFFFFD700),
      backgroundColor: const Color(0xFF191970),
      textColor: const Color(0xFFE8B4B8),
    ),
  ];
}
