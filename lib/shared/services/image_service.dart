import 'dart:io';
import 'package:flutter/foundation.dart';

import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

// Export ImageSource for convenience
export 'package:image_picker/image_picker.dart' show ImageSource;

/// ANR-proof image service using compute for heavy operations
class ImageService {
  static final ImagePicker _picker = ImagePicker();

  /// Pick image from camera or gallery (ANR-safe)
  static Future<File?> pickImage({required ImageSource source}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image == null) return null;
      return File(image.path);
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  /// Compress image to reduce file size
  static Future<File> compressImage(
    File imageFile, {
    int quality = 85,
    int maxWidth = 1024,
    int maxHeight = 1024,
  }) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      final appDir = await getApplicationDocumentsDirectory();

      // Process in compute to prevent ANR
      final result = await compute(_processImageInBackground, {
        'imageBytes': imageBytes,
        'outputDir': appDir.path,
        'quality': quality,
        'maxWidth': maxWidth,
        'maxHeight': maxHeight,
      });

      return File(result['outputPath']);
    } catch (e) {
      debugPrint('Error compressing image: $e');
      return imageFile;
    }
  }

  /// Detect face in image (simplified)
  static Future<bool> detectFace(File imageFile) async {
    try {
      // Simulate face detection processing
      await Future.delayed(const Duration(milliseconds: 500));
      // Mock: always return true for demo
      return true;
    } catch (e) {
      debugPrint('Error detecting face: $e');
      return false;
    }
  }

  /// Delete image file
  static Future<void> deleteImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Error deleting image: $e');
    }
  }
}

/// Background image processing function
Map<String, dynamic> _processImageInBackground(Map<String, dynamic> params) {
  try {
    final imageBytes = params['imageBytes'] as List<int>;
    final outputDir = params['outputDir'] as String;
    final quality = params['quality'] as int? ?? 85;
    final maxWidth = params['maxWidth'] as int? ?? 1024;
    final maxHeight = params['maxHeight'] as int? ?? 1024;

    // Decode image
    final image = img.decodeImage(Uint8List.fromList(imageBytes));
    if (image == null) throw Exception('Failed to decode image');

    // Resize if needed
    final resized = img.copyResize(
      image,
      width: maxWidth,
      height: maxHeight,
    );

    // Encode as JPEG
    final compressedBytes = img.encodeJpg(resized, quality: quality);

    // Save to file
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final outputPath = '$outputDir/compressed_$timestamp.jpg';
    final outputFile = File(outputPath);
    outputFile.writeAsBytesSync(compressedBytes);

    return {'outputPath': outputPath};
  } catch (e) {
    throw Exception('Image processing failed: $e');
  }
}
