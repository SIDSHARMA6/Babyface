enum QuizType {
  boyOrGirl,
  babyName,
  personality,
  features,
}

extension QuizTypeExtension on QuizType {
  String get displayName {
    switch (this) {
      case QuizType.boyOrGirl:
        return 'Boy or Girl?';
      case QuizType.babyName:
        return 'Baby Name';
      case QuizType.personality:
        return 'Personality';
      case QuizType.features:
        return 'Features';
    }
  }

  String get emoji {
    switch (this) {
      case QuizType.boyOrGirl:
        return '👶';
      case QuizType.babyName:
        return '📝';
      case QuizType.personality:
        return '🎭';
      case QuizType.features:
        return '👀';
    }
  }
}

enum BabyGender {
  boy,
  girl,
  unknown,
}

class QuizQuestion {
  final String id;
  final String question;
  final List<QuizOption> options;
  final QuizType type;

  QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.type,
  });
}

class QuizOption {
  final String id;
  final String text;
  final int points;
  final BabyGender? gender;

  QuizOption({
    required this.id,
    required this.text,
    required this.points,
    this.gender,
  });
}

class QuizAnswer {
  final String questionId;
  final String optionId;
  final int points;

  QuizAnswer({
    required this.questionId,
    required this.optionId,
    required this.points,
  });
}

class QuizResult {
  final String id;
  final QuizType type;
  final List<QuizAnswer> answers;
  final int totalPoints;
  final BabyGender predictedGender;
  final String? predictedName;
  final DateTime createdAt;

  QuizResult({
    required this.id,
    required this.type,
    required this.answers,
    required this.totalPoints,
    required this.predictedGender,
    this.predictedName,
    required this.createdAt,
  });

  String get prediction => predictedGender == BabyGender.boy ? 'Boy' : 'Girl';
  int get totalScore => totalPoints;
  Duration get timeTaken => const Duration(minutes: 2); // Mock
}

class QuizSession {
  final String id;
  final QuizType type;
  final List<QuizQuestion> questions;
  final List<QuizAnswer> answers;
  final int currentQuestionIndex;
  final bool isCompleted;

  QuizSession({
    required this.id,
    required this.type,
    required this.questions,
    this.answers = const [],
    this.currentQuestionIndex = 0,
    this.isCompleted = false,
  });

  QuizQuestion get currentQuestion => questions[currentQuestionIndex];
  bool get hasNextQuestion => currentQuestionIndex < questions.length - 1;
  int get progress =>
      ((currentQuestionIndex + 1) / questions.length * 100).round();
}
