import 'dart:io';
import 'dart:math' as math;
import 'package:vector_math/vector_math.dart';
import 'face_detection_service.dart';
import 'feature_extraction_service.dart';
import 'indian_adaptation_service.dart';
import 'age_simulation_service.dart';

/// Advanced AI baby generation service with α blend factor
class AdvancedAIBabyService {
  static final math.Random _random = math.Random();

  /// Generate AI baby with α blend factor
  static Future<AdvancedBabyResult> generateBabyWithBlend({
    required File malePhoto,
    required File femalePhoto,
    required String maleName,
    required String femaleName,
    required double alpha, // 0.0 = 100% female, 1.0 = 100% male
    required String indianRegion,
    required String ageGroup,
    required String gender,
    double adaptationStrength = 0.8,
  }) async {
    try {
      // Step 1: Detect faces
      final maleDetection = await FaceDetectionService.detectFaces(malePhoto);
      final femaleDetection = await FaceDetectionService.detectFaces(femalePhoto);

      if (!maleDetection.hasFaces || !femaleDetection.hasFaces) {
        throw Exception('Could not detect faces in one or both photos');
      }

      final maleFace = maleDetection.faces.first;
      final femaleFace = femaleDetection.faces.first;

      // Step 2: Extract features
      final maleFeatures = await FeatureExtractionService.extractFeatures(malePhoto, maleFace);
      final femaleFeatures = await FeatureExtractionService.extractFeatures(femalePhoto, femaleFace);

      // Step 3: Blend latent vectors with α factor
      final blendedVector = FeatureExtractionService.blendVectors(
        maleFeatures.vector,
        femaleFeatures.vector,
        alpha,
      );

      // Step 4: Create blended facial features
      final blendedFacialFeatures = _blendFacialFeatures(
        maleFeatures.facialFeatures,
        femaleFeatures.facialFeatures,
        alpha,
      );

      // Step 5: Apply Indian adaptation
      final indianFeatures = IndianAdaptationService.adaptFeatures(
        blendedFacialFeatures,
        indianRegion,
        adaptationStrength,
      );

      // Step 6: Simulate baby age
      final babyAgeFeatures = AgeSimulationService.simulateAge(
        indianFeatures.originalFeatures,
        ageGroup,
        gender,
      );

      // Step 7: Generate baby image (mock - replace with actual synthesis)
      final babyImagePath = await _generateBabyImage(
        blendedVector,
        babyAgeFeatures,
        indianFeatures,
      );

      // Step 8: Calculate compatibility scores
      final compatibilityScores = _calculateCompatibilityScores(
        maleFeatures,
        femaleFeatures,
        alpha,
      );

      // Step 9: Generate name suggestions
      final nameSuggestions = IndianAdaptationService.generateIndianNames(
        indianRegion,
        gender,
        blendedFacialFeatures,
      );

      // Step 10: Generate personality traits
      final personalityTraits = _generatePersonalityTraits(
        maleName,
        femaleName,
        alpha,
        babyAgeFeatures,
      );

      return AdvancedBabyResult(
        success: true,
        babyImagePath: babyImagePath,
        maleName: maleName,
        femaleName: femaleName,
        alpha: alpha,
        indianRegion: indianRegion,
        ageGroup: ageGroup,
        gender: gender,
        babyAgeFeatures: babyAgeFeatures,
        indianFeatures: indianFeatures,
        compatibilityScores: compatibilityScores,
        nameSuggestions: nameSuggestions,
        personalityTraits: personalityTraits,
        blendedVector: blendedVector,
        generationTime: DateTime.now(),
      );
    } catch (e) {
      return AdvancedBabyResult(
        success: false,
        errorMessage: 'Failed to generate baby: $e',
        maleName: maleName,
        femaleName: femaleName,
        alpha: alpha,
        indianRegion: indianRegion,
        ageGroup: ageGroup,
        gender: gender,
        generationTime: DateTime.now(),
      );
    }
  }

