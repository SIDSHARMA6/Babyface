import '../entities/memory_journey_entity.dart';
import '../repositories/memory_journey_repository.dart';
import '../../data/models/memory_model.dart';

/// Create Memory Journey Use Case
/// Handles the business logic for creating a new memory journey
class CreateMemoryJourneyUseCase {
  final MemoryJourneyRepository _repository;

  CreateMemoryJourneyUseCase(this._repository);

  /// Execute the use case
  Future<MemoryJourneyEntity> call(CreateMemoryJourneyParams params) async {
    // Validate input
    if (params.title.trim().isEmpty) {
      throw ArgumentError('Journey title cannot be empty');
    }

    if (params.memories.isEmpty) {
      throw ArgumentError('Journey must have at least one memory');
    }

    // Create the request entity
    final request = MemoryJourneyRequestEntity(
      title: params.title.trim(),
      subtitle: params.subtitle?.trim() ?? '',
      theme: params.theme,
      memories: params.memories,
      settings: params.settings,
    );

    // Create the journey
    final journey = await _repository.createJourney(request);

    return journey;
  }
}

/// Parameters for creating a memory journey
class CreateMemoryJourneyParams {
  final String title;
  final String? subtitle;
  final String theme;
  final List<MemoryModel> memories; // Using MemoryModel to match entity
  final MemoryJourneySettingsEntity? settings;

  CreateMemoryJourneyParams({
    required this.title,
    this.subtitle,
    this.theme = 'romantic-sunset',
    required this.memories,
    this.settings,
  });
}
