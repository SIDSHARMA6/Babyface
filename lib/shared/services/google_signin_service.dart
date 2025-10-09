import 'package:google_sign_in/google_sign_in.dart';
import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart' as app_user;

/// Clean Google Sign-In service
class GoogleSignInService {
  static final GoogleSignInService _instance = GoogleSignInService._internal();
  factory GoogleSignInService() => _instance;
  GoogleSignInService._internal();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId:
        '828723503305-0fgi0n2gm7e1m4mj9flm5lue0dp714o4.apps.googleusercontent.com',
  );
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Sign in with Google
  Future<app_user.User?> signInWithGoogle() async {
    try {
      developer.log('🔐 [GoogleSignIn] Starting Google Sign-In...');

      // Sign out any existing user
      await _googleSignIn.signOut();
      await _auth.signOut();

      // Trigger Google Sign-In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        developer.log('❌ [GoogleSignIn] User cancelled sign-in');
        return null;
      }

      developer.log('✅ [GoogleSignIn] Google user obtained: ${googleUser.email}');

      // Get authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with error handling
      UserCredential? userCredential;
      try {
        userCredential = await _auth.signInWithCredential(credential);
        developer.log(
            '✅ [GoogleSignIn] Firebase sign-in successful: ${userCredential.user?.uid}');
      } catch (e) {
        developer.log('❌ [GoogleSignIn] Firebase sign-in failed: $e');

        // Handle PigeonUserDetails type cast error
        if (e.toString().contains('PigeonUserDetails')) {
          developer.log(
              '🔐 [GoogleSignIn] Handling PigeonUserDetails type cast error...');

          // Wait a bit and try to get the current user
          await Future.delayed(const Duration(milliseconds: 500));
          final currentUser = _auth.currentUser;

          if (currentUser != null) {
            developer.log(
                '✅ [GoogleSignIn] Got current user after error: ${currentUser.uid}');
            // Use the current user directly
            final firebaseUser = currentUser;

            // Create User object
            final user = app_user.User(
              id: firebaseUser.uid,
              email: firebaseUser.email ?? '',
              displayName: firebaseUser.displayName,
              photoUrl: firebaseUser.photoURL,
              firstName: firebaseUser.displayName?.split(' ').first,
              lastName: firebaseUser.displayName?.split(' ').last,
              isComplete: false, // Will be updated during onboarding
              createdAt: DateTime.now(),
            );

            // Save to SharedPreferences
            await _saveUserToPrefs(user);

            developer.log('✅ [GoogleSignIn] User saved to SharedPreferences');
            return user;
          } else {
            developer.log('❌ [GoogleSignIn] No current user found after error');
            return null;
          }
        } else {
          rethrow;
        }
      }

      // If we reach here, the normal flow worked
      final firebaseUser = userCredential.user!;

      // Create User object
      final user = app_user.User(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName,
        photoUrl: firebaseUser.photoURL,
        firstName: firebaseUser.displayName?.split(' ').first,
        lastName: firebaseUser.displayName?.split(' ').last,
        isComplete: false, // Will be updated during onboarding
        createdAt: DateTime.now(),
      );

      // Save to SharedPreferences
      await _saveUserToPrefs(user);

      developer.log('✅ [GoogleSignIn] User saved to SharedPreferences');
      return user;
    } catch (e) {
      developer.log('❌ [GoogleSignIn] Error: $e');
      return null;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      await _clearUserFromPrefs();
      developer.log('✅ [GoogleSignIn] Sign out successful');
    } catch (e) {
      developer.log('❌ [GoogleSignIn] Sign out error: $e');
    }
  }

  /// Get current user from SharedPreferences
  Future<app_user.User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('current_user');

      developer.log(
          '🔐 [GoogleSignIn] getCurrentUser - userData: ${userData != null ? "Found" : "Not found"}');

      if (userData != null) {
        developer.log('🔐 [GoogleSignIn] Raw userData: $userData');
        final userMap =
            Map<String, dynamic>.from(Uri.splitQueryString(userData));
        developer.log('🔐 [GoogleSignIn] Parsed userMap: $userMap');

        // Convert string values to proper types
        final convertedMap = <String, dynamic>{
          'id': userMap['id'] ?? '',
          'email': userMap['email'] ?? '',
          'displayName': userMap['displayName'],
          'photoUrl': userMap['photoUrl'],
          'firstName': userMap['firstName'],
          'lastName': userMap['lastName'],
          'gender': userMap['gender'],
          'partnerName': userMap['partnerName'],
          'bondName': userMap['bondName'],
          'isComplete': userMap['isComplete'] == 'true',
          'createdAt': userMap['createdAt'] ?? DateTime.now().toIso8601String(),
        };

        return app_user.User.fromMap(convertedMap);
      }
      return null;
    } catch (e) {
      developer.log('❌ [GoogleSignIn] Error getting current user: $e');
      return null;
    }
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final user = await getCurrentUser();
    return user != null;
  }

  /// Save user to SharedPreferences
  Future<void> _saveUserToPrefs(app_user.User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userMap = user.toMap();
      developer.log('🔐 [GoogleSignIn] Saving user map: $userMap');

      final userData = Uri(
          queryParameters: userMap.map(
        (key, value) => MapEntry(key, value?.toString() ?? ''),
      )).query;

      developer.log('🔐 [GoogleSignIn] Saving userData: $userData');

      await prefs.setString('current_user', userData);
      await prefs.setBool('is_logged_in', true);

      developer.log('✅ [GoogleSignIn] User saved successfully');
    } catch (e) {
      developer.log('❌ [GoogleSignIn] Error saving user: $e');
    }
  }

  /// Clear user from SharedPreferences
  Future<void> _clearUserFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('current_user');
      await prefs.setBool('is_logged_in', false);
    } catch (e) {
      developer.log('❌ [GoogleSignIn] Error clearing user: $e');
    }
  }

  /// Update user data
  Future<void> updateUser(app_user.User user) async {
    await _saveUserToPrefs(user);
  }
}
