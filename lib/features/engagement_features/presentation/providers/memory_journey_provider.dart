import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/memory_journey_entity.dart';
import '../../domain/repositories/memory_journey_repository.dart';
import '../../domain/usecases/create_memory_journey_usecase.dart';
import '../../domain/usecases/get_memory_journey_usecase.dart';
import '../../domain/usecases/update_memory_journey_usecase.dart';
import '../../data/repositories/memory_journey_repository_impl.dart';
import '../../../../shared/services/hive_service.dart';
import '../../data/models/memory_model.dart';

/// Memory Journey Repository Provider
final memoryJourneyRepositoryProvider =
    Provider<MemoryJourneyRepository>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return MemoryJourneyRepositoryImpl(hiveService);
});

/// Memory Journey Use Cases Providers
final createMemoryJourneyUseCaseProvider =
    Provider<CreateMemoryJourneyUseCase>((ref) {
  final repository = ref.watch(memoryJourneyRepositoryProvider);
  return CreateMemoryJourneyUseCase(repository);
});

final getMemoryJourneyUseCaseProvider =
    Provider<GetMemoryJourneyUseCase>((ref) {
  final repository = ref.watch(memoryJourneyRepositoryProvider);
  return GetMemoryJourneyUseCase(repository);
});

final getAllMemoryJourneysUseCaseProvider =
    Provider<GetAllMemoryJourneysUseCase>((ref) {
  final repository = ref.watch(memoryJourneyRepositoryProvider);
  return GetAllMemoryJourneysUseCase(repository);
});

final getRecentMemoryJourneysUseCaseProvider =
    Provider<GetRecentMemoryJourneysUseCase>((ref) {
  final repository = ref.watch(memoryJourneyRepositoryProvider);
  return GetRecentMemoryJourneysUseCase(repository);
});

final searchMemoryJourneysUseCaseProvider =
    Provider<SearchMemoryJourneysUseCase>((ref) {
  final repository = ref.watch(memoryJourneyRepositoryProvider);
  return SearchMemoryJourneysUseCase(repository);
});

final updateMemoryJourneyUseCaseProvider =
    Provider<UpdateMemoryJourneyUseCase>((ref) {
  final repository = ref.watch(memoryJourneyRepositoryProvider);
  return UpdateMemoryJourneyUseCase(repository);
});

final addMemoryToJourneyUseCaseProvider =
    Provider<AddMemoryToJourneyUseCase>((ref) {
  final repository = ref.watch(memoryJourneyRepositoryProvider);
  return AddMemoryToJourneyUseCase(repository);
});

final removeMemoryFromJourneyUseCaseProvider =
    Provider<RemoveMemoryFromJourneyUseCase>((ref) {
  final repository = ref.watch(memoryJourneyRepositoryProvider);
  return RemoveMemoryFromJourneyUseCase(repository);
});

final updateJourneySettingsUseCaseProvider =
    Provider<UpdateJourneySettingsUseCase>((ref) {
  final repository = ref.watch(memoryJourneyRepositoryProvider);
  return UpdateJourneySettingsUseCase(repository);
});

final updateExportSettingsUseCaseProvider =
    Provider<UpdateExportSettingsUseCase>((ref) {
  final repository = ref.watch(memoryJourneyRepositoryProvider);
  return UpdateExportSettingsUseCase(repository);
});

/// Memory Journey State
class MemoryJourneyState {
  final List<MemoryJourneyEntity> journeys;
  final MemoryJourneyEntity? currentJourney;
  final bool isLoading;
  final String? error;
  final String? searchQuery;

  const MemoryJourneyState({
    this.journeys = const [],
    this.currentJourney,
    this.isLoading = false,
    this.error,
    this.searchQuery,
  });

