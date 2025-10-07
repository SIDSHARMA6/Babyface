import 'dart:io';
// import 'dart:math' as math;
// import 'dart:typed_data';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
// import 'package:image/image.dart' as img;
import 'package:vector_math/vector_math.dart';

/// Advanced face detection service with real AI implementation
class FaceDetectionService {
  static final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableLandmarks: true,
      enableClassification: true,
      enableTracking: true,
      minFaceSize: 0.1,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );

  /// Detect faces in image using Google ML Kit
  static Future<FaceDetectionResult> detectFaces(File imageFile) async {
    try {
      // Read image file
      // final Uint8List imageBytes = await imageFile.readAsBytes();
      final inputImage = InputImage.fromFile(imageFile);

      // Detect faces
      final List<Face> faces = await _faceDetector.processImage(inputImage);

      if (faces.isEmpty) {
        return FaceDetectionResult(
          hasFaces: false,
          confidence: 0.0,
          error: 'No faces detected in image',
        );
      }

      // Convert to our format
      final detectedFaces = faces.map((face) {
        final rect = face.boundingBox;
        return DetectedFace(
          x: rect.left,
          y: rect.top,
          width: rect.width,
          height: rect.height,
          confidence: face.headEulerAngleY != null
              ? (1.0 - (face.headEulerAngleY!.abs() / 90.0)).clamp(0.0, 1.0)
              : 0.8,
          angle: face.headEulerAngleY ?? 0.0,
          landmarks: _extractLandmarks(face),
          contours: _extractContours(face),
        );
      }).toList();

      // Calculate overall confidence
      final avgConfidence =
          detectedFaces.map((f) => f.confidence).reduce((a, b) => a + b) /
              detectedFaces.length;

      return FaceDetectionResult(
        hasFaces: true,
        confidence: avgConfidence,
        faceCount: faces.length,
        faces: detectedFaces,
      );
    } catch (e) {
      return FaceDetectionResult(
        hasFaces: false,
        confidence: 0.0,
        error: 'Face detection failed: $e',
      );
    }
  }

  /// Extract facial landmarks from detected face
  static List<Vector2> _extractLandmarks(Face face) {
    final landmarks = <Vector2>[];

    for (final landmark in face.landmarks.values) {
      if (landmark != null) {
        landmarks.add(Vector2(
            landmark.position.x.toDouble(), landmark.position.y.toDouble()));
      }
    }

    return landmarks;
  }

  /// Extract face contours for detailed analysis
  static List<Vector2> _extractContours(Face face) {
    final contours = <Vector2>[];

    for (final contour in face.contours.values) {
      if (contour != null) {
        for (final point in contour.points) {
          contours.add(Vector2(point.x.toDouble(), point.y.toDouble()));
        }
      }
    }

    return contours;
  }

  /// Validate if image is suitable for baby generation
  static Future<FaceValidationResult> validateFaceForGeneration(
      File imageFile) async {
    try {
      final detectionResult = await detectFaces(imageFile);

      if (!detectionResult.hasFaces) {
        return FaceValidationResult(
          isValid: false,
          reason: 'No face detected in image',
          suggestions: [
            'Ensure the photo shows a clear face',
            'Use good lighting',
            'Face should be looking towards camera',
          ],
        );
      }

      if (detectionResult.faceCount > 1) {
        return FaceValidationResult(
          isValid: false,
          reason: 'Multiple faces detected',
          suggestions: [
            'Use a photo with only one person',
            'Crop the image to show only one face',
          ],
        );
      }

      return FaceValidationResult(
        isValid: true,
        confidence: detectionResult.confidence,
      );
    } catch (e) {
      return FaceValidationResult(
        isValid: false,
        reason: 'Face validation failed: $e',
      );
    }
  }
}

/// Face detection result
class FaceDetectionResult {
  final bool hasFaces;
  final double confidence;
  final int faceCount;
  final List<DetectedFace> faces;
  final String? error;

  FaceDetectionResult({
    required this.hasFaces,
    required this.confidence,
    this.faceCount = 0,
    this.faces = const [],
    this.error,
  });
}

/// Detected face data with landmarks and contours
class DetectedFace {
  final double x;
  final double y;
  final double width;
  final double height;
  final double confidence;
  final double angle;
  final List<Vector2> landmarks;
  final List<Vector2> contours;

  DetectedFace({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.confidence,
    required this.angle,
    this.landmarks = const [],
    this.contours = const [],
  });

  /// Get face center point
  Vector2 get center => Vector2(x + width / 2, y + height / 2);

  /// Get face area
  double get area => width * height;

  /// Check if face is properly aligned (not too tilted)
  bool get isWellAligned => angle.abs() < 15.0;

  /// Get key facial landmarks for blending
  Map<String, Vector2> get keyLandmarks {
    if (landmarks.length < 5) return {};

    return {
      'leftEye': landmarks[0],
      'rightEye': landmarks[1],
      'nose': landmarks[2],
      'leftMouth': landmarks[3],
      'rightMouth': landmarks[4],
    };
  }
}

/// Face validation result
class FaceValidationResult {
  final bool isValid;
  final String? reason;
  final double confidence;
  final List<String> suggestions;

  FaceValidationResult({
    required this.isValid,
    this.reason,
    this.confidence = 0.0,
    this.suggestions = const [],
  });
}
