import 'hive_service.dart';
import 'dart:developer' as developer;
import 'firebase_service.dart';

/// AI mood analysis model
class MoodAnalysis {
  final String id;
  final DateTime date;
  final String overallMood;
  final double moodScore;
  final List<String> dominantEmotions;
  final List<String> moodTriggers;
  final String analysis;
  final List<String> suggestions;
  final String partnerInsight;
  final DateTime createdAt;
  final DateTime updatedAt;

  MoodAnalysis({
    required this.id,
    required this.date,
    required this.overallMood,
    required this.moodScore,
    required this.dominantEmotions,
    required this.moodTriggers,
    required this.analysis,
    required this.suggestions,
    required this.partnerInsight,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'overallMood': overallMood,
      'moodScore': moodScore,
      'dominantEmotions': dominantEmotions,
      'moodTriggers': moodTriggers,
      'analysis': analysis,
      'suggestions': suggestions,
      'partnerInsight': partnerInsight,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory MoodAnalysis.fromMap(Map<String, dynamic> map) {
    return MoodAnalysis(
      id: map['id'] ?? '',
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      overallMood: map['overallMood'] ?? '',
      moodScore: map['moodScore']?.toDouble() ?? 0.0,
      dominantEmotions: List<String>.from(map['dominantEmotions'] ?? []),
      moodTriggers: List<String>.from(map['moodTriggers'] ?? []),
      analysis: map['analysis'] ?? '',
      suggestions: List<String>.from(map['suggestions'] ?? []),
      partnerInsight: map['partnerInsight'] ?? '',
      createdAt:
          DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

/// Weekly recap model
class WeeklyRecap {
  final String id;
  final DateTime weekStart;
  final DateTime weekEnd;
  final double averageMoodScore;
  final String overallMoodTrend;
  final List<String> topEmotions;
  final List<String> moodHighlights;
  final List<String> challenges;
  final List<String> achievements;
  final String relationshipInsight;
  final List<String> recommendations;
  final String personalizedMessage;
  final DateTime createdAt;
  final DateTime updatedAt;

  WeeklyRecap({
    required this.id,
    required this.weekStart,
    required this.weekEnd,
    required this.averageMoodScore,
    required this.overallMoodTrend,
    required this.topEmotions,
    required this.moodHighlights,
    required this.challenges,
    required this.achievements,
    required this.relationshipInsight,
    required this.recommendations,
    required this.personalizedMessage,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'weekStart': weekStart.toIso8601String(),
      'weekEnd': weekEnd.toIso8601String(),
      'averageMoodScore': averageMoodScore,
      'overallMoodTrend': overallMoodTrend,
      'topEmotions': topEmotions,
      'moodHighlights': moodHighlights,
      'challenges': challenges,
      'achievements': achievements,
      'relationshipInsight': relationshipInsight,
      'recommendations': recommendations,
      'personalizedMessage': personalizedMessage,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory WeeklyRecap.fromMap(Map<String, dynamic> map) {
    return WeeklyRecap(
      id: map['id'] ?? '',
      weekStart:
          DateTime.parse(map['weekStart'] ?? DateTime.now().toIso8601String()),
      weekEnd:
          DateTime.parse(map['weekEnd'] ?? DateTime.now().toIso8601String()),
      averageMoodScore: map['averageMoodScore']?.toDouble() ?? 0.0,
      overallMoodTrend: map['overallMoodTrend'] ?? '',
      topEmotions: List<String>.from(map['topEmotions'] ?? []),
      moodHighlights: List<String>.from(map['moodHighlights'] ?? []),
      challenges: List<String>.from(map['challenges'] ?? []),
      achievements: List<String>.from(map['achievements'] ?? []),
      relationshipInsight: map['relationshipInsight'] ?? '',
      recommendations: List<String>.from(map['recommendations'] ?? []),
      personalizedMessage: map['personalizedMessage'] ?? '',
      createdAt:
          DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

/// AI mood assistant service
class AIMoodAssistantService {
  static final AIMoodAssistantService _instance =
      AIMoodAssistantService._internal();
  factory AIMoodAssistantService() => _instance;
  AIMoodAssistantService._internal();

  final HiveService _hiveService = HiveService();
  final FirebaseService _firebaseService = FirebaseService();
  static const String _boxName = 'ai_mood_assistant_box';
  static const String _analysesKey = 'mood_analyses';
  static const String _recapsKey = 'weekly_recaps';

  /// Get AI mood assistant service instance
  static AIMoodAssistantService get instance => _instance;

  /// Analyze mood data and generate insights
  Future<MoodAnalysis> analyzeMoodData(
      List<Map<String, dynamic>> moodEntries) async {
    try {
      if (moodEntries.isEmpty) {
        return _createDefaultAnalysis();
      }

      // Calculate average mood score
      final averageScore = moodEntries
              .map((e) => e['intensity'] as int)
              .reduce((a, b) => a + b) /
          moodEntries.length;

      // Analyze dominant emotions
      final emotionCounts = <String, int>{};
      for (final entry in moodEntries) {
        final emotion = entry['emotion'] as String;
        emotionCounts[emotion] = (emotionCounts[emotion] ?? 0) + 1;
      }

      final dominantEmotions = emotionCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      // Analyze mood triggers
      final triggerCounts = <String, int>{};
      for (final entry in moodEntries) {
        final triggers = entry['triggers'] as List<String>? ?? [];
        for (final trigger in triggers) {
          triggerCounts[trigger] = (triggerCounts[trigger] ?? 0) + 1;
        }
      }

      final moodTriggers = triggerCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      // Generate AI analysis
      final analysis =
          _generateMoodAnalysis(averageScore, dominantEmotions, moodTriggers);

      // Generate suggestions
      final suggestions =
          _generateMoodSuggestions(averageScore, dominantEmotions);

      // Generate partner insight
      final partnerInsight =
          _generatePartnerInsight(averageScore, dominantEmotions);

      final moodAnalysis = MoodAnalysis(
        id: 'analysis_${DateTime.now().millisecondsSinceEpoch}',
        date: DateTime.now(),
        overallMood: _getOverallMoodLabel(averageScore),
        moodScore: averageScore,
        dominantEmotions: dominantEmotions.take(3).map((e) => e.key).toList(),
        moodTriggers: moodTriggers.take(3).map((t) => t.key).toList(),
        analysis: analysis,
        suggestions: suggestions,
        partnerInsight: partnerInsight,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save analysis
      await _saveMoodAnalysis(moodAnalysis);

      return moodAnalysis;
    } catch (e) {
      developer.log('❌ [AIMoodAssistantService] Error analyzing mood data: $e');
      return _createDefaultAnalysis();
    }
  }

  /// Generate weekly recap
  Future<WeeklyRecap> generateWeeklyRecap(
      List<MoodAnalysis> weeklyAnalyses) async {
    try {
      if (weeklyAnalyses.isEmpty) {
        return _createDefaultRecap();
      }

      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekEnd = weekStart.add(Duration(days: 6));

      // Calculate average mood score
      final averageMoodScore =
          weeklyAnalyses.map((a) => a.moodScore).reduce((a, b) => a + b) /
              weeklyAnalyses.length;

      // Determine mood trend
      final moodTrend = _calculateMoodTrend(weeklyAnalyses);

      // Collect top emotions
      final allEmotions = <String>[];
      for (final analysis in weeklyAnalyses) {
        allEmotions.addAll(analysis.dominantEmotions);
      }

      final emotionCounts = <String, int>{};
      for (final emotion in allEmotions) {
        emotionCounts[emotion] = (emotionCounts[emotion] ?? 0) + 1;
      }

      final topEmotions = emotionCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      // Generate insights
      final moodHighlights = _generateMoodHighlights(weeklyAnalyses);
      final challenges = _generateChallenges(weeklyAnalyses);
      final achievements = _generateAchievements(weeklyAnalyses);
      final relationshipInsight = _generateRelationshipInsight(weeklyAnalyses);
      final recommendations = _generateRecommendations(weeklyAnalyses);
      final personalizedMessage =
          _generatePersonalizedMessage(averageMoodScore, moodTrend);

      final weeklyRecap = WeeklyRecap(
        id: 'recap_${DateTime.now().millisecondsSinceEpoch}',
        weekStart: weekStart,
        weekEnd: weekEnd,
        averageMoodScore: averageMoodScore,
        overallMoodTrend: moodTrend,
        topEmotions: topEmotions.take(3).map((e) => e.key).toList(),
        moodHighlights: moodHighlights,
        challenges: challenges,
        achievements: achievements,
        relationshipInsight: relationshipInsight,
        recommendations: recommendations,
        personalizedMessage: personalizedMessage,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save recap
      await _saveWeeklyRecap(weeklyRecap);

      return weeklyRecap;
    } catch (e) {
      developer.log('❌ [AIMoodAssistantService] Error generating weekly recap: $e');
      return _createDefaultRecap();
    }
  }

  /// Get mood analysis history
  Future<List<MoodAnalysis>> getMoodAnalysisHistory() async {
    try {
      await _hiveService.ensureBoxOpen(_boxName);
      final data = _hiveService.retrieve(_boxName, _analysesKey);

      if (data != null) {
        return (data as List)
            .map(
                (item) => MoodAnalysis.fromMap(Map<String, dynamic>.from(item)))
            .toList();
      }

      return [];
    } catch (e) {
      developer.log(
          '❌ [AIMoodAssistantService] Error getting mood analysis history: $e');
      return [];
    }
  }

  /// Get weekly recap history
  Future<List<WeeklyRecap>> getWeeklyRecapHistory() async {
    try {
      await _hiveService.ensureBoxOpen(_boxName);
      final data = _hiveService.retrieve(_boxName, _recapsKey);

      if (data != null) {
        return (data as List)
            .map((item) => WeeklyRecap.fromMap(Map<String, dynamic>.from(item)))
            .toList();
      }

      return [];
    } catch (e) {
      developer.log(
          '❌ [AIMoodAssistantService] Error getting weekly recap history: $e');
      return [];
    }
  }

  /// Get latest mood analysis
  Future<MoodAnalysis?> getLatestMoodAnalysis() async {
    try {
      final analyses = await getMoodAnalysisHistory();
      if (analyses.isNotEmpty) {
        analyses.sort((a, b) => b.date.compareTo(a.date));
        return analyses.first;
      }
      return null;
    } catch (e) {
      developer.log(
          '❌ [AIMoodAssistantService] Error getting latest mood analysis: $e');
      return null;
    }
  }

  /// Get latest weekly recap
  Future<WeeklyRecap?> getLatestWeeklyRecap() async {
    try {
      final recaps = await getWeeklyRecapHistory();
      if (recaps.isNotEmpty) {
        recaps.sort((a, b) => b.weekStart.compareTo(a.weekStart));
        return recaps.first;
      }
      return null;
    } catch (e) {
      developer.log('❌ [AIMoodAssistantService] Error getting latest weekly recap: $e');
      return null;
    }
  }

  /// Generate mood analysis text
  String _generateMoodAnalysis(
      double averageScore,
      List<MapEntry<String, int>> dominantEmotions,
      List<MapEntry<String, int>> moodTriggers) {
    final moodLabel = _getOverallMoodLabel(averageScore);
    final topEmotion =
        dominantEmotions.isNotEmpty ? dominantEmotions.first.key : 'neutral';
    final topTrigger =
        moodTriggers.isNotEmpty ? moodTriggers.first.key : 'general';

    return 'Your mood this week has been $moodLabel with an average score of ${averageScore.toStringAsFixed(1)}/10. '
        'The dominant emotion was $topEmotion, often triggered by $topTrigger. '
        'This suggests you\'re experiencing $moodLabel emotional patterns that are worth exploring together.';
  }

  /// Generate mood suggestions
  List<String> _generateMoodSuggestions(
      double averageScore, List<MapEntry<String, int>> dominantEmotions) {
    final suggestions = <String>[];

    if (averageScore < 4) {
      suggestions.add('Consider scheduling more quality time together');
      suggestions.add('Try engaging in activities that bring you joy');
      suggestions.add('Practice mindfulness and gratitude exercises');
    } else if (averageScore < 7) {
      suggestions.add('Maintain your current positive momentum');
      suggestions.add('Explore new shared experiences together');
      suggestions.add('Continue open communication about feelings');
    } else {
      suggestions.add('Celebrate your positive emotional state');
      suggestions.add('Share your happiness with your partner');
      suggestions.add('Use this energy to strengthen your bond');
    }

    return suggestions;
  }

  /// Generate partner insight
  String _generatePartnerInsight(
      double averageScore, List<MapEntry<String, int>> dominantEmotions) {
    if (averageScore < 4) {
      return 'Your partner may benefit from extra support and understanding during this time. '
          'Consider checking in more frequently and offering emotional comfort.';
    } else if (averageScore < 7) {
      return 'Your partner seems to be in a balanced emotional state. '
          'This is a great time to deepen your connection and create new memories together.';
    } else {
      return 'Your partner is radiating positive energy! '
          'This is an excellent opportunity to celebrate together and plan exciting activities.';
    }
  }

  /// Calculate mood trend
  String _calculateMoodTrend(List<MoodAnalysis> analyses) {
    if (analyses.length < 2) return 'stable';

    final scores = analyses.map((a) => a.moodScore).toList();
    final firstHalf = scores.take(scores.length ~/ 2).reduce((a, b) => a + b) /
        (scores.length ~/ 2);
    final secondHalf = scores.skip(scores.length ~/ 2).reduce((a, b) => a + b) /
        (scores.length - scores.length ~/ 2);

    if (secondHalf > firstHalf + 0.5) return 'improving';
    if (secondHalf < firstHalf - 0.5) return 'declining';
    return 'stable';
  }

  /// Generate mood highlights
  List<String> _generateMoodHighlights(List<MoodAnalysis> analyses) {
    final highlights = <String>[];

    for (final analysis in analyses) {
      if (analysis.moodScore >= 8) {
        highlights.add(
            '${analysis.date.day}/${analysis.date.month}: ${analysis.overallMood} mood');
      }
    }

    return highlights.take(3).toList();
  }

  /// Generate challenges
  List<String> _generateChallenges(List<MoodAnalysis> analyses) {
    final challenges = <String>[];

    for (final analysis in analyses) {
      if (analysis.moodScore < 4) {
        challenges.add(
            '${analysis.date.day}/${analysis.date.month}: ${analysis.overallMood} mood');
      }
    }

    return challenges.take(3).toList();
  }

  /// Generate achievements
  List<String> _generateAchievements(List<MoodAnalysis> analyses) {
    final achievements = <String>[];

    final highMoodDays = analyses.where((a) => a.moodScore >= 8).length;
    if (highMoodDays >= 3) {
      achievements.add('Had $highMoodDays high-mood days this week');
    }

    final consistentMood = analyses.every((a) => a.moodScore >= 6);
    if (consistentMood) {
      achievements.add('Maintained consistent positive mood');
    }

    return achievements;
  }

  /// Generate relationship insight
  String _generateRelationshipInsight(List<MoodAnalysis> analyses) {
    final averageScore =
        analyses.map((a) => a.moodScore).reduce((a, b) => a + b) /
            analyses.length;

    if (averageScore >= 7) {
      return 'Your relationship is thriving! The positive mood patterns suggest strong emotional connection and mutual support.';
    } else if (averageScore >= 5) {
      return 'Your relationship shows good emotional balance. There\'s room for growth and deeper connection.';
    } else {
      return 'Your relationship may benefit from more attention and care. Consider focusing on communication and shared activities.';
    }
  }

  /// Generate recommendations
  List<String> _generateRecommendations(List<MoodAnalysis> analyses) {
    final recommendations = <String>[];

    final averageScore =
        analyses.map((a) => a.moodScore).reduce((a, b) => a + b) /
            analyses.length;

    if (averageScore < 5) {
      recommendations.add('Schedule regular check-ins with your partner');
      recommendations.add('Plan relaxing activities together');
      recommendations.add('Practice gratitude and positive affirmations');
    } else if (averageScore < 7) {
      recommendations.add('Continue building on your positive momentum');
      recommendations.add('Try new shared experiences');
      recommendations.add('Maintain open communication');
    } else {
      recommendations.add('Celebrate your positive relationship dynamic');
      recommendations.add('Share your happiness with others');
      recommendations.add('Use this energy to plan future adventures');
    }

    return recommendations;
  }

  /// Generate personalized message
  String _generatePersonalizedMessage(double averageScore, String moodTrend) {
    if (averageScore >= 7) {
      return 'You\'re doing amazing! Your positive mood and $moodTrend trend show that your relationship is flourishing. Keep up the great work!';
    } else if (averageScore >= 5) {
      return 'You\'re on a good path! Your $moodTrend mood trend suggests steady progress. Continue nurturing your relationship.';
    } else {
      return 'Remember that every relationship has ups and downs. Your $moodTrend mood trend shows you\'re working through challenges together.';
    }
  }

  /// Get overall mood label
  String _getOverallMoodLabel(double score) {
    if (score >= 8) return 'excellent';
    if (score >= 6) return 'good';
    if (score >= 4) return 'moderate';
    return 'challenging';
  }

  /// Create default analysis
  MoodAnalysis _createDefaultAnalysis() {
    return MoodAnalysis(
      id: 'default_analysis',
      date: DateTime.now(),
      overallMood: 'neutral',
      moodScore: 5.0,
      dominantEmotions: ['neutral'],
      moodTriggers: ['general'],
      analysis: 'No mood data available for analysis.',
      suggestions: ['Start tracking your mood to get personalized insights'],
      partnerInsight:
          'Begin mood tracking to understand your emotional patterns together',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Create default recap
  WeeklyRecap _createDefaultRecap() {
    return WeeklyRecap(
      id: 'default_recap',
      weekStart: DateTime.now().subtract(Duration(days: 7)),
      weekEnd: DateTime.now(),
      averageMoodScore: 5.0,
      overallMoodTrend: 'stable',
      topEmotions: ['neutral'],
      moodHighlights: [],
      challenges: [],
      achievements: [],
      relationshipInsight:
          'Start tracking your mood to get weekly insights about your relationship.',
      recommendations: [
        'Begin mood tracking to receive personalized recommendations'
      ],
      personalizedMessage:
          'Welcome to your mood tracking journey! Start logging your emotions to get personalized insights.',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Save mood analysis
  Future<void> _saveMoodAnalysis(MoodAnalysis analysis) async {
    try {
      final analyses = await getMoodAnalysisHistory();
      analyses.add(analysis);

      await _hiveService.store(
          _boxName, _analysesKey, analyses.map((a) => a.toMap()).toList());

      // Sync to Firebase
      await _saveAnalysisToFirebase(analysis);
    } catch (e) {
      developer.log('❌ [AIMoodAssistantService] Error saving mood analysis: $e');
    }
  }

  /// Save weekly recap
  Future<void> _saveWeeklyRecap(WeeklyRecap recap) async {
    try {
      final recaps = await getWeeklyRecapHistory();
      recaps.add(recap);

      await _hiveService.store(
          _boxName, _recapsKey, recaps.map((r) => r.toMap()).toList());

      // Sync to Firebase
      await _saveRecapToFirebase(recap);
    } catch (e) {
      developer.log('❌ [AIMoodAssistantService] Error saving weekly recap: $e');
    }
  }

  /// Save analysis to Firebase
  Future<void> _saveAnalysisToFirebase(MoodAnalysis analysis) async {
    try {
      await _firebaseService.saveToFirestore(
        collection: 'mood_analyses',
        documentId: analysis.id,
        data: analysis.toMap(),
      );
    } catch (e) {
      developer.log('❌ [AIMoodAssistantService] Error saving analysis to Firebase: $e');
    }
  }

  /// Save recap to Firebase
  Future<void> _saveRecapToFirebase(WeeklyRecap recap) async {
    try {
      await _firebaseService.saveToFirestore(
        collection: 'weekly_recaps',
        documentId: recap.id,
        data: recap.toMap(),
      );
    } catch (e) {
      developer.log('❌ [AIMoodAssistantService] Error saving recap to Firebase: $e');
    }
  }

  /// Clear all data
  Future<void> clearAllData() async {
    try {
      await _hiveService.ensureBoxOpen(_boxName);
      await _hiveService.delete(_boxName, _analysesKey);
      await _hiveService.delete(_boxName, _recapsKey);
      developer.log('✅ [AIMoodAssistantService] All data cleared');
    } catch (e) {
      developer.log('❌ [AIMoodAssistantService] Error clearing data: $e');
    }
  }
}
