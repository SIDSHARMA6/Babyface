import 'dart:developer' as developer;
import 'firebase_service.dart';
import 'baby_name_service.dart';
import 'simple_memory_service.dart';
import 'anniversary_tracker_service.dart';
import 'period_tracker_service.dart';

/// Service to sync all data from Firebase on app startup
class DataSyncService {
  static DataSyncService? _instance;
  static DataSyncService get instance => _instance ??= DataSyncService._();

  DataSyncService._();

  final FirebaseService _firebaseService = FirebaseService();

  /// Sync all data from Firebase to local storage
  Future<void> syncAllDataFromFirebase() async {
    try {
      developer.log('🔄 [DataSyncService] Starting data sync from Firebase...');

      // Check if Firebase is initialized and user is logged in
      if (!_firebaseService.isInitialized) {
        developer
            .log('❌ [DataSyncService] Firebase not initialized, skipping sync');
        return;
      }

      if (_firebaseService.currentUser == null) {
        developer.log('❌ [DataSyncService] No user logged in, skipping sync');
        return;
      }

      developer.log('✅ [DataSyncService] User logged in, starting sync...');

      // Sync all services in parallel for better performance
      await Future.wait([
        _syncBabyNames(),
        _syncMemories(),
        _syncAnniversaryEvents(),
        _syncPeriodCycle(),
      ]);

      developer.log('✅ [DataSyncService] All data synced successfully');
    } catch (e) {
      developer.log('❌ [DataSyncService] Error during data sync: $e');
    }
  }

  /// Sync baby names from Firebase
  Future<void> _syncBabyNames() async {
    try {
      developer.log('🔄 [DataSyncService] Syncing baby names...');
      await BabyNameService.instance.syncAllDataFromFirebase();
      developer.log('✅ [DataSyncService] Baby names synced');
    } catch (e) {
      developer.log('❌ [DataSyncService] Error syncing baby names: $e');
    }
  }

  /// Sync memories from Firebase
  Future<void> _syncMemories() async {
    try {
      developer.log('🔄 [DataSyncService] Syncing memories...');
      // SimpleMemoryService already has sync functionality in getAllMemoriesWithSync
      // We just need to trigger it
      await SimpleMemoryService.getAllMemoriesWithSync();
      developer.log('✅ [DataSyncService] Memories synced');
    } catch (e) {
      developer.log('❌ [DataSyncService] Error syncing memories: $e');
    }
  }

  /// Sync anniversary events from Firebase
  Future<void> _syncAnniversaryEvents() async {
    try {
      developer.log('🔄 [DataSyncService] Syncing anniversary events...');
      await AnniversaryTrackerService.instance.syncAllEventsFromFirebase();
      developer.log('✅ [DataSyncService] Anniversary events synced');
    } catch (e) {
      developer.log('❌ [DataSyncService] Error syncing anniversary events: $e');
    }
  }

  /// Sync period cycle from Firebase
  Future<void> _syncPeriodCycle() async {
    try {
      developer.log('🔄 [DataSyncService] Syncing period cycle...');
      await PeriodTrackerService.instance.syncCycleFromFirebase();
      developer.log('✅ [DataSyncService] Period cycle synced');
    } catch (e) {
      developer.log('❌ [DataSyncService] Error syncing period cycle: $e');
    }
  }

  /// Check if sync is needed (e.g., first time user or after long offline period)
  Future<bool> isSyncNeeded() async {
    try {
      // For now, always sync on app startup
      // In the future, we could check last sync timestamp
      return true;
    } catch (e) {
      developer.log('❌ [DataSyncService] Error checking sync status: $e');
      return false;
    }
  }
}
