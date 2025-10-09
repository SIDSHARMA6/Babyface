import '../entities/memory_journal_entity.dart';
import 'dart:developer' as developer;
import '../../../../shared/services/simple_memory_service.dart';

/// Get memories use case
/// Follows master plan clean architecture
class GetMemoriesUsecase {
  final SimpleMemoryService _memoryService = SimpleMemoryService();

  /// Execute get memories
  Future<List<MemoryJournalEntity>> execute() async {
    try {
      // Get real memories from SimpleMemoryService
      final memories = await SimpleMemoryService.getAllMemoriesWithSync();

      // Convert to MemoryJournalEntity
      return memories
          .map((memory) => MemoryJournalEntity(
                id: memory.id,
                title: memory.title,
                content: memory.description,
                type: _mapMemoryType(memory.mood),
                location: '',
                createdAt:
                    DateTime.fromMillisecondsSinceEpoch(memory.timestamp),
                tags: [],
                isFavorite: memory.isFavorite,
              ))
          .toList();
    } catch (e) {
      developer.log('Error getting memories: $e');
      return [];
    }
  }

  /// Map memory type from service to entity
  MemoryType _mapMemoryType(String type) {
    switch (type.toLowerCase()) {
      case 'date':
        return MemoryType.date;
      case 'vacation':
        return MemoryType.vacation;
      case 'anniversary':
        return MemoryType.anniversary;
      case 'everyday':
        return MemoryType.everyday;
      case 'milestone':
        return MemoryType.milestone;
      default:
        return MemoryType.everyday;
    }
  }
}
