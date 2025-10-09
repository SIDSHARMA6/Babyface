import 'package:cloud_functions/cloud_functions.dart';
import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

/// Service for calling Firebase Cloud Functions
class CloudFunctionsService {
  static final CloudFunctionsService _instance = CloudFunctionsService._internal();
  factory CloudFunctionsService() => _instance;
  CloudFunctionsService._internal();

  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// Update user profile in Firebase
  Future<Map<String, dynamic>> updateUserProfile(Map<String, dynamic> profileData) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final callable = _functions.httpsCallable('updateUserProfile');
      final result = await callable.call({
        'userId': user.uid,
        'profileData': profileData,
      });

      return result.data;
    } catch (e) {
      developer.log('Error updating user profile: $e');
      rethrow;
    }
  }

  /// Get user profile from Firebase
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final callable = _functions.httpsCallable('getUserProfile');
      final result = await callable.call({
        'userId': user.uid,
      });

      return result.data;
    } catch (e) {
      developer.log('Error getting user profile: $e');
      rethrow;
    }
  }

  /// Save user login details
  Future<void> saveUserLogin({
    String? loginMethod,
    Map<String, dynamic>? deviceInfo,
    Map<String, dynamic>? location,
    String? ipAddress,
    String? userAgent,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final callable = _functions.httpsCallable('saveUserLogin');
      await callable.call({
        'userId': user.uid,
        'loginData': {
          'loginMethod': loginMethod ?? 'email',
          'deviceInfo': deviceInfo ?? await _getDeviceInfo(),
          'location': location,
          'ipAddress': ipAddress,
          'userAgent': userAgent,
        },
      });
    } catch (e) {
      developer.log('Error saving user login: $e');
      // Don't rethrow as this is not critical
    }
  }

  /// Save user activity
  Future<void> saveUserActivity({
    required String activityType,
    Map<String, dynamic>? activityData,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final callable = _functions.httpsCallable('saveUserActivity');
      await callable.call({
        'userId': user.uid,
        'activity': {
          'type': activityType,
          'data': activityData ?? {},
        },
      });
    } catch (e) {
      developer.log('Error saving user activity: $e');
      // Don't rethrow as this is not critical
    }
  }

  /// Delete user account
  Future<Map<String, dynamic>> deleteUserAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final callable = _functions.httpsCallable('deleteUserAccount');
      final result = await callable.call({
        'userId': user.uid,
      });

      return result.data;
    } catch (e) {
      developer.log('Error deleting user account: $e');
      rethrow;
    }
  }

  /// Generate sharing caption
  Future<String> generateSharingCaption({
    required String type,
    Map<String, dynamic>? metadata,
    String? customMessage,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final callable = _functions.httpsCallable('generateSharingCaption');
      final result = await callable.call({
        'userId': user.uid,
        'type': type,
        'metadata': metadata ?? {},
        'customMessage': customMessage,
      });

      return result.data['caption'] ?? 'Check out this amazing app! ✨';
    } catch (e) {
      developer.log('Error generating sharing caption: $e');
      return 'Check out this amazing app! ✨';
    }
  }

  /// Generate sharing link
  Future<Map<String, dynamic>> generateSharingLink({
    required String contentType,
    required String contentId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final callable = _functions.httpsCallable('generateSharingLink');
      final result = await callable.call({
        'userId': user.uid,
        'contentType': contentType,
        'contentId': contentId,
        'metadata': metadata ?? {},
      });

      return result.data;
    } catch (e) {
      developer.log('Error generating sharing link: $e');
      rethrow;
    }
  }

  /// Track sharing click
  Future<void> trackSharingClick({
    required String sharingId,
    required String action,
  }) async {
    try {
      final user = _auth.currentUser;
      final clickerId = user?.uid ?? 'anonymous';

      final callable = _functions.httpsCallable('trackSharingClick');
      await callable.call({
        'sharingId': sharingId,
        'clickerId': clickerId,
        'action': action,
      });
    } catch (e) {
      developer.log('Error tracking sharing click: $e');
      // Don't rethrow as this is not critical
    }
  }

  /// Get device information
  Future<Map<String, dynamic>> _getDeviceInfo() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return {
          'platform': 'android',
          'model': androidInfo.model,
          'brand': androidInfo.brand,
          'version': androidInfo.version.release,
          'sdkInt': androidInfo.version.sdkInt,
        };
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return {
          'platform': 'ios',
          'model': iosInfo.model,
          'name': iosInfo.name,
          'systemName': iosInfo.systemName,
          'systemVersion': iosInfo.systemVersion,
        };
      } else {
        return {
          'platform': 'unknown',
        };
      }
    } catch (e) {
      return {
        'platform': 'unknown',
        'error': e.toString(),
      };
    }
  }
}

