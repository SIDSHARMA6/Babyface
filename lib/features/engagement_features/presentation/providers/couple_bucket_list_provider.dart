import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/couple_bucket_list_entity.dart';
import '../../domain/usecases/get_bucket_list_items_usecase.dart';
import '../../domain/usecases/add_bucket_list_item_usecase.dart';
import '../../domain/usecases/update_bucket_list_item_usecase.dart';

/// Couple bucket list state
class CoupleBucketListState {
  final List<CoupleBucketListEntity> bucketList;
  final BucketListCategory? selectedCategory;
  final bool isLoading;
  final String? errorMessage;

  const CoupleBucketListState({
    this.bucketList = const [],
    this.selectedCategory,
    this.isLoading = false,
    this.errorMessage,
  });

  CoupleBucketListState copyWith({
    List<CoupleBucketListEntity>? bucketList,
    BucketListCategory? selectedCategory,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CoupleBucketListState(
      bucketList: bucketList ?? this.bucketList,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Get filtered bucket list based on selected category
  List<CoupleBucketListEntity> get filteredBucketList {
    if (selectedCategory == null) return bucketList;
    return bucketList
        .where((item) => item.category == selectedCategory)
        .toList();
  }

  /// Get completed items
  List<CoupleBucketListEntity> get completedItems {
    return bucketList
        .where((item) => item.status == BucketListStatus.completed)
        .toList();
  }

  /// Get items in progress
  List<CoupleBucketListEntity> get inProgressItems {
    return bucketList
        .where((item) => item.status == BucketListStatus.inProgress)
        .toList();
  }

  /// Get wishlist items
  List<CoupleBucketListEntity> get wishlistItems {
    return bucketList
        .where((item) => item.status == BucketListStatus.wishlist)
        .toList();
  }

  /// Get overdue items
  List<CoupleBucketListEntity> get overdueItems {
    return bucketList.where((item) => item.isOverdue).toList();
  }

  /// Get items due soon
  List<CoupleBucketListEntity> get itemsDueSoon {
    return bucketList.where((item) => item.isDueSoon).toList();
  }
}

/// Couple bucket list notifier
class CoupleBucketListNotifier extends StateNotifier<CoupleBucketListState> {
  final GetBucketListItemsUsecase _getItemsUsecase;
  final AddBucketListItemUsecase _addItemUsecase;
  final UpdateBucketListItemUsecase _updateItemUsecase;

  CoupleBucketListNotifier(
    this._getItemsUsecase,
    this._addItemUsecase,
    this._updateItemUsecase,
  ) : super(const CoupleBucketListState()) {
    loadBucketList();
  }

  /// Load bucket list items
  Future<void> loadBucketList() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final items = await _getItemsUsecase.execute();

      state = state.copyWith(
        bucketList: items,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _getCuteErrorMessage(e.toString()),
      );
    }
  }

  /// Add new bucket list item
  Future<void> addItem(CoupleBucketListRequest request) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      await _addItemUsecase.execute(request);

      // Reload bucket list
      await loadBucketList();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _getCuteErrorMessage(e.toString()),
      );
    }
  }

  /// Update bucket list item
  Future<void> updateItem(
      String itemId, CoupleBucketListRequest request) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      await _updateItemUsecase.execute(itemId, request);

      // Update local state
      final items = state.bucketList.map((item) {
        if (item.id == itemId) {
          return item.copyWith(
            title: request.title,
            description: request.description,
            category: request.category,
            priority: request.priority,
            targetDate: request.targetDate,
            location: request.location,
            estimatedCost: request.estimatedCost,
            tags: request.tags,
            notes: request.notes,
            updatedAt: DateTime.now(),
          );
        }
        return item;
      }).toList();

      state = state.copyWith(
        bucketList: items,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _getCuteErrorMessage(e.toString()),
      );
    }
  }

  /// Update item status
  Future<void> updateItemStatus(String itemId, BucketListStatus status) async {
    try {
      // Update local state
      final items = state.bucketList.map((item) {
        if (item.id == itemId) {
          return item.copyWith(
            status: status,
            completedAt:
                status == BucketListStatus.completed ? DateTime.now() : null,
            updatedAt: DateTime.now(),
          );
        }
        return item;
      }).toList();

      state = state.copyWith(bucketList: items);
    } catch (e) {
      state = state.copyWith(errorMessage: _getCuteErrorMessage(e.toString()));
    }
  }

  /// Delete bucket list item
  Future<void> deleteItem(String itemId) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      // Update local state
      final items =
          state.bucketList.where((item) => item.id != itemId).toList();

      state = state.copyWith(
        bucketList: items,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _getCuteErrorMessage(e.toString()),
      );
    }
  }

  /// Filter items by category
  void filterByCategory(BucketListCategory? category) {
    state = state.copyWith(selectedCategory: category);
  }

  /// Sort items by priority
  void sortByPriority() {
    final items = List<CoupleBucketListEntity>.from(state.bucketList);
    items.sort((a, b) => b.priority.compareTo(a.priority));
    state = state.copyWith(bucketList: items);
  }

  /// Sort items by due date
  void sortByDueDate() {
    final items = List<CoupleBucketListEntity>.from(state.bucketList);
    items.sort((a, b) {
      if (a.targetDate == null && b.targetDate == null) return 0;
      if (a.targetDate == null) return 1;
      if (b.targetDate == null) return -1;
      return a.targetDate!.compareTo(b.targetDate!);
    });
    state = state.copyWith(bucketList: items);
  }

  /// Sort items by status
  void sortByStatus() {
    final items = List<CoupleBucketListEntity>.from(state.bucketList);
    items.sort((a, b) => a.status.index.compareTo(b.status.index));
    state = state.copyWith(bucketList: items);
  }

  /// Get items by category
  List<CoupleBucketListEntity> getItemsByCategory(BucketListCategory category) {
    return state.bucketList.where((item) => item.category == category).toList();
  }

  /// Get items by status
  List<CoupleBucketListEntity> getItemsByStatus(BucketListStatus status) {
    return state.bucketList.where((item) => item.status == status).toList();
  }

  /// Get items due in next 30 days
  List<CoupleBucketListEntity> getItemsDueInNext30Days() {
    final now = DateTime.now();
    final thirtyDaysFromNow = now.add(const Duration(days: 30));

    return state.bucketList.where((item) {
      if (item.targetDate == null) return false;
      return item.targetDate!.isAfter(now) &&
          item.targetDate!.isBefore(thirtyDaysFromNow) &&
          item.status != BucketListStatus.completed;
    }).toList();
  }

  /// Get completion rate
  double getCompletionRate() {
    if (state.bucketList.isEmpty) return 0.0;
    final completedCount = state.completedItems.length;
    return completedCount / state.bucketList.length;
  }

  /// Get total estimated cost
  double getTotalEstimatedCost() {
    return state.bucketList
        .where((item) =>
            item.estimatedCost != null &&
            item.status != BucketListStatus.completed)
        .fold(0.0, (sum, item) => sum + item.estimatedCost!);
  }

  /// Get completed cost
  double getCompletedCost() {
    return state.bucketList
        .where((item) =>
            item.estimatedCost != null &&
            item.status == BucketListStatus.completed)
        .fold(0.0, (sum, item) => sum + item.estimatedCost!);
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Get cute error message for users
  String _getCuteErrorMessage(String error) {
    if (error.contains('network') || error.contains('connection')) {
      return 'Oops! Our adventure connection got interrupted 💕 Try again in a moment!';
    } else if (error.contains('timeout')) {
      return 'Adventures take time to load! ⏰ Please try again, sweetheart!';
    } else if (error.contains('server')) {
      return 'Our adventure server is taking a break 😴 Try again soon!';
    } else if (error.contains('permission')) {
      return 'We need your permission to save adventures 💖 Please check your settings!';
    } else {
      return 'Something went wrong, but our adventures are still strong! 💕 Try again!';
    }
  }
}

/// Provider for get bucket list items use case
final getBucketListItemsUsecaseProvider =
    Provider<GetBucketListItemsUsecase>((ref) {
  throw UnimplementedError('GetBucketListItemsUsecase must be provided');
});

/// Provider for add bucket list item use case
final addBucketListItemUsecaseProvider =
    Provider<AddBucketListItemUsecase>((ref) {
  throw UnimplementedError('AddBucketListItemUsecase must be provided');
});

/// Provider for update bucket list item use case
final updateBucketListItemUsecaseProvider =
    Provider<UpdateBucketListItemUsecase>((ref) {
  throw UnimplementedError('UpdateBucketListItemUsecase must be provided');
});

/// Provider for couple bucket list notifier
final coupleBucketListProvider =
    StateNotifierProvider<CoupleBucketListNotifier, CoupleBucketListState>(
        (ref) {
  final getItemsUsecase = ref.watch(getBucketListItemsUsecaseProvider);
  final addItemUsecase = ref.watch(addBucketListItemUsecaseProvider);
  final updateItemUsecase = ref.watch(updateBucketListItemUsecaseProvider);
  return CoupleBucketListNotifier(
      getItemsUsecase, addItemUsecase, updateItemUsecase);
});
