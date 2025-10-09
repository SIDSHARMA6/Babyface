import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:image/image.dart' as img;
import '../../data/models/memory_model.dart';

/// Emotion Analysis Service
/// Analyzes photos and memories for emotional content and provides dynamic theming
class EmotionAnalyzer {
  static final EmotionAnalyzer _instance = EmotionAnalyzer._internal();
  factory EmotionAnalyzer() => _instance;
  EmotionAnalyzer._internal();

  /// Analyze memory for emotional content
  Future<EmotionAnalysis> analyzeMemory(MemoryModel memory) async {
    final analysis = EmotionAnalysis(
      memoryId: memory.id,
      dominantEmotion: _analyzeTextEmotion(memory.title, memory.description),
      colorAnalysis: await _analyzePhotoColors(memory.photoPath),
      moodScore: _calculateMoodScore(memory),
      suggestedTheme: _suggestTheme(memory),
      emotionalKeywords: _extractEmotionalKeywords(memory),
    );

    return analysis;
  }

  /// Analyze multiple memories for journey-level emotions
  Future<JourneyEmotionAnalysis> analyzeJourney(
      List<MemoryModel> memories) async {
    final individualAnalyses = <EmotionAnalysis>[];

    for (final memory in memories) {
      final analysis = await analyzeMemory(memory);
      individualAnalyses.add(analysis);
    }

    return JourneyEmotionAnalysis(
      overallMood: _calculateOverallMood(individualAnalyses),
      dominantEmotion: _findDominantEmotion(individualAnalyses),
      emotionalJourney: _mapEmotionalJourney(individualAnalyses),
      suggestedThemes: _suggestJourneyThemes(individualAnalyses),
      moodProgression: _calculateMoodProgression(individualAnalyses),
    );
  }

  /// Analyze text for emotional content
  EmotionType _analyzeTextEmotion(String title, String description) {
    final text = '${title.toLowerCase()} ${description.toLowerCase()}';

    // Simple keyword-based emotion detection
    final joyKeywords = [
      'happy',
      'joy',
      'excited',
      'amazing',
      'wonderful',
      'love',
      'loved',
      'beautiful',
      'perfect',
      'fantastic'
    ];
    final sadnessKeywords = [
      'sad',
      'cry',
      'miss',
      'hurt',
      'pain',
      'difficult',
      'hard',
      'struggle',
      'loss'
    ];
    final angerKeywords = [
      'angry',
      'mad',
      'frustrated',
      'annoyed',
      'upset',
      'furious'
    ];
    final fearKeywords = [
      'scared',
      'afraid',
      'worried',
      'anxious',
      'nervous',
      'fear'
    ];
    final surpriseKeywords = [
      'surprised',
      'shocked',
      'amazed',
      'wow',
      'incredible',
      'unexpected'
    ];
    final loveKeywords = [
      'love',
      'romantic',
      'heart',
      'kiss',
      'hug',
      'together',
      'forever',
      'soulmate'
    ];

    final joyScore = _countKeywords(text, joyKeywords);
    final sadnessScore = _countKeywords(text, sadnessKeywords);
    final angerScore = _countKeywords(text, angerKeywords);
    final fearScore = _countKeywords(text, fearKeywords);
    final surpriseScore = _countKeywords(text, surpriseKeywords);
    final loveScore = _countKeywords(text, loveKeywords);

    final scores = {
      EmotionType.joy: joyScore,
      EmotionType.sadness: sadnessScore,
      EmotionType.anger: angerScore,
      EmotionType.fear: fearScore,
      EmotionType.surprise: surpriseScore,
      EmotionType.love: loveScore,
    };

    return scores.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  /// Count keyword occurrences in text
  int _countKeywords(String text, List<String> keywords) {
    int count = 0;
    for (final keyword in keywords) {
      count += text.split(keyword).length - 1;
    }
    return count;
  }

  /// Analyze photo colors for emotional content
  Future<ColorAnalysis> _analyzePhotoColors(String? photoPath) async {
    if (photoPath == null) {
      return ColorAnalysis(
        dominantColors: [Colors.grey],
        brightness: 0.5,
        saturation: 0.5,
        warmth: 0.5,
        emotionalTone: EmotionType.neutral,
      );
    }

    try {
      final file = File(photoPath);
      if (!await file.exists()) {
        return ColorAnalysis(
          dominantColors: [Colors.grey],
          brightness: 0.5,
          saturation: 0.5,
          warmth: 0.5,
          emotionalTone: EmotionType.neutral,
        );
      }

      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        return ColorAnalysis(
          dominantColors: [Colors.grey],
          brightness: 0.5,
          saturation: 0.5,
          warmth: 0.5,
          emotionalTone: EmotionType.neutral,
        );
      }

      return _analyzeImageColors(image);
    } catch (e) {
      developer.log('Error analyzing photo colors: $e');
      return ColorAnalysis(
        dominantColors: [Colors.grey],
        brightness: 0.5,
        saturation: 0.5,
        warmth: 0.5,
        emotionalTone: EmotionType.neutral,
      );
    }
  }

