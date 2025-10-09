import 'hive_service.dart';
import 'dart:developer' as developer;
import 'firebase_service.dart';

/// Zodiac sign model
class ZodiacSign {
  final String name;
  final String symbol;
  final String emoji;
  final String element;
  final String quality;
  final String rulingPlanet;
  final List<int> dateRange;
  final String description;
  final List<String> traits;
  final List<String> compatibleSigns;
  final String color;

  ZodiacSign({
    required this.name,
    required this.symbol,
    required this.emoji,
    required this.element,
    required this.quality,
    required this.rulingPlanet,
    required this.dateRange,
    required this.description,
    required this.traits,
    required this.compatibleSigns,
    required this.color,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'symbol': symbol,
      'emoji': emoji,
      'element': element,
      'quality': quality,
      'rulingPlanet': rulingPlanet,
      'dateRange': dateRange,
      'description': description,
      'traits': traits,
      'compatibleSigns': compatibleSigns,
      'color': color,
    };
  }

  factory ZodiacSign.fromMap(Map<String, dynamic> map) {
    return ZodiacSign(
      name: map['name'] ?? '',
      symbol: map['symbol'] ?? '',
      emoji: map['emoji'] ?? '',
      element: map['element'] ?? '',
      quality: map['quality'] ?? '',
      rulingPlanet: map['rulingPlanet'] ?? '',
      dateRange: List<int>.from(map['dateRange'] ?? []),
      description: map['description'] ?? '',
      traits: List<String>.from(map['traits'] ?? []),
      compatibleSigns: List<String>.from(map['compatibleSigns'] ?? []),
      color: map['color'] ?? '',
    );
  }
}

/// Zodiac compatibility model
class ZodiacCompatibility {
  final String id;
  final String partner1Sign;
  final String partner2Sign;
  final int compatibilityScore;
  final String compatibilityLevel;
  final String description;
  final List<String> strengths;
  final List<String> challenges;
  final List<String> advice;
  final DateTime createdAt;
  final DateTime updatedAt;

