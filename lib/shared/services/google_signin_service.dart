import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart' as AppUser;

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
  Future<AppUser.User?> signInWithGoogle() async {
    try {
      print('🔐 [GoogleSignIn] Starting Google Sign-In...');

      // Sign out any existing user
      await _googleSignIn.signOut();
      await _auth.signOut();

      // Trigger Google Sign-In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('❌ [GoogleSignIn] User cancelled sign-in');
        return null;
      }

      print('✅ [GoogleSignIn] Google user obtained: ${googleUser.email}');

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
        print(
            '✅ [GoogleSignIn] Firebase sign-in successful: ${userCredential.user?.uid}');
      } catch (e) {
        print('❌ [GoogleSignIn] Firebase sign-in failed: $e');

        // Handle PigeonUserDetails type cast error
        if (e.toString().contains('PigeonUserDetails')) {
          print(
              '🔐 [GoogleSignIn] Handling PigeonUserDetails type cast error...');

          // Wait a bit and try to get the current user
          await Future.delayed(const Duration(milliseconds: 500));
          final currentUser = _auth.currentUser;

          if (currentUser != null) {
            print(
                '✅ [GoogleSignIn] Got current user after error: ${currentUser.uid}');
            // Use the current user directly
            final firebaseUser = currentUser;

            // Create User object
            final user = AppUser.User(
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

            print('✅ [GoogleSignIn] User saved to SharedPreferences');
            return user;
          } else {
            print('❌ [GoogleSignIn] No current user found after error');
            return null;
          }
        } else {
          rethrow;
        }
      }

      // If we reach here, the normal flow worked
      final firebaseUser = userCredential.user!;

      // Create User object
      final user = AppUser.User(
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

      print('✅ [GoogleSignIn] User saved to SharedPreferences');
      return user;
    } catch (e) {
      print('❌ [GoogleSignIn] Error: $e');
      return null;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      await _clearUserFromPrefs();
      print('✅ [GoogleSignIn] Sign out successful');
    } catch (e) {
      print('❌ [GoogleSignIn] Sign out error: $e');
    }
  }

  /// Get current user from SharedPreferences
  Future<AppUser.User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('current_user');
      
      print('🔐 [GoogleSignIn] getCurrentUser - userData: ${userData != null ? "Found" : "Not found"}');

      if (userData != null) {
        print('🔐 [GoogleSignIn] Raw userData: $userData');
        final userMap =
            Map<String, dynamic>.from(Uri.splitQueryString(userData));
        print('🔐 [GoogleSignIn] Parsed userMap: $userMap');

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

        return AppUser.User.fromMap(convertedMap);
      }
      return null;
    } catch (e) {
      print('❌ [GoogleSignIn] Error getting current user: $e');
      return null;
    }
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final user = await getCurrentUser();
    return user != null;
  }

  /// Save user to SharedPreferences
  Future<void> _saveUserToPrefs(AppUser.User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userMap = user.toMap();
      print('🔐 [GoogleSignIn] Saving user map: $userMap');
      
      final userData = Uri(
          queryParameters: userMap.map(
                (key, value) => MapEntry(key, value?.toString() ?? ''),
              )).query;
      
      print('🔐 [GoogleSignIn] Saving userData: $userData');

      await prefs.setString('current_user', userData);
      await prefs.setBool('is_logged_in', true);
      
      print('✅ [GoogleSignIn] User saved successfully');
    } catch (e) {
      print('❌ [GoogleSignIn] Error saving user: $e');
    }
  }

  /// Clear user from SharedPreferences
  Future<void> _clearUserFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('current_user');
      await prefs.setBool('is_logged_in', false);
    } catch (e) {
      print('❌ [GoogleSignIn] Error clearing user: $e');
    }
  }

  /// Update user data
  Future<void> updateUser(AppUser.User user) async {
    await _saveUserToPrefs(user);
  }
}
