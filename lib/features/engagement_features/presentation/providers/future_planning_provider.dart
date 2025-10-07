import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/future_planning_entity.dart';
import '../../domain/usecases/get_future_goals_usecase.dart';
import '../../domain/usecases/add_future_goal_usecase.dart';
import '../../domain/usecases/update_future_goal_usecase.dart';

/// Future planning state
class FuturePlanningState {
  final List<FuturePlanningEntity> goals;
  final FuturePlanningCategory? selectedCategory;
  final bool isLoading;
  final String? errorMessage;

  const FuturePlanningState({
    this.goals = const [],
    this.selectedCategory,
    this.isLoading = false,
    this.errorMessage,
  });

  FuturePlanningState copyWith({
    List<FuturePlanningEntity>? goals,
    FuturePlanningCategory? selectedCategory,
    bool? isLoading,
    String? errorMessage,
  }) {
    return FuturePlanningState(
      goals: goals ?? this.goals,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Get filtered goals based on selected category
  List<FuturePlanningEntity> get filteredGoals {
    if (selectedCategory == null) return goals;
    return goals.where((goal) => goal.category == selectedCategory).toList();
  }

  /// Get overdue goals
  List<FuturePlanningEntity> get overdueGoals {
    return goals.where((goal) => goal.isOverdue).toList();
  }

  /// Get goals due soon
  List<FuturePlanningEntity> get goalsDueSoon {
    return goals.where((goal) => goal.isDueSoon).toList();
  }

  /// Get completed goals
  List<FuturePlanningEntity> get completedGoals {
    return goals
        .where((goal) => goal.status == FuturePlanningStatus.completed)
        .toList();
  }

  /// Get goals in progress
  List<FuturePlanningEntity> get inProgressGoals {
    return goals
        .where((goal) => goal.status == FuturePlanningStatus.inProgress)
        .toList();
  }
}

/// Future planning notifier
class FuturePlanningNotifier extends StateNotifier<FuturePlanningState> {
  final GetFutureGoalsUsecase _getGoalsUsecase;
  final AddFutureGoalUsecase _addGoalUsecase;
  final UpdateFutureGoalUsecase _updateGoalUsecase;

  FuturePlanningNotifier(
    this._getGoalsUsecase,
    this._addGoalUsecase,
    this._updateGoalUsecase,
  ) : super(const FuturePlanningState()) {
    loadGoals();
  }

  /// Load future goals
  Future<void> loadGoals() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final goals = await _getGoalsUsecase.execute();

      state = state.copyWith(
        goals: goals,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _getCuteErrorMessage(e.toString()),
      );
    }
  }

  /// Add new goal
  Future<void> addGoal(FuturePlanningRequest request) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      await _addGoalUsecase.execute(request);

