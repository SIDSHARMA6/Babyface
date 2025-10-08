import '../../../../shared/services/firebase_user_service.dart';
import '../models/memory_model.dart';

/// Firebase Memory Repository
/// Provides full CRUD operations for memories in Firestore
class FirebaseMemoryRepository {
  final FirebaseUserService _firebaseUserService;

  FirebaseMemoryRepository(this._firebaseUserService);

  /// Get all memories for the current user
  Future<List<MemoryModel>> getAllMemories() async {
    try {
      final currentUser = _firebaseUserService.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final memoriesData =
          await _firebaseUserService.getMemories(currentUser.uid);

      return memoriesData.map((data) => MemoryModel.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Failed to get memories: $e');
    }
  }

  /// Get memory by ID
  Future<MemoryModel?> getMemoryById(String id) async {
    try {
      final currentUser = _firebaseUserService.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final memories = await getAllMemories();
      return memories.where((memory) => memory.id == id).firstOrNull;
    } catch (e) {
      throw Exception('Failed to get memory by ID: $e');
    }
  }

  /// Add new memory
  Future<MemoryModel> addMemory(MemoryModel memory) async {
    try {
      final currentUser = _firebaseUserService.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      await _firebaseUserService.saveMemory(
        userId: currentUser.uid,
        memoryId: memory.id,
        title: memory.title,
        description: memory.description,
        emoji: memory.emoji,
        photoPath: memory.photoPath,
        voicePath: memory.voicePath,
        mood: memory.mood,
        date: DateTime.fromMillisecondsSinceEpoch(memory.timestamp),
        tags: memory.tags,
        location: memory.location,
      );

      return memory;
    } catch (e) {
      throw Exception('Failed to add memory: $e');
    }
  }

  /// Update existing memory
  Future<MemoryModel> updateMemory(MemoryModel memory) async {
    try {
      final currentUser = _firebaseUserService.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      await _firebaseUserService.updateMemory(
        userId: currentUser.uid,
        memoryId: memory.id,
        title: memory.title,
        description: memory.description,
        emoji: memory.emoji,
        photoPath: memory.photoPath,
        voicePath: memory.voicePath,
        mood: memory.mood,
        date: DateTime.fromMillisecondsSinceEpoch(memory.timestamp),
        tags: memory.tags,
        location: memory.location,
        isFavorite: memory.isFavorite,
      );

      return memory;
    } catch (e) {
      throw Exception('Failed to update memory: $e');
    }
  }

  /// Delete memory
  Future<void> deleteMemory(String id) async {
    try {
      final currentUser = _firebaseUserService.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      await _firebaseUserService.deleteMemory(
        userId: currentUser.uid,
        memoryId: id,
      );
    } catch (e) {
      throw Exception('Failed to delete memory: $e');
    }
  }

  /// Toggle favorite status
  Future<void> toggleFavorite(String id) async {
    try {
      final currentUser = _firebaseUserService.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final memory = await getMemoryById(id);
      if (memory == null) {
        throw Exception('Memory not found');
      }

      await _firebaseUserService.toggleMemoryFavorite(
        userId: currentUser.uid,
        memoryId: id,
        isFavorite: !memory.isFavorite,
      );
    } catch (e) {
      throw Exception('Failed to toggle favorite: $e');
    }
  }

  /// Get favorite memories
  Future<List<MemoryModel>> getFavoriteMemories() async {
    try {
      final allMemories = await getAllMemories();
      return allMemories.where((memory) => memory.isFavorite).toList();
    } catch (e) {
      throw Exception('Failed to get favorite memories: $e');
    }
  }

  /// Get memories by mood
  Future<List<MemoryModel>> getMemoriesByMood(String mood) async {
    try {
      final allMemories = await getAllMemories();
      return allMemories.where((memory) => memory.mood == mood).toList();
    } catch (e) {
      throw Exception('Failed to get memories by mood: $e');
    }
  }

  /// Search memories
  Future<List<MemoryModel>> searchMemories(String query) async {
    try {
      final allMemories = await getAllMemories();
      final lowercaseQuery = query.toLowerCase();

      return allMemories.where((memory) {
        return memory.title.toLowerCase().contains(lowercaseQuery) ||
            memory.description.toLowerCase().contains(lowercaseQuery) ||
            memory.tags
                .any((tag) => tag.toLowerCase().contains(lowercaseQuery));
      }).toList();
    } catch (e) {
      throw Exception('Failed to search memories: $e');
    }
  }
}
