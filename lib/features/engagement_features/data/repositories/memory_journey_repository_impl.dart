import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/memory_journey_entity.dart';
import '../../domain/repositories/memory_journey_repository.dart';
import '../models/memory_journey_model.dart';
import '../models/memory_model.dart';
import '../../../../shared/services/hive_service.dart';

/// Memory Journey Repository Implementation
/// Implements the repository interface using Hive for local storage
class MemoryJourneyRepositoryImpl implements MemoryJourneyRepository {
  final HiveService _hiveService;
  final String _boxName = 'memory_journey_box';

  MemoryJourneyRepositoryImpl(this._hiveService);

  @override
  Future<MemoryJourneyEntity> createJourney(
      MemoryJourneyRequestEntity request) async {
    final journeyId = const Uuid().v4();
    final now = DateTime.now();

    // Convert memories to MemoryModel if they aren't already
    final memories = request.memories
        .map((memory) => memory is MemoryModel
            ? memory
            : MemoryModel.fromMap(memory as Map<String, dynamic>))
        .toList();

    // Sort memories by timestamp
    memories.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Calculate road positions for memories
    _calculateRoadPositions(memories);

    final journey = MemoryJourneyModel(
      journeyId: journeyId,
      title: request.title,
      subtitle: request.subtitle,
      theme: request.theme,
      createdAt: now,
      lastModified: now,
      memories: memories,
      settings: request.settings?.toModel() ?? MemoryJourneySettings(),
      exportSettings: MemoryJourneyExportSettings(),
    );

    // Store in Hive
    await _hiveService.store(_boxName, journeyId, journey.toMap());

    return journey.toEntity();
  }

  @override
  Future<MemoryJourneyEntity?> getJourney(String journeyId) async {
    final journeyData = _hiveService.retrieve(_boxName, journeyId);
    if (journeyData == null) return null;

    final journey =
        MemoryJourneyModel.fromMap(journeyData as Map<String, dynamic>);
    return journey.toEntity();
  }

  @override
  Future<List<MemoryJourneyEntity>> getAllJourneys() async {
    final allData = _hiveService.getAll(_boxName);
    final journeys = <MemoryJourneyEntity>[];

    for (final data in allData.values) {
      if (data is Map<String, dynamic>) {
        final journey = MemoryJourneyModel.fromMap(data);
        journeys.add(journey.toEntity());
      }
    }

    // Sort by last modified date (newest first)
    journeys.sort((a, b) => b.lastModified.compareTo(a.lastModified));

    return journeys;
  }

  @override
  Future<MemoryJourneyEntity> updateJourney(MemoryJourneyEntity journey) async {
    final journeyModel = MemoryJourneyModel(
      journeyId: journey.journeyId,
      title: journey.title,
      subtitle: journey.subtitle,
      theme: journey.theme,
      createdAt: journey.createdAt,
      lastModified: DateTime.now(),
      memories: journey.memories,
      settings: journey.settings.toModel(),
      exportSettings: journey.exportSettings.toModel(),
    );

    await _hiveService.store(_boxName, journey.journeyId, journeyModel.toMap());
    return journey;
  }

  @override
  Future<void> deleteJourney(String journeyId) async {
    await _hiveService.delete(_boxName, journeyId);
  }

  @override
  Future<MemoryJourneyEntity> addMemoryToJourney(
      String journeyId, MemoryModel memory) async {
    final journey = await getJourney(journeyId);
    if (journey == null) {
      throw Exception('Journey not found');
    }

    final updatedMemories = List<MemoryModel>.from(journey.memories)
      ..add(memory);
    updatedMemories.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    _calculateRoadPositions(updatedMemories);

    final updatedJourney = journey.copyWith(
      memories: updatedMemories,
      lastModified: DateTime.now(),
    );

    return await updateJourney(updatedJourney);
  }

