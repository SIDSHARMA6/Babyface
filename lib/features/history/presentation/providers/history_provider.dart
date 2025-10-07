import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/services/history_service.dart';
import '../../../../shared/models/baby_result.dart';

/// History state
class HistoryState {
  final List<BabyResult> results;
  final HistoryStats stats;
  final bool isLoading;
  final String? error;
  final HistoryFilter filter;
  final HistorySortBy sortBy;

  const HistoryState({
    this.results = const [],
    required this.stats,
    this.isLoading = false,
    this.error,
    this.filter = HistoryFilter.all,
    this.sortBy = HistorySortBy.newest,
  });

  HistoryState copyWith({
    List<BabyResult>? results,
    HistoryStats? stats,
    bool? isLoading,
    String? error,
    HistoryFilter? filter,
    HistorySortBy? sortBy,
  }) {
    return HistoryState(
      results: results ?? this.results,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      filter: filter ?? this.filter,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}

/// History notifier
class HistoryNotifier extends StateNotifier<HistoryState> {
  HistoryNotifier()
      : super(HistoryState(
            stats: HistoryStats(totalResults: 0, thisMonth: 0, thisWeek: 0))) {
    loadHistory();
  }

  /// Load history
  Future<void> loadHistory() async {
    state = state.copyWith(isLoading: true);
    try {
      final results = await HistoryService.getAllResults();
      final stats = HistoryStats(
        totalResults: results.length,
        thisMonth: results.length,
        thisWeek: results.length,
      );
      state = state.copyWith(
        results: results,
        stats: stats,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Refresh history
  Future<void> refreshHistory() async {
    await loadHistory();
  }

  /// Delete result
  Future<void> deleteResult(String id) async {
    try {
      await HistoryService.deleteResult(id);
      await loadHistory();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Clear all history
  Future<void> clearAll() async {
    try {
      await HistoryService.clearAll();
      await loadHistory();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Set filter
  void setFilter(HistoryFilter filter) {
    state = state.copyWith(filter: filter);
  }

  /// Set sort
  void setSortBy(HistorySortBy sortBy) {
    state = state.copyWith(sortBy: sortBy);
  }
}

/// History provider
final historyProvider = StateNotifierProvider<HistoryNotifier, HistoryState>(
  (ref) => HistoryNotifier(),
);
