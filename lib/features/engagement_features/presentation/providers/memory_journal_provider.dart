import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/memory_journal_entity.dart';
import '../../domain/usecases/add_memory_usecase.dart';
import '../../domain/usecases/get_memories_usecase.dart';

/// Memory journal state
class MemoryJournalState {
  final List<MemoryJournalEntity> memories;
  final bool isLoading;
  final String? errorMessage;

  const MemoryJournalState({
    this.memories = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  MemoryJournalState copyWith({
    List<MemoryJournalEntity>? memories,
    bool? isLoading,
    String? errorMessage,
  }) {
    return MemoryJournalState(
      memories: memories ?? this.memories,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Memory journal notifier
class MemoryJournalNotifier extends StateNotifier<MemoryJournalState> {
  final AddMemoryUsecase _addMemoryUsecase;
  final GetMemoriesUsecase _getMemoriesUsecase;

  MemoryJournalNotifier(
    this._addMemoryUsecase,
    this._getMemoriesUsecase,
  ) : super(const MemoryJournalState()) {
    loadMemories();
  }

  /// Add new memory
  Future<void> addMemory(MemoryJournalRequest request) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final memory = await _addMemoryUsecase.execute(request);

      state = state.copyWith(
        memories: [memory, ...state.memories],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Load all memories
  Future<void> loadMemories() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final memories = await _getMemoriesUsecase.execute();

      state = state.copyWith(
        memories: memories,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Toggle favorite status
  Future<void> toggleFavorite(String memoryId) async {
    try {
      final memories = state.memories.map((memory) {
        if (memory.id == memoryId) {
          return memory.copyWith(isFavorite: !memory.isFavorite);
        }
        return memory;
      }).toList();

      state = state.copyWith(memories: memories);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  /// Delete memory
  Future<void> deleteMemory(String memoryId) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      // Remove from local state
      final memories = state.memories.where((m) => m.id != memoryId).toList();

      state = state.copyWith(
        memories: memories,
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
}

/// Provider for add memory use case
final addMemoryUsecaseProvider = Provider<AddMemoryUsecase>((ref) {
  throw UnimplementedError('AddMemoryUsecase must be provided');
});

/// Provider for get memories use case
final getMemoriesUsecaseProvider = Provider<GetMemoriesUsecase>((ref) {
  throw UnimplementedError('GetMemoriesUsecase must be provided');
});

/// Provider for memory journal notifier
final memoryJournalProvider = StateNotifierProvider<MemoryJournalNotifier, MemoryJournalState>((ref) {
  final addUsecase = ref.watch(addMemoryUsecaseProvider);
  final getUsecase = ref.watch(getMemoriesUsecaseProvider);
  
  return MemoryJournalNotifier(addUsecase, getUsecase);
});
