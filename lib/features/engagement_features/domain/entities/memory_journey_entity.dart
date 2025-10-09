import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../data/models/memory_model.dart';

/// Memory Journey Entity
/// Follows clean architecture principles
class MemoryJourneyEntity extends Equatable {
  final String journeyId;
  final String title;
  final String subtitle;
  final String theme;
  final DateTime createdAt;
  final DateTime lastModified;
  final List<MemoryModel> memories;
  final MemoryJourneySettingsEntity settings;
  final MemoryJourneyExportSettingsEntity exportSettings;

  const MemoryJourneyEntity({
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

  @override
  List<Object?> get props => [
        journeyId,
        title,
        subtitle,
        theme,
        createdAt,
        lastModified,
        memories,
        settings,
        exportSettings,
      ];

  MemoryJourneyEntity copyWith({
    String? journeyId,
    String? title,
    String? subtitle,
    String? theme,
    DateTime? createdAt,
    DateTime? lastModified,
    List<MemoryModel>? memories,
    MemoryJourneySettingsEntity? settings,
    MemoryJourneyExportSettingsEntity? exportSettings,
  }) {
    return MemoryJourneyEntity(
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
}

/// Memory Journey Settings Entity
class MemoryJourneySettingsEntity extends Equatable {
  final double animationSpeed;
  final bool showLabels;
  final bool showDates;
  final bool showEmotions;
  final bool autoPlay;
  final bool loopAnimation;
  final String? backgroundMusic;
  final bool particleEffects;
  final bool depthOfField;
  final String theme;

  const MemoryJourneySettingsEntity({
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

  @override
  List<Object?> get props => [
        animationSpeed,
        showLabels,
        showDates,
        showEmotions,
        autoPlay,
        loopAnimation,
        backgroundMusic,
        particleEffects,
        depthOfField,
        theme,
      ];

  MemoryJourneySettingsEntity copyWith({
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
    return MemoryJourneySettingsEntity(
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

/// Memory Journey Export Settings Entity
class MemoryJourneyExportSettingsEntity extends Equatable {
  final String videoQuality;
  final bool includeAudio;
  final bool watermark;
  final String duration;

  const MemoryJourneyExportSettingsEntity({
    this.videoQuality = 'high',
    this.includeAudio = true,
    this.watermark = true,
    this.duration = 'auto',
  });

  @override
  List<Object?> get props => [videoQuality, includeAudio, watermark, duration];

  MemoryJourneyExportSettingsEntity copyWith({
    String? videoQuality,
    bool? includeAudio,
    bool? watermark,
    String? duration,
  }) {
    return MemoryJourneyExportSettingsEntity(
      videoQuality: videoQuality ?? this.videoQuality,
      includeAudio: includeAudio ?? this.includeAudio,
      watermark: watermark ?? this.watermark,
      duration: duration ?? this.duration,
    );
  }
}

/// Memory Journey Theme Entity
class MemoryJourneyThemeEntity extends Equatable {
  final String name;
  final String displayName;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final Color backgroundColor;
  final Color textColor;

  const MemoryJourneyThemeEntity({
    required this.name,
    required this.displayName,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  List<Object?> get props => [
        name,
        displayName,
        primaryColor,
        secondaryColor,
        accentColor,
        backgroundColor,
        textColor,
      ];

  /// Predefined themes
  static final List<MemoryJourneyThemeEntity> predefinedThemes = [
    MemoryJourneyThemeEntity(
      name: 'romantic-sunset',
      displayName: 'Romantic Sunset',
      primaryColor: const Color(0xFFFF6B9D),
      secondaryColor: const Color(0xFFFFB347),
      accentColor: const Color(0xFF2C3E50),
      backgroundColor: const Color(0xFF071428),
      textColor: const Color(0xFFF8F8FF),
    ),
    MemoryJourneyThemeEntity(
      name: 'love-garden',
      displayName: 'Love Garden',
      primaryColor: const Color(0xFFFFB6C1),
      secondaryColor: const Color(0xFF9CAF88),
      accentColor: const Color(0xFFD4A5A5),
      backgroundColor: const Color(0xFFFFF8DC),
      textColor: const Color(0xFF2C3E50),
    ),
    MemoryJourneyThemeEntity(
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

/// Memory Journey Request Entity
class MemoryJourneyRequestEntity extends Equatable {
  final String title;
  final String subtitle;
  final String theme;
  final List<MemoryModel> memories;
  final MemoryJourneySettingsEntity? settings;

  const MemoryJourneyRequestEntity({
    required this.title,
    required this.subtitle,
    required this.theme,
    required this.memories,
    this.settings,
  });

  @override
  List<Object?> get props => [title, subtitle, theme, memories, settings];
}
