import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'dart:developer' as developer;
import '../../shared/services/hive_service.dart';
import '../../shared/services/performance_service.dart';

/// Navigation state class
class NavigationState {
  final int currentIndex;
  final bool isAnimating;
  final DateTime lastUpdated;

  const NavigationState({
    this.currentIndex = 0,
    this.isAnimating = false,
    required this.lastUpdated,
  });

  NavigationState copyWith({
    int? currentIndex,
    bool? isAnimating,
    DateTime? lastUpdated,
  }) {
    return NavigationState(
      currentIndex: currentIndex ?? this.currentIndex,
      isAnimating: isAnimating ?? this.isAnimating,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NavigationState &&
        other.currentIndex == currentIndex &&
        other.isAnimating == isAnimating &&
        other.lastUpdated == lastUpdated;
  }

  @override
  int get hashCode {
    return currentIndex.hashCode ^ isAnimating.hashCode ^ lastUpdated.hashCode;
  }
}

/// Navigation notifier with Hive persistence
class NavigationNotifier extends StateNotifier<NavigationState> {
  final HiveService _hiveService;
  static const String _boxName = 'navigation_state';
  static const String _currentIndexKey = 'current_index';

  NavigationNotifier(this._hiveService)
      : super(NavigationState(lastUpdated: DateTime.now())) {
    // Always start at Dashboard (index 0) for better UX
    _resetToHome();
  }

  /// Load navigation state from Hive
  Future<void> _loadFromHive() async {
    try {
      final savedIndex = _hiveService.retrieve(_boxName, _currentIndexKey);
      if (savedIndex != null) {
        state = state.copyWith(
          currentIndex: savedIndex as int,
          lastUpdated: DateTime.now(),
        );
      }
    } catch (e) {
      // Failed to load navigation state: $e
    }
  }

  /// Save navigation state to Hive
  Future<void> _saveToHive() async {
    try {
      await _hiveService.store(_boxName, _currentIndexKey, state.currentIndex);
    } catch (e) {
      // Failed to save navigation state: $e
    }
  }

  /// Set current navigation index with optimized performance and haptic feedback
  void setCurrentIndex(int index) {
    developer.log('🔐 [NavigationProvider] Setting current index to: $index');

    if (state.currentIndex != index) {
      // Add haptic feedback for smooth navigation
      HapticFeedback.lightImpact();

      state = state.copyWith(
        currentIndex: index,
        lastUpdated: DateTime.now(),
      );

      developer.log(
          '🔐 [NavigationProvider] State updated - currentIndex: ${state.currentIndex}');

      // Save to Hive with performance monitoring
      PerformanceService.measureBuildTime('NavigationPersistence', () {
        _saveToHive();
      });
    }
  }

  /// Reset to home tab
  void _resetToHome() {
    developer.log('🔐 [NavigationProvider] Resetting to home tab (Dashboard)');
    state = state.copyWith(
      currentIndex: 0, // Dashboard is always index 0
      lastUpdated: DateTime.now(),
    );
    _saveToHive();
  }

  /// Reset to home tab
  void resetToHome() {
    setCurrentIndex(0);
  }

  /// Set animation state
  void setAnimating(bool isAnimating) {
    if (state.isAnimating != isAnimating) {
      state = state.copyWith(
        isAnimating: isAnimating,
        lastUpdated: DateTime.now(),
      );
    }
  }

  /// Get current tab name
  String getCurrentTabName() {
    switch (state.currentIndex) {
      case 0:
        return 'Home';
      case 1:
        return 'History';
      case 2:
        return 'Quiz';
      case 3:
        return 'Goals';
      case 4:
        return 'Profile';
      default:
        return 'Unknown';
    }
  }

  /// Check if tab is active
  bool isTabActive(int index) {
    return state.currentIndex == index;
  }

  /// Get tab icon based on state
  String getTabIcon(int index, bool isActive) {
    switch (index) {
      case 0:
        return isActive ? 'home' : 'home_outline';
      case 1:
        return isActive ? 'history' : 'history_outline';
      case 2:
        return isActive ? 'quiz' : 'quiz_outline';
      case 3:
        return isActive ? 'favorite' : 'favorite_outline';
      case 4:
        return isActive ? 'person' : 'person_outline';
      default:
        return 'home_outline';
    }
  }
}

/// Navigation provider for Riverpod
final navigationProvider =
    StateNotifierProvider<NavigationNotifier, NavigationState>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return NavigationNotifier(hiveService);
});

/// Current navigation index provider
final currentNavigationIndexProvider = Provider<int>((ref) {
  return ref.watch(navigationProvider).currentIndex;
});

/// Navigation animation state provider
final navigationAnimationProvider = Provider<bool>((ref) {
  return ref.watch(navigationProvider).isAnimating;
});

/// Current tab name provider
final currentTabNameProvider = Provider<String>((ref) {
  final notifier = ref.watch(navigationProvider.notifier);
  return notifier.getCurrentTabName();
});
