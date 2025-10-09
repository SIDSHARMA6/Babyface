import 'dart:convert';
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';
import 'simple_firebase_service.dart';

/// Simple Memory Model - With photo support
class SimpleMemory {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final String date;
  final String mood;
  final int timestamp;
  final bool isFavorite;
  final String? photoPath;
  final String? voicePath;
  final String? location;
  final List<String> tags;

  SimpleMemory({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.date,
    required this.mood,
    required this.timestamp,
    this.isFavorite = false,
    this.photoPath,
    this.voicePath,
    this.location,
    this.tags = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'emoji': emoji,
        'date': date,
        'mood': mood,
        'timestamp': timestamp,
        'isFavorite': isFavorite,
        'photoPath': photoPath,
        'voicePath': voicePath,
        'location': location,
        'tags': tags,
      };

  factory SimpleMemory.fromJson(Map<String, dynamic> json) => SimpleMemory(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        emoji: json['emoji'] ?? '💕',
        date: json['date'] ?? '',
        mood: json['mood'] ?? 'happy',
        timestamp: json['timestamp'] ?? 0,
        isFavorite: json['isFavorite'] ?? false,
        photoPath: json['photoPath'],
        voicePath: json['voicePath'],
        location: json['location'],
        tags: List<String>.from(json['tags'] ?? []),
      );
}

/// Simple Memory Service using SharedPreferences
/// Ultra-simple, no complex file handling
class SimpleMemoryService {
  static const String _memoriesKey = 'memories';
  static bool _isSyncing = false; // Prevent multiple simultaneous syncs

  /// Get all memories async (for SharedPreferences)
  static Future<List<SimpleMemory>> getAllMemoriesAsync() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final memoriesJson = prefs.getStringList(_memoriesKey) ?? [];

      return memoriesJson.map((jsonString) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        return SimpleMemory.fromJson(json);
      }).toList();
    } catch (e) {
      developer.log('Error getting memories: $e');
      return [];
    }
  }

  /// Get all memories with Firebase sync
  /// Shows SharedPrefs first, then does ONE Firebase sync
  static Future<List<SimpleMemory>> getAllMemoriesWithSync() async {
    try {
      // 1. Get memories from SharedPreferences (instant)
      final localMemories = await getAllMemoriesAsync();
      developer.log(
          '📱 Loaded ${localMemories.length} memories from SharedPreferences');

      // 2. Do ONE Firebase sync (no callback, no infinite loop)
      if (!_isSyncing) {
        _isSyncing = true;
        Future.microtask(() async {
          try {
            developer.log('🔄 Starting ONE Firebase sync...');
            final firebaseMemories =
                await SimpleFirebaseService.getMemoriesFromFirebase();
            if (firebaseMemories.isNotEmpty) {
              await _saveMemoriesToSharedPrefs(firebaseMemories);
              developer.log(
                  '✅ Firebase sync completed: ${firebaseMemories.length} memories');
            }
          } catch (e) {
            developer.log('❌ Firebase sync failed: $e');
          } finally {
            _isSyncing = false;
          }
        });
      }

      return localMemories;
    } catch (e) {
      developer.log('Error getting memories with sync: $e');
      return [];
    }
  }

  /// Save memories to SharedPreferences
  static Future<void> _saveMemoriesToSharedPrefs(
      List<SimpleMemory> memories) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final memoriesJson =
          memories.map((memory) => jsonEncode(memory.toJson())).toList();
      await prefs.setStringList(_memoriesKey, memoriesJson);
    } catch (e) {
      developer.log('Error saving memories to SharedPreferences: $e');
    }
  }

  /// Save memory - SharedPreferences + Firebase sync
  static Future<void> saveMemory(SimpleMemory memory) async {
    try {
      // 1. Save to SharedPreferences (instant)
      final prefs = await SharedPreferences.getInstance();
      final memoriesJson = prefs.getStringList(_memoriesKey) ?? [];

      // Remove existing memory with same ID
      memoriesJson.removeWhere((jsonString) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        return json['id'] == memory.id;
      });

      // Add new memory
      memoriesJson.add(jsonEncode(memory.toJson()));

      await prefs.setStringList(_memoriesKey, memoriesJson);
      developer.log('✅ Memory saved to SharedPreferences: ${memory.title}');

      // 2. Save to Firebase in background (don't await)
      _saveToFirebaseInBackground(memory);
    } catch (e) {
      developer.log('❌ Error saving memory: $e');
    }
  }

  /// Save to Firebase in background
  static void _saveToFirebaseInBackground(SimpleMemory memory) {
    Future.microtask(() async {
      try {
        await SimpleFirebaseService.saveMemoryToFirebase(memory);
      } catch (e) {
        developer.log('❌ Error saving to Firebase: $e');
      }
    });
  }

  /// Delete memory - SharedPreferences + Firebase sync
  static Future<void> deleteMemory(String id) async {
    try {
      // 1. Delete from SharedPreferences (instant)
      final prefs = await SharedPreferences.getInstance();
      final memoriesJson = prefs.getStringList(_memoriesKey) ?? [];

      memoriesJson.removeWhere((jsonString) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        return json['id'] == id;
      });

      await prefs.setStringList(_memoriesKey, memoriesJson);
      developer.log('✅ Memory deleted from SharedPreferences: $id');

      // 2. Delete from Firebase in background (don't await)
      _deleteFromFirebaseInBackground(id);
    } catch (e) {
      developer.log('❌ Error deleting memory: $e');
    }
  }

  /// Delete from Firebase in background
  static void _deleteFromFirebaseInBackground(String id) {
    Future.microtask(() async {
      try {
        await SimpleFirebaseService.deleteMemoryFromFirebase(id);
      } catch (e) {
        developer.log('❌ Error deleting from Firebase: $e');
      }
    });
  }

  /// Toggle favorite
  static Future<void> toggleFavorite(String id) async {
    try {
      final memories = await getAllMemoriesAsync();
      final memory = memories.firstWhere((m) => m.id == id);

      final updatedMemory = SimpleMemory(
        id: memory.id,
        title: memory.title,
        description: memory.description,
        emoji: memory.emoji,
        date: memory.date,
        mood: memory.mood,
        timestamp: memory.timestamp,
        isFavorite: !memory.isFavorite,
      );

      await saveMemory(updatedMemory);
    } catch (e) {
      developer.log('❌ Error toggling favorite: $e');
    }
  }
}
