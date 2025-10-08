import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:typed_data';
import 'firebase_service.dart';

/// Firebase User Service for comprehensive user data management
class FirebaseUserService {
  static final FirebaseUserService _instance = FirebaseUserService._internal();
  factory FirebaseUserService() => _instance;
  FirebaseUserService._internal();

  final FirebaseService _firebaseService = FirebaseService();

  /// Create user profile in Firestore
  Future<void> createUserProfile({
    required String userId,
    required String email,
    String? displayName,
    String? photoURL,
    String? firstName,
    String? lastName,
    String? partnerName,
    String? bondName,
    String? gender,
    String? partnerGender,
    DateTime? dateOfBirth,
    DateTime? relationshipStartDate,
  }) async {
    if (!_firebaseService.isInitialized || _firebaseService.firestore == null) {
      print('Firebase not initialized, skipping user profile creation');
      return;
    }

    try {
      final userData = {
        'uid': userId,
        'email': email,
        'displayName': displayName ?? '',
        'photoURL': photoURL ?? '',
        'firstName': firstName ?? '',
        'lastName': lastName ?? '',
        'partnerName': partnerName ?? '',
        'bondName': bondName ?? '',
        'gender': gender ?? '',
        'partnerGender': partnerGender ?? '',
        'dateOfBirth': dateOfBirth?.toIso8601String(),
        'relationshipStartDate': relationshipStartDate?.toIso8601String(),
        'isPremium': false,
        'premiumExpiryDate': null,
        'totalGenerations': 0,
        'totalMemories': 0,
        'totalQuizzes': 0,
        'referralCode': _generateReferralCode(),
        'referralRewards': 0,
        'totalReferrals': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
        'preferences': {
          'notifications': true,
          'emailUpdates': true,
          'dataSharing': false,
          'theme': 'light',
          'language': 'en',
        },
        'stats': {
          'appOpens': 0,
          'timeSpent': 0,
          'favoriteFeature': '',
          'lastActiveFeature': '',
        },
      };

      // Save user profile
      await _firebaseService.firestore!
          .collection('users')
          .doc(userId)
          .set(userData);

      // Create user's memory journal
      await _firebaseService.firestore!
          .collection('memory_journals')
          .doc(userId)
          .set({
        'userId': userId,
        'memories': [],
        'totalMemories': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Create user's baby generation history
      await _firebaseService.firestore!
          .collection('baby_generations')
          .doc(userId)
          .set({
        'userId': userId,
        'generations': [],
        'totalGenerations': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('User profile created successfully for $userId');
    } catch (e) {
      print('Error creating user profile: $e');
      // Don't rethrow - allow app to continue
    }
  }

  /// Update user profile
  Future<void> updateUserProfile({
    required String userId,
    Map<String, dynamic>? profileData,
  }) async {
    if (!_firebaseService.isInitialized || _firebaseService.firestore == null) {
      print('Firebase not initialized, skipping user profile update');
      return;
    }

    try {
      final updateData = {
        ...?profileData,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firebaseService.firestore!
          .collection('users')
          .doc(userId)
          .update(updateData);
      print('User profile updated successfully for $userId');
    } catch (e) {
      print('Error updating user profile: $e');
      // Don't rethrow - allow app to continue
    }
  }

  /// Get user profile
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    if (!_firebaseService.isInitialized || _firebaseService.firestore == null) {
      print('Firebase not initialized, returning null for user profile');
      return null;
    }

    try {
      final doc = await _firebaseService.firestore!
          .collection('users')
          .doc(userId)
          .get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  /// Save user login details
  Future<void> saveUserLogin({
    required String userId,
    String? loginMethod,
    Map<String, dynamic>? deviceInfo,
    Map<String, dynamic>? location,
    String? ipAddress,
    String? userAgent,
  }) async {
    try {
      final loginRecord = {
        'userId': userId,
        'loginMethod': loginMethod ?? 'email',
        'deviceInfo': deviceInfo ?? {},
        'location': location,
        'ipAddress': ipAddress,
        'userAgent': userAgent,
        'timestamp': FieldValue.serverTimestamp(),
      };

      // Save login record
      await _firebaseService.firestore!
          .collection('user_logins')
          .add(loginRecord);

      // Update user's last login and app opens
      await _firebaseService.firestore!.collection('users').doc(userId).update({
        'lastLoginAt': FieldValue.serverTimestamp(),
        'stats.appOpens': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('User login saved successfully for $userId');
    } catch (e) {
      print('Error saving user login: $e');
      // Don't rethrow as this is not critical
    }
  }

  /// Save user activity
  Future<void> saveUserActivity({
    required String userId,
    required String activityType,
    Map<String, dynamic>? activityData,
  }) async {
    if (!_firebaseService.isInitialized || _firebaseService.firestore == null) {
      print('Firebase not initialized, skipping user activity save');
      return;
    }

    try {
      final activityRecord = {
        'userId': userId,
        'activityType': activityType,
        'activityData': activityData ?? {},
        'timestamp': FieldValue.serverTimestamp(),
      };

      await _firebaseService.firestore!
          .collection('user_activities')
          .add(activityRecord);

      // Update user stats based on activity
      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      switch (activityType) {
        case 'baby_generation':
          updateData['totalGenerations'] = FieldValue.increment(1);
          updateData['stats.lastActiveFeature'] = 'baby_generation';
          break;
        case 'memory_created':
          updateData['totalMemories'] = FieldValue.increment(1);
          updateData['stats.lastActiveFeature'] = 'memory_journal';
          break;
        case 'quiz_completed':
          updateData['totalQuizzes'] = FieldValue.increment(1);
          updateData['stats.lastActiveFeature'] = 'quiz';
          break;
      }

      await _firebaseService.firestore!
          .collection('users')
          .doc(userId)
          .update(updateData);
      print('User activity saved successfully for $userId');
    } catch (e) {
      print('Error saving user activity: $e');
      // Don't rethrow as this is not critical
    }
  }

  /// Save memory to user's memory journal
  Future<void> saveMemory({
    required String userId,
    required String memoryId,
    required String title,
    required String description,
    required String emoji,
    String? photoPath,
    String? voicePath,
    required String mood,
    required DateTime date,
    List<String>? tags,
    String? location,
  }) async {
    try {
      final now = DateTime.now();
      final memoryData = {
        'id': memoryId,
        'title': title,
        'description': description,
        'emoji': emoji,
        'photoPath': photoPath,
        'voicePath': voicePath,
        'mood': mood,
        'date': date.toIso8601String(),
        'tags': tags ?? [],
        'location': location,
        'isFavorite': false,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
        'timestamp': now.millisecondsSinceEpoch,
      };

      // Create memory document in user's memory journal subcollection
      await _firebaseService.firestore!
          .collection('users')
          .doc(userId)
          .collection('memories')
          .doc(memoryId)
          .set(memoryData);

      // Update user's total memories count
      await _firebaseService.firestore!.collection('users').doc(userId).update({
        'totalMemories': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Save user activity
      await saveUserActivity(
        userId: userId,
        activityType: 'memory_created',
        activityData: {
          'memoryId': memoryId,
          'title': title,
          'mood': mood,
        },
      );

      print('Memory saved successfully for user $userId');
    } catch (e) {
      print('Error saving memory: $e');
      rethrow;
    }
  }

  /// Get user's memories
  Future<List<Map<String, dynamic>>> getUserMemories(String userId) async {
    if (!_firebaseService.isInitialized || _firebaseService.firestore == null) {
      print('Firebase not initialized, returning empty memories list');
      return [];
    }

    try {
      final doc = await _firebaseService.firestore!
          .collection('memory_journals')
          .doc(userId)
          .get();
      if (doc.exists) {
        final data = doc.data();
        return List<Map<String, dynamic>>.from(data?['memories'] ?? []);
      }
      return [];
    } catch (e) {
      print('Error getting user memories: $e');
      return [];
    }
  }

  /// Save baby generation result
  Future<void> saveBabyGeneration({
    required String userId,
    required String generationId,
    required Map<String, dynamic> generationData,
  }) async {
    try {
      final babyGenerationData = {
        'id': generationId,
        'userId': userId,
        'generationData': generationData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Add generation to user's baby generation history
      await _firebaseService.firestore!
          .collection('baby_generations')
          .doc(userId)
          .update({
        'generations': FieldValue.arrayUnion([babyGenerationData]),
        'totalGenerations': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update user's total generations count
      await _firebaseService.firestore!.collection('users').doc(userId).update({
        'totalGenerations': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Save user activity
      await saveUserActivity(
        userId: userId,
        activityType: 'baby_generation',
        activityData: {
          'generationId': generationId,
          'resultType': generationData['type'] ?? 'standard',
        },
      );

      print('Baby generation saved successfully for user $userId');
    } catch (e) {
      print('Error saving baby generation: $e');
      rethrow;
    }
  }

  /// Get user's baby generations
  Future<List<Map<String, dynamic>>> getUserBabyGenerations(
      String userId) async {
    if (!_firebaseService.isInitialized || _firebaseService.firestore == null) {
      print('Firebase not initialized, returning empty generations list');
      return [];
    }

    try {
      final doc = await _firebaseService.firestore!
          .collection('baby_generations')
          .doc(userId)
          .get();
      if (doc.exists) {
        final data = doc.data();
        return List<Map<String, dynamic>>.from(data?['generations'] ?? []);
      }
      return [];
    } catch (e) {
      print('Error getting user baby generations: $e');
      return [];
    }
  }

  /// Upload file to Firebase Storage
  Future<String> uploadFile({
    required String userId,
    required String filePath,
    required String fileName,
    required List<int> fileData,
  }) async {
    if (!_firebaseService.isInitialized || _firebaseService.storage == null) {
      throw Exception('Firebase not initialized. Call initialize() first.');
    }

    try {
      final ref = _firebaseService.storage!
          .ref()
          .child('users/$userId/$filePath/$fileName');
      final uploadTask = ref.putData(Uint8List.fromList(fileData));
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      print('File uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Error uploading file: $e');
      rethrow;
    }
  }

  /// Delete user account and all associated data
  Future<void> deleteUserAccount(String userId) async {
    if (!_firebaseService.isInitialized || _firebaseService.firestore == null) {
      print('Firebase not initialized, cannot delete user account');
      return;
    }

    try {
      // Delete user's data from all collections
      final collections = [
        'users',
        'memory_journals',
        'baby_generations',
        'user_logins',
        'user_activities'
      ];

      for (final collection in collections) {
        if (collection == 'users' ||
            collection == 'memory_journals' ||
            collection == 'baby_generations') {
          // Delete user document
          await _firebaseService.firestore!
              .collection(collection)
              .doc(userId)
              .delete();
        } else {
          // Delete subcollections or documents
          final snapshot = await _firebaseService.firestore!
              .collection(collection)
              .where('userId', isEqualTo: userId)
              .get();
          final batch = _firebaseService.firestore!.batch();
          for (final doc in snapshot.docs) {
            batch.delete(doc.reference);
          }
          await batch.commit();
        }
      }

      // Delete user's storage files
      if (_firebaseService.storage != null) {
        try {
          final listResult = await _firebaseService.storage!
              .ref()
              .child('users/$userId')
              .listAll();
          for (final item in listResult.items) {
            await item.delete();
          }
        } catch (e) {
          print('Error deleting storage files: $e');
        }
      }

      print('User account deleted successfully for $userId');
    } catch (e) {
      print('Error deleting user account: $e');
      // Don't rethrow - allow app to continue
    }
  }

  /// Generate referral code
  String _generateReferralCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    String result = '';
    for (int i = 0; i < 8; i++) {
      result += chars[(random + i) % chars.length];
    }
    return result;
  }

  /// Get all memories for a user (new structure)
  Future<List<Map<String, dynamic>>> getMemories(String userId) async {
    try {
      final snapshot = await _firebaseService.firestore!
          .collection('users')
          .doc(userId)
          .collection('memories')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => {
                ...doc.data(),
                'id': doc.id,
              })
          .toList();
    } catch (e) {
      print('Error getting memories: $e');
      return [];
    }
  }

  /// Update memory
  Future<void> updateMemory({
    required String userId,
    required String memoryId,
    required String title,
    required String description,
    required String emoji,
    String? photoPath,
    String? voicePath,
    required String mood,
    required DateTime date,
    List<String>? tags,
    String? location,
    bool? isFavorite,
  }) async {
    try {
      final now = DateTime.now();
      final memoryData = {
        'title': title,
        'description': description,
        'emoji': emoji,
        'photoPath': photoPath,
        'voicePath': voicePath,
        'mood': mood,
        'date': date.toIso8601String(),
        'tags': tags ?? [],
        'location': location,
        'updatedAt': now.toIso8601String(),
        'timestamp': now.millisecondsSinceEpoch,
      };

      // Add isFavorite if provided
      if (isFavorite != null) {
        memoryData['isFavorite'] = isFavorite;
      }

      await _firebaseService.firestore!
          .collection('users')
          .doc(userId)
          .collection('memories')
          .doc(memoryId)
          .update(memoryData);

      // Save user activity
      await saveUserActivity(
        userId: userId,
        activityType: 'memory_updated',
        activityData: {
          'memoryId': memoryId,
          'timestamp': now.toIso8601String(),
        },
      );
    } catch (e) {
      print('Error updating memory: $e');
      // Don't rethrow as this is not critical
    }
  }

  /// Delete memory
  Future<void> deleteMemory({
    required String userId,
    required String memoryId,
  }) async {
    try {
      await _firebaseService.firestore!
          .collection('users')
          .doc(userId)
          .collection('memories')
          .doc(memoryId)
          .delete();

      // Update user's total memories count
      await _firebaseService.firestore!.collection('users').doc(userId).update({
        'totalMemories': FieldValue.increment(-1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Save user activity
      await saveUserActivity(
        userId: userId,
        activityType: 'memory_deleted',
        activityData: {
          'memoryId': memoryId,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      print('Error deleting memory: $e');
      // Don't rethrow as this is not critical
    }
  }

  /// Toggle memory favorite status
  Future<void> toggleMemoryFavorite({
    required String userId,
    required String memoryId,
    required bool isFavorite,
  }) async {
    try {
      await _firebaseService.firestore!
          .collection('users')
          .doc(userId)
          .collection('memories')
          .doc(memoryId)
          .update({
        'isFavorite': isFavorite,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      // Save user activity
      await saveUserActivity(
        userId: userId,
        activityType: 'memory_favorite_toggled',
        activityData: {
          'memoryId': memoryId,
          'isFavorite': isFavorite,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      print('Error toggling memory favorite: $e');
      // Don't rethrow as this is not critical
    }
  }

  /// Get current user
  User? get currentUser => _firebaseService.auth?.currentUser;

  /// Check if user is signed in
  bool get isSignedIn => _firebaseService.auth?.currentUser != null;
}

/// Firebase User Service provider
final firebaseUserServiceProvider = Provider<FirebaseUserService>((ref) {
  return FirebaseUserService();
});
