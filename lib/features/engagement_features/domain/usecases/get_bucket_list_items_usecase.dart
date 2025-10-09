import '../entities/couple_bucket_list_entity.dart';
import 'dart:developer' as developer;
import '../../../../shared/services/bucket_list_service.dart';

/// Get bucket list items use case
/// Follows master plan clean architecture
class GetBucketListItemsUsecase {
  final BucketListService _bucketListService = BucketListService();

  /// Execute get bucket list items
  Future<List<CoupleBucketListEntity>> execute() async {
    try {
      // Get real bucket list items from BucketListService
      final bucketListItems = await _bucketListService.getAllBucketListItems();

      // Convert to CoupleBucketListEntity
      return bucketListItems
          .map((item) => CoupleBucketListEntity(
                id: item.id,
                title: item.title,
                description: item.description,
                category: _mapBucketListCategory(item.category),
                status: _mapBucketListStatus(item.status),
                priority: item.priority,
                targetDate: item.targetDate,
                location: item.location ?? '',
                estimatedCost: item.estimatedCost ?? 0.0,
                tags: item.tags ?? [],
                notes: item.notes ?? '',
                createdAt: item.createdAt,
              ))
          .toList();
    } catch (e) {
      developer.log('Error getting bucket list items: $e');
      return [];
    }
  }

  /// Map bucket list category from service to entity
  BucketListCategory _mapBucketListCategory(String category) {
    switch (category.toLowerCase()) {
      case 'travel':
        return BucketListCategory.travel;
      case 'adventure':
        return BucketListCategory.adventure;
      case 'food':
        return BucketListCategory.food;
      case 'entertainment':
        return BucketListCategory.entertainment;
      case 'learning':
        return BucketListCategory.learning;
      case 'fitness':
        return BucketListCategory.fitness;
      case 'romantic':
        return BucketListCategory.romantic;
      case 'personal':
        return BucketListCategory.personal;
      default:
        return BucketListCategory.travel;
    }
  }

  /// Map bucket list status from service to entity
  BucketListStatus _mapBucketListStatus(String status) {
    switch (status.toLowerCase()) {
      case 'planned':
        return BucketListStatus.planned;
      case 'in_progress':
        return BucketListStatus.inProgress;
      case 'completed':
        return BucketListStatus.completed;
      case 'cancelled':
        return BucketListStatus.cancelled;
      case 'wishlist':
        return BucketListStatus.wishlist;
      default:
        return BucketListStatus.planned;
    }
  }
}
