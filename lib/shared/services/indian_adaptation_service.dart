import 'dart:math' as math;
import 'feature_extraction_service.dart';

/// Service for adapting facial features to Indian characteristics
class IndianAdaptationService {
  static const Map<String, IndianRegion> _regions = {
    'north': IndianRegion(
      name: 'North India',
      skinTones: ['wheatish', 'fair', 'light olive'],
      eyeShapes: ['almond', 'round'],
      noseShapes: ['straight', 'aquiline'],
      faceShapes: ['oval', 'heart'],
      culturalFeatures: ['bindi', 'traditional jewelry'],
    ),
    'south': IndianRegion(
      name: 'South India',
      skinTones: ['medium brown', 'deep caramel', 'wheatish'],
      eyeShapes: ['almond', 'large'],
      noseShapes: ['small', 'button'],
      faceShapes: ['oval', 'round'],
      culturalFeatures: ['bindi', 'flower garlands'],
    ),
    'east': IndianRegion(
      name: 'East India',
      skinTones: ['fair', 'wheatish', 'light brown'],
      eyeShapes: ['almond', 'upturned'],
      noseShapes: ['small', 'straight'],
      faceShapes: ['oval', 'heart'],
      culturalFeatures: ['bindi', 'traditional makeup'],
    ),
    'west': IndianRegion(
      name: 'West India',
      skinTones: ['wheatish', 'medium brown', 'olive'],
      eyeShapes: ['almond', 'large'],
      noseShapes: ['straight', 'button'],
      faceShapes: ['oval', 'square'],
      culturalFeatures: ['bindi', 'traditional attire'],
    ),
    'pan_india': IndianRegion(
      name: 'Pan-India',
      skinTones: ['wheatish', 'fair', 'medium brown', 'deep caramel', 'olive'],
      eyeShapes: ['almond', 'round', 'large'],
      noseShapes: ['straight', 'small', 'button', 'aquiline'],
      faceShapes: ['oval', 'heart', 'round', 'square'],
      culturalFeatures: ['bindi', 'traditional jewelry', 'flower garlands'],
    ),
  };

  /// Adapt facial features to Indian characteristics
  static IndianAdaptedFeatures adaptFeatures(
    FacialFeatures originalFeatures,
    String region,
    double adaptationStrength,
  ) {
    final indianRegion =
        _regions[region.toLowerCase()] ?? _regions['pan_india']!;
    // final random = math.Random();

    // Adapt skin tone
    final adaptedSkinTone = _adaptSkinTone(
      originalFeatures.skinTone,
      indianRegion.skinTones,
      adaptationStrength,
    );

    // Adapt eye shape
    final adaptedEyeShape = _adaptEyeShape(
      originalFeatures.eyeToFaceRatio,
      indianRegion.eyeShapes,
      adaptationStrength,
    );

    // Adapt nose shape
    final adaptedNoseShape = _adaptNoseShape(
      originalFeatures.faceRatio,
      indianRegion.noseShapes,
      adaptationStrength,
    );

    // Adapt face shape
    final adaptedFaceShape = _adaptFaceShape(
      originalFeatures.faceShape,
      indianRegion.faceShapes,
      adaptationStrength,
    );

    // Add cultural features
    final culturalFeatures = _addCulturalFeatures(
      indianRegion.culturalFeatures,
      adaptationStrength,
    );

    return IndianAdaptedFeatures(
      region: indianRegion.name,
      skinTone: adaptedSkinTone,
      eyeShape: adaptedEyeShape,
      noseShape: adaptedNoseShape,
      faceShape: adaptedFaceShape,
      culturalFeatures: culturalFeatures,
      adaptationStrength: adaptationStrength,
      originalFeatures: originalFeatures,
    );
  }

  /// Adapt skin tone to Indian characteristics
  static String _adaptSkinTone(
    String originalTone,
    List<String> indianTones,
    double strength,
  ) {
    if (strength < 0.1) return originalTone;

    // Map original tones to Indian equivalents
    final toneMapping = {
      'fair': 'fair',
      'light': 'wheatish',
      'medium': 'medium brown',
      'olive': 'olive',
      'tan': 'wheatish',
      'dark': 'deep caramel',
    };

    final mappedTone = toneMapping[originalTone.toLowerCase()] ?? 'wheatish';

    // Blend with random Indian tone based on strength
    if (strength > 0.5) {
      final random = math.Random();
      return indianTones[random.nextInt(indianTones.length)];
    }

    return mappedTone;
  }

  /// Adapt eye shape to Indian characteristics
  static String _adaptEyeShape(
    double eyeRatio,
    List<String> indianShapes,
    double strength,
  ) {
    if (strength < 0.1) return 'original';

    // Determine eye shape based on ratio
    String baseShape = 'almond';
    if (eyeRatio > 0.4) {
      baseShape = 'large';
    } else if (eyeRatio < 0.25) {
      baseShape = 'round';
    }

    // Blend with Indian characteristics
    if (strength > 0.7) {
      final random = math.Random();
      return indianShapes[random.nextInt(indianShapes.length)];
    }

    return baseShape;
  }

  /// Adapt nose shape to Indian characteristics
  static String _adaptNoseShape(
    double faceRatio,
    List<String> indianShapes,
    double strength,
  ) {
    if (strength < 0.1) return 'original';

    // Determine nose shape based on face ratio
    String baseShape = 'straight';
    if (faceRatio > 0.8) {
      baseShape = 'button';
    } else if (faceRatio < 0.7) {
      baseShape = 'small';
    }

    // Blend with Indian characteristics
    if (strength > 0.7) {
      final random = math.Random();
      return indianShapes[random.nextInt(indianShapes.length)];
    }

    return baseShape;
  }

