import 'package:hive/hive.dart';
import '../../domain/entities/baby_generation_entity.dart';

/// Baby generation local datasource
/// Follows master plan clean architecture
abstract class BabyGenerationLocalDatasource {
  Future<void> saveGeneration(BabyGenerationEntity entity);
  Future<BabyGenerationEntity?> getGeneration(String id);
  Future<List<BabyGenerationEntity>> getAllGenerations();
  Future<List<BabyGenerationEntity>> getGenerationsByStatus(GenerationStatus status);
  Future<void> deleteGeneration(String id);
  Future<void> clearOldGenerations(int daysOld);
}

/// Baby generation local datasource implementation
class BabyGenerationLocalDatasourceImpl implements BabyGenerationLocalDatasource {
  static const String _boxName = 'baby_generations';
  late Box<Map<dynamic, dynamic>> _box;

  /// Initialize the datasource
  Future<void> init() async {
    _box = await Hive.openBox<Map<dynamic, dynamic>>(_boxName);
  }

  @override
  Future<void> saveGeneration(BabyGenerationEntity entity) async {
    await _box.put(entity.id, _entityToMap(entity));
  }

  @override
  Future<BabyGenerationEntity?> getGeneration(String id) async {
    final data = _box.get(id);
    if (data != null) {
      return _mapToEntity(data);
    }
    return null;
  }

  @override
  Future<List<BabyGenerationEntity>> getAllGenerations() async {
    final allData = _box.values.toList();
    return allData.map((data) => _mapToEntity(data)).toList();
  }

  @override
  Future<List<BabyGenerationEntity>> getGenerationsByStatus(GenerationStatus status) async {
    final allGenerations = await getAllGenerations();
    return allGenerations.where((gen) => gen.status == status).toList();
  }

  @override
  Future<void> deleteGeneration(String id) async {
    await _box.delete(id);
  }

  @override
  Future<void> clearOldGenerations(int daysOld) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
    final allGenerations = await getAllGenerations();
    
    for (final generation in allGenerations) {
      if (generation.createdAt.isBefore(cutoffDate) && 
          generation.status == GenerationStatus.completed) {
        await deleteGeneration(generation.id);
      }
    }
  }

  /// Convert entity to map for storage
  Map<String, dynamic> _entityToMap(BabyGenerationEntity entity) {
    return {
      'id': entity.id,
      'maleImagePath': entity.maleImagePath,
      'femaleImagePath': entity.femaleImagePath,
      'generatedImagePath': entity.generatedImagePath,
      'status': entity.status.name,
      'progress': entity.progress,
      'createdAt': entity.createdAt.toIso8601String(),
      'completedAt': entity.completedAt?.toIso8601String(),
      'errorMessage': entity.errorMessage,
      'metadata': {
        'aiModel': entity.metadata.aiModel,
        'processingTime': entity.metadata.processingTime,
        'parameters': entity.metadata.parameters,
        'quality': entity.metadata.quality,
        'resolution': entity.metadata.resolution,
      },
    };
  }

  /// Convert map to entity
  BabyGenerationEntity _mapToEntity(Map<dynamic, dynamic> data) {
    final metadataData = data['metadata'] as Map<String, dynamic>?;
    final metadata = GenerationMetadata(
      aiModel: metadataData?['aiModel'],
      processingTime: metadataData?['processingTime'],
      parameters: metadataData?['parameters'],
      quality: metadataData?['quality'],
      resolution: metadataData?['resolution'],
    );

    return BabyGenerationEntity(
      id: data['id'] as String,
      maleImagePath: data['maleImagePath'] as String,
      femaleImagePath: data['femaleImagePath'] as String,
      generatedImagePath: data['generatedImagePath'] as String?,
      status: GenerationStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => GenerationStatus.pending,
      ),
      progress: (data['progress'] as num).toDouble(),
      createdAt: DateTime.parse(data['createdAt'] as String),
      completedAt: data['completedAt'] != null 
          ? DateTime.parse(data['completedAt'] as String)
          : null,
      errorMessage: data['errorMessage'] as String?,
      metadata: metadata,
    );
  }
}
