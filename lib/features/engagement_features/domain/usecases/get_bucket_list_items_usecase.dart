import '../entities/couple_bucket_list_entity.dart';

/// Get bucket list items use case
/// Follows master plan clean architecture
class GetBucketListItemsUsecase {
  /// Execute get bucket list items
  Future<List<CoupleBucketListEntity>> execute() async {
    // Simulate loading time
    await Future.delayed(const Duration(milliseconds: 800));

    // Return sample bucket list items data for demo
    return [
      CoupleBucketListEntity(
        id: '1',
        title: 'Visit Paris Together',
        description:
            'Experience the City of Love with romantic walks along the Seine and visits to iconic landmarks',
        category: BucketListCategory.travel,
        status: BucketListStatus.planned,
        priority: 5,
        targetDate: DateTime(2024, 6, 1),
        location: 'Paris, France',
        estimatedCost: 3000.0,
        tags: ['romantic', 'travel', 'europe'],
        notes: 'Book flights and hotel for 1 week stay',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      CoupleBucketListEntity(
        id: '2',
        title: 'Go Skydiving',
        description:
            'Experience the ultimate adrenaline rush together with a tandem skydive',
        category: BucketListCategory.adventure,
        status: BucketListStatus.wishlist,
        priority: 4,
        targetDate: DateTime(2024, 8, 15),
        location: 'Local skydiving center',
        estimatedCost: 500.0,
        tags: ['adventure', 'thrilling', 'bucket-list'],
        notes: 'Need to check weight and health requirements',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
      CoupleBucketListEntity(
        id: '3',
        title: 'Learn to Dance',
        description:
            'Take ballroom dancing lessons together and perform at a local competition',
        category: BucketListCategory.romantic,
        status: BucketListStatus.inProgress,
        priority: 3,
        targetDate: DateTime(2024, 5, 30),
        location: 'Local dance studio',
        estimatedCost: 200.0,
        tags: ['romantic', 'learning', 'fun'],
        notes: 'Currently taking weekly lessons',
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
      ),
      CoupleBucketListEntity(
        id: '4',
        title: 'Try Every Restaurant in Our City',
        description: 'Visit and rate every restaurant in our hometown together',
        category: BucketListCategory.food,
        status: BucketListStatus.inProgress,
        priority: 2,
        targetDate: DateTime(2024, 12, 31),
        location: 'Our city',
        estimatedCost: 1500.0,
        tags: ['food', 'local', 'exploration'],
        notes: 'Started with 5 restaurants so far',
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
      ),
      CoupleBucketListEntity(
        id: '5',
        title: 'Watch Sunrise from a Mountain Peak',
        description: 'Hike to a mountain peak and watch the sunrise together',
        category: BucketListCategory.adventure,
        status: BucketListStatus.completed,
        priority: 4,
        targetDate: DateTime(2024, 3, 15),
        location: 'Blue Ridge Mountains',
        estimatedCost: 100.0,
        tags: ['nature', 'hiking', 'sunrise'],
        notes: 'Amazing experience! Will definitely do again',
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
        completedAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      CoupleBucketListEntity(
        id: '6',
        title: 'Attend a Music Festival',
        description:
            'Experience live music and camping together at a major music festival',
        category: BucketListCategory.entertainment,
        status: BucketListStatus.planned,
        priority: 3,
        targetDate: DateTime(2024, 7, 20),
        location: 'Coachella Valley',
        estimatedCost: 800.0,
        tags: ['music', 'festival', 'camping'],
        notes: 'Tickets purchased, need to plan camping gear',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      CoupleBucketListEntity(
        id: '7',
        title: 'Learn a New Language',
        description:
            'Master Spanish together for our future travels to South America',
        category: BucketListCategory.learning,
        status: BucketListStatus.wishlist,
        priority: 3,
        targetDate: DateTime(2024, 10, 31),
        location: 'Online course',
        estimatedCost: 150.0,
        tags: ['learning', 'language', 'travel'],
        notes: 'Planning to take online Spanish course',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
      CoupleBucketListEntity(
        id: '8',
        title: 'Run a Marathon Together',
        description: 'Train and complete a full marathon as a couple',
        category: BucketListCategory.fitness,
        status: BucketListStatus.planned,
        priority: 4,
        targetDate: DateTime(2024, 11, 15),
        location: 'Local marathon',
        estimatedCost: 200.0,
        tags: ['fitness', 'marathon', 'achievement'],
        notes: 'Need to start training program',
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
      ),
      CoupleBucketListEntity(
        id: '9',
        title: 'Create a Photo Book',
        description:
            'Compile all our favorite memories into a beautiful photo book',
        category: BucketListCategory.creative,
        status: BucketListStatus.inProgress,
        priority: 2,
        targetDate: DateTime(2024, 4, 30),
        location: 'Home',
        estimatedCost: 50.0,
        tags: ['memories', 'creative', 'photography'],
        notes: 'Collecting photos from the past year',
        createdAt: DateTime.now().subtract(const Duration(days: 40)),
      ),
      CoupleBucketListEntity(
        id: '10',
        title: 'Volunteer Together',
        description:
            'Spend time volunteering at a local charity or community organization',
        category: BucketListCategory.social,
        status: BucketListStatus.wishlist,
        priority: 3,
        targetDate: DateTime(2024, 9, 1),
        location: 'Local community center',
        estimatedCost: 0.0,
        tags: ['volunteering', 'community', 'giving-back'],
        notes: 'Research local volunteer opportunities',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
  }
}
