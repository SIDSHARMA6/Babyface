import '../../../quiz/domain/entities/quiz_entities.dart';

class QuizRepository {
  // Get all quizzes from the main quiz repository
  static List<Quiz> getAllQuizzes() {
    // This will be replaced with actual data from the main QuizRepository
    return [];
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
