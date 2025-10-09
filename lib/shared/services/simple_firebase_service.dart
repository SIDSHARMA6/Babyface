import 'dart:convert';
import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'simple_memory_service.dart';

/// Simple Firebase Service for Memory Sync
/// Handles Firebase operations for memory synchronization
class SimpleFirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user ID
  static String? get currentUserId => _auth.currentUser?.uid;

  /// Save memory to Firebase
  static Future<void> saveMemoryToFirebase(SimpleMemory memory) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        developer.log('❌ No user logged in, skipping Firebase save');
        return;
      }

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('memories')
          .doc(memory.id)
          .set(memory.toJson());

      developer.log('✅ Memory saved to Firebase: ${memory.title}');
    } catch (e) {
      developer.log('❌ Error saving memory to Firebase: $e');
    }
  }

  /// Get memories from Firebase
  static Future<List<SimpleMemory>> getMemoriesFromFirebase() async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        developer.log('❌ No user logged in, returning empty list');
        return [];
      }

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('memories')
          .orderBy('timestamp', descending: true)
          .get();

      final memories = snapshot.docs.map((doc) {
        final data = doc.data();
        return SimpleMemory.fromJson(data);
      }).toList();

      developer.log('✅ Retrieved ${memories.length} memories from Firebase');
      return memories;
    } catch (e) {
      developer.log('❌ Error getting memories from Firebase: $e');
      return [];
    }
  }

  /// Delete memory from Firebase
  static Future<void> deleteMemoryFromFirebase(String id) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        developer.log('❌ No user logged in, skipping Firebase delete');
        return;
      }

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('memories')
          .doc(id)
          .delete();

      developer.log('✅ Memory deleted from Firebase: $id');
    } catch (e) {
      developer.log('❌ Error deleting memory from Firebase: $e');
    }
  }

  /// Sync all memories to Firebase
  static Future<void> syncAllMemoriesToFirebase() async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        developer.log('❌ No user logged in, skipping Firebase sync');
        return;
      }

      // Get all memories from SharedPreferences
      final memories = await SimpleMemoryService.getAllMemoriesAsync();

      if (memories.isEmpty) {
        developer.log('📱 No memories to sync to Firebase');
        return;
      }

      // Batch write to Firebase
      final batch = _firestore.batch();

      for (final memory in memories) {
        final docRef = _firestore
            .collection('users')
            .doc(userId)
            .collection('memories')
            .doc(memory.id);

        batch.set(docRef, memory.toJson());
      }

      await batch.commit();
      developer.log('✅ Synced ${memories.length} memories to Firebase');
    } catch (e) {
      developer.log('❌ Error syncing memories to Firebase: $e');
    }
  }

  /// Sync Firebase memories to SharedPreferences
  static Future<void> syncFirebaseToSharedPreferences() async {
    try {
      final firebaseMemories = await getMemoriesFromFirebase();

      if (firebaseMemories.isEmpty) {
        developer.log('📱 No Firebase memories to sync');
        return;
      }

      // Save Firebase memories to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final memoriesJson = firebaseMemories
          .map((memory) => jsonEncode(memory.toJson()))
          .toList();
      await prefs.setStringList('memories', memoriesJson);

      developer.log(
          '✅ Synced ${firebaseMemories.length} Firebase memories to SharedPreferences');
    } catch (e) {
      developer.log('❌ Error syncing Firebase to SharedPreferences: $e');
    }
  }
}