  /// Adapt face shape to Indian characteristics
  static String _adaptFaceShape(
    String originalShape,
    List<String> indianShapes,
    double strength,
  ) {
    if (strength < 0.1) return originalShape;

    // Map original shapes to Indian equivalents
    final shapeMapping = {
      'oval': 'oval',
      'round': 'round',
      'square': 'square',
      'heart': 'heart',
      'long': 'oval',
    };

    final mappedShape = shapeMapping[originalShape.toLowerCase()] ?? 'oval';

    // Blend with random Indian shape based on strength
    if (strength > 0.5) {
      final random = math.Random();
      return indianShapes[random.nextInt(indianShapes.length)];
    }

    return mappedShape;
  }

  /// Add cultural features
  static List<String> _addCulturalFeatures(
    List<String> availableFeatures,
    double strength,
  ) {
    if (strength < 0.3) return [];

    final random = math.Random();
    final numFeatures = (strength * availableFeatures.length).round();
    final selectedFeatures = <String>[];

    for (int i = 0; i < numFeatures && i < availableFeatures.length; i++) {
      final feature =
          availableFeatures[random.nextInt(availableFeatures.length)];
      if (!selectedFeatures.contains(feature)) {
        selectedFeatures.add(feature);
      }
    }

    return selectedFeatures;
  }

  /// Generate Indian baby name based on region and features
  static List<String> generateIndianNames(
    String region,
    String gender,
    FacialFeatures features,
  ) {
    final indianRegion =
        _regions[region.toLowerCase()] ?? _regions['pan_india']!;
    final random = math.Random();

    final names = <String>[];

    if (gender.toLowerCase() == 'male') {
      final maleNames = _getMaleNames(indianRegion.name);
      for (int i = 0; i < 2; i++) {
        names.add(maleNames[random.nextInt(maleNames.length)]);
      }
    } else {
      final femaleNames = _getFemaleNames(indianRegion.name);
      for (int i = 0; i < 2; i++) {
        names.add(femaleNames[random.nextInt(femaleNames.length)]);
      }
    }

    return names;
  }

  /// Get male names for specific region
  static List<String> _getMaleNames(String region) {
    final nameMap = {
      'North India': ['Arjun', 'Rohan', 'Vikram', 'Rajesh', 'Amit', 'Suresh'],
      'South India': [
        'Krishna',
        'Ravi',
        'Suresh',
        'Kumar',
        'Prakash',
        'Venkat'
      ],
      'East India': [
        'Amit',
        'Sourav',
        'Debashish',
        'Pranab',
        'Suman',
        'Biswajit'
      ],
      'West India': ['Raj', 'Vikram', 'Amit', 'Suresh', 'Prakash', 'Kumar'],
      'Pan-India': ['Arjun', 'Rohan', 'Krishna', 'Amit', 'Raj', 'Vikram'],
    };

    return nameMap[region] ?? nameMap['Pan-India']!;
  }

  /// Get female names for specific region
  static List<String> _getFemaleNames(String region) {
    final nameMap = {
      'North India': ['Priya', 'Anita', 'Sunita', 'Kavita', 'Rita', 'Sita'],
      'South India': ['Lakshmi', 'Kavitha', 'Priya', 'Anita', 'Sunita', 'Rita'],
      'East India': ['Anita', 'Soma', 'Mita', 'Rita', 'Sita', 'Gita'],
      'West India': ['Priya', 'Anita', 'Sunita', 'Kavita', 'Rita', 'Sita'],
      'Pan-India': ['Priya', 'Anita', 'Sunita', 'Kavita', 'Rita', 'Sita'],
    };

    return nameMap[region] ?? nameMap['Pan-India']!;
  }
}

/// Indian region characteristics
class IndianRegion {
  final String name;
  final List<String> skinTones;
  final List<String> eyeShapes;
  final List<String> noseShapes;
  final List<String> faceShapes;
  final List<String> culturalFeatures;

  const IndianRegion({
    required this.name,
    required this.skinTones,
    required this.eyeShapes,
    required this.noseShapes,
    required this.faceShapes,
    required this.culturalFeatures,
  });
}

/// Indian-adapted facial features
class IndianAdaptedFeatures {
  final String region;
  final String skinTone;
  final String eyeShape;
  final String noseShape;
  final String faceShape;
  final List<String> culturalFeatures;
  final double adaptationStrength;
  final FacialFeatures originalFeatures;

  IndianAdaptedFeatures({
    required this.region,
    required this.skinTone,
    required this.eyeShape,
    required this.noseShape,
    required this.faceShape,
    required this.culturalFeatures,
    required this.adaptationStrength,
    required this.originalFeatures,
  });

  /// Get description of adapted features
  String get description {
    final features = [
      'Beautiful $skinTone complexion',
      'Stunning $eyeShape eyes',
      'Perfect $noseShape nose',
      'Lovely $faceShape face',
    ];

    if (culturalFeatures.isNotEmpty) {
      features.add('Traditional ${culturalFeatures.join(' and ')}');
    }

    return features.join(' with ');
  }

  /// Calculate cultural authenticity score
  double get authenticityScore {
    double score = 0.0;

    // Base score from adaptation strength
    score += adaptationStrength * 0.6;

    // Bonus for cultural features
    score += (culturalFeatures.length / 3.0) * 0.2;

    // Bonus for regional accuracy
    if (region != 'Pan-India') score += 0.2;

    return score.clamp(0.0, 1.0);
  }
}
