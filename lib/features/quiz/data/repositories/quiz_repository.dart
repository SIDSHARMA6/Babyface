import '../../../quiz/domain/entities/quiz_entities.dart';

class QuizRepository {
  // Mock data for now - will be replaced with actual data source
  static List<Quiz> getAllQuizzes() {
    return [
      Quiz(
        category: QuizCategory.babyPrediction,
        title: "Baby Prediction Quiz",
        description: "Predict your future baby's features and personality",
        icon: "🍼",
        levels: _getBabyPredictionLevels(),
        totalLevels: 5,
        completedLevels: 1,
        progressPercentage: 20.0,
        isFeatured: true,
      ),
      Quiz(
        category: QuizCategory.coupleCompatibility,
        title: "Couple Compatibility",
        description: "Test how well you know each other",
        icon: "💕",
        levels: _getCoupleCompatibilityLevels(),
        totalLevels: 5,
        completedLevels: 0,
        progressPercentage: 0.0,
      ),
      Quiz(
        category: QuizCategory.loveLanguage,
        title: "Love Language Quiz",
        description: "Discover your love languages",
        icon: "💬",
        levels: _getLoveLanguageLevels(),
        totalLevels: 5,
        completedLevels: 0,
        progressPercentage: 0.0,
      ),
      Quiz(
        category: QuizCategory.futureHome,
        title: "Future Home Quiz",
        description: "Plan your dream home together",
        icon: "🏠",
        levels: _getFutureHomeLevels(),
        totalLevels: 5,
        completedLevels: 0,
        progressPercentage: 0.0,
      ),
      Quiz(
        category: QuizCategory.parentingStyle,
        title: "Parenting Style Quiz",
        description: "Discover your parenting approaches",
        icon: "👨‍👩‍👧‍👦",
        levels: _getParentingStyleLevels(),
        totalLevels: 5,
        completedLevels: 0,
        progressPercentage: 0.0,
      ),
      Quiz(
        category: QuizCategory.relationshipMilestones,
        title: "Relationship Milestones",
        description: "Celebrate your journey together",
        icon: "💍",
        levels: _getRelationshipMilestonesLevels(),
        totalLevels: 5,
        completedLevels: 0,
        progressPercentage: 0.0,
      ),
      Quiz(
        category: QuizCategory.couplePuzzles,
        title: "Couple Puzzles",
        description: "Solve puzzles together",
        icon: "🧩",
        levels: _getCouplePuzzlesLevels(),
        totalLevels: 5,
        completedLevels: 0,
        progressPercentage: 0.0,
      ),
      Quiz(
        category: QuizCategory.rolePlayScenarios,
        title: "Role Play Scenarios",
        description: "What would you do if...",
        icon: "🎭",
        levels: _getRolePlayScenariosLevels(),
        totalLevels: 5,
        completedLevels: 0,
        progressPercentage: 0.0,
      ),
      Quiz(
        category: QuizCategory.futurePredictions,
        title: "Future Predictions",
        description: "Predict your future together",
        icon: "🔮",
        levels: _getFuturePredictionsLevels(),
        totalLevels: 5,
        completedLevels: 0,
        progressPercentage: 0.0,
      ),
      Quiz(
        category: QuizCategory.anniversaryMemories,
        title: "Anniversary Memories",
        description: "Relive your special moments",
        icon: "💝",
        levels: _getAnniversaryMemoriesLevels(),
        totalLevels: 5,
        completedLevels: 0,
        progressPercentage: 0.0,
      ),
    ];
  }

  static List<Quiz> getFeaturedQuizzes() {
    return getAllQuizzes().where((quiz) => quiz.isFeatured).toList();
  }

  static Quiz? getQuizByCategory(QuizCategory category) {
    try {
      return getAllQuizzes().firstWhere((quiz) => quiz.category == category);
    } catch (e) {
      return null;
    }
  }

