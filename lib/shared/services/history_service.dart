import '../models/baby_result.dart';

/// History service for managing baby generation results
class HistoryService {
  static final List<BabyResult> _results = [];

  /// Get all baby results
  static Future<List<BabyResult>> getAllResults() async {
    return List.from(_results);
  }

  /// Add a new result
  static Future<void> addResult(BabyResult result) async {
    _results.add(result);
  }

  /// Delete a result
  static Future<void> deleteResult(String id) async {
    _results.removeWhere((result) => result.id == id);
  }

  /// Clear all results
  static Future<void> clearAll() async {
    _results.clear();
  }

  /// Get results count
  static int getResultsCount() {
    return _results.length;
  }
}

/// History statistics
class HistoryStats {
  final int totalResults;
  final int thisMonth;
  final int thisWeek;

  HistoryStats({
    required this.totalResults,
    required this.thisMonth,
    required this.thisWeek,
  });
}

/// History filter options
enum HistoryFilter {
  all,
  thisWeek,
  thisMonth,
  processing,
  completed,
}

/// History sort options
enum HistorySortBy {
  newest,
  oldest,
  maleMatch,
  femaleMatch,
}
