import 'package:uuid/uuid.dart';
import '../../domain/entities/baby_generation_entity.dart';
import '../../domain/repositories/baby_generation_repository.dart';
import '../datasources/baby_generation_local_datasource.dart';
import '../datasources/baby_generation_remote_datasource.dart';

/// Baby generation repository implementation
/// Follows master plan clean architecture
class BabyGenerationRepositoryImpl implements BabyGenerationRepository {
  final BabyGenerationLocalDatasource _localDatasource;
  final BabyGenerationRemoteDatasource _remoteDatasource;
  final Uuid _uuid;

  BabyGenerationRepositoryImpl(
    this._localDatasource,
    this._remoteDatasource,
    this._uuid,
  );

  @override
  Future<BabyGenerationEntity> startGeneration({
    required String maleImagePath,
    required String femaleImagePath,
    GenerationMetadata? metadata,
  }) async {
    final id = _uuid.v4();
    final entity = BabyGenerationEntity(
      id: id,
      maleImagePath: maleImagePath,
      femaleImagePath: femaleImagePath,
      status: GenerationStatus.pending,
      progress: 0.0,
      createdAt: DateTime.now(),
      metadata: metadata ?? const GenerationMetadata(),
    );

    // Save to local storage
    await _localDatasource.saveGeneration(entity);

    // Start remote generation
    await _remoteDatasource.startGeneration(entity);

    return entity;
  }

  @override
  Future<BabyGenerationEntity?> getGenerationStatus(String id) async {
    return await _localDatasource.getGeneration(id);
  }

  @override
  Future<void> updateProgress(String id, double progress) async {
    final entity = await _localDatasource.getGeneration(id);
    if (entity != null) {
      final updatedEntity = entity.copyWith(
        progress: progress,
        status: GenerationStatus.processing,
      );
      await _localDatasource.saveGeneration(updatedEntity);
    }
  }

  @override
  Future<void> completeGeneration(String id, String generatedImagePath) async {
    final entity = await _localDatasource.getGeneration(id);
    if (entity != null) {
      final updatedEntity = entity.copyWith(
        generatedImagePath: generatedImagePath,
        status: GenerationStatus.completed,
        progress: 1.0,
        completedAt: DateTime.now(),
      );
      await _localDatasource.saveGeneration(updatedEntity);
    }
  }

  @override
  Future<void> failGeneration(String id, String errorMessage) async {
    final entity = await _localDatasource.getGeneration(id);
    if (entity != null) {
      final updatedEntity = entity.copyWith(
        status: GenerationStatus.failed,
        errorMessage: errorMessage,
        completedAt: DateTime.now(),
      );
      await _localDatasource.saveGeneration(updatedEntity);
    }
  }

  @override
  Future<void> cancelGeneration(String id) async {
    final entity = await _localDatasource.getGeneration(id);
    if (entity != null) {
      final updatedEntity = entity.copyWith(
        status: GenerationStatus.cancelled,
        completedAt: DateTime.now(),
      );
      await _localDatasource.saveGeneration(updatedEntity);
    }
  }

  @override
  Future<List<BabyGenerationEntity>> getAllGenerations() async {
    return await _localDatasource.getAllGenerations();
  }

  @override
  Future<List<BabyGenerationEntity>> getGenerationsByStatus(GenerationStatus status) async {
    return await _localDatasource.getGenerationsByStatus(status);
  }

  @override
  Future<void> deleteGeneration(String id) async {
    await _localDatasource.deleteGeneration(id);
  }

  @override
  Future<void> clearOldGenerations(int daysOld) async {
    await _localDatasource.clearOldGenerations(daysOld);
  }
}