  // Mock level data generators
  static List<QuizLevel> _getBabyPredictionLevels() {
    return [
      QuizLevel(
        levelNumber: 1,
        title: "Gender Prediction",
        description: "Predict your baby's gender",
        questions: [
          QuizQuestion(
            id: "bp_1_1",
            question: "Boy: What gender do you think our baby will be?",
            type: QuestionType.multipleChoice,
            targetPlayer: PlayerType.boy,
            options: ["Boy", "Girl", "Surprise me!"],
            correctAnswer: "Any answer is correct",
          ),
          QuizQuestion(
            id: "bp_1_2",
            question: "Girl: What gender do you hope for?",
            type: QuestionType.multipleChoice,
            targetPlayer: PlayerType.girl,
            options: ["Boy", "Girl", "I don't mind"],
            correctAnswer: "Any answer is correct",
          ),
          QuizQuestion(
            id: "bp_1_3",
            question: "Both: If it's a boy, what would you name him?",
            type: QuestionType.textInput,
            targetPlayer: PlayerType.both,
            options: [],
            correctAnswer: "Any name",
          ),
          QuizQuestion(
            id: "bp_1_4",
            question: "Both: If it's a girl, what would you name her?",
            type: QuestionType.textInput,
            targetPlayer: PlayerType.both,
            options: [],
            correctAnswer: "Any name",
          ),
        ],
        puzzle: QuizQuestion(
          id: "bp_1_puzzle",
          question: "Arrange these baby items in order of importance",
          type: QuestionType.puzzle,
          targetPlayer: PlayerType.both,
          options: ["Crib", "Diapers", "Clothes", "Toys"],
          correctAnswer: "Any order",
        ),
        isUnlocked: true,
      ),
      // Add more levels...
      for (int i = 2; i <= 5; i++)
        QuizLevel(
          levelNumber: i,
          title: "Level $i",
          description: "Description for level $i",
          questions: [
            QuizQuestion(
              id: "bp_${i}_1",
              question: "Sample question for level $i",
              type: QuestionType.multipleChoice,
              targetPlayer: PlayerType.both,
              options: ["Option A", "Option B", "Option C"],
              correctAnswer: "Option A",
            ),
          ],
          puzzle: QuizQuestion(
            id: "bp_${i}_puzzle",
            question: "Puzzle for level $i",
            type: QuestionType.puzzle,
            targetPlayer: PlayerType.both,
            options: ["Item 1", "Item 2", "Item 3"],
            correctAnswer: "Correct",
          ),
          isUnlocked: false,
        ),
    ];
  }

  static List<QuizLevel> _getCoupleCompatibilityLevels() {
    return List.generate(
        5,
        (index) => QuizLevel(
              levelNumber: index + 1,
              title: "Compatibility Level ${index + 1}",
              description: "Test your compatibility",
              questions: [
                QuizQuestion(
                  id: "cc_${index + 1}_1",
                  question: "Compatibility question ${index + 1}",
                  type: QuestionType.multipleChoice,
                  targetPlayer: PlayerType.both,
                  options: ["Option A", "Option B", "Option C"],
                  correctAnswer: "Option A",
                ),
              ],
              puzzle: QuizQuestion(
                id: "cc_${index + 1}_puzzle",
                question: "Compatibility puzzle ${index + 1}",
                type: QuestionType.puzzle,
                targetPlayer: PlayerType.both,
                options: ["Item 1", "Item 2", "Item 3"],
                correctAnswer: "Correct",
              ),
              isUnlocked: index == 0,
            ));
  }

  static List<QuizLevel> _getLoveLanguageLevels() {
    return List.generate(
        5,
        (index) => QuizLevel(
              levelNumber: index + 1,
              title: "Love Language Level ${index + 1}",
              description: "Discover love languages",
              questions: [
                QuizQuestion(
                  id: "ll_${index + 1}_1",
                  question: "Love language question ${index + 1}",
                  type: QuestionType.multipleChoice,
                  targetPlayer: PlayerType.both,
                  options: [
                    "Words of Affirmation",
                    "Quality Time",
                    "Physical Touch"
                  ],
                  correctAnswer: "Words of Affirmation",
                ),
              ],
              puzzle: QuizQuestion(
                id: "ll_${index + 1}_puzzle",
                question: "Love language puzzle ${index + 1}",
                type: QuestionType.puzzle,
                targetPlayer: PlayerType.both,
                options: ["Love", "Care", "Support"],
                correctAnswer: "Correct",
              ),
              isUnlocked: index == 0,
            ));
  }