  MemoryJourneyState copyWith({
    List<MemoryJourneyEntity>? journeys,
    MemoryJourneyEntity? currentJourney,
    bool? isLoading,
    String? error,
    String? searchQuery,
  }) {
    return MemoryJourneyState(
      journeys: journeys ?? this.journeys,
      currentJourney: currentJourney ?? this.currentJourney,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

/// Memory Journey Notifier
class MemoryJourneyNotifier extends StateNotifier<MemoryJourneyState> {
  final CreateMemoryJourneyUseCase _createJourneyUseCase;
  final GetMemoryJourneyUseCase _getJourneyUseCase;
  final GetAllMemoryJourneysUseCase _getAllJourneysUseCase;
  final GetRecentMemoryJourneysUseCase _getRecentJourneysUseCase;
  final SearchMemoryJourneysUseCase _searchJourneysUseCase;
  final UpdateMemoryJourneyUseCase _updateJourneyUseCase;
  final AddMemoryToJourneyUseCase _addMemoryToJourneyUseCase;
  final RemoveMemoryFromJourneyUseCase _removeMemoryFromJourneyUseCase;
  final UpdateJourneySettingsUseCase _updateJourneySettingsUseCase;
  final UpdateExportSettingsUseCase _updateExportSettingsUseCase;

  MemoryJourneyNotifier({
    required CreateMemoryJourneyUseCase createJourneyUseCase,
    required GetMemoryJourneyUseCase getJourneyUseCase,
    required GetAllMemoryJourneysUseCase getAllJourneysUseCase,
    required GetRecentMemoryJourneysUseCase getRecentJourneysUseCase,
    required SearchMemoryJourneysUseCase searchJourneysUseCase,
    required UpdateMemoryJourneyUseCase updateJourneyUseCase,
    required AddMemoryToJourneyUseCase addMemoryToJourneyUseCase,
    required RemoveMemoryFromJourneyUseCase removeMemoryFromJourneyUseCase,
    required UpdateJourneySettingsUseCase updateJourneySettingsUseCase,
    required UpdateExportSettingsUseCase updateExportSettingsUseCase,
  })  : _createJourneyUseCase = createJourneyUseCase,
        _getJourneyUseCase = getJourneyUseCase,
        _getAllJourneysUseCase = getAllJourneysUseCase,
        _getRecentJourneysUseCase = getRecentJourneysUseCase,
        _searchJourneysUseCase = searchJourneysUseCase,
        _updateJourneyUseCase = updateJourneyUseCase,
        _addMemoryToJourneyUseCase = addMemoryToJourneyUseCase,
        _removeMemoryFromJourneyUseCase = removeMemoryFromJourneyUseCase,
        _updateJourneySettingsUseCase = updateJourneySettingsUseCase,
        _updateExportSettingsUseCase = updateExportSettingsUseCase,
        super(const MemoryJourneyState());

  /// Load all journeys
  Future<void> loadJourneys() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final journeys = await _getAllJourneysUseCase();
      state = state.copyWith(
        journeys: journeys,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Load recent journeys
  Future<void> loadRecentJourneys({int limit = 10}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final journeys = await _getRecentJourneysUseCase(limit: limit);
      state = state.copyWith(
        journeys: journeys,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Create a new journey
  Future<void> createJourney({
    required String title,
    String? subtitle,
    String theme = 'romantic-sunset',
    required List<MemoryModel> memories,
    MemoryJourneySettingsEntity? settings,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final params = CreateMemoryJourneyParams(
        title: title,
        subtitle: subtitle,
        theme: theme,
        memories: memories,
        settings: settings,
      );

      final journey = await _createJourneyUseCase(params);

      state = state.copyWith(
        journeys: [journey, ...state.journeys],
        currentJourney: journey,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Get a specific journey
  Future<void> getJourney(String journeyId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final journey = await _getJourneyUseCase(journeyId);
      state = state.copyWith(
        currentJourney: journey,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Search journeys
  Future<void> searchJourneys(String query) async {
    if (query.trim().isEmpty) {
      await loadJourneys();
      return;
    }

    state = state.copyWith(isLoading: true, error: null, searchQuery: query);

    try {
      final journeys = await _searchJourneysUseCase(query);
      state = state.copyWith(
        journeys: journeys,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Update journey
  Future<void> updateJourney({
    required String journeyId,
    String? title,
    String? subtitle,
    String? theme,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final params = UpdateMemoryJourneyParams(
        journeyId: journeyId,
        title: title,
        subtitle: subtitle,
        theme: theme,
      );

      final updatedJourney = await _updateJourneyUseCase(params);

      // Update in journeys list
      final updatedJourneys = state.journeys.map((journey) {
        return journey.journeyId == journeyId ? updatedJourney : journey;
      }).toList();

      state = state.copyWith(
        journeys: updatedJourneys,
        currentJourney: state.currentJourney?.journeyId == journeyId
            ? updatedJourney
            : state.currentJourney,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Add memory to journey
  Future<void> addMemoryToJourney(String journeyId, MemoryModel memory) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedJourney =
          await _addMemoryToJourneyUseCase(journeyId, memory);

      // Update in journeys list
      final updatedJourneys = state.journeys.map((journey) {
        return journey.journeyId == journeyId ? updatedJourney : journey;
      }).toList();

      state = state.copyWith(
        journeys: updatedJourneys,
        currentJourney: state.currentJourney?.journeyId == journeyId
            ? updatedJourney
            : state.currentJourney,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Remove memory from journey
  Future<void> removeMemoryFromJourney(
      String journeyId, String memoryId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedJourney =
          await _removeMemoryFromJourneyUseCase(journeyId, memoryId);

      // Update in journeys list
      final updatedJourneys = state.journeys.map((journey) {
        return journey.journeyId == journeyId ? updatedJourney : journey;
      }).toList();

      state = state.copyWith(
        journeys: updatedJourneys,
        currentJourney: state.currentJourney?.journeyId == journeyId
            ? updatedJourney
            : state.currentJourney,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Update journey settings
  Future<void> updateJourneySettings(
    String journeyId,
    MemoryJourneySettingsEntity settings,
  ) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedJourney =
          await _updateJourneySettingsUseCase(journeyId, settings);

      // Update in journeys list
      final updatedJourneys = state.journeys.map((journey) {
        return journey.journeyId == journeyId ? updatedJourney : journey;
      }).toList();

      state = state.copyWith(
        journeys: updatedJourneys,
        currentJourney: state.currentJourney?.journeyId == journeyId
            ? updatedJourney
            : state.currentJourney,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Update export settings
  Future<void> updateExportSettings(
    String journeyId,
    MemoryJourneyExportSettingsEntity exportSettings,
  ) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedJourney =
          await _updateExportSettingsUseCase(journeyId, exportSettings);

      // Update in journeys list
      final updatedJourneys = state.journeys.map((journey) {
        return journey.journeyId == journeyId ? updatedJourney : journey;
      }).toList();

      state = state.copyWith(
        journeys: updatedJourneys,
        currentJourney: state.currentJourney?.journeyId == journeyId
            ? updatedJourney
            : state.currentJourney,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Set current journey
  void setCurrentJourney(MemoryJourneyEntity? journey) {
    state = state.copyWith(currentJourney: journey);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Clear search
  void clearSearch() {
    state = state.copyWith(searchQuery: null);
  }
}

/// Memory Journey Provider
final memoryJourneyProvider =
    StateNotifierProvider<MemoryJourneyNotifier, MemoryJourneyState>((ref) {
  return MemoryJourneyNotifier(
    createJourneyUseCase: ref.watch(createMemoryJourneyUseCaseProvider),
    getJourneyUseCase: ref.watch(getMemoryJourneyUseCaseProvider),
    getAllJourneysUseCase: ref.watch(getAllMemoryJourneysUseCaseProvider),
    getRecentJourneysUseCase: ref.watch(getRecentMemoryJourneysUseCaseProvider),
    searchJourneysUseCase: ref.watch(searchMemoryJourneysUseCaseProvider),
    updateJourneyUseCase: ref.watch(updateMemoryJourneyUseCaseProvider),
    addMemoryToJourneyUseCase: ref.watch(addMemoryToJourneyUseCaseProvider),
    removeMemoryFromJourneyUseCase:
        ref.watch(removeMemoryFromJourneyUseCaseProvider),
    updateJourneySettingsUseCase:
        ref.watch(updateJourneySettingsUseCaseProvider),
    updateExportSettingsUseCase: ref.watch(updateExportSettingsUseCaseProvider),
  );
});

/// Current Journey Provider
final currentJourneyProvider = Provider<MemoryJourneyEntity?>((ref) {
  return ref.watch(memoryJourneyProvider).currentJourney;
});

/// Journeys List Provider
final journeysListProvider = Provider<List<MemoryJourneyEntity>>((ref) {
  return ref.watch(memoryJourneyProvider).journeys;
});

/// Loading State Provider
final memoryJourneyLoadingProvider = Provider<bool>((ref) {
  return ref.watch(memoryJourneyProvider).isLoading;
});

/// Error State Provider
final memoryJourneyErrorProvider = Provider<String?>((ref) {
  return ref.watch(memoryJourneyProvider).error;
});

/// Search Query Provider
final memoryJourneySearchQueryProvider = Provider<String?>((ref) {
  return ref.watch(memoryJourneyProvider).searchQuery;
});
