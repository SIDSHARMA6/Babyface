import '../../../../shared/services/hive_service.dart';
import '../../../../shared/services/firebase_user_service.dart';
import '../models/memory_model.dart';
import 'memory_repository_impl.dart';
import 'firebase_memory_repository.dart';

/// Hybrid Memory Repository
/// Uses Hive for local storage and Firebase for cloud sync
/// Provides full CRUD operations with offline-first approach
class HybridMemoryRepository {
  final FirebaseUserService _firebaseUserService;
  final MemoryRepositoryImpl _hiveRepository;
  final FirebaseMemoryRepository _firebaseRepository;

  HybridMemoryRepository(HiveService hiveService, this._firebaseUserService)
      : _hiveRepository = MemoryRepositoryImpl(hiveService),
        _firebaseRepository = FirebaseMemoryRepository(_firebaseUserService);

  /// Get all memories (from Hive first, then sync with Firebase)
  Future<List<MemoryModel>> getAllMemories() async {
    try {
      // Get from Hive first (offline-first)
      final hiveMemories = await _hiveRepository.getAllMemories();

      // If user is authenticated, sync with Firebase
      if (_firebaseUserService.isSignedIn) {
        try {
          final firebaseMemories = await _firebaseRepository.getAllMemories();

          // Merge Firebase memories with Hive memories
          final allMemories = <String, MemoryModel>{};

          // Add Hive memories
          for (final memory in hiveMemories) {
            allMemories[memory.id] = memory;
          }

          // Add/Update with Firebase memories
          for (final memory in firebaseMemories) {
            allMemories[memory.id] = memory;
            // Also save to Hive for offline access
            await _hiveRepository.addMemory(memory);
          }

          return allMemories.values.toList()
            ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
        } catch (e) {
          // If Firebase fails, return Hive memories
          print('Firebase sync failed, using Hive data: $e');
          return hiveMemories;
        }
      }

      return hiveMemories;
    } catch (e) {
      throw Exception('Failed to get memories: $e');
    }
  }

  /// Get memory by ID
  Future<MemoryModel?> getMemoryById(String id) async {
    try {
      // Try Hive first
      final hiveMemory = await _hiveRepository.getMemoryById(id);
      if (hiveMemory != null) return hiveMemory;

      // If not in Hive and user is authenticated, try Firebase
      if (_firebaseUserService.isSignedIn) {
        try {
          final firebaseMemory = await _firebaseRepository.getMemoryById(id);
          if (firebaseMemory != null) {
            // Save to Hive for offline access
            await _hiveRepository.addMemory(firebaseMemory);
            return firebaseMemory;
          }
        } catch (e) {
          print('Firebase get memory failed: $e');
        }
      }

      return null;
    } catch (e) {
      throw Exception('Failed to get memory by ID: $e');
    }
  }

  /// Add new memory (save to both Hive and Firebase)
  Future<MemoryModel> addMemory(MemoryModel memory) async {
    try {
      // Save to Hive first (offline-first)
      await _hiveRepository.addMemory(memory);

      // If user is authenticated, also save to Firebase
      if (_firebaseUserService.isSignedIn) {
        try {
          await _firebaseRepository.addMemory(memory);
        } catch (e) {
          print('Firebase save failed, memory saved locally: $e');
          // Don't rethrow - memory is saved locally
        }
      }

      return memory;
    } catch (e) {
      throw Exception('Failed to add memory: $e');
    }
  }

  /// Update existing memory (update both Hive and Firebase)
  Future<MemoryModel> updateMemory(MemoryModel memory) async {
    try {
      // Update in Hive first
      await _hiveRepository.updateMemory(memory);

      // If user is authenticated, also update in Firebase
      if (_firebaseUserService.isSignedIn) {
        try {
          await _firebaseRepository.updateMemory(memory);
        } catch (e) {
          print('Firebase update failed, memory updated locally: $e');
          // Don't rethrow - memory is updated locally
        }
      }

      return memory;
    } catch (e) {
      throw Exception('Failed to update memory: $e');
    }
  }

  /// Delete memory (delete from both Hive and Firebase)
  Future<void> deleteMemory(String id) async {
    try {
      // Delete from Hive first
      await _hiveRepository.deleteMemory(id);

      // If user is authenticated, also delete from Firebase
      if (_firebaseUserService.isSignedIn) {
        try {
          await _firebaseRepository.deleteMemory(id);
        } catch (e) {
          print('Firebase delete failed, memory deleted locally: $e');
          // Don't rethrow - memory is deleted locally
        }
      }
    } catch (e) {
      throw Exception('Failed to delete memory: $e');
    }
  }

  /// Toggle favorite status (update both Hive and Firebase)
  Future<void> toggleFavorite(String id) async {
    try {
      // Toggle in Hive first
      await _hiveRepository.toggleFavorite(id);

      // If user is authenticated, also toggle in Firebase
      if (_firebaseUserService.isSignedIn) {
        try {
          await _firebaseRepository.toggleFavorite(id);
        } catch (e) {
          print('Firebase toggle favorite failed, updated locally: $e');
          // Don't rethrow - favorite is toggled locally
        }
      }
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

  /// Sync all memories with Firebase (useful for manual sync)
  Future<void> syncWithFirebase() async {
    if (!_firebaseUserService.isSignedIn) {
      throw Exception('User not authenticated');
    }

    try {
      // Get all Hive memories
      final hiveMemories = await _hiveRepository.getAllMemories();

      // Upload each memory to Firebase
      for (final memory in hiveMemories) {
        try {
          await _firebaseRepository.addMemory(memory);
        } catch (e) {
          print('Failed to sync memory ${memory.id}: $e');
        }
      }

      print('Memory sync completed');
    } catch (e) {
      throw Exception('Failed to sync with Firebase: $e');
    }
  }
}
