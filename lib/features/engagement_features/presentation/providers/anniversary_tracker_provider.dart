import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/anniversary_entity.dart';
import '../../domain/usecases/get_anniversaries_usecase.dart';
import '../../domain/usecases/add_anniversary_usecase.dart';

/// Anniversary tracker state
class AnniversaryTrackerState {
  final List<AnniversaryEntity> anniversaries;
  final bool isLoading;
  final String? errorMessage;

  const AnniversaryTrackerState({
    this.anniversaries = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  AnniversaryTrackerState copyWith({
    List<AnniversaryEntity>? anniversaries,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AnniversaryTrackerState(
      anniversaries: anniversaries ?? this.anniversaries,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Anniversary tracker notifier
class AnniversaryTrackerNotifier
    extends StateNotifier<AnniversaryTrackerState> {
  final GetAnniversariesUsecase _getAnniversariesUsecase;
  final AddAnniversaryUsecase _addAnniversaryUsecase;

  AnniversaryTrackerNotifier(
    this._getAnniversariesUsecase,
    this._addAnniversaryUsecase,
  ) : super(const AnniversaryTrackerState()) {
    loadAnniversaries();
  }

  /// Load anniversaries
  Future<void> loadAnniversaries() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final anniversaries = await _getAnniversariesUsecase.execute();

      state = state.copyWith(
        anniversaries: anniversaries,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Add anniversary
  Future<void> addAnniversary(AnniversaryRequest request) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      await _addAnniversaryUsecase.execute(request);

      // Reload anniversaries
      await loadAnniversaries();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Update anniversary
  Future<void> updateAnniversary(String id, AnniversaryRequest request) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      // Update local state
      final anniversaries = state.anniversaries.map((anniversary) {
        if (anniversary.id == id) {
          return anniversary.copyWith(
            title: request.title,
            description: request.description,
            date: request.date,
            type: request.type,
            imageUrl: request.imageUrl,
            tags: request.tags,
            isRecurring: request.isRecurring,
            updatedAt: DateTime.now(),
          );
        }
        return anniversary;
      }).toList();

      state = state.copyWith(
        anniversaries: anniversaries,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Delete anniversary
  Future<void> deleteAnniversary(String id) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      // Update local state
      final anniversaries = state.anniversaries
          .where((anniversary) => anniversary.id != id)
          .toList();

      state = state.copyWith(
        anniversaries: anniversaries,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Mark anniversary as completed
  Future<void> markAnniversaryCompleted(String id) async {
    try {
      // Update local state
      final anniversaries = state.anniversaries.map((anniversary) {
        if (anniversary.id == id) {
          return anniversary.copyWith(
            isCompleted: true,
            completedAt: DateTime.now(),
          );
        }
        return anniversary;
      }).toList();

      state = state.copyWith(anniversaries: anniversaries);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  /// Get upcoming anniversaries
  List<AnniversaryEntity> getUpcomingAnniversaries() {
    return state.anniversaries
        .where((anniversary) => anniversary.isUpcoming)
        .toList();
  }

  /// Get today's anniversaries
  List<AnniversaryEntity> getTodaysAnniversaries() {
    return state.anniversaries
        .where((anniversary) => anniversary.isToday)
        .toList();
  }

  /// Filter anniversaries by type
  List<AnniversaryEntity> filterByType(AnniversaryType type) {
    return state.anniversaries
        .where((anniversary) => anniversary.type == type)
        .toList();
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Provider for get anniversaries use case
final getAnniversariesUsecaseProvider =
    Provider<GetAnniversariesUsecase>((ref) {
  throw UnimplementedError('GetAnniversariesUsecase must be provided');
});

/// Provider for add anniversary use case
final addAnniversaryUsecaseProvider = Provider<AddAnniversaryUsecase>((ref) {
  throw UnimplementedError('AddAnniversaryUsecase must be provided');
});

/// Provider for anniversary tracker notifier
final anniversaryTrackerProvider =
    StateNotifierProvider<AnniversaryTrackerNotifier, AnniversaryTrackerState>(
        (ref) {
  final getUsecase = ref.watch(getAnniversariesUsecaseProvider);
  final addUsecase = ref.watch(addAnniversaryUsecaseProvider);
  return AnniversaryTrackerNotifier(getUsecase, addUsecase);
});
