import '../entities/baby_generation_entity.dart';

/// Baby generation repository interface
/// Follows master plan clean architecture
abstract class BabyGenerationRepository {
  /// Start baby generation process
  Future<BabyGenerationEntity> startGeneration({
    required String maleImagePath,
    required String femaleImagePath,
    GenerationMetadata? metadata,
  });

  /// Get generation status
  Future<BabyGenerationEntity?> getGenerationStatus(String id);

  /// Update generation progress
  Future<void> updateProgress(String id, double progress);

  /// Complete generation
  Future<void> completeGeneration(String id, String generatedImagePath);

  /// Fail generation
  Future<void> failGeneration(String id, String errorMessage);

  /// Cancel generation
  Future<void> cancelGeneration(String id);

  /// Get all generations
  Future<List<BabyGenerationEntity>> getAllGenerations();

  /// Get generations by status
  Future<List<BabyGenerationEntity>> getGenerationsByStatus(GenerationStatus status);

  /// Delete generation
  Future<void> deleteGeneration(String id);

  /// Clear completed generations older than specified days
  Future<void> clearOldGenerations(int daysOld);
}
