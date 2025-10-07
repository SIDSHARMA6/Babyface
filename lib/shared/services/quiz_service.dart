import '../models/quiz_models.dart';

/// Service for managing quiz functionality
class QuizService {
  /// Create a new quiz session
  static QuizSession createSession(QuizType type) {
    final questions = _getQuestionsForType(type);

    return QuizSession(
      id: 'quiz_${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      questions: questions,
    );
  }

  /// Get questions for a specific quiz type
  static List<QuizQuestion> _getQuestionsForType(QuizType type) {
    switch (type) {
      case QuizType.boyOrGirl:
        return _getBoyOrGirlQuestions();
      case QuizType.babyName:
        return _getBabyNameQuestions();
      case QuizType.personality:
        return _getPersonalityQuestions();
      case QuizType.features:
        return _getFeaturesQuestions();
    }
  }

  static List<QuizQuestion> _getBoyOrGirlQuestions() {
    return [
      QuizQuestion(
        id: 'q1',
        question: 'What are you craving most?',
        type: QuizType.boyOrGirl,
        options: [
          QuizOption(
              id: 'o1',
              text: 'Sweet treats',
              points: 2,
              gender: BabyGender.girl),
          QuizOption(
              id: 'o2',
              text: 'Salty snacks',
              points: 2,
              gender: BabyGender.boy),
          QuizOption(
              id: 'o3', text: 'Spicy food', points: 1, gender: BabyGender.boy),
          QuizOption(
              id: 'o4', text: 'Fruits', points: 1, gender: BabyGender.girl),
        ],
      ),
      QuizQuestion(
        id: 'q2',
        question: 'How is your morning sickness?',
        type: QuizType.boyOrGirl,
        options: [
          QuizOption(
              id: 'o1',
              text: 'Severe all day',
              points: 2,
              gender: BabyGender.girl),
          QuizOption(
              id: 'o2',
              text: 'Mild in mornings',
              points: 1,
              gender: BabyGender.boy),
          QuizOption(
              id: 'o3', text: 'None at all', points: 2, gender: BabyGender.boy),
          QuizOption(
              id: 'o4',
              text: 'Comes and goes',
              points: 1,
              gender: BabyGender.girl),
        ],
      ),
    ];
  }

  static List<QuizQuestion> _getBabyNameQuestions() {
    return [
      QuizQuestion(
        id: 'n1',
        question: 'What style of name do you prefer?',
        type: QuizType.babyName,
        options: [
          QuizOption(id: 'o1', text: 'Classic and traditional', points: 3),
          QuizOption(id: 'o2', text: 'Modern and unique', points: 2),
          QuizOption(id: 'o3', text: 'Nature-inspired', points: 1),
          QuizOption(id: 'o4', text: 'Cultural/family name', points: 2),
        ],
      ),
    ];
  }

  static List<QuizQuestion> _getPersonalityQuestions() {
    return [
      QuizQuestion(
        id: 'p1',
        question: 'What personality trait do you hope for?',
        type: QuizType.personality,
        options: [
          QuizOption(id: 'o1', text: 'Adventurous and bold', points: 3),
          QuizOption(id: 'o2', text: 'Calm and peaceful', points: 2),
          QuizOption(id: 'o3', text: 'Creative and artistic', points: 2),
          QuizOption(id: 'o4', text: 'Smart and curious', points: 3),
        ],
      ),
    ];
  }

  static List<QuizQuestion> _getFeaturesQuestions() {
    return [
      QuizQuestion(
        id: 'f1',
        question: 'Which parent has stronger genes?',
        type: QuizType.features,
        options: [
          QuizOption(id: 'o1', text: 'Mother', points: 2),
          QuizOption(id: 'o2', text: 'Father', points: 2),
          QuizOption(id: 'o3', text: 'Equal mix', points: 3),
          QuizOption(id: 'o4', text: 'Grandparents', points: 1),
        ],
      ),
    ];
  }

  /// Calculate quiz result
  static QuizResult calculateResult(QuizSession session) {
    final totalPoints = session.answers.fold<int>(
      0,
      (sum, answer) => sum + answer.points,
    );

    BabyGender predictedGender = BabyGender.unknown;
    if (session.type == QuizType.boyOrGirl) {
      // Simple logic: more points towards boy or girl
      final boyPoints = session.answers
          .where((a) => _getOptionGender(session, a) == BabyGender.boy)
          .fold<int>(0, (sum, a) => sum + a.points);
      final girlPoints = session.answers
          .where((a) => _getOptionGender(session, a) == BabyGender.girl)
          .fold<int>(0, (sum, a) => sum + a.points);

      predictedGender =
          boyPoints > girlPoints ? BabyGender.boy : BabyGender.girl;
    }

    return QuizResult(
      id: 'result_${DateTime.now().millisecondsSinceEpoch}',
      type: session.type,
      answers: session.answers,
      totalPoints: totalPoints,
      predictedGender: predictedGender,
      createdAt: DateTime.now(),
    );
  }

  static BabyGender? _getOptionGender(QuizSession session, QuizAnswer answer) {
    for (final question in session.questions) {
      if (question.id == answer.questionId) {
        for (final option in question.options) {
          if (option.id == answer.optionId) {
            return option.gender;
          }
        }
      }
    }
    return null;
  }
}