  static List<QuizLevel> _getFutureHomeLevels() {
    return List.generate(
        5,
        (index) => QuizLevel(
              levelNumber: index + 1,
              title: "Future Home Level ${index + 1}",
              description: "Plan your dream home",
              questions: [
                QuizQuestion(
                  id: "fh_${index + 1}_1",
                  question: "Future home question ${index + 1}",
                  type: QuestionType.multipleChoice,
                  targetPlayer: PlayerType.both,
                  options: ["Option A", "Option B", "Option C"],
                  correctAnswer: "Option A",
                ),
              ],
              puzzle: QuizQuestion(
                id: "fh_${index + 1}_puzzle",
                question: "Home planning puzzle ${index + 1}",
                type: QuestionType.puzzle,
                targetPlayer: PlayerType.both,
                options: ["Room 1", "Room 2", "Room 3"],
                correctAnswer: "Correct",
              ),
              isUnlocked: index == 0,
            ));
  }

  static List<QuizLevel> _getParentingStyleLevels() {
    return List.generate(
        5,
        (index) => QuizLevel(
              levelNumber: index + 1,
              title: "Parenting Level ${index + 1}",
              description: "Discover parenting styles",
              questions: [
                QuizQuestion(
                  id: "ps_${index + 1}_1",
                  question: "Parenting question ${index + 1}",
                  type: QuestionType.multipleChoice,
                  targetPlayer: PlayerType.both,
                  options: ["Option A", "Option B", "Option C"],
                  correctAnswer: "Option A",
                ),
              ],
              puzzle: QuizQuestion(
                id: "ps_${index + 1}_puzzle",
                question: "Parenting puzzle ${index + 1}",
                type: QuestionType.puzzle,
                targetPlayer: PlayerType.both,
                options: ["Style A", "Style B", "Style C"],
                correctAnswer: "Correct",
              ),
              isUnlocked: index == 0,
            ));
  }

  static List<QuizLevel> _getRelationshipMilestonesLevels() {
    return List.generate(
        5,
        (index) => QuizLevel(
              levelNumber: index + 1,
              title: "Milestone Level ${index + 1}",
              description: "Celebrate milestones",
              questions: [
                QuizQuestion(
                  id: "rm_${index + 1}_1",
                  question: "Milestone question ${index + 1}",
                  type: QuestionType.multipleChoice,
                  targetPlayer: PlayerType.both,
                  options: ["Option A", "Option B", "Option C"],
                  correctAnswer: "Option A",
                ),
              ],
              puzzle: QuizQuestion(
                id: "rm_${index + 1}_puzzle",
                question: "Milestone puzzle ${index + 1}",
                type: QuestionType.puzzle,
                targetPlayer: PlayerType.both,
                options: [],
                correctAnswer: "Correct",
              ),
              isUnlocked: index == 0,
            ));
  }

  static List<QuizLevel> _getCouplePuzzlesLevels() {
    return List.generate(
        5,
        (index) => QuizLevel(
              levelNumber: index + 1,
              title: "Puzzle Level ${index + 1}",
              description: "Solve together",
              questions: [
                QuizQuestion(
                  id: "cp_${index + 1}_1",
                  question: "Puzzle question ${index + 1}",
                  type: QuestionType.multipleChoice,
                  targetPlayer: PlayerType.both,
                  options: ["Option A", "Option B", "Option C"],
                  correctAnswer: "Option A",
                ),
              ],
              puzzle: QuizQuestion(
                id: "cp_${index + 1}_puzzle",
                question: "Couple puzzle ${index + 1}",
                type: QuestionType.puzzle,
                targetPlayer: PlayerType.both,
                options: [],
                correctAnswer: "Correct",
              ),
              isUnlocked: index == 0,
            ));
  }

