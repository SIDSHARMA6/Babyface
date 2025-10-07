import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/baby_generation_entity.dart';
import '../../domain/usecases/start_baby_generation_usecase.dart';
import '../../data/repositories/baby_generation_repository_impl.dart';
import '../../data/datasources/baby_generation_local_datasource.dart';
import '../../data/datasources/baby_generation_remote_datasource.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

/// Baby generation state
class BabyGenerationState {
  final List<BabyGenerationEntity> generations;
  final BabyGenerationEntity? currentGeneration;
  final bool isLoading;
  final String? errorMessage;

  const BabyGenerationState({
    this.generations = const [],
    this.currentGeneration,
    this.isLoading = false,
    this.errorMessage,
  });

  BabyGenerationState copyWith({
    List<BabyGenerationEntity>? generations,
    BabyGenerationEntity? currentGeneration,
    bool? isLoading,
    String? errorMessage,
  }) {
    return BabyGenerationState(
      generations: generations ?? this.generations,
      currentGeneration: currentGeneration ?? this.currentGeneration,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Baby generation notifier
class BabyGenerationNotifier extends StateNotifier<BabyGenerationState> {
  final StartBabyGenerationUsecase _startGenerationUsecase;
  final BabyGenerationRepositoryImpl _repository;

  BabyGenerationNotifier(
    this._startGenerationUsecase,
    this._repository,
  ) : super(const BabyGenerationState());

  /// Start baby generation
  Future<void> startGeneration({
    required String maleImagePath,
    required String femaleImagePath,
  }) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final generation = await _startGenerationUsecase.execute(
        maleImagePath: maleImagePath,
        femaleImagePath: femaleImagePath,
      );

      state = state.copyWith(
        currentGeneration: generation,
        generations: [generation, ...state.generations],
        isLoading: false,
      );

      // Start monitoring the generation
      _monitorGeneration(generation.id);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Monitor generation progress
  void _monitorGeneration(String id) {
    // This would typically use a timer or stream to check status
    // For now, we'll simulate progress updates
    _simulateProgress(id);
  }

  /// Simulate generation progress
  void _simulateProgress(String id) async {
    for (int i = 0; i <= 100; i += 10) {
      await Future.delayed(const Duration(milliseconds: 500));
      
      final currentGen = state.currentGeneration;
      if (currentGen != null && currentGen.id == id) {
        final updatedGen = currentGen.copyWith(
          progress: i / 100.0,
          status: i < 100 ? GenerationStatus.processing : GenerationStatus.completed,
          generatedImagePath: i == 100 ? 'generated_baby_$id.jpg' : null,
          completedAt: i == 100 ? DateTime.now() : null,
        );

        state = state.copyWith(currentGeneration: updatedGen);
        
        // Update in repository
        if (i == 100) {
          await _repository.completeGeneration(id, 'generated_baby_$id.jpg');
        } else {
          await _repository.updateProgress(id, i / 100.0);
        }
      }
    }
  }

  /// Cancel current generation
  Future<void> cancelGeneration() async {
    final currentGen = state.currentGeneration;
    if (currentGen != null) {
      await _repository.cancelGeneration(currentGen.id);
      state = state.copyWith(currentGeneration: null);
    }
  }

  /// Load all generations
  Future<void> loadGenerations() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final generations = await _repository.getAllGenerations();
      
      state = state.copyWith(
        generations: generations,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Delete generation
  Future<void> deleteGeneration(String id) async {
    try {
      await _repository.deleteGeneration(id);
      
      state = state.copyWith(
        generations: state.generations.where((g) => g.id != id).toList(),
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }
}

/// Provider for baby generation repository
final babyGenerationRepositoryProvider = Provider<BabyGenerationRepositoryImpl>((ref) {
  final localDatasource = BabyGenerationLocalDatasourceImpl();
  final remoteDatasource = BabyGenerationRemoteDatasourceImpl(http.Client());
  final uuid = const Uuid();
  
  return BabyGenerationRepositoryImpl(localDatasource, remoteDatasource, uuid);
});

/// Provider for start baby generation use case
final startBabyGenerationUsecaseProvider = Provider<StartBabyGenerationUsecase>((ref) {
  final repository = ref.watch(babyGenerationRepositoryProvider);
  return StartBabyGenerationUsecase(repository);
});

/// Provider for baby generation notifier
final babyGenerationProvider = StateNotifierProvider<BabyGenerationNotifier, BabyGenerationState>((ref) {
  final startUsecase = ref.watch(startBabyGenerationUsecaseProvider);
  final repository = ref.watch(babyGenerationRepositoryProvider);
  
  return BabyGenerationNotifier(startUsecase, repository);
});
