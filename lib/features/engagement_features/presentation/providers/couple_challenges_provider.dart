import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/couple_challenge_entity.dart';
import '../../domain/usecases/get_challenges_usecase.dart';
import '../../domain/usecases/start_challenge_usecase.dart';

/// Couple challenges state
class CoupleChallengesState {
  final List<CoupleChallengeEntity> challenges;
  final bool isLoading;
  final String? errorMessage;

  const CoupleChallengesState({
    this.challenges = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  CoupleChallengesState copyWith({
    List<CoupleChallengeEntity>? challenges,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CoupleChallengesState(
      challenges: challenges ?? this.challenges,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Couple challenges notifier
class CoupleChallengesNotifier extends StateNotifier<CoupleChallengesState> {
  final GetChallengesUsecase _getChallengesUsecase;
  final StartChallengeUsecase _startChallengeUsecase;

  CoupleChallengesNotifier(
    this._getChallengesUsecase,
    this._startChallengeUsecase,
  ) : super(const CoupleChallengesState()) {
    loadChallenges();
  }

  /// Load all challenges
  Future<void> loadChallenges() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final challenges = await _getChallengesUsecase.execute();

      state = state.copyWith(
        challenges: challenges,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Start a challenge
  Future<void> startChallenge(String challengeId) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      await _startChallengeUsecase.execute(challengeId);

      // Update challenge status
      final challenges = state.challenges.map((challenge) {
        if (challenge.id == challengeId) {
          return challenge.copyWith(
            isCompleted: true,
            completedAt: DateTime.now(),
          );
        }
        return challenge;
      }).toList();

      state = state.copyWith(
        challenges: challenges,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Filter challenges
  void filterChallenges(CoupleChallengeRequest request) {
    // This would typically call a filtered use case
    // For now, we'll just reload all challenges
    loadChallenges();
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Provider for get challenges use case
final getChallengesUsecaseProvider = Provider<GetChallengesUsecase>((ref) {
  throw UnimplementedError('GetChallengesUsecase must be provided');
});

/// Provider for start challenge use case
final startChallengeUsecaseProvider = Provider<StartChallengeUsecase>((ref) {
  throw UnimplementedError('StartChallengeUsecase must be provided');
});

/// Provider for couple challenges notifier
final coupleChallengesProvider =
    StateNotifierProvider<CoupleChallengesNotifier, CoupleChallengesState>(
        (ref) {
  final getUsecase = ref.watch(getChallengesUsecaseProvider);
  final startUsecase = ref.watch(startChallengeUsecaseProvider);

  return CoupleChallengesNotifier(getUsecase, startUsecase);
});
