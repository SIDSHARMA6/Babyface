import 'dart:io';
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

/// Service to manage bond profile data (name + image) using SharedPreferences
class BondProfileService {
  static const String _bondNameKey = 'bond_name';
  static const String _bondImagePathKey = 'bond_image_path';

  static BondProfileService? _instance;
  static BondProfileService get instance =>
      _instance ??= BondProfileService._();

  BondProfileService._();

  /// Get bond name from SharedPreferences
  Future<String?> getBondName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_bondNameKey);
    } catch (e) {
      developer.log('Error getting bond name: $e');
      return null;
    }
  }

  /// Save bond name to SharedPreferences
  Future<bool> saveBondName(String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_bondNameKey, name);
    } catch (e) {
      developer.log('Error saving bond name: $e');
      return false;
    }
  }

  /// Get bond image path from SharedPreferences
  Future<String?> getBondImagePath() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_bondImagePathKey);
    } catch (e) {
      developer.log('Error getting bond image path: $e');
      return null;
    }
  }

  /// Save bond image path to SharedPreferences
  Future<bool> saveBondImagePath(String imagePath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_bondImagePathKey, imagePath);
    } catch (e) {
      developer.log('Error saving bond image path: $e');
      return false;
    }
  }

  /// Save bond image file and return the saved path
  Future<String?> saveBondImage(File imageFile) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final bondDir = Directory('${appDir.path}/bond_profile');

      // Create directory if it doesn't exist
      if (!await bondDir.exists()) {
        await bondDir.create(recursive: true);
      }

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'bond_image_$timestamp.jpg';
      final savedFile = File('${bondDir.path}/$fileName');

      // Copy the image file
      await imageFile.copy(savedFile.path);

      // Save path to SharedPreferences
      await saveBondImagePath(savedFile.path);

      return savedFile.path;
    } catch (e) {
      developer.log('Error saving bond image: $e');
      return null;
    }
  }

  /// Clear bond profile data
  Future<bool> clearBondProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_bondNameKey);
      await prefs.remove(_bondImagePathKey);

      // Also delete the image file if it exists
      final imagePath = await getBondImagePath();
      if (imagePath != null) {
        final imageFile = File(imagePath);
        if (await imageFile.exists()) {
          await imageFile.delete();
        }
      }

      return true;
    } catch (e) {
      developer.log('Error clearing bond profile: $e');
      return false;
    }
  }

  /// Check if bond profile exists
  Future<bool> hasBondProfile() async {
    final name = await getBondName();
    final imagePath = await getBondImagePath();
    return name != null && name.isNotEmpty && imagePath != null;
  }
}