  static List<QuizLevel> _getRolePlayScenariosLevels() {
    return List.generate(
        5,
        (index) => QuizLevel(
              levelNumber: index + 1,
              title: "Scenario Level ${index + 1}",
              description: "Role play scenarios",
              questions: [
                QuizQuestion(
                  id: "rps_${index + 1}_1",
                  question: "Scenario question ${index + 1}",
                  type: QuestionType.multipleChoice,
                  targetPlayer: PlayerType.both,
                  options: ["Option A", "Option B", "Option C"],
                  correctAnswer: "Option A",
                ),
              ],
              puzzle: QuizQuestion(
                id: "rps_${index + 1}_puzzle",
                question: "Scenario puzzle ${index + 1}",
                type: QuestionType.puzzle,
                targetPlayer: PlayerType.both,
                options: [],
                correctAnswer: "Correct",
              ),
              isUnlocked: index == 0,
            ));
  }

  static List<QuizLevel> _getFuturePredictionsLevels() {
    return List.generate(
        5,
        (index) => QuizLevel(
              levelNumber: index + 1,
              title: "Prediction Level ${index + 1}",
              description: "Predict the future",
              questions: [
                QuizQuestion(
                  id: "fp_${index + 1}_1",
                  question: "Future prediction question ${index + 1}",
                  type: QuestionType.multipleChoice,
                  targetPlayer: PlayerType.both,
                  options: ["Option A", "Option B", "Option C"],
                  correctAnswer: "Option A",
                ),
              ],
              puzzle: QuizQuestion(
                id: "fp_${index + 1}_puzzle",
                question: "Future puzzle ${index + 1}",
                type: QuestionType.puzzle,
                targetPlayer: PlayerType.both,
                options: [],
                correctAnswer: "Correct",
              ),
              isUnlocked: index == 0,
            ));
  }

  static List<QuizLevel> _getAnniversaryMemoriesLevels() {
    return List.generate(
        5,
        (index) => QuizLevel(
              levelNumber: index + 1,
              title: "Memory Level ${index + 1}",
              description: "Relive memories",
              questions: [
                QuizQuestion(
                  id: "am_${index + 1}_1",
                  question: "Memory question ${index + 1}",
                  type: QuestionType.multipleChoice,
                  targetPlayer: PlayerType.both,
                  options: ["Option A", "Option B", "Option C"],
                  correctAnswer: "Option A",
                ),
              ],
              puzzle: QuizQuestion(
                id: "am_${index + 1}_puzzle",
                question: "Memory puzzle ${index + 1}",
                type: QuestionType.puzzle,
                targetPlayer: PlayerType.both,
                options: [],
                correctAnswer: "Correct",
              ),
              isUnlocked: index == 0,
            ));
  }

  // Additional methods for quiz provider
  static List<QuizQuestion> getQuestionsForLevel(
      QuizCategory category, int level) {
    final quiz = getQuizByCategory(category);
    if (quiz != null && level <= quiz.levels.length) {
      return quiz.levels[level - 1].questions;
    }
    return [];
  }

  static String getMotivationalMessage(int score, int total) {
    final percentage = (score / total * 100).round();
    if (percentage >= 90) return "Amazing! You two know each other so well! 🌟";
    if (percentage >= 70) return "Great job! Your connection is strong! 💕";
    if (percentage >= 50) {
      return "Good work! Keep learning about each other! 😊";
    }
    return "Every couple's journey is unique! Keep exploring together! 💫";
  }

  static String getPersonalizedFeedback(QuizCategory category, int score) {
    switch (category) {
      case QuizCategory.babyPrediction:
        return "Your baby predictions show great imagination! 👶";
      case QuizCategory.coupleCompatibility:
        return "Your compatibility grows stronger with each quiz! 💑";
      case QuizCategory.loveLanguage:
        return "Understanding love languages deepens your bond! 💝";
      default:
        return "Keep exploring your relationship together! 🌈";
    }
  }
}
