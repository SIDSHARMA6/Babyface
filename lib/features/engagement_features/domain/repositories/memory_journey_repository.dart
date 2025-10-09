import '../entities/memory_journey_entity.dart';
import '../../data/models/memory_model.dart';

/// Memory Journey Repository Interface
/// Defines the contract for memory journey data operations
abstract class MemoryJourneyRepository {
  /// Create a new memory journey
  Future<MemoryJourneyEntity> createJourney(MemoryJourneyRequestEntity request);

  /// Get a memory journey by ID
  Future<MemoryJourneyEntity?> getJourney(String journeyId);

  /// Get all memory journeys for the current user
  Future<List<MemoryJourneyEntity>> getAllJourneys();

  /// Update an existing memory journey
  Future<MemoryJourneyEntity> updateJourney(MemoryJourneyEntity journey);

  /// Delete a memory journey
  Future<void> deleteJourney(String journeyId);

  /// Add a memory to a journey
  Future<MemoryJourneyEntity> addMemoryToJourney(
      String journeyId, MemoryModel memory);

  /// Remove a memory from a journey
  Future<MemoryJourneyEntity> removeMemoryFromJourney(
      String journeyId, String memoryId);

  /// Update journey settings
  Future<MemoryJourneyEntity> updateJourneySettings(
    String journeyId,
    MemoryJourneySettingsEntity settings,
  );

  /// Update export settings
  Future<MemoryJourneyEntity> updateExportSettings(
    String journeyId,
    MemoryJourneyExportSettingsEntity exportSettings,
  );

  /// Get journey themes
  Future<List<MemoryJourneyThemeEntity>> getAvailableThemes();

  /// Export journey as video
  Future<String> exportJourneyAsVideo(String journeyId);

  /// Export journey as image
  Future<String> exportJourneyAsImage(String journeyId);

  /// Share journey
  Future<void> shareJourney(String journeyId, String shareType);

  /// Get journey statistics
  Future<Map<String, dynamic>> getJourneyStatistics(String journeyId);

  /// Search journeys by title or content
  Future<List<MemoryJourneyEntity>> searchJourneys(String query);

  /// Get recent journeys
  Future<List<MemoryJourneyEntity>> getRecentJourneys({int limit = 10});

  /// Get favorite journeys
  Future<List<MemoryJourneyEntity>> getFavoriteJourneys();

  /// Mark journey as favorite
  Future<void> markJourneyAsFavorite(String journeyId, bool isFavorite);

  /// Duplicate journey
  Future<MemoryJourneyEntity> duplicateJourney(
      String journeyId, String newTitle);

  /// Get journey by memory ID
  Future<MemoryJourneyEntity?> getJourneyByMemoryId(String memoryId);

  /// Get journey count
  Future<int> getJourneyCount();

  /// Clear all journeys (for testing or reset)
  Future<void> clearAllJourneys();
}
