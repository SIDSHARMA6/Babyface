import '../entities/baby_generation_entity.dart';
import '../repositories/baby_generation_repository.dart';

/// Start baby generation use case
/// Follows master plan clean architecture
class StartBabyGenerationUsecase {
  final BabyGenerationRepository _repository;

  StartBabyGenerationUsecase(this._repository);

  /// Execute start baby generation
  Future<BabyGenerationEntity> execute({
    required String maleImagePath,
    required String femaleImagePath,
    GenerationMetadata? metadata,
  }) async {
    // Validate inputs
    if (maleImagePath.isEmpty) {
      throw ArgumentError('Male image path cannot be empty');
    }
    if (femaleImagePath.isEmpty) {
      throw ArgumentError('Female image path cannot be empty');
    }

    // Create metadata if not provided
    final generationMetadata = metadata ?? const GenerationMetadata(
      aiModel: 'babyface-v1',
      quality: 'high',
      resolution: '1024x1024',
    );

    // Start generation
    return await _repository.startGeneration(
      maleImagePath: maleImagePath,
      femaleImagePath: femaleImagePath,
      metadata: generationMetadata,
    );
  }
}
