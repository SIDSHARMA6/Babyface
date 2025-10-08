import 'dart:typed_data';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../firebase_options.dart';

/// Firebase service for cloud backend
/// Follows master plan cloud integration standards
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  bool _isInitialized = false;
  FirebaseAuth? _auth;
  FirebaseFirestore? _firestore;
  FirebaseStorage? _storage;
  FirebaseAnalytics? _analytics;
  FirebaseCrashlytics? _crashlytics;
  FirebaseMessaging? _messaging;

  /// Check if Firebase is initialized
  bool get isInitialized => _isInitialized;

  /// Initialize Firebase service
  Future<void> initialize() async {
    print('🔥 [FirebaseService] Starting Firebase initialization...');

    if (_isInitialized) {
      print('🔥 [FirebaseService] Firebase already initialized, skipping...');
      return;
    }

    try {
      // Check if Firebase is already initialized
      if (Firebase.apps.isNotEmpty) {
        print(
            '🔥 [FirebaseService] Firebase apps already exist, marking as initialized');
        _isInitialized = true;
        return;
      }

      print('🔥 [FirebaseService] Initializing Firebase with options...');
      // Initialize Firebase with options
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('🔥 [FirebaseService] Firebase.initializeApp completed');

      // Wait a bit for Firebase to fully initialize
      print('🔥 [FirebaseService] Waiting for Firebase to fully initialize...');
      await Future.delayed(const Duration(milliseconds: 500));

      print('🔥 [FirebaseService] Initializing Firebase services...');
      // Initialize Firebase services
      _auth = FirebaseAuth.instance;
      print('🔥 [FirebaseService] FirebaseAuth initialized');

      _firestore = FirebaseFirestore.instance;
      print('🔥 [FirebaseService] FirebaseFirestore initialized');

      _storage = FirebaseStorage.instance;
      print('🔥 [FirebaseService] FirebaseStorage initialized');

      _analytics = FirebaseAnalytics.instance;
      print('🔥 [FirebaseService] FirebaseAnalytics initialized');

      _crashlytics = FirebaseCrashlytics.instance;
      print('🔥 [FirebaseService] FirebaseCrashlytics initialized');

      _messaging = FirebaseMessaging.instance;
      print('🔥 [FirebaseService] FirebaseMessaging initialized');

      print('🔥 [FirebaseService] Configuring Firebase settings...');
      // Configure Firebase settings
      await _configureFirebase();
      print('🔥 [FirebaseService] Firebase configuration completed');

      _isInitialized = true;
      print('✅ [FirebaseService] Firebase initialized successfully');
    } catch (e) {
      // Log the error but don't throw - allow app to continue with limited functionality
      print('❌ [FirebaseService] Firebase initialization failed: $e');
      print('❌ [FirebaseService] Error type: ${e.runtimeType}');
      _isInitialized = false;
    }
  }

  /// Configure Firebase settings
  Future<void> _configureFirebase() async {
    try {
      // Enable crashlytics
      await _crashlytics?.setCrashlyticsCollectionEnabled(true);

      // Request notification permissions
      await _messaging?.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // Configure Firestore settings
      _firestore?.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
    } catch (e) {
      print('Firebase configuration failed: $e');
      // Continue without some Firebase features
    }
  }

  /// Get Firebase Auth instance
  FirebaseAuth? get auth => _auth;

  /// Get Firestore instance
  FirebaseFirestore? get firestore => _firestore;

  /// Get Storage instance
  FirebaseStorage? get storage => _storage;

  /// Get Analytics instance
  FirebaseAnalytics? get analytics => _analytics;

  /// Get Crashlytics instance
  FirebaseCrashlytics? get crashlytics => _crashlytics;

  /// Get Messaging instance
  FirebaseMessaging? get messaging => _messaging;

  /// Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (!_isInitialized || _auth == null) {
      throw Exception('Firebase not initialized. Call initialize() first.');
    }

    try {
      final credential = await _auth!.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Track sign in event
      if (_analytics != null) {
        await _analytics!.logLogin(loginMethod: 'email');
      }

      return credential;
    } catch (e) {
      if (_crashlytics != null) {
        await _crashlytics!.recordError(e, null);
      }
      rethrow;
    }
  }

  /// Create user with email and password
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (!_isInitialized || _auth == null) {
      throw Exception('Firebase not initialized. Call initialize() first.');
    }

    try {
      final credential = await _auth!.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Track sign up event
      if (_analytics != null) {
        await _analytics!.logSignUp(signUpMethod: 'email');
      }

      return credential;
    } catch (e) {
      if (_crashlytics != null) {
        await _crashlytics!.recordError(e, null);
      }
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    if (!_isInitialized || _auth == null) {
      throw Exception('Firebase not initialized. Call initialize() first.');
    }

    try {
      await _auth!.signOut();
      if (_analytics != null) {
        await _analytics!.logEvent(name: 'user_sign_out');
      }
    } catch (e) {
      if (_crashlytics != null) {
        await _crashlytics!.recordError(e, null);
      }
      rethrow;
    }
  }

  /// Get current user
  User? get currentUser => _auth?.currentUser;

  /// Check if user is signed in
  bool get isSignedIn => _auth?.currentUser != null;

  /// Upload file to Firebase Storage
  Future<String> uploadFile({
    required String path,
    required String fileName,
    required List<int> fileData,
  }) async {
    if (!_isInitialized || _storage == null) {
      throw Exception('Firebase not initialized. Call initialize() first.');
    }

    try {
      final ref = _storage!.ref().child(path).child(fileName);
      final uploadTask = ref.putData(Uint8List.fromList(fileData));
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      if (_analytics != null) {
        await _analytics!.logEvent(
          name: 'file_upload',
          parameters: {
            'file_name': fileName,
            'file_size': fileData.length,
          },
        );
      }

      return downloadUrl;
    } catch (e) {
      if (_crashlytics != null) {
        await _crashlytics!.recordError(e, null);
      }
      rethrow;
    }
  }

  /// Download file from Firebase Storage
  Future<List<int>> downloadFile(String downloadUrl) async {
    if (!_isInitialized || _storage == null) {
      throw Exception('Firebase not initialized. Call initialize() first.');
    }

    try {
      final ref = _storage!.refFromURL(downloadUrl);
      final data = await ref.getData();

      if (data == null) {
        throw Exception('File not found');
      }

      return data;
    } catch (e) {
      if (_crashlytics != null) {
        await _crashlytics!.recordError(e, null);
      }
      rethrow;
    }
  }

  /// Save data to Firestore
  Future<void> saveToFirestore({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    if (!_isInitialized || _firestore == null) {
      throw Exception('Firebase not initialized. Call initialize() first.');
    }

    try {
      await _firestore!
          .collection(collection)
          .doc(documentId)
          .set(data, SetOptions(merge: true));

      if (_analytics != null) {
        await _analytics!.logEvent(
          name: 'firestore_write',
          parameters: {
            'collection': collection,
            'document_id': documentId,
          },
        );
      }
    } catch (e) {
      if (_crashlytics != null) {
        await _crashlytics!.recordError(e, null);
      }
      rethrow;
    }
  }

  /// Get data from Firestore
  Future<DocumentSnapshot> getFromFirestore({
    required String collection,
    required String documentId,
  }) async {
    if (!_isInitialized || _firestore == null) {
      throw Exception('Firebase not initialized. Call initialize() first.');
    }

    try {
      final doc =
          await _firestore!.collection(collection).doc(documentId).get();

      if (_analytics != null) {
        await _analytics!.logEvent(
          name: 'firestore_read',
          parameters: {
            'collection': collection,
            'document_id': documentId,
          },
        );
      }

      return doc;
    } catch (e) {
      if (_crashlytics != null) {
        await _crashlytics!.recordError(e, null);
      }
      rethrow;
    }
  }

  /// Query data from Firestore
  Future<QuerySnapshot> queryFirestore({
    required String collection,
    Query? query,
  }) async {
    if (!_isInitialized || _firestore == null) {
      throw Exception('Firebase not initialized. Call initialize() first.');
    }

    try {
      final q = query ?? _firestore!.collection(collection);
      final snapshot = await q.get();

      if (_analytics != null) {
        await _analytics!.logEvent(
          name: 'firestore_query',
          parameters: {
            'collection': collection,
          },
        );
      }

      return snapshot;
    } catch (e) {
      if (_crashlytics != null) {
        await _crashlytics!.recordError(e, null);
      }
      rethrow;
    }
  }

  /// Delete data from Firestore
  Future<void> deleteFromFirestore({
    required String collection,
    required String documentId,
  }) async {
    if (!_isInitialized || _firestore == null) {
      throw Exception('Firebase not initialized. Call initialize() first.');
    }

    try {
      await _firestore!.collection(collection).doc(documentId).delete();

      if (_analytics != null) {
        await _analytics!.logEvent(
          name: 'firestore_delete',
          parameters: {
            'collection': collection,
            'document_id': documentId,
          },
        );
      }
    } catch (e) {
      if (_crashlytics != null) {
        await _crashlytics!.recordError(e, null);
      }
      rethrow;
    }
  }

  /// Track custom event
  Future<void> trackEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    if (!_isInitialized || _analytics == null) {
      return; // Silently fail if Firebase not initialized
    }

    try {
      await _analytics!.logEvent(
        name: name,
        parameters: parameters,
      );
    } catch (e) {
      if (_crashlytics != null) {
        await _crashlytics!.recordError(e, null);
      }
    }
  }

  /// Set user properties
  Future<void> setUserProperties({
    required String userId,
    Map<String, dynamic>? properties,
  }) async {
    if (!_isInitialized || _analytics == null) {
      return; // Silently fail if Firebase not initialized
    }

    try {
      await _analytics!.setUserId(id: userId);

      if (properties != null) {
        for (final entry in properties.entries) {
          await _analytics!.setUserProperty(
            name: entry.key,
            value: entry.value.toString(),
          );
        }
      }
    } catch (e) {
      if (_crashlytics != null) {
        await _crashlytics!.recordError(e, null);
      }
    }
  }

  /// Record error
  Future<void> recordError(
    dynamic error,
    StackTrace? stackTrace, {
    String? reason,
  }) async {
    if (!_isInitialized || _crashlytics == null) {
      return; // Silently fail if Firebase not initialized
    }

    try {
      await _crashlytics!.recordError(
        error,
        stackTrace,
        reason: reason,
      );
    } catch (e) {
      // Ignore crashlytics errors
    }
  }

  /// Get FCM token
  Future<String?> getFCMToken() async {
    if (!_isInitialized || _messaging == null) {
      return null;
    }

    try {
      return await _messaging!.getToken();
    } catch (e) {
      if (_crashlytics != null) {
        await _crashlytics!.recordError(e, null);
      }
      return null;
    }
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    if (!_isInitialized || _messaging == null) {
      return; // Silently fail if Firebase not initialized
    }

    try {
      await _messaging!.subscribeToTopic(topic);
      if (_analytics != null) {
        await _analytics!.logEvent(
          name: 'topic_subscribe',
          parameters: {'topic': topic},
        );
      }
    } catch (e) {
      if (_crashlytics != null) {
        await _crashlytics!.recordError(e, null);
      }
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    if (!_isInitialized || _messaging == null) {
      return; // Silently fail if Firebase not initialized
    }

    try {
      await _messaging!.unsubscribeFromTopic(topic);
      if (_analytics != null) {
        await _analytics!.logEvent(
          name: 'topic_unsubscribe',
          parameters: {'topic': topic},
        );
      }
    } catch (e) {
      if (_crashlytics != null) {
        await _crashlytics!.recordError(e, null);
      }
    }
  }
}

/// Firebase service provider for Riverpod
final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});
