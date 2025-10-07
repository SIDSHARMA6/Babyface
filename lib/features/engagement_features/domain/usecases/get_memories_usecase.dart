import '../entities/memory_journal_entity.dart';

/// Get memories use case
/// Follows master plan clean architecture
class GetMemoriesUsecase {
  /// Execute get memories
  Future<List<MemoryJournalEntity>> execute() async {
    // Simulate loading time
    await Future.delayed(const Duration(milliseconds: 800));

    // Return sample memories for demo
    return [
      MemoryJournalEntity(
        id: '1',
        title: 'Our First Date',
        content: 'We went to that cute little café downtown. The coffee was amazing and we talked for hours. I knew right then that this was something special.',
        type: MemoryType.date,
        location: 'Downtown Café',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        tags: ['first', 'coffee', 'special'],
        isFavorite: true,
      ),
      MemoryJournalEntity(
        id: '2',
        title: 'Beach Vacation',
        content: 'Our first vacation together! The sunset was absolutely breathtaking. We built sandcastles and collected seashells like little kids.',
        type: MemoryType.vacation,
        location: 'Miami Beach',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        tags: ['vacation', 'beach', 'sunset'],
        isFavorite: true,
      ),
      MemoryJournalEntity(
        id: '3',
        title: 'Cooking Together',
        content: 'We tried to make pasta from scratch today. It was a disaster but we laughed so much! The kitchen was covered in flour.',
        type: MemoryType.everyday,
        location: 'Our Kitchen',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        tags: ['cooking', 'fun', 'messy'],
        isFavorite: false,
      ),
      MemoryJournalEntity(
        id: '4',
        title: 'Anniversary Dinner',
        content: 'One year together! We went to that fancy restaurant we always talked about. The food was incredible and the company was even better.',
        type: MemoryType.anniversary,
        location: 'The Grand Restaurant',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        tags: ['anniversary', 'fancy', 'celebration'],
        isFavorite: true,
      ),
    ];
  }
}
