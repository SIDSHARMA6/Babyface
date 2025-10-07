import '../entities/future_planning_entity.dart';

/// Get future goals use case
/// Follows master plan clean architecture
class GetFutureGoalsUsecase {
  /// Execute get future goals
  Future<List<FuturePlanningEntity>> execute() async {
    // Simulate loading time
    await Future.delayed(const Duration(milliseconds: 800));

    // Return sample future goals data for demo
    return [
      FuturePlanningEntity(
        id: '1',
        title: 'Buy Our Dream Home',
        description:
            'Save up and purchase our first home together with a beautiful garden',
        category: FuturePlanningCategory.home,
        targetDate: DateTime(2025, 12, 31),
        status: FuturePlanningStatus.inProgress,
        priority: 5,
        tags: ['home', 'investment', 'family'],
        notes: 'Need to save \$50,000 for down payment',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      FuturePlanningEntity(
        id: '2',
        title: 'Plan Our Wedding',
        description: 'Organize the perfect wedding ceremony and reception',
        category: FuturePlanningCategory.relationship,
        targetDate: DateTime(2024, 6, 15),
        status: FuturePlanningStatus.planning,
        priority: 5,
        tags: ['wedding', 'celebration', 'love'],
        notes: 'Venue booked for June 15th, 2024',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      FuturePlanningEntity(
        id: '3',
        title: 'Travel to Japan',
        description:
            'Experience the beautiful culture and cuisine of Japan together',
        category: FuturePlanningCategory.travel,
        targetDate: DateTime(2024, 9, 1),
        status: FuturePlanningStatus.inProgress,
        priority: 4,
        tags: ['travel', 'culture', 'adventure'],
        notes: 'Book flights and accommodation for 2 weeks',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
      FuturePlanningEntity(
        id: '4',
        title: 'Start a Family',
        description: 'Prepare for and welcome our first child',
        category: FuturePlanningCategory.family,
        targetDate: DateTime(2025, 3, 1),
        status: FuturePlanningStatus.planning,
        priority: 5,
        tags: ['family', 'baby', 'future'],
        notes: 'Need to prepare nursery and save for baby expenses',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      FuturePlanningEntity(
        id: '5',
        title: 'Learn to Cook Together',
        description: 'Take cooking classes and master new recipes as a couple',
        category: FuturePlanningCategory.hobbies,
        targetDate: DateTime(2024, 4, 30),
        status: FuturePlanningStatus.completed,
        priority: 3,
        tags: ['cooking', 'learning', 'fun'],
        notes: 'Completed Italian cuisine course!',
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        completedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      FuturePlanningEntity(
        id: '6',
        title: 'Get Fit Together',
        description: 'Join a gym and maintain a healthy lifestyle as a couple',
        category: FuturePlanningCategory.health,
        targetDate: DateTime(2024, 12, 31),
        status: FuturePlanningStatus.inProgress,
        priority: 4,
        tags: ['health', 'fitness', 'wellness'],
        notes: 'Joined local gym, going 3 times per week',
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
      ),
      FuturePlanningEntity(
        id: '7',
        title: 'Save for Retirement',
        description: 'Start building our retirement fund together',
        category: FuturePlanningCategory.finance,
        targetDate: DateTime(2050, 1, 1),
        status: FuturePlanningStatus.inProgress,
        priority: 4,
        tags: ['finance', 'retirement', 'investment'],
        notes: 'Setting aside \$500 per month',
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
      ),
      FuturePlanningEntity(
        id: '8',
        title: 'Learn a New Language',
        description: 'Master Spanish together for our future travels',
        category: FuturePlanningCategory.education,
        targetDate: DateTime(2024, 8, 31),
        status: FuturePlanningStatus.planning,
        priority: 3,
        tags: ['education', 'language', 'travel'],
        notes: 'Planning to take online Spanish course',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
    ];
  }
}