  @override
  Future<MemoryJourneyEntity> removeMemoryFromJourney(
      String journeyId, String memoryId) async {
    final journey = await getJourney(journeyId);
    if (journey == null) {
      throw Exception('Journey not found');
    }

    final updatedMemories =
        journey.memories.where((m) => m.id != memoryId).toList();
    _calculateRoadPositions(updatedMemories);

    final updatedJourney = journey.copyWith(
      memories: updatedMemories,
      lastModified: DateTime.now(),
    );

    return await updateJourney(updatedJourney);
  }

  @override
  Future<MemoryJourneyEntity> updateJourneySettings(
    String journeyId,
    MemoryJourneySettingsEntity settings,
  ) async {
    final journey = await getJourney(journeyId);
    if (journey == null) {
      throw Exception('Journey not found');
    }

    final updatedJourney = journey.copyWith(
      settings: settings,
      lastModified: DateTime.now(),
    );

    return await updateJourney(updatedJourney);
  }

  @override
  Future<MemoryJourneyEntity> updateExportSettings(
    String journeyId,
    MemoryJourneyExportSettingsEntity exportSettings,
  ) async {
    final journey = await getJourney(journeyId);
    if (journey == null) {
      throw Exception('Journey not found');
    }

    final updatedJourney = journey.copyWith(
      exportSettings: exportSettings,
      lastModified: DateTime.now(),
    );

    return await updateJourney(updatedJourney);
  }

  @override
  Future<List<MemoryJourneyThemeEntity>> getAvailableThemes() async {
    return MemoryJourneyThemeEntity.predefinedThemes;
  }

  @override
  Future<String> exportJourneyAsVideo(String journeyId) async {
    // TODO: Implement video export functionality
    throw UnimplementedError('Video export not yet implemented');
  }

  @override
  Future<String> exportJourneyAsImage(String journeyId) async {
    // TODO: Implement image export functionality
    throw UnimplementedError('Image export not yet implemented');
  }

  @override
  Future<void> shareJourney(String journeyId, String shareType) async {
    // TODO: Implement sharing functionality
    throw UnimplementedError('Sharing not yet implemented');
  }

  @override
  Future<Map<String, dynamic>> getJourneyStatistics(String journeyId) async {
    final journey = await getJourney(journeyId);
    if (journey == null) {
      throw Exception('Journey not found');
    }

    return {
      'totalMemories': journey.memories.length,
      'favoriteMemories': journey.memories.where((m) => m.isFavorite).length,
      'dateRange': _getDateRange(journey.memories),
      'themes': journey.memories.map((m) => m.mood).toSet().toList(),
      'createdAt': journey.createdAt.toIso8601String(),
      'lastModified': journey.lastModified.toIso8601String(),
    };
  }