      // Reload goals
      await loadGoals();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _getCuteErrorMessage(e.toString()),
      );
    }
  }

  /// Update goal
  Future<void> updateGoal(String goalId, FuturePlanningRequest request) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      await _updateGoalUsecase.execute(goalId, request);

      // Update local state
      final goals = state.goals.map((goal) {
        if (goal.id == goalId) {
          return goal.copyWith(
            title: request.title,
            description: request.description,
            category: request.category,
            targetDate: request.targetDate,
            priority: request.priority,
            tags: request.tags,
            notes: request.notes,
            updatedAt: DateTime.now(),
          );
        }
        return goal;
      }).toList();

      state = state.copyWith(
        goals: goals,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _getCuteErrorMessage(e.toString()),
      );
    }
  }

  /// Update goal status
  Future<void> updateGoalStatus(
      String goalId, FuturePlanningStatus status) async {
    try {
      // Update local state
      final goals = state.goals.map((goal) {
        if (goal.id == goalId) {
          return goal.copyWith(
            status: status,
            completedAt: status == FuturePlanningStatus.completed
                ? DateTime.now()
                : null,
            updatedAt: DateTime.now(),
          );
        }
        return goal;
      }).toList();

      state = state.copyWith(goals: goals);
    } catch (e) {
      state = state.copyWith(errorMessage: _getCuteErrorMessage(e.toString()));
    }
  }

  /// Delete goal
  Future<void> deleteGoal(String goalId) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      // Update local state
      final goals = state.goals.where((goal) => goal.id != goalId).toList();

      state = state.copyWith(
        goals: goals,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _getCuteErrorMessage(e.toString()),
      );
    }
  }

  /// Filter goals by category
  void filterByCategory(FuturePlanningCategory? category) {
    state = state.copyWith(selectedCategory: category);
  }

  /// Sort goals by priority
  void sortByPriority() {
    final goals = List<FuturePlanningEntity>.from(state.goals);
    goals.sort((a, b) => b.priority.compareTo(a.priority));
    state = state.copyWith(goals: goals);
  }

  /// Sort goals by due date
  void sortByDueDate() {
    final goals = List<FuturePlanningEntity>.from(state.goals);
    goals.sort((a, b) => a.targetDate.compareTo(b.targetDate));
    state = state.copyWith(goals: goals);
  }

  /// Sort goals by status
  void sortByStatus() {
    final goals = List<FuturePlanningEntity>.from(state.goals);
    goals.sort((a, b) => a.status.index.compareTo(b.status.index));
    state = state.copyWith(goals: goals);
  }

  /// Get goals by category
  List<FuturePlanningEntity> getGoalsByCategory(
      FuturePlanningCategory category) {
    return state.goals.where((goal) => goal.category == category).toList();
  }

  /// Get goals by status
  List<FuturePlanningEntity> getGoalsByStatus(FuturePlanningStatus status) {
    return state.goals.where((goal) => goal.status == status).toList();
  }

  /// Get goals due in next 30 days
  List<FuturePlanningEntity> getGoalsDueInNext30Days() {
    final now = DateTime.now();
    final thirtyDaysFromNow = now.add(const Duration(days: 30));

    return state.goals.where((goal) {
      return goal.targetDate.isAfter(now) &&
          goal.targetDate.isBefore(thirtyDaysFromNow) &&
          goal.status != FuturePlanningStatus.completed;
    }).toList();
  }

  /// Get completion rate
  double getCompletionRate() {
    if (state.goals.isEmpty) return 0.0;
    final completedCount = state.completedGoals.length;
    return completedCount / state.goals.length;
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Get cute error message for users
  String _getCuteErrorMessage(String error) {
    if (error.contains('network') || error.contains('connection')) {
      return 'Oops! Our dream connection got interrupted 💕 Try again in a moment!';
    } else if (error.contains('timeout')) {
      return 'Dreams take time to load! ⏰ Please try again, sweetheart!';
    } else if (error.contains('server')) {
      return 'Our dream server is taking a break 😴 Try again soon!';
    } else if (error.contains('permission')) {
      return 'We need your permission to save dreams 💖 Please check your settings!';
    } else {
      return 'Something went wrong, but our dreams are still strong! 💕 Try again!';
    }
  }
}

/// Provider for get future goals use case
final getFutureGoalsUsecaseProvider = Provider<GetFutureGoalsUsecase>((ref) {
  throw UnimplementedError('GetFutureGoalsUsecase must be provided');
});

/// Provider for add future goal use case
final addFutureGoalUsecaseProvider = Provider<AddFutureGoalUsecase>((ref) {
  throw UnimplementedError('AddFutureGoalUsecase must be provided');
});

/// Provider for update future goal use case
final updateFutureGoalUsecaseProvider =
    Provider<UpdateFutureGoalUsecase>((ref) {
  throw UnimplementedError('UpdateFutureGoalUsecase must be provided');
});

/// Provider for future planning notifier
final futurePlanningProvider =
    StateNotifierProvider<FuturePlanningNotifier, FuturePlanningState>((ref) {
  final getGoalsUsecase = ref.watch(getFutureGoalsUsecaseProvider);
  final addGoalUsecase = ref.watch(addFutureGoalUsecaseProvider);
  final updateGoalUsecase = ref.watch(updateFutureGoalUsecaseProvider);
  return FuturePlanningNotifier(
      getGoalsUsecase, addGoalUsecase, updateGoalUsecase);
});
