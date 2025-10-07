import 'dart:io';
import 'dart:math' as math;
import 'package:vector_math/vector_math.dart';
import 'package:image/image.dart' as img;
import 'face_detection_service.dart';

/// Service for extracting facial features and creating latent vectors
class FeatureExtractionService {
  static const int _latentVectorSize = 512; // Standard FaceNet size

  /// Extract latent vector from face image
  static Future<LatentVector> extractFeatures(
      File imageFile, DetectedFace face) async {
    try {
      // Read and preprocess image
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);
      if (image == null) throw Exception('Failed to decode image');

      // Crop face region
      final croppedFace = _cropFaceRegion(image, face);

      // Resize to standard size (112x112 for FaceNet)
      final resizedFace = img.copyResize(croppedFace, width: 112, height: 112);

      // Normalize image
      final normalizedFace = _normalizeImage(resizedFace);

      // Extract features using mock FaceNet (in real implementation, use actual model)
      final latentVector = await _extractLatentVector(normalizedFace);

      // Extract additional facial features
      final facialFeatures = _extractFacialFeatures(face, normalizedFace);

      return LatentVector(
        vector: latentVector,
        facialFeatures: facialFeatures,
        confidence: face.confidence,
        extractedAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Feature extraction failed: $e');
    }
  }

  /// Crop face region from image
  static img.Image _cropFaceRegion(img.Image image, DetectedFace face) {
    final x = face.x.round();
    final y = face.y.round();
    final width = face.width.round();
    final height = face.height.round();

    // Add padding around face
    final padding = (math.min(width, height) * 0.2).round();
    final paddedX = math.max(0, x - padding);
    final paddedY = math.max(0, y - padding);
    final paddedWidth = math.min(image.width - paddedX, width + 2 * padding);
    final paddedHeight = math.min(image.height - paddedY, height + 2 * padding);

    return img.copyCrop(
      image,
      paddedX,
      paddedY,
      paddedWidth,
      paddedHeight,
    );
  }

  /// Normalize image for feature extraction
  static img.Image _normalizeImage(img.Image image) {
    // For now, just return the original image
    // In a real implementation, you would convert to RGB format properly
    img.Image normalized = image;

    // Normalize pixel values to [0, 1]
    final pixels = normalized.getBytes();
    for (int i = 0; i < pixels.length; i++) {
      pixels[i] = (pixels[i] / 255.0).round().clamp(0, 255);
    }

    return normalized;
  }

  /// Extract latent vector using mock FaceNet (replace with actual model)
  static Future<List<double>> _extractLatentVector(img.Image image) async {
    // Mock implementation - in real app, use actual FaceNet model
    final vector = <double>[];

    // Generate random but consistent vector based on image content
    final pixels = image.getBytes();
    final seed = pixels.fold(0, (sum, pixel) => sum + pixel) % 1000000;
    final random = math.Random(seed);

    for (int i = 0; i < _latentVectorSize; i++) {
      vector.add((random.nextDouble() - 0.5) * 2.0); // Range [-1, 1]
    }

    // Normalize vector
    final magnitude =
        math.sqrt(vector.map((v) => v * v).reduce((a, b) => a + b));
    return vector.map((v) => v / magnitude).toList();
  }

  /// Extract detailed facial features
  static FacialFeatures _extractFacialFeatures(
      DetectedFace face, img.Image image) {
    final landmarks = face.keyLandmarks;

    // Calculate facial ratios
    final eyeDistance =
        landmarks['leftEye'] != null && landmarks['rightEye'] != null
            ? landmarks['leftEye']!.distanceTo(landmarks['rightEye']!)
            : 0.0;

    final faceWidth = face.width;
    final faceHeight = face.height;

    // Calculate eye-to-face ratio
    final eyeToFaceRatio = eyeDistance / faceWidth;

    // Calculate face shape
    final faceRatio = faceWidth / faceHeight;
    String faceShape = 'oval';
    if (faceRatio > 0.85) {
      faceShape = 'round';
    } else if (faceRatio < 0.7) {
      faceShape = 'long';
    } else if (faceRatio > 0.8) {
      faceShape = 'square';
    }

    // Extract color features
    final colorFeatures = _extractColorFeatures(image);

    return FacialFeatures(
      eyeDistance: eyeDistance,
      eyeToFaceRatio: eyeToFaceRatio,
      faceRatio: faceRatio,
      faceShape: faceShape,
      skinTone: colorFeatures['skinTone'] ?? 'medium',
      eyeColor: colorFeatures['eyeColor'] ?? 'brown',
      hairColor: colorFeatures['hairColor'] ?? 'black',
      landmarks: landmarks,
      isWellAligned: face.isWellAligned,
    );
  }

