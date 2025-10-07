import 'dart:typed_data';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Firebase service for cloud backend
/// Follows master plan cloud integration standards
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  bool _isInitialized = false;
  late FirebaseAuth _auth;
  late FirebaseFirestore _firestore;
  late FirebaseStorage _storage;
  late FirebaseAnalytics _analytics;
  late FirebaseCrashlytics _crashlytics;
  late FirebaseMessaging _messaging;

  /// Initialize Firebase service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize Firebase
      await Firebase.initializeApp();

      // Initialize Firebase services
      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
      _storage = FirebaseStorage.instance;
      _analytics = FirebaseAnalytics.instance;
      _crashlytics = FirebaseCrashlytics.instance;
      _messaging = FirebaseMessaging.instance;

      // Configure Firebase settings
      await _configureFirebase();

      _isInitialized = true;
    } catch (e) {
      throw Exception('Failed to initialize Firebase: $e');
    }
  }

  /// Configure Firebase settings
  Future<void> _configureFirebase() async {
    // Enable crashlytics
    await _crashlytics.setCrashlyticsCollectionEnabled(true);

    // Request notification permissions
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Configure Firestore settings
    _firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  /// Get Firebase Auth instance
  FirebaseAuth get auth => _auth;

  /// Get Firestore instance
  FirebaseFirestore get firestore => _firestore;

  /// Get Storage instance
  FirebaseStorage get storage => _storage;

  /// Get Analytics instance
  FirebaseAnalytics get analytics => _analytics;

  /// Get Crashlytics instance
  FirebaseCrashlytics get crashlytics => _crashlytics;

  /// Get Messaging instance
  FirebaseMessaging get messaging => _messaging;

  /// Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Track sign in event
      await _analytics.logLogin(loginMethod: 'email');

      return credential;
    } catch (e) {
      await _crashlytics.recordError(e, null);
      rethrow;
    }
  }

  /// Create user with email and password
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Track sign up event
      await _analytics.logSignUp(signUpMethod: 'email');

      return credential;
    } catch (e) {
      await _crashlytics.recordError(e, null);
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _analytics.logEvent(name: 'user_sign_out');
    } catch (e) {
      await _crashlytics.recordError(e, null);
      rethrow;
    }
  }

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Check if user is signed in
  bool get isSignedIn => _auth.currentUser != null;

  /// Upload file to Firebase Storage
  Future<String> uploadFile({
    required String path,
    required String fileName,
    required List<int> fileData,
  }) async {
    try {
      final ref = _storage.ref().child(path).child(fileName);
      final uploadTask = ref.putData(Uint8List.fromList(fileData));
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      await _analytics.logEvent(
        name: 'file_upload',
        parameters: {
          'file_name': fileName,
          'file_size': fileData.length,
        },
      );

      return downloadUrl;
    } catch (e) {
      await _crashlytics.recordError(e, null);
      rethrow;
    }
  }

  /// Download file from Firebase Storage
  Future<List<int>> downloadFile(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      final data = await ref.getData();

      if (data == null) {
        throw Exception('File not found');
      }

      return data;
    } catch (e) {
      await _crashlytics.recordError(e, null);
      rethrow;
    }
  }

  /// Save data to Firestore
  Future<void> saveToFirestore({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore
          .collection(collection)
          .doc(documentId)
          .set(data, SetOptions(merge: true));

      await _analytics.logEvent(
        name: 'firestore_write',
        parameters: {
          'collection': collection,
          'document_id': documentId,
        },
      );
    } catch (e) {
      await _crashlytics.recordError(e, null);
      rethrow;
    }
  }

  /// Get data from Firestore
  Future<DocumentSnapshot> getFromFirestore({
    required String collection,
    required String documentId,
  }) async {
    try {
      final doc = await _firestore.collection(collection).doc(documentId).get();

      await _analytics.logEvent(
        name: 'firestore_read',
        parameters: {
          'collection': collection,
          'document_id': documentId,
        },
      );

      return doc;
    } catch (e) {
      await _crashlytics.recordError(e, null);
      rethrow;
    }
  }

  /// Query data from Firestore
  Future<QuerySnapshot> queryFirestore({
    required String collection,
    Query? query,
  }) async {
    try {
      final q = query ?? _firestore.collection(collection);
      final snapshot = await q.get();

      await _analytics.logEvent(
        name: 'firestore_query',
        parameters: {
          'collection': collection,
        },
      );

      return snapshot;
    } catch (e) {
      await _crashlytics.recordError(e, null);
      rethrow;
    }
  }

  /// Delete data from Firestore
  Future<void> deleteFromFirestore({
    required String collection,
    required String documentId,
  }) async {
    try {
      await _firestore.collection(collection).doc(documentId).delete();

      await _analytics.logEvent(
        name: 'firestore_delete',
        parameters: {
          'collection': collection,
          'document_id': documentId,
        },
      );
    } catch (e) {
      await _crashlytics.recordError(e, null);
      rethrow;
    }
  }

  /// Track custom event
  Future<void> trackEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await _analytics.logEvent(
        name: name,
        parameters: parameters,
      );
    } catch (e) {
      await _crashlytics.recordError(e, null);
    }
  }

  /// Set user properties
  Future<void> setUserProperties({
    required String userId,
    Map<String, dynamic>? properties,
  }) async {
    try {
      await _analytics.setUserId(id: userId);

      if (properties != null) {
        for (final entry in properties.entries) {
          await _analytics.setUserProperty(
            name: entry.key,
            value: entry.value.toString(),
          );
        }
      }
    } catch (e) {
      await _crashlytics.recordError(e, null);
    }
  }

  /// Record error
  Future<void> recordError(
    dynamic error,
    StackTrace? stackTrace, {
    String? reason,
  }) async {
    try {
      await _crashlytics.recordError(
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
    try {
      return await _messaging.getToken();
    } catch (e) {
      await _crashlytics.recordError(e, null);
      return null;
    }
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      await _analytics.logEvent(
        name: 'topic_subscribe',
        parameters: {'topic': topic},
      );
    } catch (e) {
      await _crashlytics.recordError(e, null);
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      await _analytics.logEvent(
        name: 'topic_unsubscribe',
        parameters: {'topic': topic},
      );
    } catch (e) {
      await _crashlytics.recordError(e, null);
    }
  }
}

/// Firebase service provider for Riverpod
final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});