  /// Blend facial features with α factor
  static FacialFeatures _blendFacialFeatures(
    FacialFeatures maleFeatures,
    FacialFeatures femaleFeatures,
    double alpha,
  ) {
    return FacialFeatures(
      eyeDistance: alpha * maleFeatures.eyeDistance + (1 - alpha) * femaleFeatures.eyeDistance,
      eyeToFaceRatio: alpha * maleFeatures.eyeToFaceRatio + (1 - alpha) * femaleFeatures.eyeToFaceRatio,
      faceRatio: alpha * maleFeatures.faceRatio + (1 - alpha) * femaleFeatures.faceRatio,
      faceShape: alpha > 0.5 ? maleFeatures.faceShape : femaleFeatures.faceShape,
      skinTone: alpha > 0.5 ? maleFeatures.skinTone : femaleFeatures.skinTone,
      eyeColor: alpha > 0.5 ? maleFeatures.eyeColor : femaleFeatures.eyeColor,
      hairColor: alpha > 0.5 ? maleFeatures.hairColor : femaleFeatures.hairColor,
      landmarks: _blendLandmarks(maleFeatures.landmarks, femaleFeatures.landmarks, alpha),
      isWellAligned: maleFeatures.isWellAligned && femaleFeatures.isWellAligned,
    );
  }

  /// Blend facial landmarks
  static Map<String, Vector2> _blendLandmarks(
    Map<String, Vector2> maleLandmarks,
    Map<String, Vector2> femaleLandmarks,
    double alpha,
  ) {
    final blendedLandmarks = <String, Vector2>{};
    
    for (final key in maleLandmarks.keys) {
      if (femaleLandmarks.containsKey(key)) {
        final malePoint = maleLandmarks[key]!;
        final femalePoint = femaleLandmarks[key]!;
        
        blendedLandmarks[key] = Vector2(
          alpha * malePoint.x + (1 - alpha) * femalePoint.x,
          alpha * malePoint.y + (1 - alpha) * femalePoint.y,
        );
      }
    }
    
    return blendedLandmarks;
  }

  /// Generate baby image (mock implementation)
  static Future<String> _generateBabyImage(
    List<double> blendedVector,
    BabyAgeFeatures babyFeatures,
    IndianAdaptedFeatures indianFeatures,
  ) async {
    // Mock implementation - in real app, use StyleGAN or similar
    await Future.delayed(Duration(milliseconds: 500 + _random.nextInt(1000)));
    
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'generated_baby_$timestamp.jpg';
  }

  /// Calculate compatibility scores
  static CompatibilityScores _calculateCompatibilityScores(
    LatentVector maleFeatures,
    LatentVector femaleFeatures,
    double alpha,
  ) {
    // Calculate vector similarity
    final vectorSimilarity = FeatureExtractionService.calculateSimilarity(
      maleFeatures.vector,
      femaleFeatures.vector,
    );

    // Calculate facial feature compatibility
    final facialCompatibility = maleFeatures.facialFeatures.calculateCompatibility(
      femaleFeatures.facialFeatures,
    );

    // Calculate overall compatibility
    final overallCompatibility = (vectorSimilarity * 0.6 + facialCompatibility * 0.4);

    // Calculate parent resemblance
    final maleResemblance = alpha;
    final femaleResemblance = 1.0 - alpha;

    return CompatibilityScores(
      overallCompatibility: overallCompatibility,
      vectorSimilarity: vectorSimilarity,
      facialCompatibility: facialCompatibility,
      maleResemblance: maleResemblance,
      femaleResemblance: femaleResemblance,
      alpha: alpha,
    );
  }

  /// Generate personality traits based on parents and α factor
  static List<String> _generatePersonalityTraits(
    String maleName,
    String femaleName,
    double alpha,
    BabyAgeFeatures babyFeatures,
  ) {
    final traits = <String>[];
    
    // Base traits from age
    if (babyFeatures.age <= 3) {
      traits.addAll(['Curious', 'Playful', 'Energetic']);
    } else if (babyFeatures.age <= 12) {
      traits.addAll(['Adventurous', 'Independent', 'Creative']);
    } else {
      traits.addAll(['Smart', 'Confident', 'Social']);
    }

    // Traits influenced by α factor
    if (alpha > 0.7) {
      traits.addAll(['Strong-willed', 'Determined', 'Bold']);
    } else if (alpha < 0.3) {
      traits.addAll(['Gentle', 'Caring', 'Sensitive']);
    } else {
      traits.addAll(['Balanced', 'Adaptable', 'Harmonious']);
    }

    // Cuteness-based traits
    if (babyFeatures.cutenessScore > 0.8) {
      traits.addAll(['Adorable', 'Charming', 'Sweet']);
    }

    // Shuffle and return 5 traits
    traits.shuffle(_random);
    return traits.take(5).toList();
  }

