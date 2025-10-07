import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'dart:io';
// import '../models/hive_adapters.dart';

/// Hive service for local storage
/// Follows master plan offline-first standards
class HiveService {
  static final HiveService _instance = HiveService._internal();
  factory HiveService() => _instance;
  HiveService._internal();

  bool _isInitialized = false;
  final Map<String, Box> _boxes = {};

  /// Initialize Hive service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Get application documents directory
      final directory = await getApplicationDocumentsDirectory();
      Hive.init(directory.path);

      // Register adapters
      _registerAdapters();

      // Open boxes
      await _openBoxes();

      _isInitialized = true;
    } catch (e) {
      throw Exception('Failed to initialize Hive: $e');
    }
  }

  /// Register Hive adapters
  void _registerAdapters() {
    // Register custom adapters here
    // Hive.registerAdapter(BabyResultAdapter());
    // Hive.registerAdapter(UserProfileAdapter());
    // Hive.registerAdapter(QuizResultAdapter());
  }

  /// Open all required boxes
  Future<void> _openBoxes() async {
    final boxNames = [
      'baby_results',
      'user_profiles',
      'quiz_results',
      'memory_journal',
      'couple_challenges',
      'premium_subscriptions',
      'analytics_events',
      'app_settings',
    ];

    for (final boxName in boxNames) {
      try {
        final box = await Hive.openBox(boxName);
        _boxes[boxName] = box;
      } catch (e) {
        // Failed to open box $boxName: $e
      }
    }
  }

  /// Get box by name
  Box? getBox(String boxName) {
    return _boxes[boxName];
  }

  /// Store data in box
  Future<void> store(String boxName, String key, dynamic value) async {
    final box = _boxes[boxName];
    if (box == null) {
      throw Exception('Box $boxName not found');
    }
    await box.put(key, value);
  }

  /// Retrieve data from box
  dynamic retrieve(String boxName, String key) {
    final box = _boxes[boxName];
    if (box == null) {
      throw Exception('Box $boxName not found');
    }
    return box.get(key);
  }

  /// Delete data from box
  Future<void> delete(String boxName, String key) async {
    final box = _boxes[boxName];
    if (box == null) {
      throw Exception('Box $boxName not found');
    }
    await box.delete(key);
  }

  /// Clear all data from box
  Future<void> clear(String boxName) async {
    final box = _boxes[boxName];
    if (box == null) {
      throw Exception('Box $boxName not found');
    }
    await box.clear();
  }

  /// Get all keys from box
  Iterable<dynamic> getKeys(String boxName) {
    final box = _boxes[boxName];
    if (box == null) {
      throw Exception('Box $boxName not found');
    }
    return box.keys;
  }

  /// Get all values from box
  Iterable<dynamic> getValues(String boxName) {
    final box = _boxes[boxName];
    if (box == null) {
      throw Exception('Box $boxName not found');
    }
    return box.values;
  }

  /// Check if key exists in box
  bool containsKey(String boxName, String key) {
    final box = _boxes[boxName];
    if (box == null) {
      throw Exception('Box $boxName not found');
    }
    return box.containsKey(key);
  }

  /// Get box length
  int getLength(String boxName) {
    final box = _boxes[boxName];
    if (box == null) {
      throw Exception('Box $boxName not found');
    }
    return box.length;
  }

  /// Close all boxes
  Future<void> closeAll() async {
    for (final box in _boxes.values) {
      await box.close();
    }
    _boxes.clear();
    _isInitialized = false;
  }

  /// Get storage size
  Future<int> getStorageSize() async {
    int totalSize = 0;
    for (final box in _boxes.values) {
      totalSize += box.length;
    }
    return totalSize;
  }

  /// Clean up old data
  Future<void> cleanupOldData({int daysOld = 30}) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));

    for (final boxName in _boxes.keys) {
      final box = _boxes[boxName];
      if (box == null) continue;

      final keysToDelete = <String>[];

      for (final key in box.keys) {
        final value = box.get(key);
        if (value is Map && value.containsKey('createdAt')) {
          final createdAt = DateTime.parse(value['createdAt']);
          if (createdAt.isBefore(cutoffDate)) {
            keysToDelete.add(key.toString());
          }
        }
      }

      for (final key in keysToDelete) {
        await box.delete(key);
      }
    }
  }

  /// Backup data
  Future<void> backupData() async {
    // Implementation for data backup
    // This could save data to cloud storage or export to file
  }

  /// Restore data
  Future<void> restoreData() async {
    // Implementation for data restore
    // This could restore data from cloud storage or import from file
  }
}

/// Hive service provider for Riverpod
final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});
