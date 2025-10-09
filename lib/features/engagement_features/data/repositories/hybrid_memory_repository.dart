import 'dart:async';
import 'dart:developer' as developer;
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

  /// Get all memories synchronously (instant read from Hive cache)
  List<MemoryModel> getAllMemoriesSync() {
    try {
      // Get from Hive cache instantly (no async)
      return _hiveRepository.getAllMemoriesSync();
    } catch (e) {
      developer.log('Error getting memories synchronously: $e');
      return [];
    }
  }

  /// Get all memories (from Hive first, then sync with Firebase)
  Future<List<MemoryModel>> getAllMemories() async {
    try {
      // Get from Hive first (offline-first)
      final hiveMemories = await _hiveRepository.getAllMemories();

      // If user is authenticated, sync with Firebase (non-blocking)
      if (_firebaseUserService.isSignedIn) {
        unawaited(_syncWithFirebase(hiveMemories));
      }

      return hiveMemories;
    } catch (e) {
      developer.log('Error getting memories from Hive, trying Firebase: $e');
      // If Hive fails and user is authenticated, try Firebase as fallback
      if (_firebaseUserService.isSignedIn) {
        try {
          final firebaseMemories = await _firebaseRepository.getAllMemories();
          // Save Firebase memories to Hive for future offline access
          for (final memory in firebaseMemories) {
            try {
              await _hiveRepository.addMemory(memory);
            } catch (hiveError) {
              developer.log('Failed to save Firebase memory to Hive: $hiveError');
            }
          }
          return firebaseMemories;
        } catch (firebaseError) {
          developer.log('Firebase also failed: $firebaseError');
        }
      }
      throw Exception('Failed to get memories: $e');
    }
  }

  /// Sync memories with Firebase (non-blocking)
  Future<void> _syncWithFirebase(List<MemoryModel> hiveMemories) async {
    try {
      final firebaseMemories = await _firebaseRepository.getAllMemories();

      // Create a map of Hive memories for quick lookup
      final hiveMemoryMap = <String, MemoryModel>{};
      for (final memory in hiveMemories) {
        hiveMemoryMap[memory.id] = memory;
      }

      // Sync Firebase memories to Hive (download)
      for (final firebaseMemory in firebaseMemories) {
        if (!hiveMemoryMap.containsKey(firebaseMemory.id)) {
          // New memory from Firebase, save to Hive
          try {
            await _hiveRepository.addMemory(firebaseMemory);
            developer.log(
                'Synced memory from Firebase to Hive: ${firebaseMemory.title}');
          } catch (e) {
            developer.log('Failed to sync memory ${firebaseMemory.id} to Hive: $e');
          }
        }
      }

      // Sync Hive memories to Firebase (upload)
      final firebaseMemoryMap = <String, MemoryModel>{};
      for (final memory in firebaseMemories) {
        firebaseMemoryMap[memory.id] = memory;
      }

      for (final hiveMemory in hiveMemories) {
        if (!firebaseMemoryMap.containsKey(hiveMemory.id)) {
          // New memory in Hive, upload to Firebase
          try {
            await _firebaseRepository.addMemory(hiveMemory);
            developer.log('Synced memory from Hive to Firebase: ${hiveMemory.title}');
          } catch (e) {
            developer.log('Failed to sync memory ${hiveMemory.id} to Firebase: $e');
          }
        }
      }
    } catch (e) {
      developer.log('Firebase sync failed: $e');
      // Don't rethrow - local data is still available
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
          developer.log('Firebase get memory failed: $e');
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

      // If user is authenticated, also save to Firebase (non-blocking)
      if (_firebaseUserService.isSignedIn) {
        unawaited(_firebaseRepository.addMemory(memory).catchError((e) {
          developer.log('Firebase save failed, memory saved locally: $e');
          return memory; // Return the memory that was saved locally
        }));
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
          developer.log('Firebase update failed, memory updated locally: $e');
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
          developer.log('Firebase delete failed, memory deleted locally: $e');
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
          developer.log('Firebase toggle favorite failed, updated locally: $e');
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
          developer.log('Failed to sync memory ${memory.id}: $e');
        }
      }

      developer.log('Memory sync completed');
    } catch (e) {
      throw Exception('Failed to sync with Firebase: $e');
    }
  }
}
