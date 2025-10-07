import 'package:uuid/uuid.dart';
import '../entities/memory_journal_entity.dart';

/// Add memory use case
/// Follows master plan clean architecture
class AddMemoryUsecase {
  /// Execute add memory
  Future<MemoryJournalEntity> execute(MemoryJournalRequest request) async {
    // Simulate processing time
    await Future.delayed(const Duration(milliseconds: 500));

    final memory = MemoryJournalEntity(
      id: const Uuid().v4(),
      title: request.title,
      content: request.content,
      imagePaths: request.imagePaths,
      createdAt: DateTime.now(),
      type: request.type,
      location: request.location,
      tags: request.tags,
    );

    // In a real implementation, this would save to the repository
    // For now, we'll just return the created memory
    
    return memory;
  }
}
