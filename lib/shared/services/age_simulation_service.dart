// import 'dart:math' as math;
import 'feature_extraction_service.dart';

/// Service for simulating baby faces at different ages
class AgeSimulationService {
  static const Map<String, AgeCharacteristics> _ageCharacteristics = {
    'newborn': AgeCharacteristics(
      age: 0,
      description: 'Newborn (0-1 months)',
      faceRatio: 0.85,
      eyeSize: 0.15,
      noseSize: 0.08,
      mouthSize: 0.12,
      cheekFullness: 0.9,
      skinSmoothness: 1.0,
      hairDensity: 0.3,
    ),
    '3months': AgeCharacteristics(
      age: 3,
      description: '3 months old',
      faceRatio: 0.88,
      eyeSize: 0.18,
      noseSize: 0.10,
      mouthSize: 0.14,
      cheekFullness: 0.85,
      skinSmoothness: 0.95,
      hairDensity: 0.5,
    ),
    '1year': AgeCharacteristics(
      age: 12,
      description: '1 year old',
      faceRatio: 0.90,
      eyeSize: 0.20,
      noseSize: 0.12,
      mouthSize: 0.16,
      cheekFullness: 0.80,
      skinSmoothness: 0.90,
      hairDensity: 0.7,
    ),
    '3years': AgeCharacteristics(
      age: 36,
      description: '3 years old',
      faceRatio: 0.92,
      eyeSize: 0.22,
      noseSize: 0.14,
      mouthSize: 0.18,
      cheekFullness: 0.75,
      skinSmoothness: 0.85,
      hairDensity: 0.9,
    ),
  };

  /// Simulate baby face at specific age
  static BabyAgeFeatures simulateAge(
    FacialFeatures parentFeatures,
    String ageGroup,
    String gender,
  ) {
    final ageChar = _ageCharacteristics[ageGroup] ?? _ageCharacteristics['1year']!;
    // final random = math.Random();
    
    // Adjust facial features based on age
    final adjustedFaceRatio = _adjustFaceRatio(parentFeatures.faceRatio, ageChar);
    // final adjustedEyeRatio = _adjustEyeRatio(parentFeatures.eyeToFaceRatio, ageChar);
    // final adjustedFaceShape = _adjustFaceShape(parentFeatures.faceShape, ageChar);
    
    // Generate age-specific characteristics
    final babyFeatures = BabyAgeFeatures(
      ageGroup: ageGroup,
      age: ageChar.age,
      description: ageChar.description,
      faceRatio: adjustedFaceRatio,
      eyeSize: ageChar.eyeSize,
      noseSize: ageChar.noseSize,
      mouthSize: ageChar.mouthSize,
      cheekFullness: ageChar.cheekFullness,
      skinSmoothness: ageChar.skinSmoothness,
      hairDensity: ageChar.hairDensity,
      gender: gender,
      parentFeatures: parentFeatures,
      cutenessScore: _calculateCutenessScore(ageChar, parentFeatures),
    );
    
    return babyFeatures;
  }

  /// Adjust face ratio for baby age
  static double _adjustFaceRatio(double parentRatio, AgeCharacteristics ageChar) {
    // Babies have more rounded faces
    final babyRatio = parentRatio * 0.9 + ageChar.faceRatio * 0.1;
    return babyRatio.clamp(0.7, 1.0);
  }

  /// Adjust eye ratio for baby age
  static double _adjustEyeRatio(double parentRatio, AgeCharacteristics ageChar) {
    // Babies have larger eyes relative to face
    final babyRatio = parentRatio * 0.8 + ageChar.eyeSize * 0.2;
    return babyRatio.clamp(0.1, 0.4);
  }

  /// Adjust face shape for baby age
  static String _adjustFaceShape(String parentShape, AgeCharacteristics ageChar) {
    // Babies tend to have rounder faces
    final shapeMapping = {
      'oval': 'round',
      'heart': 'round',
      'square': 'oval',
      'long': 'oval',
      'round': 'round',
    };
    
    return shapeMapping[parentShape.toLowerCase()] ?? 'round';
  }

  /// Calculate cuteness score based on age and features
  static double _calculateCutenessScore(
    AgeCharacteristics ageChar,
    FacialFeatures parentFeatures,
  ) {
    double score = 0.0;
    
    // Base cuteness from age (newborns are cutest)
    score += (1.0 - (ageChar.age / 36.0)) * 0.4;
    
    // Cuteness from facial proportions
    score += ageChar.cheekFullness * 0.2;
    score += ageChar.eyeSize * 0.2;
    score += ageChar.skinSmoothness * 0.1;
    
    // Cuteness from parent features
    if (parentFeatures.isWellAligned) score += 0.1;
    
    return score.clamp(0.0, 1.0);
  }

