/// Comprehensive quiz types covering all requirements from tasks.md
enum QuizType {
  /// Boy/Girl prediction quiz using traditional signs and symptoms
  boyGirl,

  /// Baby name generator based on preferences and cultural background
  babyNames,

  /// Physical features prediction using basic genetics principles
  babyFeatures,

  /// Couple compatibility assessment for parenting readiness
  coupleCompatibility,

  /// Baby personality prediction based on parental traits
  personality,

  /// Parenting style assessment and recommendations
  parentingStyle,

  /// Baby milestones prediction timeline
  milestones,

  /// Birth month personality traits and characteristics
  birthMonth,
}

/// Quiz difficulty levels affecting scoring and complexity
enum QuizDifficulty {
  easy,
  medium,
  hard,
}

extension QuizTypeExtension on QuizType {
  String get displayName {
    switch (this) {
      case QuizType.boyGirl:
        return 'Boy or Girl Prediction';
      case QuizType.babyNames:
        return 'Baby Name Generator';
      case QuizType.babyFeatures:
        return 'Baby Features Quiz';
      case QuizType.coupleCompatibility:
        return 'Couple Compatibility';
      case QuizType.personality:
        return 'Personality Predictor';
      case QuizType.parentingStyle:
        return 'Parenting Style';
      case QuizType.milestones:
        return 'Milestones Predictor';
      case QuizType.birthMonth:
        return 'Birth Month Traits';
    }
  }

  String get description {
    switch (this) {
      case QuizType.boyGirl:
        return 'Predict your baby\'s gender using traditional signs';
      case QuizType.babyNames:
        return 'Discover perfect names for your future baby';
      case QuizType.babyFeatures:
        return 'Predict physical features using genetics';
      case QuizType.coupleCompatibility:
        return 'Test your parenting compatibility';
      case QuizType.personality:
        return 'Discover your baby\'s personality traits';
      case QuizType.parentingStyle:
        return 'Find your natural parenting approach';
      case QuizType.milestones:
        return 'Predict developmental milestones';
      case QuizType.birthMonth:
        return 'Explore birth month personality traits';
    }
  }

  /// Category for grouping quizzes
  String get category {
    switch (this) {
      case QuizType.boyGirl:
      case QuizType.babyFeatures:
      case QuizType.milestones:
        return 'Prediction';
      case QuizType.babyNames:
        return 'Names';
      case QuizType.coupleCompatibility:
      case QuizType.parentingStyle:
        return 'Parenting';
      case QuizType.personality:
      case QuizType.birthMonth:
        return 'Personality';
    }
  }

  /// Base score multiplier for this quiz type
  double get scoreMultiplier {
    switch (this) {
      case QuizType.boyGirl:
      case QuizType.babyNames:
        return 1.0; // Easy quizzes
      case QuizType.babyFeatures:
      case QuizType.coupleCompatibility:
      case QuizType.parentingStyle:
      case QuizType.milestones:
        return 1.5; // Medium quizzes
      case QuizType.personality:
        return 2.0; // Hard quizzes
      case QuizType.birthMonth:
        return 0.8; // Simple quiz
    }
  }
}

extension QuizDifficultyExtension on QuizDifficulty {
  String get displayName {
    switch (this) {
      case QuizDifficulty.easy:
        return 'Easy';
      case QuizDifficulty.medium:
        return 'Medium';
      case QuizDifficulty.hard:
        return 'Hard';
    }
  }

  /// Points multiplier based on difficulty
  double get pointsMultiplier {
    switch (this) {
      case QuizDifficulty.easy:
        return 1.0;
      case QuizDifficulty.medium:
        return 1.5;
      case QuizDifficulty.hard:
        return 2.0;
    }
  }

  /// Time bonus threshold in seconds
  int get timeBonusThreshold {
    switch (this) {
      case QuizDifficulty.easy:
        return 120; // 2 minutes
      case QuizDifficulty.medium:
        return 180; // 3 minutes
      case QuizDifficulty.hard:
        return 300; // 5 minutes
    }
  }
}