  /// Analyze image colors
  ColorAnalysis _analyzeImageColors(img.Image image) {
    final colors = <Color>[];
    int totalBrightness = 0;
    int totalSaturation = 0;
    int totalWarmth = 0;
    int pixelCount = 0;

    // Sample pixels for analysis
    for (int y = 0; y < image.height; y += 10) {
      for (int x = 0; x < image.width; x += 10) {
        final pixel = image.getPixel(x, y);
        final r = img.getRed(pixel);
        final g = img.getGreen(pixel);
        final b = img.getBlue(pixel);

        final color = Color.fromRGBO(r, g, b, 1.0);
        colors.add(color);

        // Calculate brightness (0-1)
        final brightness = (r + g + b) / (3 * 255);
        totalBrightness += (brightness * 100).round();

        // Calculate saturation (simplified)
        final max = [r, g, b].reduce((a, b) => a > b ? a : b);
        final min = [r, g, b].reduce((a, b) => a < b ? a : b);
        final saturation = max == 0 ? 0 : (max - min) / max;
        totalSaturation += (saturation * 100).round();

        // Calculate warmth (red vs blue)
        final warmth = (r - b) / 255;
        totalWarmth += ((warmth + 1) / 2 * 100).round();

        pixelCount++;
      }
    }

    final avgBrightness = totalBrightness / pixelCount / 100;
    final avgSaturation = totalSaturation / pixelCount / 100;
    final avgWarmth = totalWarmth / pixelCount / 100;

    // Get dominant colors
    final dominantColors = _getDominantColors(colors);

    // Determine emotional tone based on colors
    final emotionalTone =
        _determineEmotionalTone(avgBrightness, avgSaturation, avgWarmth);

    return ColorAnalysis(
      dominantColors: dominantColors,
      brightness: avgBrightness,
      saturation: avgSaturation,
      warmth: avgWarmth,
      emotionalTone: emotionalTone,
    );
  }

