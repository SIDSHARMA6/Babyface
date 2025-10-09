import '../entities/memory_journey_entity.dart';
import '../repositories/memory_journey_repository.dart';

/// Get Memory Journey Use Case
/// Handles the business logic for retrieving a memory journey
class GetMemoryJourneyUseCase {
  final MemoryJourneyRepository _repository;

  GetMemoryJourneyUseCase(this._repository);

  /// Execute the use case
  Future<MemoryJourneyEntity?> call(String journeyId) async {
    if (journeyId.trim().isEmpty) {
      throw ArgumentError('Journey ID cannot be empty');
    }

    return await _repository.getJourney(journeyId);
  }
}

/// Get All Memory Journeys Use Case
class GetAllMemoryJourneysUseCase {
  final MemoryJourneyRepository _repository;

  GetAllMemoryJourneysUseCase(this._repository);

  /// Execute the use case
  Future<List<MemoryJourneyEntity>> call() async {
    return await _repository.getAllJourneys();
  }
}

/// Get Recent Memory Journeys Use Case
class GetRecentMemoryJourneysUseCase {
  final MemoryJourneyRepository _repository;

  GetRecentMemoryJourneysUseCase(this._repository);

  /// Execute the use case
  Future<List<MemoryJourneyEntity>> call({int limit = 10}) async {
    if (limit <= 0) {
      throw ArgumentError('Limit must be greater than 0');
    }

    return await _repository.getRecentJourneys(limit: limit);
  }
}

/// Search Memory Journeys Use Case
class SearchMemoryJourneysUseCase {
  final MemoryJourneyRepository _repository;

  SearchMemoryJourneysUseCase(this._repository);

  /// Execute the use case
  Future<List<MemoryJourneyEntity>> call(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    return await _repository.searchJourneys(query.trim());
  }
}
