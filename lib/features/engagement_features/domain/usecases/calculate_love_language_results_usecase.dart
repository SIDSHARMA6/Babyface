import '../entities/love_language_entity.dart';

/// Calculate love language results use case
/// Follows master plan clean architecture
class CalculateLoveLanguageResultsUsecase {
  /// Execute calculate love language results
  Future<LoveLanguageQuizResultEntity> execute(
      LoveLanguageQuizRequest request) async {
    // Simulate processing time
    await Future.delayed(const Duration(milliseconds: 1000));

    // Calculate scores for each love language type
    final scores = <LoveLanguageType, int>{};

    // Initialize scores
    for (final type in LoveLanguageType.values) {
      scores[type] = 0;
    }

    // Calculate scores based on answers
    // In a real implementation, this would:
    // 1. Get the actual questions and answers
    // 2. Calculate scores based on answer points
    // 3. Determine primary and secondary languages

    // For demo purposes, return sample results
    scores[LoveLanguageType.wordsOfAffirmation] = 85;
    scores[LoveLanguageType.qualityTime] = 78;
    scores[LoveLanguageType.actsOfService] = 65;
    scores[LoveLanguageType.physicalTouch] = 45;
    scores[LoveLanguageType.receivingGifts] = 32;

    // Create love language entities
    final results = scores.entries.map((entry) {
      return LoveLanguageEntity(
        id: entry.key.name,
        title: _getLoveLanguageTitle(entry.key),
        description: _getLoveLanguageDescription(entry.key),
        type: entry.key,
        examples: _getLoveLanguageExamples(entry.key),
        iconUrl: 'assets/icons/${entry.key.name}.png',
        score: entry.value,
        createdAt: DateTime.now(),
      );
    }).toList();

    // Sort by score to get primary and secondary
    results.sort((a, b) => b.score.compareTo(a.score));

    final primaryLanguage = results.first;
    final secondaryLanguage = results.length > 1 ? results[1] : results.first;
    final totalScore = results.fold(0, (sum, language) => sum + language.score);

    return LoveLanguageQuizResultEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      results: results,
      primaryLanguage: primaryLanguage,
      secondaryLanguage: secondaryLanguage,
      totalScore: totalScore,
      completedAt: DateTime.now(),
      userId: request.userId,
    );
  }

  String _getLoveLanguageTitle(LoveLanguageType type) {
    switch (type) {
      case LoveLanguageType.wordsOfAffirmation:
        return 'Words of Affirmation';
      case LoveLanguageType.actsOfService:
        return 'Acts of Service';
      case LoveLanguageType.receivingGifts:
        return 'Receiving Gifts';
      case LoveLanguageType.qualityTime:
        return 'Quality Time';
      case LoveLanguageType.physicalTouch:
        return 'Physical Touch';
    }
  }

  String _getLoveLanguageDescription(LoveLanguageType type) {
    switch (type) {
      case LoveLanguageType.wordsOfAffirmation:
        return 'You feel most loved when your partner expresses their feelings through words, compliments, and verbal encouragement.';
      case LoveLanguageType.actsOfService:
        return 'You feel most loved when your partner does helpful things for you, showing they care through their actions.';
      case LoveLanguageType.receivingGifts:
        return 'You feel most loved when your partner gives you thoughtful gifts, showing they were thinking of you.';
      case LoveLanguageType.qualityTime:
        return 'You feel most loved when your partner gives you their undivided attention and spends quality time with you.';
      case LoveLanguageType.physicalTouch:
        return 'You feel most loved through physical affection like hugs, kisses, holding hands, and physical closeness.';
    }
  }

  List<String> _getLoveLanguageExamples(LoveLanguageType type) {
    switch (type) {
      case LoveLanguageType.wordsOfAffirmation:
        return [
          'Saying "I love you" regularly',
          'Giving compliments and praise',
          'Writing love notes or messages',
          'Encouraging words during difficult times',
          'Expressing appreciation verbally',
        ];
      case LoveLanguageType.actsOfService:
        return [
          'Helping with household chores',
          'Running errands for you',
          'Cooking your favorite meal',
          'Taking care of tasks you dislike',
          'Being there when you need help',
        ];
      case LoveLanguageType.receivingGifts:
        return [
          'Surprise gifts on special occasions',
          'Thoughtful presents that show they know you',
          'Small tokens of affection',
          'Handmade gifts with personal meaning',
          'Gifts that solve a problem you have',
        ];
      case LoveLanguageType.qualityTime:
        return [
          'Having deep conversations together',
          'Going on dates without distractions',
          'Doing activities you both enjoy',
          'Taking walks and talking',
          'Creating shared experiences',
        ];
      case LoveLanguageType.physicalTouch:
        return [
          'Holding hands while walking',
          'Hugs and kisses throughout the day',
          'Cuddling while watching TV',
          'Gentle touches and caresses',
          'Physical comfort during stress',
        ];
    }
  }
}
