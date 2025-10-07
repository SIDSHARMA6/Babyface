import '../entities/couple_challenge_entity.dart';

/// Get challenges use case
/// Follows master plan clean architecture
class GetChallengesUsecase {
  /// Execute get challenges
  Future<List<CoupleChallengeEntity>> execute() async {
    // Simulate loading time
    await Future.delayed(const Duration(milliseconds: 800));

    // Return sample challenges for demo
    return [
      CoupleChallengeEntity(
        id: '1',
        title: 'Love Letter Exchange',
        description:
            'Write heartfelt letters to each other and exchange them in a romantic setting.',
        type: ChallengeType.romantic,
        difficulty: ChallengeDifficulty.easy,
        duration: 30,
        instructions: [
          'Find a quiet, romantic spot',
          'Write a letter expressing your feelings',
          'Exchange letters and read them together',
          'Share what you loved most about each other\'s letters',
        ],
        reward: 'Romantic dinner date',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        expiresAt: DateTime.now().add(const Duration(days: 7)),
        tags: ['romance', 'communication', 'writing'],
      ),
      CoupleChallengeEntity(
        id: '2',
        title: 'Cook Together Challenge',
        description: 'Prepare a three-course meal together from scratch.',
        type: ChallengeType.cooking,
        difficulty: ChallengeDifficulty.medium,
        duration: 120,
        instructions: [
          'Choose a recipe together',
          'Shop for ingredients',
          'Prepare appetizer, main course, and dessert',
          'Set a beautiful table and enjoy your meal',
        ],
        reward: 'Cooking class voucher',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        expiresAt: DateTime.now().add(const Duration(days: 5)),
        tags: ['cooking', 'teamwork', 'creativity'],
      ),
      CoupleChallengeEntity(
        id: '3',
        title: 'Adventure Scavenger Hunt',
        description: 'Create and complete a scavenger hunt around your city.',
        type: ChallengeType.adventure,
        difficulty: ChallengeDifficulty.hard,
        duration: 180,
        instructions: [
          'Create a list of 10 interesting locations',
          'Take photos at each location',
          'Complete a fun activity at each stop',
          'Share your adventure story',
        ],
        reward: 'Weekend getaway',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        expiresAt: DateTime.now().add(const Duration(days: 10)),
        tags: ['adventure', 'exploration', 'photography'],
      ),
      CoupleChallengeEntity(
        id: '4',
        title: 'Dance Like No One\'s Watching',
        description: 'Learn a new dance together and perform it.',
        type: ChallengeType.fun,
        difficulty: ChallengeDifficulty.medium,
        duration: 60,
        instructions: [
          'Choose a dance style you both want to learn',
          'Find a tutorial or take a class',
          'Practice for at least 30 minutes',
          'Record your final performance',
        ],
        reward: 'Dance class package',
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
        expiresAt: DateTime.now().add(const Duration(days: 6)),
        tags: ['dance', 'fun', 'learning'],
      ),
      CoupleChallengeEntity(
        id: '5',
        title: 'Deep Conversation Night',
        description: 'Have a meaningful conversation using deep questions.',
        type: ChallengeType.communication,
        difficulty: ChallengeDifficulty.easy,
        duration: 90,
        instructions: [
          'Prepare 20 deep questions about dreams, fears, and aspirations',
          'Find a comfortable, distraction-free environment',
          'Take turns asking and answering questions',
          'Listen actively and share openly',
        ],
        reward: 'Couple\'s therapy session',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        expiresAt: DateTime.now().add(const Duration(days: 8)),
        tags: ['communication', 'intimacy', 'connection'],
      ),
      CoupleChallengeEntity(
        id: '6',
        title: 'Fitness Challenge',
        description: 'Complete a 30-day fitness challenge together.',
        type: ChallengeType.fitness,
        difficulty: ChallengeDifficulty.hard,
        duration: 30,
        instructions: [
          'Choose a fitness goal (running, yoga, strength training)',
          'Create a daily workout schedule',
          'Track your progress together',
          'Celebrate milestones along the way',
        ],
        reward: 'Gym membership',
        createdAt: DateTime.now().subtract(const Duration(days: 6)),
        expiresAt: DateTime.now().add(const Duration(days: 30)),
        tags: ['fitness', 'health', 'motivation'],
      ),
    ];
  }
}