  /// Generate multiple age variations
  static List<BabyAgeFeatures> generateAgeVariations(
    FacialFeatures parentFeatures,
    String gender,
    List<String> ageGroups,
  ) {
    return ageGroups.map((ageGroup) {
      return simulateAge(parentFeatures, ageGroup, gender);
    }).toList();
  }

  /// Get available age groups
  static List<String> getAvailableAgeGroups() {
    return _ageCharacteristics.keys.toList();
  }

  /// Get age group description
  static String getAgeDescription(String ageGroup) {
    return _ageCharacteristics[ageGroup]?.description ?? 'Unknown age';
  }

  /// Calculate age progression from one age to another
  static BabyAgeFeatures progressAge(
    BabyAgeFeatures currentFeatures,
    String targetAgeGroup,
  ) {
    final targetAgeChar = _ageCharacteristics[targetAgeGroup];
    if (targetAgeChar == null) return currentFeatures;
    
    // Calculate progression factor
    final currentAge = currentFeatures.age;
    final targetAge = targetAgeChar.age;
    final progressionFactor = (targetAge - currentAge) / 36.0; // Max 3 years
    
    // Interpolate features
    final newFaceRatio = currentFeatures.faceRatio + 
        (targetAgeChar.faceRatio - currentFeatures.faceRatio) * progressionFactor;
    
    final newEyeSize = currentFeatures.eyeSize + 
        (targetAgeChar.eyeSize - currentFeatures.eyeSize) * progressionFactor;
    
    return BabyAgeFeatures(
      ageGroup: targetAgeGroup,
      age: targetAge,
      description: targetAgeChar.description,
      faceRatio: newFaceRatio,
      eyeSize: newEyeSize,
      noseSize: targetAgeChar.noseSize,
      mouthSize: targetAgeChar.mouthSize,
      cheekFullness: targetAgeChar.cheekFullness,
      skinSmoothness: targetAgeChar.skinSmoothness,
      hairDensity: targetAgeChar.hairDensity,
      gender: currentFeatures.gender,
      parentFeatures: currentFeatures.parentFeatures,
      cutenessScore: _calculateCutenessScore(targetAgeChar, currentFeatures.parentFeatures),
    );
  }
}

/// Age-specific characteristics for baby faces
class AgeCharacteristics {
  final int age;
  final String description;
  final double faceRatio;
  final double eyeSize;
  final double noseSize;
  final double mouthSize;
  final double cheekFullness;
  final double skinSmoothness;
  final double hairDensity;

  const AgeCharacteristics({
    required this.age,
    required this.description,
    required this.faceRatio,
    required this.eyeSize,
    required this.noseSize,
    required this.mouthSize,
    required this.cheekFullness,
    required this.skinSmoothness,
    required this.hairDensity,
  });
}

/// Baby face features at specific age
class BabyAgeFeatures {
  final String ageGroup;
  final int age;
  final String description;
  final double faceRatio;
  final double eyeSize;
  final double noseSize;
  final double mouthSize;
  final double cheekFullness;
  final double skinSmoothness;
  final double hairDensity;
  final String gender;
  final FacialFeatures parentFeatures;
  final double cutenessScore;

  BabyAgeFeatures({
    required this.ageGroup,
    required this.age,
    required this.description,
    required this.faceRatio,
    required this.eyeSize,
    required this.noseSize,
    required this.mouthSize,
    required this.cheekFullness,
    required this.skinSmoothness,
    required this.hairDensity,
    required this.gender,
    required this.parentFeatures,
    required this.cutenessScore,
  });

  /// Get age-appropriate description
  String get ageDescription {
    final descriptions = {
      'newborn': 'Your precious newborn with those adorable tiny features!',
      '3months': 'Your growing 3-month-old with those big curious eyes!',
      '1year': 'Your active 1-year-old with that infectious smile!',
      '3years': 'Your playful 3-year-old with that mischievous grin!',
    };
    
    return descriptions[ageGroup] ?? 'Your beautiful baby at $age months!';
  }

  /// Get cuteness level description
  String get cutenessDescription {
    if (cutenessScore >= 0.9) return 'Absolutely adorable! 💕';
    if (cutenessScore >= 0.8) return 'Super cute! 😍';
    if (cutenessScore >= 0.7) return 'Very cute! 🥰';
    if (cutenessScore >= 0.6) return 'Cute! 😊';
    return 'Sweet! 😌';
  }

  /// Calculate compatibility with parent features
  double calculateParentCompatibility() {
    return parentFeatures.calculateCompatibility(parentFeatures);
  }
}