  /// Get dominant colors from a list
  List<Color> _getDominantColors(List<Color> colors) {
    // Simple color clustering - in a real implementation, you'd use more sophisticated algorithms
    final colorMap = <String, int>{};

    for (final color in colors) {
      // Quantize colors to reduce noise
      final quantized = Color.fromRGBO(
        (color.red ~/ 32) * 32,
        (color.green ~/ 32) * 32,
        (color.blue ~/ 32) * 32,
        1.0,
      );
      final key = '${quantized.red},${quantized.green},${quantized.blue}';
      colorMap[key] = (colorMap[key] ?? 0) + 1;
    }

    final sortedColors = colorMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedColors.take(5).map((entry) {
      final parts = entry.key.split(',');
      return Color.fromRGBO(
          int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]), 1.0);
    }).toList();
  }

  /// Determine emotional tone from color analysis
  EmotionType _determineEmotionalTone(
      double brightness, double saturation, double warmth) {
    if (brightness > 0.7 && saturation > 0.6) {
      return warmth > 0.6 ? EmotionType.joy : EmotionType.surprise;
    } else if (brightness < 0.4) {
      return warmth > 0.5 ? EmotionType.sadness : EmotionType.fear;
    } else if (saturation > 0.8 && warmth > 0.7) {
      return EmotionType.love;
    } else if (saturation < 0.3) {
      return EmotionType.sadness;
    } else {
      return EmotionType.neutral;
    }
  }

  /// Calculate mood score for a memory
  double _calculateMoodScore(MemoryModel memory) {
    double score = 0.5; // Base neutral score

    // Convert string mood to enum and adjust score
    final mood = MemoryMood.fromString(memory.mood);
    switch (mood) {
      case MemoryMood.joyful:
        score += 0.3;
        break;
      case MemoryMood.romantic:
        score += 0.4;
        break;
      case MemoryMood.fun:
        score += 0.2;
        break;
      case MemoryMood.sweet:
        score += 0.3;
        break;
      case MemoryMood.emotional:
        score += 0.1;
        break;
      case MemoryMood.excited:
        score += 0.2;
        break;
    }

    // Adjust based on favorite status
    if (memory.isFavorite) {
      score += 0.2;
    }

    return score.clamp(0.0, 1.0);
  }

  /// Suggest theme based on memory analysis
  String _suggestTheme(MemoryModel memory) {
    final moodScore = _calculateMoodScore(memory);

    if (moodScore > 0.8) {
      return 'romantic-sunset';
    } else if (moodScore > 0.6) {
      return 'love-garden';
    } else {
      return 'midnight-romance';
    }
  }

  /// Extract emotional keywords from memory
  List<String> _extractEmotionalKeywords(MemoryModel memory) {
    final text = '${memory.title} ${memory.description}';
    final keywords = <String>[];

    final emotionKeywords = {
      'joy': [
        'happy',
        'joy',
        'excited',
        'amazing',
        'wonderful',
        'love',
        'beautiful',
        'perfect'
      ],
      'romance': [
        'love',
        'romantic',
        'heart',
        'kiss',
        'hug',
        'together',
        'forever'
      ],
      'adventure': [
        'adventure',
        'explore',
        'discover',
        'journey',
        'travel',
        'new'
      ],
      'peace': ['calm', 'peaceful', 'quiet', 'serene', 'tranquil', 'relaxed'],
    };

    for (final category in emotionKeywords.entries) {
      for (final keyword in category.value) {
        if (text.toLowerCase().contains(keyword)) {
          keywords.add(category.key);
        }
      }
    }

    return keywords.toSet().toList();
  }

  /// Calculate overall mood for journey
  double _calculateOverallMood(List<EmotionAnalysis> analyses) {
    if (analyses.isEmpty) return 0.5;

    final totalScore =
        analyses.fold<double>(0.0, (sum, analysis) => sum + analysis.moodScore);
    return totalScore / analyses.length;
  }

  /// Find dominant emotion across all memories
  EmotionType _findDominantEmotion(List<EmotionAnalysis> analyses) {
    if (analyses.isEmpty) return EmotionType.neutral;

    final emotionCounts = <EmotionType, int>{};
    for (final analysis in analyses) {
      emotionCounts[analysis.dominantEmotion] =
          (emotionCounts[analysis.dominantEmotion] ?? 0) + 1;
    }

    return emotionCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Map emotional journey over time
  List<EmotionPoint> _mapEmotionalJourney(List<EmotionAnalysis> analyses) {
    return analyses.asMap().entries.map((entry) {
      final index = entry.key;
      final analysis = entry.value;
      return EmotionPoint(
        index: index,
        emotion: analysis.dominantEmotion,
        intensity: analysis.moodScore,
        timestamp: DateTime.now().add(Duration(days: index)),
      );
    }).toList();
  }

  /// Suggest themes for the entire journey
  List<String> _suggestJourneyThemes(List<EmotionAnalysis> analyses) {
    final themeScores = <String, double>{};

    for (final analysis in analyses) {
      final theme = analysis.suggestedTheme;
      themeScores[theme] = (themeScores[theme] ?? 0.0) + analysis.moodScore;
    }

    final sortedThemes = themeScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedThemes.map((entry) => entry.key).toList();
  }

  /// Calculate mood progression over time
  List<double> _calculateMoodProgression(List<EmotionAnalysis> analyses) {
    return analyses.map((analysis) => analysis.moodScore).toList();
  }

  /// Get dynamic theme based on current emotion
  String getDynamicTheme(EmotionType emotion, double intensity) {
    switch (emotion) {
      case EmotionType.joy:
        return intensity > 0.7 ? 'romantic-sunset' : 'love-garden';
      case EmotionType.love:
        return 'romantic-sunset';
      case EmotionType.sadness:
        return 'midnight-romance';
      case EmotionType.surprise:
        return 'love-garden';
      case EmotionType.anger:
      case EmotionType.fear:
        return 'midnight-romance';
      case EmotionType.neutral:
      default:
        return 'love-garden';
    }
  }

  /// Get emotion-based color palette
  Map<String, Color> getEmotionColors(EmotionType emotion) {
    switch (emotion) {
      case EmotionType.joy:
        return {
          'primary': Colors.orange,
          'secondary': Colors.yellow,
          'accent': Colors.amber,
        };
      case EmotionType.love:
        return {
          'primary': Colors.pink,
          'secondary': Colors.red,
          'accent': Colors.purple,
        };
      case EmotionType.sadness:
        return {
          'primary': Colors.blue,
          'secondary': Colors.indigo,
          'accent': Colors.grey,
        };
      case EmotionType.surprise:
        return {
          'primary': Colors.purple,
          'secondary': Colors.cyan,
          'accent': Colors.teal,
        };
      case EmotionType.anger:
        return {
          'primary': Colors.red,
          'secondary': Colors.orange,
          'accent': Colors.brown,
        };
      case EmotionType.fear:
        return {
          'primary': Colors.grey,
          'secondary': Colors.black,
          'accent': Colors.blueGrey,
        };
      case EmotionType.neutral:
      default:
        return {
          'primary': Colors.grey,
          'secondary': Colors.blueGrey,
          'accent': Colors.grey,
        };
    }
  }
}

