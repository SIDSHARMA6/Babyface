import '../entities/anniversary_entity.dart';

/// Get anniversaries use case
/// Follows master plan clean architecture
class GetAnniversariesUsecase {
  /// Execute get anniversaries
  Future<List<AnniversaryEntity>> execute() async {
    // Simulate loading time
    await Future.delayed(const Duration(milliseconds: 800));

    // Return sample anniversaries data for demo
    return [
      AnniversaryEntity(
        id: '1',
        title: 'Our First Date',
        description: 'The day we first met and fell in love',
        date: DateTime(2020, 3, 15),
        type: AnniversaryType.firstDate,
        years: 4,
        tags: ['romantic', 'special'],
        createdAt: DateTime.now(),
      ),
      AnniversaryEntity(
        id: '2',
        title: 'Moving In Together',
        description: 'The day we decided to share our lives under one roof',
        date: DateTime(2021, 8, 20),
        type: AnniversaryType.movingIn,
        years: 3,
        tags: ['milestone', 'commitment'],
        createdAt: DateTime.now(),
      ),
      AnniversaryEntity(
        id: '3',
        title: 'Our Engagement',
        description:
            'The magical moment when we decided to spend forever together',
        date: DateTime(2022, 12, 25),
        type: AnniversaryType.engagement,
        years: 2,
        tags: ['engagement', 'christmas'],
        createdAt: DateTime.now(),
      ),
      AnniversaryEntity(
        id: '4',
        title: 'Our Wedding Day',
        description: 'The most beautiful day of our lives',
        date: DateTime(2023, 6, 10),
        type: AnniversaryType.marriage,
        years: 1,
        tags: ['wedding', 'summer'],
        createdAt: DateTime.now(),
      ),
      AnniversaryEntity(
        id: '5',
        title: 'First Kiss',
        description: 'The moment that changed everything',
        date: DateTime(2020, 3, 20),
        type: AnniversaryType.firstKiss,
        years: 4,
        tags: ['romantic', 'first'],
        createdAt: DateTime.now(),
      ),
    ];
  }
}