  /// Extract color features from image
  static Map<String, String> _extractColorFeatures(img.Image image) {
    // Mock color extraction - in real implementation, use color analysis
    final random = math.Random();

    final skinTones = ['fair', 'light', 'medium', 'olive', 'tan', 'dark'];
    final eyeColors = ['brown', 'hazel', 'green', 'blue', 'amber'];
    final hairColors = ['black', 'brown', 'blonde', 'red', 'gray'];

    return {
      'skinTone': skinTones[random.nextInt(skinTones.length)],
      'eyeColor': eyeColors[random.nextInt(eyeColors.length)],
      'hairColor': hairColors[random.nextInt(hairColors.length)],
    };
  }

  /// Blend two latent vectors with alpha factor
  static List<double> blendVectors(
    List<double> vector1,
    List<double> vector2,
    double alpha,
  ) {
    if (vector1.length != vector2.length) {
      throw Exception('Vector dimensions must match');
    }

    final blended = <double>[];
    for (int i = 0; i < vector1.length; i++) {
      blended.add(alpha * vector1[i] + (1 - alpha) * vector2[i]);
    }

    return blended;
  }

  /// Calculate similarity between two latent vectors
  static double calculateSimilarity(
      List<double> vector1, List<double> vector2) {
    if (vector1.length != vector2.length) return 0.0;

    double dotProduct = 0.0;
    double norm1 = 0.0;
    double norm2 = 0.0;

    for (int i = 0; i < vector1.length; i++) {
      dotProduct += vector1[i] * vector2[i];
      norm1 += vector1[i] * vector1[i];
      norm2 += vector2[i] * vector2[i];
    }

    return dotProduct / (math.sqrt(norm1) * math.sqrt(norm2));
  }
}

/// Latent vector representation of a face
class LatentVector {
  final List<double> vector;
  final FacialFeatures facialFeatures;
  final double confidence;
  final DateTime extractedAt;

  LatentVector({
    required this.vector,
    required this.facialFeatures,
    required this.confidence,
    required this.extractedAt,
  });

  /// Get vector magnitude
  double get magnitude {
    return math.sqrt(vector.map((v) => v * v).reduce((a, b) => a + b));
  }

  /// Normalize vector to unit length
  List<double> get normalized {
    final mag = magnitude;
    if (mag == 0) return vector;
    return vector.map((v) => v / mag).toList();
  }
}

/// Detailed facial features extracted from image
class FacialFeatures {
  final double eyeDistance;
  final double eyeToFaceRatio;
  final double faceRatio;
  final String faceShape;
  final String skinTone;
  final String eyeColor;
  final String hairColor;
  final Map<String, Vector2> landmarks;
  final bool isWellAligned;

  FacialFeatures({
    required this.eyeDistance,
    required this.eyeToFaceRatio,
    required this.faceRatio,
    required this.faceShape,
    required this.skinTone,
    required this.eyeColor,
    required this.hairColor,
    required this.landmarks,
    required this.isWellAligned,
  });

  /// Calculate compatibility with another face
  double calculateCompatibility(FacialFeatures other) {
    double score = 0.0;

    // Face shape compatibility
    if (faceShape == other.faceShape) score += 0.3;

    // Eye ratio compatibility
    final eyeRatioDiff = (eyeToFaceRatio - other.eyeToFaceRatio).abs();
    score += (1.0 - eyeRatioDiff) * 0.2;

    // Face ratio compatibility
    final faceRatioDiff = (faceRatio - other.faceRatio).abs();
    score += (1.0 - faceRatioDiff) * 0.2;

    // Alignment compatibility
    if (isWellAligned && other.isWellAligned) score += 0.3;

    return score.clamp(0.0, 1.0);
  }
}
