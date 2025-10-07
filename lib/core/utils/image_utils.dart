import 'dart:io';

/// Utility functions for image processing
class ImageUtils {
  /// Check if file is a valid image
  static bool isValidImageFile(File file) {
    final extension = file.path.toLowerCase();
    return extension.endsWith('.jpg') ||
        extension.endsWith('.jpeg') ||
        extension.endsWith('.png') ||
        extension.endsWith('.webp');
  }

  /// Get file size in MB
  static Future<double> getFileSizeInMB(File file) async {
    final bytes = await file.length();
    return bytes / (1024 * 1024);
  }

  /// Check if image file size is acceptable
  static Future<bool> isAcceptableSize(File file,
      {double maxSizeMB = 10.0}) async {
    final sizeMB = await getFileSizeInMB(file);
    return sizeMB <= maxSizeMB;
  }

  /// Generate unique filename
  static String generateUniqueFilename(String extension) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'img_$timestamp.$extension';
  }
}