  /// Generate multiple variations with different α values
  static Future<List<AdvancedBabyResult>> generateVariations({
    required File malePhoto,
    required File femalePhoto,
    required String maleName,
    required String femaleName,
    required String indianRegion,
    required String ageGroup,
    required String gender,
    int numVariations = 6,
  }) async {
    final variations = <AdvancedBabyResult>[];
    
    for (int i = 0; i < numVariations; i++) {
      final alpha = i / (numVariations - 1); // 0.0 to 1.0
      
      final result = await generateBabyWithBlend(
        malePhoto: malePhoto,
        femalePhoto: femalePhoto,
        maleName: maleName,
        femaleName: femaleName,
        alpha: alpha,
        indianRegion: indianRegion,
        ageGroup: ageGroup,
        gender: gender,
      );
      
      if (result.success) {
        variations.add(result);
      }
    }
    
    return variations;
  }

  /// Generate random blend variations
  static Future<List<AdvancedBabyResult>> generateRandomBlends({
    required File malePhoto,
    required File femalePhoto,
    required String maleName,
    required String femaleName,
    required String indianRegion,
    required String ageGroup,
    required String gender,
    int numVariations = 3,
  }) async {
    final variations = <AdvancedBabyResult>[];
    
    for (int i = 0; i < numVariations; i++) {
      final alpha = _random.nextDouble(); // Random α between 0.0 and 1.0
      
      final result = await generateBabyWithBlend(
        malePhoto: malePhoto,
        femalePhoto: femalePhoto,
        maleName: maleName,
        femaleName: femaleName,
        alpha: alpha,
        indianRegion: indianRegion,
        ageGroup: ageGroup,
        gender: gender,
      );
      
      if (result.success) {
        variations.add(result);
      }
    }
    
    return variations;
  }
}

/// Advanced baby generation result with α blend factor
class AdvancedBabyResult {
  final bool success;
  final String? babyImagePath;
  final String? errorMessage;
  final String maleName;
  final String femaleName;
  final double alpha;
  final String indianRegion;
  final String ageGroup;
  final String gender;
  final BabyAgeFeatures? babyAgeFeatures;
  final IndianAdaptedFeatures? indianFeatures;
  final CompatibilityScores? compatibilityScores;
  final List<String>? nameSuggestions;
  final List<String>? personalityTraits;
  final List<double>? blendedVector;
  final DateTime generationTime;

  AdvancedBabyResult({
    required this.success,
    this.babyImagePath,
    this.errorMessage,
    required this.maleName,
    required this.femaleName,
    required this.alpha,
    required this.indianRegion,
    required this.ageGroup,
    required this.gender,
    this.babyAgeFeatures,
    this.indianFeatures,
    this.compatibilityScores,
    this.nameSuggestions,
    this.personalityTraits,
    this.blendedVector,
    required this.generationTime,
  });

  /// Get α factor description
  String get alphaDescription {
    if (alpha <= 0.2) return '${(alpha * 100).round()}% Dad, ${((1 - alpha) * 100).round()}% Mom - More like Mom';
    if (alpha <= 0.4) return '${(alpha * 100).round()}% Dad, ${((1 - alpha) * 100).round()}% Mom - Mostly Mom';
    if (alpha <= 0.6) return '${(alpha * 100).round()}% Dad, ${((1 - alpha) * 100).round()}% Mom - Balanced';
    if (alpha <= 0.8) return '${(alpha * 100).round()}% Dad, ${((1 - alpha) * 100).round()}% Mom - Mostly Dad';
    return '${(alpha * 100).round()}% Dad, ${((1 - alpha) * 100).round()}% Mom - More like Dad';
  }

  /// Get parent resemblance description
  String get parentResemblance {
    if (alpha > 0.7) return 'Takes after $maleName (Dad)';
    if (alpha < 0.3) return 'Takes after $femaleName (Mom)';
    return 'Perfect blend of both parents';
  }
}

/// Compatibility scores for baby generation
class CompatibilityScores {
  final double overallCompatibility;
  final double vectorSimilarity;
  final double facialCompatibility;
  final double maleResemblance;
  final double femaleResemblance;
  final double alpha;

  CompatibilityScores({
    required this.overallCompatibility,
    required this.vectorSimilarity,
    required this.facialCompatibility,
    required this.maleResemblance,
    required this.femaleResemblance,
    required this.alpha,
  });

  /// Get overall compatibility percentage
  int get compatibilityPercentage => (overallCompatibility * 100).round();

  /// Get compatibility description
  String get compatibilityDescription {
    if (overallCompatibility >= 0.9) return 'Perfect Match! 💕';
    if (overallCompatibility >= 0.8) return 'Excellent Match! 😍';
    if (overallCompatibility >= 0.7) return 'Great Match! 🥰';
    if (overallCompatibility >= 0.6) return 'Good Match! 😊';
    return 'Nice Match! 😌';
  }
}
