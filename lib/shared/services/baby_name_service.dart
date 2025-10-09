import 'dart:developer' as developer;
import 'hive_service.dart';
import 'firebase_service.dart';

/// Generated baby name model
class GeneratedBabyName {
  final String id;
  final String name;
  final String meaning;
  final String gender;
  final double loveScore;
  final DateTime createdAt;
  final String? parent1Name;
  final String? parent2Name;

  GeneratedBabyName({
    required this.id,
    required this.name,
    required this.meaning,
    required this.gender,
    required this.loveScore,
    required this.createdAt,
    this.parent1Name,
    this.parent2Name,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'meaning': meaning,
        'gender': gender,
        'loveScore': loveScore,
        'createdAt': createdAt.toIso8601String(),
        'parent1Name': parent1Name,
        'parent2Name': parent2Name,
      };

  static GeneratedBabyName fromJson(Map<String, dynamic> json) =>
      GeneratedBabyName(
        id: json['id'],
        name: json['name'],
        meaning: json['meaning'],
        gender: json['gender'],
        loveScore: json['loveScore'].toDouble(),
        createdAt: DateTime.parse(json['createdAt']),
        parent1Name: json['parent1Name'],
        parent2Name: json['parent2Name'],
      );
}

/// Final baby name model
class FinalBabyName {
  final String id;
  final String name;
  final String meaning;
  final String gender;
  final DateTime createdAt;
  final String? parent1Name;
  final String? parent2Name;
  final String? notes;

  FinalBabyName({
    required this.id,
    required this.name,
    required this.meaning,
    required this.gender,
    required this.createdAt,
    this.parent1Name,
    this.parent2Name,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'meaning': meaning,
        'gender': gender,
        'createdAt': createdAt.toIso8601String(),
        'parent1Name': parent1Name,
        'parent2Name': parent2Name,
        'notes': notes,
      };

  static FinalBabyName fromJson(Map<String, dynamic> json) => FinalBabyName(
        id: json['id'],
        name: json['name'],
        meaning: json['meaning'],
        gender: json['gender'],
        createdAt: DateTime.parse(json['createdAt']),
        parent1Name: json['parent1Name'],
        parent2Name: json['parent2Name'],
        notes: json['notes'],
      );
}

/// Service to manage baby names generation and final name saving
class BabyNameService {
  static const String _generatedNamesKey = 'generated_baby_names';
  static const String _finalNamesKey = 'final_baby_names';
  static const String _generationCountKey = 'baby_name_generation_count';

  static BabyNameService? _instance;
  static BabyNameService get instance => _instance ??= BabyNameService._();

  BabyNameService._();

  final HiveService _hiveService = HiveService();
  final FirebaseService _firebaseService = FirebaseService();

  /// Save generated baby name
  Future<bool> saveGeneratedName(GeneratedBabyName name) async {
    try {
      // Ensure box is open before accessing
      await _hiveService.ensureBoxOpen('baby_names_box');

      if (!_hiveService.isBoxOpen('baby_names_box')) {
        developer.log(
            '🔐 [BabyNameService] Box not open, cannot save generated name');
        return false;
      }

      // Get existing generated names
      final existingNames = await getGeneratedNames();
      existingNames.add(name);

      // Save to Hive
      await _hiveService.store('baby_names_box', _generatedNamesKey,
          existingNames.map((n) => n.toJson()).toList());

      // Update generation count
      await _incrementGenerationCount();

      // Save to Firebase
      await _saveGeneratedNameToFirebase(name);

      developer.log('✅ Generated baby name saved: ${name.name}');
      return true;
    } catch (e) {
      developer.log('❌ Error saving generated name: $e');
      return false;
    }
  }

