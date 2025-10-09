import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;
import '../models/period_cycle.dart';
import 'hive_service.dart';
import 'firebase_service.dart';

/// Service to manage period tracking with SharedPreferences and Firebase
class PeriodTrackerService {
  static const String _cycleKey = 'period_cycle';
  static const String _notificationsEnabledKey = 'period_notifications_enabled';

  static PeriodTrackerService? _instance;
  static PeriodTrackerService get instance =>
      _instance ??= PeriodTrackerService._();

  PeriodTrackerService._();

  final HiveService _hiveService = HiveService();
  final FirebaseService _firebaseService = FirebaseService();

  /// Get current period cycle (optimized with caching)
  Future<PeriodCycle?> getCurrentCycle() async {
    try {
      // Ensure box is open before accessing
      await _hiveService.ensureBoxOpen('period_box');

      if (!_hiveService.isBoxOpen('period_box')) {
        return null;
      }

      final cycleJson = _hiveService.retrieve('period_box', _cycleKey)
          as Map<String, dynamic>?;
      if (cycleJson == null) return null;

      return PeriodCycle.fromJson(cycleJson);
    } catch (e) {
      developer.log('Error getting current cycle: $e');
      return null;
    }
  }

  /// Set period cycle
  Future<bool> setCycle(PeriodCycle cycle) async {
    try {
      // Ensure box is open before accessing
      await _hiveService.ensureBoxOpen('period_box');

      if (!_hiveService.isBoxOpen('period_box')) {
        developer
            .log('🔐 [PeriodTrackerService] Box not open, cannot save cycle');
        return false;
      }

      await _hiveService.store('period_box', _cycleKey, cycle.toJson());

      // Also save to Firebase
      await _saveToFirebase(cycle);

      return true;
    } catch (e) {
      developer.log('Error setting cycle: $e');
      return false;
    }
  }

