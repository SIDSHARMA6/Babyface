import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/services/simple_memory_service.dart';
import '../../data/models/memory_model.dart';

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

/// Memory journal notifier with SharedPreferences + Firebase integration
/// ULTRA-FAST PERFORMANCE - Instant UI updates with background persistence
class MemoryJournalNotifier extends StateNotifier<MemoryJournalState> {
  List<MemoryModel> _allMemories =
      []; // Cache all memories for instant filtering

  MemoryJournalNotifier() : super(const MemoryJournalState()) {
    loadMemories(); // Load from SharedPreferences + Firebase sync
  }

  /// Load memories from SharedPreferences + Firebase sync
  Future<void> loadMemories() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Get memories from SharedPreferences + Firebase sync
      final simpleMemories = await SimpleMemoryService.getAllMemoriesWithSync();

      // Convert SimpleMemory to MemoryModel
      final memories = simpleMemories
          .map((simpleMemory) => MemoryModel(
                id: simpleMemory.id,
                title: simpleMemory.title,
                description: simpleMemory.description,
                emoji: simpleMemory.emoji,
                photoPath: simpleMemory.photoPath,
                date: simpleMemory.date,
                voicePath: simpleMemory.voicePath,
                mood: simpleMemory.mood,
                positionIndex: 0,
                timestamp: simpleMemory.timestamp,
                isFavorite: simpleMemory.isFavorite,
                location: simpleMemory.location,
                tags: simpleMemory.tags,
              ))
          .toList();

      _allMemories = memories;
      state = state.copyWith(memories: memories, isLoading: false);
      developer.log(
          '📱 Loaded ${memories.length} memories from SharedPreferences + Firebase');
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
      developer.log('❌ Error loading memories: $e');
    }
  }

  /// Add new memory - SharedPreferences + Firebase
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
      state = state.copyWith(isAddingMemory: true);

      final memory = MemoryModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        description: description,
        emoji: emoji,
        photoPath: photoPath,
        date: date?.toIso8601String() ?? DateTime.now().toIso8601String(),
        voicePath: voicePath,
        mood: mood,
        positionIndex: _allMemories.length,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        isFavorite: false,
        location: location,
        tags: tags,
      );

      // Convert MemoryModel to SimpleMemory and save
      final simpleMemory = SimpleMemory(
        id: memory.id,
        title: memory.title,
        description: memory.description,
        emoji: memory.emoji,
        date: memory.date,
        mood: memory.mood,
        timestamp: memory.timestamp,
        isFavorite: memory.isFavorite,
        photoPath: memory.photoPath,
        voicePath: memory.voicePath,
        location: memory.location,
        tags: memory.tags,
      );

      await SimpleMemoryService.saveMemory(simpleMemory);

      // Refresh the list
      await loadMemories();

      state = state.copyWith(isAddingMemory: false);
      developer.log('✅ Memory added successfully: ${memory.title}');
    } catch (e) {
      state = state.copyWith(isAddingMemory: false, errorMessage: e.toString());
      developer.log('❌ Error adding memory: $e');
    }
  }

  /// Update memory - SharedPreferences + Firebase
  Future<void> updateMemory(MemoryModel memory) async {
    try {
      // Convert MemoryModel to SimpleMemory and save
      final simpleMemory = SimpleMemory(
        id: memory.id,
        title: memory.title,
        description: memory.description,
        emoji: memory.emoji,
        date: memory.date,
        mood: memory.mood,
        timestamp: memory.timestamp,
        isFavorite: memory.isFavorite,
        photoPath: memory.photoPath,
        voicePath: memory.voicePath,
        location: memory.location,
        tags: memory.tags,
      );

      await SimpleMemoryService.saveMemory(simpleMemory);

      // Refresh the list
      await loadMemories();

      developer.log('✅ Memory updated successfully: ${memory.title}');
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      developer.log('❌ Error updating memory: $e');
    }
  }

  /// Update memory with parameters - SharedPreferences + Firebase
  Future<MemoryModel> updateMemoryWithParams({
    required String id,
    String? title,
    String? description,
    String? emoji,
    String? photoPath,
    String? voicePath,
    String? location,
    List<String>? tags,
    String? mood,
    DateTime? date,
  }) async {
    try {
      // Find existing memory
      final existingMemory = _allMemories.firstWhere((m) => m.id == id);

      // Create updated memory
      final updatedMemory = existingMemory.copyWith(
        title: title ?? existingMemory.title,
        description: description ?? existingMemory.description,
        emoji: emoji ?? existingMemory.emoji,
        photoPath: photoPath ?? existingMemory.photoPath,
        voicePath: voicePath ?? existingMemory.voicePath,
        location: location ?? existingMemory.location,
        tags: tags ?? existingMemory.tags,
        mood: mood ?? existingMemory.mood,
        date: date?.toIso8601String() ?? existingMemory.date,
      );

      await updateMemory(updatedMemory);
      return updatedMemory;
    } catch (e) {
      developer.log('❌ Error updating memory with params: $e');
      return _allMemories.firstWhere((m) => m.id == id);
    }
  }

  /// Delete memory - SharedPreferences + Firebase
  Future<void> deleteMemory(String id) async {
    try {
      await SimpleMemoryService.deleteMemory(id);

      // Refresh the list
      await loadMemories();

      developer.log('✅ Memory deleted successfully: $id');
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      developer.log('❌ Error deleting memory: $e');
    }
  }

  /// Toggle favorite - SharedPreferences + Firebase
  Future<void> toggleFavorite(String id) async {
    try {
      await SimpleMemoryService.toggleFavorite(id);

      // Refresh the list
      await loadMemories();

      developer.log('✅ Favorite toggled successfully: $id');
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      developer.log('❌ Error toggling favorite: $e');
    }
  }

  /// Get favorite memories
  List<MemoryModel> getFavoriteMemories() {
    return _allMemories.where((memory) => memory.isFavorite).toList();
  }

  /// Get memories by mood
  List<MemoryModel> getMemoriesByMood(String mood) {
    return _allMemories.where((memory) => memory.mood == mood).toList();
  }

  /// Search memories
  List<MemoryModel> searchMemories(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _allMemories.where((memory) {
      return memory.title.toLowerCase().contains(lowercaseQuery) ||
          memory.description.toLowerCase().contains(lowercaseQuery) ||
          memory.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Provider
final memoryJournalProvider =
    StateNotifierProvider<MemoryJournalNotifier, MemoryJournalState>((ref) {
  return MemoryJournalNotifier();
});