/// Emotion types
enum EmotionType {
  joy,
  sadness,
  anger,
  fear,
  surprise,
  love,
  neutral,
}

/// Emotion analysis result
class EmotionAnalysis {
  final String memoryId;
  final EmotionType dominantEmotion;
  final ColorAnalysis colorAnalysis;
  final double moodScore;
  final String suggestedTheme;
  final List<String> emotionalKeywords;

  EmotionAnalysis({
    required this.memoryId,
    required this.dominantEmotion,
    required this.colorAnalysis,
    required this.moodScore,
    required this.suggestedTheme,
    required this.emotionalKeywords,
  });
}

/// Color analysis result
class ColorAnalysis {
  final List<Color> dominantColors;
  final double brightness;
  final double saturation;
  final double warmth;
  final EmotionType emotionalTone;

  ColorAnalysis({
    required this.dominantColors,
    required this.brightness,
    required this.saturation,
    required this.warmth,
    required this.emotionalTone,
  });
}

/// Journey-level emotion analysis
class JourneyEmotionAnalysis {
  final double overallMood;
  final EmotionType dominantEmotion;
  final List<EmotionPoint> emotionalJourney;
  final List<String> suggestedThemes;
  final List<double> moodProgression;

  JourneyEmotionAnalysis({
    required this.overallMood,
    required this.dominantEmotion,
    required this.emotionalJourney,
    required this.suggestedThemes,
    required this.moodProgression,
  });
}

/// Emotion point in time
class EmotionPoint {
  final int index;
  final EmotionType emotion;
  final double intensity;
  final DateTime timestamp;

  EmotionPoint({
    required this.index,
    required this.emotion,
    required this.intensity,
    required this.timestamp,
  });
}