  /// Update last period start date
  Future<bool> updateLastPeriodStart(DateTime date) async {
    try {
      final currentCycle = await getCurrentCycle();
      if (currentCycle == null) {
        // Create new cycle
        final newCycle = PeriodCycle(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          lastPeriodStart: date,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        return await setCycle(newCycle);
      } else {
        // Update existing cycle
        final updatedCycle = currentCycle.copyWith(
          lastPeriodStart: date,
          updatedAt: DateTime.now(),
        );
        return await setCycle(updatedCycle);
      }
    } catch (e) {
      developer.log('Error updating last period start: $e');
      return false;
    }
  }

  /// Update cycle length
  Future<bool> updateCycleLength(int length) async {
    try {
      final currentCycle = await getCurrentCycle();
      if (currentCycle == null) return false;

      final updatedCycle = currentCycle.copyWith(
        cycleLength: length,
        updatedAt: DateTime.now(),
      );

      return await setCycle(updatedCycle);
    } catch (e) {
      developer.log('Error updating cycle length: $e');
      return false;
    }
  }

  /// Update period length
  Future<bool> updatePeriodLength(int length) async {
    try {
      final currentCycle = await getCurrentCycle();
      if (currentCycle == null) return false;

      final updatedCycle = currentCycle.copyWith(
        periodLength: length,
        updatedAt: DateTime.now(),
      );

      return await setCycle(updatedCycle);
    } catch (e) {
      developer.log('Error updating period length: $e');
      return false;
    }
  }

  /// Get current day in cycle
  Future<int> getCurrentDayInCycle() async {
    try {
      final cycle = await getCurrentCycle();
      if (cycle == null) return 0;

      return cycle.currentDayInCycle;
    } catch (e) {
      developer.log('Error getting current day in cycle: $e');
      return 0;
    }
  }

  /// Get current cycle phase
  Future<CyclePhase?> getCurrentPhase() async {
    try {
      final cycle = await getCurrentCycle();
      if (cycle == null) return null;

      return cycle.currentPhase;
    } catch (e) {
      developer.log('Error getting current phase: $e');
      return null;
    }
  }

  /// Get daily dialogue
  Future<String> getDailyDialogue() async {
    try {
      final cycle = await getCurrentCycle();
      if (cycle == null) {
        return "Start tracking your cycle to get daily insights 💖";
      }

      return cycle.dailyDialogue;
    } catch (e) {
      developer.log('Error getting daily dialogue: $e');
      return "Your body is amazing every day 💖";
    }
  }

  /// Get pregnancy probability
  Future<PregnancyProbability?> getPregnancyProbability() async {
    try {
      final cycle = await getCurrentCycle();
      if (cycle == null) return null;

      return cycle.pregnancyProbability;
    } catch (e) {
      developer.log('Error getting pregnancy probability: $e');
      return null;
    }
  }

  /// Get days until next period
  Future<int> getDaysUntilNextPeriod() async {
    try {
      final cycle = await getCurrentCycle();
      if (cycle == null) return 0;

      return cycle.daysUntilNextPeriod;
    } catch (e) {
      developer.log('Error getting days until next period: $e');
      return 0;
    }
  }

  /// Check if cycle is set up
  Future<bool> isCycleSetUp() async {
    try {
      final cycle = await getCurrentCycle();
      return cycle != null;
    } catch (e) {
      developer.log('Error checking if cycle is set up: $e');
      return false;
    }
  }

  /// Set notification preferences
  Future<bool> setNotificationsEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setBool(_notificationsEnabledKey, enabled);
    } catch (e) {
      developer.log('Error setting notification preferences: $e');
      return false;
    }
  }

  /// Get notification preferences
  Future<bool> getNotificationsEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_notificationsEnabledKey) ?? true;
    } catch (e) {
      developer.log('Error getting notification preferences: $e');
      return true;
    }
  }

  /// Sync cycle data from Firebase to local storage
  Future<void> syncCycleFromFirebase() async {
    try {
      if (!_firebaseService.isInitialized) {
        developer.log('Firebase not initialized, skipping sync');
        return;
      }

      // Ensure box is open
      await _hiveService.ensureBoxOpen('period_box');
      if (!_hiveService.isBoxOpen('period_box')) {
        developer.log('Box not open, cannot sync');
        return;
      }

      // Get data from Firebase
      final firebaseCycle = await _firebaseService.getAllFromFirestore(
        collection: 'period_cycles',
      );

      if (firebaseCycle.isNotEmpty) {
        final cycleData =
            firebaseCycle.first; // Should only be one cycle per user
        final cycle = PeriodCycle.fromJson(cycleData);

        // Save to local storage
        await _hiveService.store('period_box', _cycleKey, cycle.toJson());

        developer.log('✅ Synced period cycle from Firebase');
      }
    } catch (e) {
      developer.log('❌ Error syncing period cycle from Firebase: $e');
    }
  }

  /// Save to Firebase (real implementation)
  Future<void> _saveToFirebase(PeriodCycle cycle) async {
    try {
      if (!_firebaseService.isInitialized) {
        developer.log('Firebase not initialized, skipping cycle save');
        return;
      }

      await _firebaseService.saveToFirestore(
        collection: 'period_cycles',
        documentId: cycle.id,
        data: cycle.toJson(),
      );

      developer.log('✅ Period cycle saved to Firebase');
    } catch (e) {
      developer.log('❌ Error saving period cycle to Firebase: $e');
    }
  }

  /// Get cycle statistics
  Future<Map<String, dynamic>> getCycleStats() async {
    try {
      final cycle = await getCurrentCycle();

      if (cycle == null) {
        return {
          'isSetUp': false,
          'currentDay': 0,
          'phase': 'Not Set',
          'daysUntilNext': 0,
          'pregnancyProbability': 'Unknown',
          'nextPeriod': null,
        };
      }

      return {
        'isSetUp': true,
        'currentDay': cycle.currentDayInCycle,
        'phase': cycle.currentPhase.displayName,
        'daysUntilNext': cycle.daysUntilNextPeriod,
        'pregnancyProbability': cycle.pregnancyProbability.displayName,
        'dailyDialogue': cycle.dailyDialogue,
        'nextPeriod': cycle.nextPeriodStart.toIso8601String(),
      };
    } catch (e) {
      developer.log('❌ [PeriodTrackerService] Error getting cycle stats: $e');
      return {
        'isSetUp': false,
        'currentDay': 0,
        'phase': 'Error',
        'daysUntilNext': 0,
        'pregnancyProbability': 'Error',
        'nextPeriod': null,
      };
    }
  }
}
