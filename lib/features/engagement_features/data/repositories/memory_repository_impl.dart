import '../../../../shared/services/hive_service.dart';
import 'dart:developer' as developer;
import '../models/memory_model.dart';

/// Memory repository interface
abstract class MemoryRepository {
  /// Get all memories sorted by timestamp
  Future<List<MemoryModel>> getAllMemories();

  /// Get all memories synchronously (instant read from cache)
  List<MemoryModel> getAllMemoriesSync();

  /// Get memory by ID
  Future<MemoryModel?> getMemoryById(String id);

  /// Add new memory
  Future<MemoryModel> addMemory(MemoryModel memory);

  /// Update existing memory
  Future<MemoryModel> updateMemory(MemoryModel memory);

  /// Delete memory
  Future<void> deleteMemory(String id);

  /// Toggle favorite status
  Future<void> toggleFavorite(String id);

  /// Get favorite memories
  Future<List<MemoryModel>> getFavoriteMemories();

  /// Get memories by mood
  Future<List<MemoryModel>> getMemoriesByMood(String mood);

  /// Search memories
  Future<List<MemoryModel>> searchMemories(String query);
}

/// Memory repository implementation with Hive storage
class MemoryRepositoryImpl implements MemoryRepository {
  final HiveService _hiveService;
  static const String _boxName = 'memory_box';

  MemoryRepositoryImpl(this._hiveService);

  @override
  List<MemoryModel> getAllMemoriesSync() {
    try {
      developer.log(
          '🔍 [MemoryRepository] Getting all memories synchronously from box: $_boxName');

      // Direct read from Hive cache - NO async
      final memoriesData = _hiveService.getAll(_boxName);
      developer.log(
          '🔍 [MemoryRepository] Retrieved ${memoriesData.length} entries from Hive');

      final memories = <MemoryModel>[];
      int processedCount = 0;

      for (final entry in memoriesData.entries) {
        // Safety check to prevent infinite loops
        if (processedCount >= 100) {
          developer.log(
              '⚠️ [MemoryRepository] Processed maximum 100 entries, stopping');
          break;
        }

        try {
          developer.log('🔍 [MemoryRepository] Processing entry: ${entry.key}');
          final memoryData = entry.value;

          // Ensure the data is in the correct format
          if (memoryData is Map) {
            // Convert to Map<String, dynamic> if needed
            final Map<String, dynamic> memoryMap =
                Map<String, dynamic>.from(memoryData);
            final memory = MemoryModel.fromMap(memoryMap);
            memories.add(memory);
            developer.log(
                '🔍 [MemoryRepository] Successfully loaded memory: ${memory.title}');
          } else {
            developer.log(
                '❌ [MemoryRepository] Invalid memory data format for ${entry.key}');
          }
        } catch (e) {
          developer.log('❌ [MemoryRepository] Error loading memory ${entry.key}: $e');
          // Skip invalid entries
          continue;
        }

        processedCount++;
      }

      // Sort by timestamp (newest first)
      memories.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      developer.log(
          '🔍 [MemoryRepository] Returning ${memories.length} memories synchronously');
      return memories;
    } catch (e) {
      developer.log('❌ [MemoryRepository] Failed to get memories synchronously: $e');
      // Return empty list instead of throwing to prevent app crashes
      return [];
    }
  }

