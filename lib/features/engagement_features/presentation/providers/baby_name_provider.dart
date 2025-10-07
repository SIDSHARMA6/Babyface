import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/baby_name_entity.dart';
import '../../domain/usecases/generate_baby_names_usecase.dart';

/// Baby name state
class BabyNameState {
  final List<BabyNameEntity> names;
  final bool isLoading;
  final String? errorMessage;
  final BabyNameRequest? lastRequest;

  const BabyNameState({
    this.names = const [],
    this.isLoading = false,
    this.errorMessage,
    this.lastRequest,
  });

  BabyNameState copyWith({
    List<BabyNameEntity>? names,
    bool? isLoading,
    String? errorMessage,
    BabyNameRequest? lastRequest,
  }) {
    return BabyNameState(
      names: names ?? this.names,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      lastRequest: lastRequest ?? this.lastRequest,
    );
  }
}

/// Baby name notifier
class BabyNameNotifier extends StateNotifier<BabyNameState> {
  final GenerateBabyNamesUsecase _generateNamesUsecase;

  BabyNameNotifier(this._generateNamesUsecase) : super(const BabyNameState());

  /// Generate baby names
  Future<void> generateNames(BabyNameRequest request) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final names = await _generateNamesUsecase.execute(request);

      state = state.copyWith(
        names: names,
        isLoading: false,
        lastRequest: request,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Clear names
  void clearNames() {
    state = state.copyWith(names: []);
  }
}

/// Provider for generate baby names use case
final generateBabyNamesUsecaseProvider = Provider<GenerateBabyNamesUsecase>((ref) {
  // This would typically inject the repository
  throw UnimplementedError('GenerateBabyNamesUsecase must be provided');
});

/// Provider for baby name notifier
final babyNameProvider = StateNotifierProvider<BabyNameNotifier, BabyNameState>((ref) {
  final usecase = ref.watch(generateBabyNamesUsecaseProvider);
  return BabyNameNotifier(usecase);
});