  /// Get all generated baby names
  Future<List<GeneratedBabyName>> getGeneratedNames() async {
    try {
      // Ensure box is open before accessing
      await _hiveService.ensureBoxOpen('baby_names_box');

      if (!_hiveService.isBoxOpen('baby_names_box')) {
        developer
            .log('🔐 [BabyNameService] Box not open, returning empty list');
        return [];
      }

      final namesJson = _hiveService.retrieve(
          'baby_names_box', _generatedNamesKey) as List<dynamic>?;
      if (namesJson == null) return [];

      return namesJson
          .map((json) =>
              GeneratedBabyName.fromJson(json as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      developer.log('Error getting generated names: $e');
      return [];
    }
  }

  /// Save final baby name
  Future<bool> saveFinalName(FinalBabyName name) async {
    try {
      // Ensure box is open before accessing
      await _hiveService.ensureBoxOpen('baby_names_box');

      if (!_hiveService.isBoxOpen('baby_names_box')) {
        developer
            .log('🔐 [BabyNameService] Box not open, cannot save final name');
        return false;
      }

      // Get existing final names
      final existingNames = await getFinalNames();
      existingNames.add(name);

      // Save to Hive
      await _hiveService.store('baby_names_box', _finalNamesKey,
          existingNames.map((n) => n.toJson()).toList());

      // Save to Firebase
      await _saveFinalNameToFirebase(name);

      developer.log('✅ Final baby name saved: ${name.name}');
      return true;
    } catch (e) {
      developer.log('❌ Error saving final name: $e');
      return false;
    }
  }

  /// Get all final baby names
  Future<List<FinalBabyName>> getFinalNames() async {
    try {
      // Ensure box is open before accessing
      await _hiveService.ensureBoxOpen('baby_names_box');

      if (!_hiveService.isBoxOpen('baby_names_box')) {
        developer
            .log('🔐 [BabyNameService] Box not open, returning empty list');
        return [];
      }

      final namesJson = _hiveService.retrieve('baby_names_box', _finalNamesKey)
          as List<dynamic>?;
      if (namesJson == null) return [];

      return namesJson
          .map((json) => FinalBabyName.fromJson(json as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      developer.log('Error getting final names: $e');
      return [];
    }
  }

  /// Get generation count
  Future<int> getGenerationCount() async {
    try {
      // Ensure box is open before accessing
      await _hiveService.ensureBoxOpen('baby_names_box');

      if (!_hiveService.isBoxOpen('baby_names_box')) {
        developer.log('🔐 [BabyNameService] Box not open, returning 0 count');
        return 0;
      }

      final count =
          _hiveService.retrieve('baby_names_box', _generationCountKey) as int?;
      return count ?? 0;
    } catch (e) {
      developer.log('Error getting generation count: $e');
      return 0;
    }
  }

  /// Get latest final name
  Future<String?> getLatestFinalName() async {
    try {
      final finalNames = await getFinalNames();
      if (finalNames.isEmpty) return null;
      return finalNames.first.name;
    } catch (e) {
      developer.log('Error getting latest final name: $e');
      return null;
    }
  }

  /// Increment generation count
  Future<void> _incrementGenerationCount() async {
    try {
      final currentCount = await getGenerationCount();
      await _hiveService.store(
          'baby_names_box', _generationCountKey, currentCount + 1);
    } catch (e) {
      developer.log('Error incrementing generation count: $e');
    }
  }

  /// Load generated names from Firebase and sync with local storage
  Future<void> syncGeneratedNamesFromFirebase() async {
    try {
      if (!_firebaseService.isInitialized ||
          _firebaseService.firestore == null) {
        developer.log('Firebase not initialized, skipping sync');
        return;
      }

      final userId = _firebaseService.currentUser?.uid;
      if (userId == null) {
        developer.log('No user logged in, skipping Firebase sync');
        return;
      }

      // Ensure box is open
      await _hiveService.ensureBoxOpen('baby_names_box');
      if (!_hiveService.isBoxOpen('baby_names_box')) {
        developer.log('Box not open, cannot sync');
        return;
      }

      // Get data from Firebase
      final snapshot = await _firebaseService.firestore!
          .collection('users')
          .doc(userId)
          .collection('generated_baby_names')
          .get();

      if (snapshot.docs.isNotEmpty) {
        final firebaseNames = snapshot.docs
            .map((doc) => GeneratedBabyName.fromJson(doc.data()))
            .toList();

        // Save to local storage
        await _hiveService.store('baby_names_box', _generatedNamesKey,
            firebaseNames.map((n) => n.toJson()).toList());

        developer.log(
            '✅ Synced ${firebaseNames.length} generated names from Firebase');
      }
    } catch (e) {
      developer.log('❌ Error syncing generated names from Firebase: $e');
    }
  }

  /// Load final names from Firebase and sync with local storage
  Future<void> syncFinalNamesFromFirebase() async {
    try {
      if (!_firebaseService.isInitialized ||
          _firebaseService.firestore == null) {
        developer.log('Firebase not initialized, skipping sync');
        return;
      }

      final userId = _firebaseService.currentUser?.uid;
      if (userId == null) {
        developer.log('No user logged in, skipping Firebase sync');
        return;
      }

      // Ensure box is open
      await _hiveService.ensureBoxOpen('baby_names_box');
      if (!_hiveService.isBoxOpen('baby_names_box')) {
        developer.log('Box not open, cannot sync');
        return;
      }

      // Get data from Firebase
      final snapshot = await _firebaseService.firestore!
          .collection('users')
          .doc(userId)
          .collection('final_baby_names')
          .get();

      if (snapshot.docs.isNotEmpty) {
        final firebaseNames = snapshot.docs
            .map((doc) => FinalBabyName.fromJson(doc.data()))
            .toList();

        // Save to local storage
        await _hiveService.store('baby_names_box', _finalNamesKey,
            firebaseNames.map((n) => n.toJson()).toList());

        developer
            .log('✅ Synced ${firebaseNames.length} final names from Firebase');
      }
    } catch (e) {
      developer.log('❌ Error syncing final names from Firebase: $e');
    }
  }

  /// Sync all baby name data from Firebase
  Future<void> syncAllDataFromFirebase() async {
    await syncGeneratedNamesFromFirebase();
    await syncFinalNamesFromFirebase();
  }

  /// Save generated name to Firebase
  Future<void> _saveGeneratedNameToFirebase(GeneratedBabyName name) async {
    try {
      if (!_firebaseService.isInitialized ||
          _firebaseService.firestore == null) {
        developer.log('Firebase not initialized, skipping generated name save');
        return;
      }

      final userId = _firebaseService.currentUser?.uid;
      if (userId == null) {
        developer.log('No user logged in, skipping Firebase save');
        return;
      }

      await _firebaseService.firestore!
          .collection('users')
          .doc(userId)
          .collection('generated_baby_names')
          .doc(name.id)
          .set(name.toJson());

      developer.log('✅ Generated name saved to Firebase: ${name.name}');
    } catch (e) {
      developer.log('❌ Error saving generated name to Firebase: $e');
    }
  }

  /// Save final name to Firebase
  Future<void> _saveFinalNameToFirebase(FinalBabyName name) async {
    try {
      if (!_firebaseService.isInitialized ||
          _firebaseService.firestore == null) {
        developer.log('Firebase not initialized, skipping final name save');
        return;
      }

      final userId = _firebaseService.currentUser?.uid;
      if (userId == null) {
        developer.log('No user logged in, skipping Firebase save');
        return;
      }

      await _firebaseService.firestore!
          .collection('users')
          .doc(userId)
          .collection('final_baby_names')
          .doc(name.id)
          .set(name.toJson());

      developer.log('✅ Final name saved to Firebase: ${name.name}');
    } catch (e) {
      developer.log('❌ Error saving final name to Firebase: $e');
    }
  }

  /// Clear all baby name data
  Future<bool> clearAllData() async {
    try {
      // Ensure box is open before accessing
      await _hiveService.ensureBoxOpen('baby_names_box');

      if (!_hiveService.isBoxOpen('baby_names_box')) {
        developer.log('🔐 [BabyNameService] Box not open, cannot clear data');
        return false;
      }

      // Clear from Hive
      await _hiveService.store(
          'baby_names_box', _generatedNamesKey, <Map<String, dynamic>>[]);
      await _hiveService
          .store('baby_names_box', _finalNamesKey, <Map<String, dynamic>>[]);
      await _hiveService.store('baby_names_box', _generationCountKey, 0);

      developer.log('✅ All baby name data cleared');
      return true;
    } catch (e) {
      developer.log('❌ Error clearing baby name data: $e');
      return false;
    }
  }
}
