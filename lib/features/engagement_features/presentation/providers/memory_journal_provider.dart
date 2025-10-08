import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/services/hive_service.dart';
import '../../../../shared/services/firebase_user_service.dart';
import '../../data/models/memory_model.dart';
import '../../data/repositories/hybrid_memory_repository.dart';

/// Memory journal state
class MemoryJournalState {
  final List<MemoryModel> memories;
  final bool isLoading;
  final String? errorMessage;
  final bool isAddingMemory;

  const MemoryJournalState({
    this.memories = const [],
    this.isLoading = false,
    this.errorMessage,
    this.isAddingMemory = false,
  });

  MemoryJournalState copyWith({
    List<MemoryModel>? memories,
    bool? isLoading,
    String? errorMessage,
    bool? isAddingMemory,
  }) {
    return MemoryJournalState(
      memories: memories ?? this.memories,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isAddingMemory: isAddingMemory ?? this.isAddingMemory,
    );
  }
}

/// Memory journal notifier with Hive and Firebase integration
class MemoryJournalNotifier extends StateNotifier<MemoryJournalState> {
  final HybridMemoryRepository _repository;

  MemoryJournalNotifier(this._repository) : super(const MemoryJournalState()) {
    loadMemories();
  }

  /// Load all memories from Hive
  Future<void> loadMemories() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final memories = await _repository.getAllMemories();

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

  /// Add new memory
  Future<void> addMemory({
    required String title,
    required String description,
    required String emoji,
    String? photoPath,
    String? voicePath,
    String? location,
    List<String> tags = const [],
    String mood = 'joyful',
    DateTime? date,
  }) async {
    try {
      state = state.copyWith(isAddingMemory: true, errorMessage: null);

      final now = DateTime.now();
      final memoryId = 'memory_${now.millisecondsSinceEpoch}';
      final memoryDate = date ?? now;
      final memory = MemoryModel(
        id: memoryId,
        title: title,
        description: description,
        emoji: emoji,
        photoPath: photoPath,
        voicePath: voicePath,
        date: memoryDate.toIso8601String(),
        mood: mood,
        positionIndex: state.memories.length,
        timestamp: memoryDate.millisecondsSinceEpoch,
        location: location,
        tags: tags,
      );

      // Save to both Hive and Firebase (hybrid repository handles this)
      await _repository.addMemory(memory);

      // Add to current state
      final updatedMemories = [memory, ...state.memories];
      state = state.copyWith(
        memories: updatedMemories,
        isAddingMemory: false,
      );
    } catch (e) {
      state = state.copyWith(
        isAddingMemory: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Update existing memory
  Future<void> updateMemory(MemoryModel memory) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      await _repository.updateMemory(memory);

      // Update in current state
      final updatedMemories = state.memories.map((m) {
        if (m.id == memory.id) return memory;
        return m;
      }).toList();

      state = state.copyWith(
        memories: updatedMemories,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Update existing memory with individual parameters
  Future<void> updateMemoryWithParams(
    String memoryId, {
    required String title,
    required String description,
    required String emoji,
    String? photoPath,
    String? voicePath,
    String? location,
    List<String> tags = const [],
    String mood = 'joyful',
  }) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      // Find existing memory
      final existingMemory = state.memories.firstWhere(
        (m) => m.id == memoryId,
        orElse: () => throw Exception('Memory not found'),
      );

      // Create updated memory
      final updatedMemory = existingMemory.copyWith(
        title: title,
        description: description,
        emoji: emoji,
        photoPath: photoPath,
        voicePath: voicePath,
        location: location,
        tags: tags,
        mood: mood,
      );

      await _repository.updateMemory(updatedMemory);

      // Update in current state
      final updatedMemories = state.memories.map((m) {
        if (m.id == memoryId) return updatedMemory;
        return m;
      }).toList();

      state = state.copyWith(
        memories: updatedMemories,
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
      await _repository.toggleFavorite(memoryId);

      // Update in current state
      final updatedMemories = state.memories.map((memory) {
        if (memory.id == memoryId) {
          return memory.copyWith(isFavorite: !memory.isFavorite);
        }
        return memory;
      }).toList();

      state = state.copyWith(memories: updatedMemories);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  /// Delete memory
  Future<void> deleteMemory(String memoryId) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      await _repository.deleteMemory(memoryId);

      // Remove from current state
      final updatedMemories =
          state.memories.where((m) => m.id != memoryId).toList();

      state = state.copyWith(
        memories: updatedMemories,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Search memories
  Future<void> searchMemories(String query) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final memories = await _repository.searchMemories(query);

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

  /// Get favorite memories
  Future<void> getFavoriteMemories() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final memories = await _repository.getFavoriteMemories();

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

  /// Refresh memories
  Future<void> refresh() async {
    await loadMemories();
  }
}

/// Hybrid repository provider
final hybridMemoryRepositoryProvider = Provider<HybridMemoryRepository>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  final firebaseUserService = ref.watch(firebaseUserServiceProvider);
  return HybridMemoryRepository(hiveService, firebaseUserService);
});

/// Memory journal provider
final memoryJournalProvider =
    StateNotifierProvider<MemoryJournalNotifier, MemoryJournalState>((ref) {
  final repository = ref.watch(hybridMemoryRepositoryProvider);
  return MemoryJournalNotifier(repository);
});