  @override
  Future<List<MemoryModel>> getAllMemories() async {
    try {
      developer.log('🔍 [MemoryRepository] Getting all memories from box: $_boxName');

      // Ensure the box exists and is accessible
      final box = _hiveService.getBox(_boxName);
      if (box == null) {
        developer.log(
            '❌ [MemoryRepository] Box $_boxName not found, returning empty list');
        return [];
      }

      final memoriesData = _hiveService.getAll(_boxName);
      developer.log(
          '🔍 [MemoryRepository] Retrieved ${memoriesData.length} entries from Hive');

      final memories = <MemoryModel>[];
      int processedCount = 0;

      for (final entry in memoriesData.entries) {
        // Safety check to prevent infinite loops
        if (processedCount >= 100) {
          developer.log(
              '⚠️ [MemoryRepository] Processed maximum 100 entries, stopping');
          break;
        }

        try {
          developer.log('🔍 [MemoryRepository] Processing entry: ${entry.key}');
          final memoryData = entry.value;

          // Ensure the data is in the correct format
          if (memoryData is Map) {
            // Convert to Map<String, dynamic> if needed
            final Map<String, dynamic> memoryMap =
                Map<String, dynamic>.from(memoryData);
            final memory = MemoryModel.fromMap(memoryMap);
            memories.add(memory);
            developer.log(
                '🔍 [MemoryRepository] Successfully loaded memory: ${memory.title}');
          } else {
            developer.log(
                '❌ [MemoryRepository] Invalid memory data format for ${entry.key}');
          }
        } catch (e) {
          developer.log('❌ [MemoryRepository] Error loading memory ${entry.key}: $e');
          // Skip invalid entries
          continue;
        }

        processedCount++;
      }

      // Sort by timestamp (newest first)
      memories.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      developer.log('🔍 [MemoryRepository] Returning ${memories.length} memories');
      return memories;
    } catch (e) {
      developer.log('❌ [MemoryRepository] Failed to get memories: $e');
      // Return empty list instead of throwing to prevent app crashes
      return [];
    }
  }

  @override
  Future<MemoryModel?> getMemoryById(String id) async {
    try {
      final memoryData = _hiveService.retrieve(_boxName, id);
      if (memoryData == null) return null;

      return MemoryModel.fromMap(memoryData as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to get memory by ID: $e');
    }
  }

  @override
  Future<MemoryModel> addMemory(MemoryModel memory) async {
    try {
      developer.log(
          '💾 [MemoryRepository] Adding memory: ${memory.title} with ID: ${memory.id}');

      // Ensure the box exists
      final box = _hiveService.getBox(_boxName);
      if (box == null) {
        throw Exception('Hive box $_boxName not initialized');
      }

      final memoryMap = memory.toMap();
      developer.log('💾 [MemoryRepository] Memory map: $memoryMap');

      await _hiveService.store(_boxName, memory.id, memoryMap);
      developer.log('💾 [MemoryRepository] Memory stored successfully in Hive');

      // Verify the memory was actually saved
      final savedMemory = _hiveService.retrieve(_boxName, memory.id);
      if (savedMemory == null) {
        throw Exception('Memory was not properly saved to Hive');
      }

      developer.log('✅ [MemoryRepository] Memory persistence verified');
      return memory;
    } catch (e) {
      developer.log('❌ [MemoryRepository] Failed to add memory: $e');
      throw Exception('Failed to add memory: $e');
    }
  }

  @override
  Future<MemoryModel> updateMemory(MemoryModel memory) async {
    try {
      await _hiveService.store(_boxName, memory.id, memory.toMap());
      return memory;
    } catch (e) {
      throw Exception('Failed to update memory: $e');
    }
  }

  @override
  Future<void> deleteMemory(String id) async {
    try {
      await _hiveService.delete(_boxName, id);
    } catch (e) {
      throw Exception('Failed to delete memory: $e');
    }
  }

  @override
  Future<void> toggleFavorite(String id) async {
    try {
      final memory = await getMemoryById(id);
      if (memory == null) throw Exception('Memory not found');

      final updatedMemory = memory.copyWith(isFavorite: !memory.isFavorite);
      await updateMemory(updatedMemory);
    } catch (e) {
      throw Exception('Failed to toggle favorite: $e');
    }
  }

  @override
  Future<List<MemoryModel>> getFavoriteMemories() async {
    try {
      final allMemories = await getAllMemories();
      return allMemories.where((memory) => memory.isFavorite).toList();
    } catch (e) {
      throw Exception('Failed to get favorite memories: $e');
    }
  }

  @override
  Future<List<MemoryModel>> getMemoriesByMood(String mood) async {
    try {
      final allMemories = await getAllMemories();
      return allMemories.where((memory) => memory.mood == mood).toList();
    } catch (e) {
      throw Exception('Failed to get memories by mood: $e');
    }
  }

  @override
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
