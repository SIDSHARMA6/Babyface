import '../entities/memory_journey_entity.dart';
import '../repositories/memory_journey_repository.dart';
import '../../data/models/memory_model.dart';

/// Update Memory Journey Use Case
/// Handles the business logic for updating a memory journey
class UpdateMemoryJourneyUseCase {
  final MemoryJourneyRepository _repository;

  UpdateMemoryJourneyUseCase(this._repository);

  /// Execute the use case
  Future<MemoryJourneyEntity> call(UpdateMemoryJourneyParams params) async {
    if (params.journeyId.trim().isEmpty) {
      throw ArgumentError('Journey ID cannot be empty');
    }

    // Get existing journey
    final existingJourney = await _repository.getJourney(params.journeyId);
    if (existingJourney == null) {
      throw ArgumentError('Journey not found');
    }

    // Update the journey
    final updatedJourney = existingJourney.copyWith(
      title: params.title,
      subtitle: params.subtitle,
      theme: params.theme,
      lastModified: DateTime.now(),
    );

    return await _repository.updateJourney(updatedJourney);
  }
}

/// Add Memory to Journey Use Case
class AddMemoryToJourneyUseCase {
  final MemoryJourneyRepository _repository;

  AddMemoryToJourneyUseCase(this._repository);

  /// Execute the use case
  Future<MemoryJourneyEntity> call(String journeyId, MemoryModel memory) async {
    if (journeyId.trim().isEmpty) {
      throw ArgumentError('Journey ID cannot be empty');
    }

    return await _repository.addMemoryToJourney(journeyId, memory);
  }
}

/// Remove Memory from Journey Use Case
class RemoveMemoryFromJourneyUseCase {
  final MemoryJourneyRepository _repository;

  RemoveMemoryFromJourneyUseCase(this._repository);

  /// Execute the use case
  Future<MemoryJourneyEntity> call(String journeyId, String memoryId) async {
    if (journeyId.trim().isEmpty) {
      throw ArgumentError('Journey ID cannot be empty');
    }

    if (memoryId.trim().isEmpty) {
      throw ArgumentError('Memory ID cannot be empty');
    }

    return await _repository.removeMemoryFromJourney(journeyId, memoryId);
  }
}

/// Update Journey Settings Use Case
class UpdateJourneySettingsUseCase {
  final MemoryJourneyRepository _repository;

  UpdateJourneySettingsUseCase(this._repository);

  /// Execute the use case
  Future<MemoryJourneyEntity> call(
    String journeyId,
    MemoryJourneySettingsEntity settings,
  ) async {
    if (journeyId.trim().isEmpty) {
      throw ArgumentError('Journey ID cannot be empty');
    }

    return await _repository.updateJourneySettings(journeyId, settings);
  }
}

/// Update Export Settings Use Case
class UpdateExportSettingsUseCase {
  final MemoryJourneyRepository _repository;

  UpdateExportSettingsUseCase(this._repository);

  /// Execute the use case
  Future<MemoryJourneyEntity> call(
    String journeyId,
    MemoryJourneyExportSettingsEntity exportSettings,
  ) async {
    if (journeyId.trim().isEmpty) {
      throw ArgumentError('Journey ID cannot be empty');
    }

    return await _repository.updateExportSettings(journeyId, exportSettings);
  }
}

/// Parameters for updating a memory journey
class UpdateMemoryJourneyParams {
  final String journeyId;
  final String? title;
  final String? subtitle;
  final String? theme;

  UpdateMemoryJourneyParams({
    required this.journeyId,
    this.title,
    this.subtitle,
    this.theme,
  });
}
