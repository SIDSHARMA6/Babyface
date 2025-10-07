import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/growth_timeline_entity.dart';
import '../../domain/usecases/get_growth_timeline_usecase.dart';

/// Growth timeline state
class GrowthTimelineState {
  final List<GrowthTimelineEntity> timeline;
  final bool isLoading;
  final String? errorMessage;

  const GrowthTimelineState({
    this.timeline = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  GrowthTimelineState copyWith({
    List<GrowthTimelineEntity>? timeline,
    bool? isLoading,
    String? errorMessage,
  }) {
    return GrowthTimelineState(
      timeline: timeline ?? this.timeline,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Growth timeline notifier
class GrowthTimelineNotifier extends StateNotifier<GrowthTimelineState> {
  final GetGrowthTimelineUsecase _getTimelineUsecase;

  GrowthTimelineNotifier(this._getTimelineUsecase)
      : super(const GrowthTimelineState()) {
    loadTimeline();
  }

  /// Load growth timeline
  Future<void> loadTimeline() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final timeline = await _getTimelineUsecase.execute();

      state = state.copyWith(
        timeline: timeline,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Filter timeline by month
  void filterByMonth(int month) {
    // Implementation for filtering by month
  }

  /// Filter timeline by gender
  void filterByGender(String gender) {
    // Implementation for filtering by gender
  }

  /// Mark milestone as completed
  Future<void> markMilestoneCompleted(String timelineId) async {
    try {
      // Update local state
      final timeline = state.timeline.map((item) {
        if (item.id == timelineId) {
          return item.copyWith(
            isCompleted: true,
            completedAt: DateTime.now(),
          );
        }
        return item;
      }).toList();

      state = state.copyWith(timeline: timeline);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Provider for get growth timeline use case
final getGrowthTimelineUsecaseProvider =
    Provider<GetGrowthTimelineUsecase>((ref) {
  throw UnimplementedError('GetGrowthTimelineUsecase must be provided');
});

/// Provider for growth timeline notifier
final growthTimelineProvider =
    StateNotifierProvider<GrowthTimelineNotifier, GrowthTimelineState>((ref) {
  final usecase = ref.watch(getGrowthTimelineUsecaseProvider);
  return GrowthTimelineNotifier(usecase);
});