  ZodiacCompatibility({
    required this.id,
    required this.partner1Sign,
    required this.partner2Sign,
    required this.compatibilityScore,
    required this.compatibilityLevel,
    required this.description,
    required this.strengths,
    required this.challenges,
    required this.advice,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'partner1Sign': partner1Sign,
      'partner2Sign': partner2Sign,
      'compatibilityScore': compatibilityScore,
      'compatibilityLevel': compatibilityLevel,
      'description': description,
      'strengths': strengths,
      'challenges': challenges,
      'advice': advice,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ZodiacCompatibility.fromMap(Map<String, dynamic> map) {
    return ZodiacCompatibility(
      id: map['id'] ?? '',
      partner1Sign: map['partner1Sign'] ?? '',
      partner2Sign: map['partner2Sign'] ?? '',
      compatibilityScore: map['compatibilityScore'] ?? 0,
      compatibilityLevel: map['compatibilityLevel'] ?? '',
      description: map['description'] ?? '',
      strengths: List<String>.from(map['strengths'] ?? []),
      challenges: List<String>.from(map['challenges'] ?? []),
      advice: List<String>.from(map['advice'] ?? []),
      createdAt:
          DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  ZodiacCompatibility copyWith({
    String? id,
    String? partner1Sign,
    String? partner2Sign,
    int? compatibilityScore,
    String? compatibilityLevel,
    String? description,
    List<String>? strengths,
    List<String>? challenges,
    List<String>? advice,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ZodiacCompatibility(
      id: id ?? this.id,
      partner1Sign: partner1Sign ?? this.partner1Sign,
      partner2Sign: partner2Sign ?? this.partner2Sign,
      compatibilityScore: compatibilityScore ?? this.compatibilityScore,
      compatibilityLevel: compatibilityLevel ?? this.compatibilityLevel,
      description: description ?? this.description,
      strengths: strengths ?? this.strengths,
      challenges: challenges ?? this.challenges,
      advice: advice ?? this.advice,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Zodiac compatibility service
class ZodiacCompatibilityService {
  static final ZodiacCompatibilityService _instance =
      ZodiacCompatibilityService._internal();
  factory ZodiacCompatibilityService() => _instance;
  ZodiacCompatibilityService._internal();

  final HiveService _hiveService = HiveService();
  final FirebaseService _firebaseService = FirebaseService();
  static const String _boxName = 'zodiac_compatibility_box';
  static const String _signsKey = 'zodiac_signs';
  static const String _compatibilityKey = 'zodiac_compatibility';

  /// Get zodiac compatibility service instance
  static ZodiacCompatibilityService get instance => _instance;

  /// Get all zodiac signs
  Future<List<ZodiacSign>> getAllZodiacSigns() async {
    try {
      await _hiveService.ensureBoxOpen(_boxName);
      final data = _hiveService.retrieve(_boxName, _signsKey);

      if (data != null) {
        return (data as List)
            .map((item) => ZodiacSign.fromMap(Map<String, dynamic>.from(item)))
            .toList();
      }

      // Return default zodiac signs if none exist
      return await _createDefaultZodiacSigns();
    } catch (e) {
      developer.log('❌ [ZodiacCompatibilityService] Error getting zodiac signs: $e');
      return await _createDefaultZodiacSigns();
    }
  }

  /// Get zodiac sign by name
  Future<ZodiacSign?> getZodiacSignByName(String name) async {
    try {
      final signs = await getAllZodiacSigns();
      return signs.firstWhere(
        (sign) => sign.name.toLowerCase() == name.toLowerCase(),
        orElse: () => signs.first,
      );
    } catch (e) {
      developer.log(
          '❌ [ZodiacCompatibilityService] Error getting zodiac sign by name: $e');
      return null;
    }
  }

  /// Get zodiac sign by date
  Future<ZodiacSign?> getZodiacSignByDate(DateTime date) async {
    try {
      final signs = await getAllZodiacSigns();
      final month = date.month;
      final day = date.day;

      for (final sign in signs) {
        if (sign.dateRange.length >= 4) {
          final startMonth = sign.dateRange[0];
          final startDay = sign.dateRange[1];
          final endMonth = sign.dateRange[2];
          final endDay = sign.dateRange[3];

          if ((month == startMonth && day >= startDay) ||
              (month == endMonth && day <= endDay) ||
              (startMonth > endMonth &&
                  (month > startMonth || month < endMonth))) {
            return sign;
          }
        }
      }

      return signs.first;
    } catch (e) {
      developer.log(
          '❌ [ZodiacCompatibilityService] Error getting zodiac sign by date: $e');
      return null;
    }
  }

  /// Calculate compatibility between two zodiac signs
  Future<ZodiacCompatibility> calculateCompatibility(
      String sign1, String sign2) async {
    try {
      final signs = await getAllZodiacSigns();
      final zodiac1 =
          signs.firstWhere((s) => s.name.toLowerCase() == sign1.toLowerCase());
      final zodiac2 =
          signs.firstWhere((s) => s.name.toLowerCase() == sign2.toLowerCase());

      // Calculate compatibility score based on various factors
      int score = 0;

      // Element compatibility
      if (zodiac1.element == zodiac2.element) {
        score += 30; // Same element
      } else if (_areElementsCompatible(zodiac1.element, zodiac2.element)) {
        score += 20; // Compatible elements
      } else {
        score += 10; // Incompatible elements
      }

      // Quality compatibility
      if (zodiac1.quality == zodiac2.quality) {
        score += 25; // Same quality
      } else if (_areQualitiesCompatible(zodiac1.quality, zodiac2.quality)) {
        score += 15; // Compatible qualities
      } else {
        score += 5; // Incompatible qualities
      }

      // Ruling planet compatibility
      if (zodiac1.rulingPlanet == zodiac2.rulingPlanet) {
        score += 20; // Same ruling planet
      } else if (_arePlanetsCompatible(
          zodiac1.rulingPlanet, zodiac2.rulingPlanet)) {
        score += 15; // Compatible planets
      } else {
        score += 5; // Incompatible planets
      }

      // Trait compatibility
      final commonTraits = zodiac1.traits
          .where((trait) => zodiac2.traits.contains(trait))
          .length;
      score += (commonTraits * 5).clamp(0, 25);

      // Ensure score is between 0 and 100
      score = score.clamp(0, 100);

      // Determine compatibility level
      String level;
      if (score >= 80) {
        level = 'Excellent';
      } else if (score >= 60) {
        level = 'Good';
      } else if (score >= 40) {
        level = 'Moderate';
      } else {
        level = 'Challenging';
      }

      // Generate compatibility details
      final compatibility = ZodiacCompatibility(
        id: 'compatibility_${DateTime.now().millisecondsSinceEpoch}',
        partner1Sign: sign1,
        partner2Sign: sign2,
        compatibilityScore: score,
        compatibilityLevel: level,
        description: _generateCompatibilityDescription(sign1, sign2, level),
        strengths: _generateStrengths(zodiac1, zodiac2),
        challenges: _generateChallenges(zodiac1, zodiac2),
        advice: _generateAdvice(zodiac1, zodiac2, level),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save compatibility result
      await _saveCompatibility(compatibility);

      return compatibility;
    } catch (e) {
      developer.log(
          '❌ [ZodiacCompatibilityService] Error calculating compatibility: $e');
      return ZodiacCompatibility(
        id: 'error_${DateTime.now().millisecondsSinceEpoch}',
        partner1Sign: sign1,
        partner2Sign: sign2,
        compatibilityScore: 50,
        compatibilityLevel: 'Unknown',
        description: 'Unable to calculate compatibility at this time.',
        strengths: [],
        challenges: [],
        advice: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  /// Get compatibility history
  Future<List<ZodiacCompatibility>> getCompatibilityHistory() async {
    try {
      await _hiveService.ensureBoxOpen(_boxName);
      final data = _hiveService.retrieve(_boxName, _compatibilityKey);

      if (data != null) {
        return (data as List)
            .map((item) =>
                ZodiacCompatibility.fromMap(Map<String, dynamic>.from(item)))
            .toList();
      }

      return [];
    } catch (e) {
      developer.log(
          '❌ [ZodiacCompatibilityService] Error getting compatibility history: $e');
      return [];
    }
  }

  /// Save compatibility result
  Future<void> _saveCompatibility(ZodiacCompatibility compatibility) async {
    try {
      final history = await getCompatibilityHistory();
      history.add(compatibility);

      await _hiveService.store(
          _boxName, _compatibilityKey, history.map((c) => c.toMap()).toList());

      // Sync to Firebase
      await _saveCompatibilityToFirebase(compatibility);
    } catch (e) {
      developer.log('❌ [ZodiacCompatibilityService] Error saving compatibility: $e');
    }
  }

  /// Check if elements are compatible
  bool _areElementsCompatible(String element1, String element2) {
    final compatibleElements = {
      'Fire': ['Air'],
      'Air': ['Fire'],
      'Water': ['Earth'],
      'Earth': ['Water'],
    };

    return compatibleElements[element1]?.contains(element2) ?? false;
  }

  /// Check if qualities are compatible
  bool _areQualitiesCompatible(String quality1, String quality2) {
    final compatibleQualities = {
      'Cardinal': ['Fixed', 'Mutable'],
      'Fixed': ['Cardinal', 'Mutable'],
      'Mutable': ['Cardinal', 'Fixed'],
    };

    return compatibleQualities[quality1]?.contains(quality2) ?? false;
  }

  /// Check if planets are compatible
  bool _arePlanetsCompatible(String planet1, String planet2) {
    final compatiblePlanets = {
      'Sun': ['Moon', 'Venus'],
      'Moon': ['Sun', 'Venus'],
      'Venus': ['Sun', 'Moon'],
      'Mars': ['Jupiter', 'Saturn'],
      'Jupiter': ['Mars', 'Saturn'],
      'Saturn': ['Mars', 'Jupiter'],
    };

    return compatiblePlanets[planet1]?.contains(planet2) ?? false;
  }

  /// Generate compatibility description
  String _generateCompatibilityDescription(
      String sign1, String sign2, String level) {
    switch (level) {
      case 'Excellent':
        return '$sign1 and $sign2 have an excellent astrological compatibility. Your signs complement each other perfectly, creating a harmonious and fulfilling relationship.';
      case 'Good':
        return '$sign1 and $sign2 have good astrological compatibility. While you may have some differences, your signs work well together and can create a strong bond.';
      case 'Moderate':
        return '$sign1 and $sign2 have moderate astrological compatibility. You may face some challenges, but with understanding and effort, you can build a meaningful relationship.';
      case 'Challenging':
        return '$sign1 and $sign2 have challenging astrological compatibility. Your signs may clash at times, but this can also create exciting dynamics and growth opportunities.';
      default:
        return '$sign1 and $sign2 have a unique astrological compatibility that requires exploration and understanding.';
    }
  }

  /// Generate strengths
  List<String> _generateStrengths(ZodiacSign sign1, ZodiacSign sign2) {
    final strengths = <String>[];

    if (sign1.element == sign2.element) {
      strengths.add('Shared elemental energy creates deep understanding');
    }

    if (sign1.quality == sign2.quality) {
      strengths.add('Similar approach to life and relationships');
    }

    final commonTraits =
        sign1.traits.where((trait) => sign2.traits.contains(trait)).toList();
    if (commonTraits.isNotEmpty) {
      strengths.add('Shared personality traits: ${commonTraits.join(', ')}');
    }

    if (sign1.rulingPlanet == sign2.rulingPlanet) {
      strengths.add('Same ruling planet creates natural harmony');
    }

    return strengths;
  }

  /// Generate challenges
  List<String> _generateChallenges(ZodiacSign sign1, ZodiacSign sign2) {
    final challenges = <String>[];

    if (sign1.element != sign2.element &&
        !_areElementsCompatible(sign1.element, sign2.element)) {
      challenges
          .add('Different elemental energies may cause misunderstandings');
    }

    if (sign1.quality != sign2.quality &&
        !_areQualitiesCompatible(sign1.quality, sign2.quality)) {
      challenges.add('Different approaches to life may create friction');
    }

    final conflictingTraits =
        sign1.traits.where((trait) => !sign2.traits.contains(trait)).toList();
    if (conflictingTraits.isNotEmpty) {
      challenges.add('Different personality traits may require compromise');
    }

    return challenges;
  }

  /// Generate advice
  List<String> _generateAdvice(
      ZodiacSign sign1, ZodiacSign sign2, String level) {
    final advice = <String>[];

    switch (level) {
      case 'Excellent':
        advice.add('Enjoy your natural harmony and continue to grow together');
        advice.add('Use your compatibility to help other couples');
        break;
      case 'Good':
        advice.add('Focus on your shared strengths and build on them');
        advice.add('Communicate openly about any differences');
        break;
      case 'Moderate':
        advice.add('Be patient with each other and celebrate small victories');
        advice.add('Seek to understand each other\'s perspectives');
        break;
      case 'Challenging':
        advice.add('Embrace the challenge as an opportunity for growth');
        advice.add('Focus on compromise and finding common ground');
        break;
    }

    advice.add('Remember that astrology is just one factor in relationships');
    advice
        .add('Love, communication, and effort are the most important elements');

    return advice;
  }

  /// Create default zodiac signs
  Future<List<ZodiacSign>> _createDefaultZodiacSigns() async {
    final signs = [
      ZodiacSign(
        name: 'Aries',
        symbol: '♈',
        emoji: '🐏',
        element: 'Fire',
        quality: 'Cardinal',
        rulingPlanet: 'Mars',
        dateRange: [3, 21, 4, 19],
        description: 'Bold, energetic, and pioneering',
        traits: ['Bold', 'Energetic', 'Pioneering', 'Impulsive', 'Courageous'],
        compatibleSigns: ['Leo', 'Sagittarius', 'Gemini', 'Aquarius'],
        color: '#FF6B6B',
      ),
      ZodiacSign(
        name: 'Taurus',
        symbol: '♉',
        emoji: '🐂',
        element: 'Earth',
        quality: 'Fixed',
        rulingPlanet: 'Venus',
        dateRange: [4, 20, 5, 20],
        description: 'Reliable, practical, and sensual',
        traits: ['Reliable', 'Practical', 'Sensual', 'Stubborn', 'Loyal'],
        compatibleSigns: ['Virgo', 'Capricorn', 'Cancer', 'Pisces'],
        color: '#4ECDC4',
      ),
      ZodiacSign(
        name: 'Gemini',
        symbol: '♊',
        emoji: '👥',
        element: 'Air',
        quality: 'Mutable',
        rulingPlanet: 'Mercury',
        dateRange: [5, 21, 6, 20],
        description: 'Curious, adaptable, and communicative',
        traits: [
          'Curious',
          'Adaptable',
          'Communicative',
          'Restless',
          'Versatile'
        ],
        compatibleSigns: ['Libra', 'Aquarius', 'Aries', 'Leo'],
        color: '#45B7D1',
      ),
      ZodiacSign(
        name: 'Cancer',
        symbol: '♋',
        emoji: '🦀',
        element: 'Water',
        quality: 'Cardinal',
        rulingPlanet: 'Moon',
        dateRange: [6, 21, 7, 22],
        description: 'Nurturing, intuitive, and protective',
        traits: ['Nurturing', 'Intuitive', 'Protective', 'Moody', 'Caring'],
        compatibleSigns: ['Scorpio', 'Pisces', 'Taurus', 'Virgo'],
        color: '#96CEB4',
      ),
      ZodiacSign(
        name: 'Leo',
        symbol: '♌',
        emoji: '🦁',
        element: 'Fire',
        quality: 'Fixed',
        rulingPlanet: 'Sun',
        dateRange: [7, 23, 8, 22],
        description: 'Confident, generous, and dramatic',
        traits: ['Confident', 'Generous', 'Dramatic', 'Proud', 'Creative'],
        compatibleSigns: ['Aries', 'Sagittarius', 'Gemini', 'Libra'],
        color: '#FFEAA7',
      ),
      ZodiacSign(
        name: 'Virgo',
        symbol: '♍',
        emoji: '👩',
        element: 'Earth',
        quality: 'Mutable',
        rulingPlanet: 'Mercury',
        dateRange: [8, 23, 9, 22],
        description: 'Analytical, practical, and perfectionist',
        traits: [
          'Analytical',
          'Practical',
          'Perfectionist',
          'Critical',
          'Helpful'
        ],
        compatibleSigns: ['Taurus', 'Capricorn', 'Cancer', 'Scorpio'],
        color: '#DDA0DD',
      ),
      ZodiacSign(
        name: 'Libra',
        symbol: '♎',
        emoji: '⚖️',
        element: 'Air',
        quality: 'Cardinal',
        rulingPlanet: 'Venus',
        dateRange: [9, 23, 10, 22],
        description: 'Diplomatic, charming, and balanced',
        traits: ['Diplomatic', 'Charming', 'Balanced', 'Indecisive', 'Fair'],
        compatibleSigns: ['Gemini', 'Aquarius', 'Leo', 'Sagittarius'],
        color: '#98D8C8',
      ),
      ZodiacSign(
        name: 'Scorpio',
        symbol: '♏',
        emoji: '🦂',
        element: 'Water',
        quality: 'Fixed',
        rulingPlanet: 'Pluto',
        dateRange: [10, 23, 11, 21],
        description: 'Intense, passionate, and mysterious',
        traits: [
          'Intense',
          'Passionate',
          'Mysterious',
          'Jealous',
          'Transformative'
        ],
        compatibleSigns: ['Cancer', 'Pisces', 'Virgo', 'Capricorn'],
        color: '#F7DC6F',
      ),
      ZodiacSign(
        name: 'Sagittarius',
        symbol: '♐',
        emoji: '🏹',
        element: 'Fire',
        quality: 'Mutable',
        rulingPlanet: 'Jupiter',
        dateRange: [11, 22, 12, 21],
        description: 'Adventurous, optimistic, and philosophical',
        traits: [
          'Adventurous',
          'Optimistic',
          'Philosophical',
          'Restless',
          'Honest'
        ],
        compatibleSigns: ['Aries', 'Leo', 'Libra', 'Aquarius'],
        color: '#BB8FCE',
      ),
      ZodiacSign(
        name: 'Capricorn',
        symbol: '♑',
        emoji: '🐐',
        element: 'Earth',
        quality: 'Cardinal',
        rulingPlanet: 'Saturn',
        dateRange: [12, 22, 1, 19],
        description: 'Ambitious, disciplined, and responsible',
        traits: [
          'Ambitious',
          'Disciplined',
          'Responsible',
          'Pessimistic',
          'Practical'
        ],
        compatibleSigns: ['Taurus', 'Virgo', 'Scorpio', 'Pisces'],
        color: '#85C1E9',
      ),
      ZodiacSign(
        name: 'Aquarius',
        symbol: '♒',
        emoji: '💧',
        element: 'Air',
        quality: 'Fixed',
        rulingPlanet: 'Uranus',
        dateRange: [1, 20, 2, 18],
        description: 'Independent, innovative, and humanitarian',
        traits: [
          'Independent',
          'Innovative',
          'Humanitarian',
          'Detached',
          'Original'
        ],
        compatibleSigns: ['Gemini', 'Libra', 'Aries', 'Sagittarius'],
        color: '#F8C471',
      ),
      ZodiacSign(
        name: 'Pisces',
        symbol: '♓',
        emoji: '🐠',
        element: 'Water',
        quality: 'Mutable',
        rulingPlanet: 'Neptune',
        dateRange: [2, 19, 3, 20],
        description: 'Compassionate, intuitive, and artistic',
        traits: [
          'Compassionate',
          'Intuitive',
          'Artistic',
          'Escapist',
          'Empathetic'
        ],
        compatibleSigns: ['Cancer', 'Scorpio', 'Taurus', 'Capricorn'],
        color: '#82E0AA',
      ),
    ];

    // Save default signs
    await _hiveService.ensureBoxOpen(_boxName);
    await _hiveService.store(
        _boxName, _signsKey, signs.map((s) => s.toMap()).toList());

    return signs;
  }

  /// Save compatibility to Firebase
  Future<void> _saveCompatibilityToFirebase(
      ZodiacCompatibility compatibility) async {
    try {
      await _firebaseService.saveToFirestore(
        collection: 'zodiac_compatibility',
        documentId: compatibility.id,
        data: compatibility.toMap(),
      );
    } catch (e) {
      developer.log(
          '❌ [ZodiacCompatibilityService] Error saving compatibility to Firebase: $e');
    }
  }

  /// Clear all data
  Future<void> clearAllData() async {
    try {
      await _hiveService.ensureBoxOpen(_boxName);
      await _hiveService.delete(_boxName, _signsKey);
      await _hiveService.delete(_boxName, _compatibilityKey);
      developer.log('✅ [ZodiacCompatibilityService] All data cleared');
    } catch (e) {
      developer.log('❌ [ZodiacCompatibilityService] Error clearing data: $e');
    }
  }
}