  @override
  Future<List<MemoryJourneyEntity>> searchJourneys(String query) async {
    final allJourneys = await getAllJourneys();
    final lowercaseQuery = query.toLowerCase();

    return allJourneys.where((journey) {
      return journey.title.toLowerCase().contains(lowercaseQuery) ||
          journey.subtitle.toLowerCase().contains(lowercaseQuery) ||
          journey.memories.any((memory) =>
              memory.title.toLowerCase().contains(lowercaseQuery) ||
              memory.description.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  @override
  Future<List<MemoryJourneyEntity>> getRecentJourneys({int limit = 10}) async {
    final allJourneys = await getAllJourneys();
    return allJourneys.take(limit).toList();
  }

  @override
  Future<List<MemoryJourneyEntity>> getFavoriteJourneys() async {
    // For now, return all journeys as we don't have a favorite field yet
    return await getAllJourneys();
  }

  @override
  Future<void> markJourneyAsFavorite(String journeyId, bool isFavorite) async {
    // TODO: Implement favorite functionality
    throw UnimplementedError('Favorite functionality not yet implemented');
  }

  @override
  Future<MemoryJourneyEntity> duplicateJourney(
      String journeyId, String newTitle) async {
    final originalJourney = await getJourney(journeyId);
    if (originalJourney == null) {
      throw Exception('Journey not found');
    }

    final duplicatedJourney = originalJourney.copyWith(
      journeyId: const Uuid().v4(),
      title: newTitle,
      createdAt: DateTime.now(),
      lastModified: DateTime.now(),
    );

    return await updateJourney(duplicatedJourney);
  }

  @override
  Future<MemoryJourneyEntity?> getJourneyByMemoryId(String memoryId) async {
    final allJourneys = await getAllJourneys();

    for (final journey in allJourneys) {
      if (journey.memories.any((memory) => memory.id == memoryId)) {
        return journey;
      }
    }

    return null;
  }

  @override
  Future<int> getJourneyCount() async {
    return _hiveService.getLength(_boxName);
  }

  @override
  Future<void> clearAllJourneys() async {
    await _hiveService.clear(_boxName);
  }

  /// Calculate road positions for memories based on their chronological order
  void _calculateRoadPositions(List<MemoryModel> memories) {
    if (memories.isEmpty) return;

    // Simple linear distribution along a curved path
    // In a real implementation, this would use a more sophisticated algorithm
    for (int i = 0; i < memories.length; i++) {
      final progress = i / (memories.length - 1);
      final x = 0.1 + (progress * 0.8); // 10% to 90% of width
      final y = 0.5 + (0.3 * (0.5 - (progress - 0.5).abs())); // Curved path

      memories[i] = memories[i].copyWith(
        roadPosition: Offset(x * 1000, y * 1000), // Scale to actual coordinates
      );
    }
  }

  /// Get date range for memories
  Map<String, String> _getDateRange(List<MemoryModel> memories) {
    if (memories.isEmpty) {
      return {'start': '', 'end': ''};
    }

    final sortedMemories = List<MemoryModel>.from(memories)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return {
      'start': sortedMemories.first.date,
      'end': sortedMemories.last.date,
    };
  }
}

/// Extension to convert between entities and models
extension MemoryJourneyModelExtension on MemoryJourneyModel {
  MemoryJourneyEntity toEntity() {
    return MemoryJourneyEntity(
      journeyId: journeyId,
      title: title,
      subtitle: subtitle,
      theme: theme,
      createdAt: createdAt,
      lastModified: lastModified,
      memories: memories,
      settings: settings.toEntity(),
      exportSettings: exportSettings.toEntity(),
    );
  }
}

extension MemoryJourneySettingsExtension on MemoryJourneySettings {
  MemoryJourneySettingsEntity toEntity() {
    return MemoryJourneySettingsEntity(
      animationSpeed: animationSpeed,
      showLabels: showLabels,
      showDates: showDates,
      showEmotions: showEmotions,
      autoPlay: autoPlay,
      loopAnimation: loopAnimation,
      backgroundMusic: backgroundMusic,
      particleEffects: particleEffects,
      depthOfField: depthOfField,
      theme: theme,
    );
  }
}

extension MemoryJourneySettingsEntityExtension on MemoryJourneySettingsEntity {
  MemoryJourneySettings toModel() {
    return MemoryJourneySettings(
      animationSpeed: animationSpeed,
      showLabels: showLabels,
      showDates: showDates,
      showEmotions: showEmotions,
      autoPlay: autoPlay,
      loopAnimation: loopAnimation,
      backgroundMusic: backgroundMusic,
      particleEffects: particleEffects,
      depthOfField: depthOfField,
      theme: theme,
    );
  }
}

extension MemoryJourneyExportSettingsExtension on MemoryJourneyExportSettings {
  MemoryJourneyExportSettingsEntity toEntity() {
    return MemoryJourneyExportSettingsEntity(
      videoQuality: videoQuality,
      includeAudio: includeAudio,
      watermark: watermark,
      duration: duration,
    );
  }
}

extension MemoryJourneyExportSettingsEntityExtension
    on MemoryJourneyExportSettingsEntity {
  MemoryJourneyExportSettings toModel() {
    return MemoryJourneyExportSettings(
      videoQuality: videoQuality,
      includeAudio: includeAudio,
      watermark: watermark,
      duration: duration,
    );
  }
}
