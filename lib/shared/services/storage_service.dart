import '../models/avatar_data.dart';
import 'dart:developer' as developer;
import '../models/baby_result.dart';
import 'hive_service.dart';

/// Storage service for managing app data
class StorageService {
  static const String _maleAvatarKey = 'male_avatar';
  static const String _femaleAvatarKey = 'female_avatar';
  static const String _babyResultsKey = 'baby_results';

  /// Get male avatar
  static Future<AvatarData?> getMaleAvatar() async {
    try {
      final hiveService = HiveService();
      await hiveService.ensureBoxOpen('avatar_box');
      final data = hiveService.retrieve('avatar_box', _maleAvatarKey);
      if (data != null) {
        return AvatarData.fromMap(Map<String, dynamic>.from(data));
      }
      return null;
    } catch (e) {
      developer.log('Error getting male avatar: $e');
      return null;
    }
  }

  /// Get female avatar
  static Future<AvatarData?> getFemaleAvatar() async {
    try {
      final hiveService = HiveService();
      await hiveService.ensureBoxOpen('avatar_box');
      final data = hiveService.retrieve('avatar_box', _femaleAvatarKey);
      if (data != null) {
        return AvatarData.fromMap(Map<String, dynamic>.from(data));
      }
      return null;
    } catch (e) {
      developer.log('Error getting female avatar: $e');
      return null;
    }
  }

  /// Get baby results
  static Future<List<BabyResult>> getBabyResults() async {
    try {
      final hiveService = HiveService();
      await hiveService.ensureBoxOpen('baby_results_box');
      final data = hiveService.retrieve('baby_results_box', _babyResultsKey);
      if (data != null) {
        return (data as List)
            .map((item) => BabyResult.fromMap(Map<String, dynamic>.from(item)))
            .toList();
      }
      return [];
    } catch (e) {
      developer.log('Error getting baby results: $e');
      return [];
    }
  }

  /// Save male avatar
  static Future<void> saveMaleAvatar(AvatarData avatar) async {
    try {
      final hiveService = HiveService();
      await hiveService.ensureBoxOpen('avatar_box');
      await hiveService.store('avatar_box', _maleAvatarKey, avatar.toMap());
    } catch (e) {
      developer.log('Error saving male avatar: $e');
    }
  }

  /// Save female avatar
  static Future<void> saveFemaleAvatar(AvatarData avatar) async {
    try {
      final hiveService = HiveService();
      await hiveService.ensureBoxOpen('avatar_box');
      await hiveService.store('avatar_box', _femaleAvatarKey, avatar.toMap());
    } catch (e) {
      developer.log('Error saving female avatar: $e');
    }
  }

  /// Save baby result
  static Future<void> saveBabyResult(BabyResult result) async {
    try {
      final hiveService = HiveService();
      await hiveService.ensureBoxOpen('baby_results_box');
      final existingResults = await getBabyResults();
      existingResults.add(result);
      await hiveService.store('baby_results_box', _babyResultsKey,
          existingResults.map((r) => r.toMap()).toList());
    } catch (e) {
      developer.log('Error saving baby result: $e');
    }
  }

  /// Delete male avatar
  static Future<void> deleteMaleAvatar() async {
    try {
      final hiveService = HiveService();
      await hiveService.ensureBoxOpen('avatar_box');
      await hiveService.delete('avatar_box', _maleAvatarKey);
    } catch (e) {
      developer.log('Error deleting male avatar: $e');
    }
  }

  /// Delete female avatar
  static Future<void> deleteFemaleAvatar() async {
    try {
      final hiveService = HiveService();
      await hiveService.ensureBoxOpen('avatar_box');
      await hiveService.delete('avatar_box', _femaleAvatarKey);
    } catch (e) {
      developer.log('Error deleting female avatar: $e');
    }
  }

  /// Clear all data
  static Future<void> clearAllData() async {
    try {
      final hiveService = HiveService();
      await hiveService.ensureBoxOpen('avatar_box');
      await hiveService.ensureBoxOpen('baby_results_box');
      await hiveService.delete('avatar_box', _maleAvatarKey);
      await hiveService.delete('avatar_box', _femaleAvatarKey);
      await hiveService.delete('baby_results_box', _babyResultsKey);
    } catch (e) {
      developer.log('Error clearing all data: $e');
    }
  }
}
