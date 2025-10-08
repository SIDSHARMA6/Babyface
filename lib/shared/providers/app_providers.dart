import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../services/hive_service.dart';
import '../services/firebase_service.dart';
import '../services/analytics_service.dart';
import '../services/baby_generation_service.dart';
import '../services/ai_baby_generation_service.dart';
import '../services/advanced_ai_baby_service.dart';
import '../services/face_detection_service.dart';
import '../services/feature_extraction_service.dart';
import '../services/indian_adaptation_service.dart';
import '../services/age_simulation_service.dart';
import '../services/image_service.dart';
import '../services/storage_service.dart';
import '../services/sharing_service.dart';
import '../services/history_service.dart';
import '../services/quiz_service.dart';
import '../models/baby_result.dart';
import '../models/user_profile.dart';
import '../providers/login_provider.dart';

/// Core service providers
final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});

final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});

/// Baby generation service providers
final babyGenerationServiceProvider = Provider<BabyGenerationService>((ref) {
  return BabyGenerationService();
});

final aiBabyGenerationServiceProvider =
    Provider<AIBabyGenerationService>((ref) {
  return AIBabyGenerationService();
});

final advancedAIBabyServiceProvider = Provider<AdvancedAIBabyService>((ref) {
  return AdvancedAIBabyService();
});

/// AI/ML service providers
final faceDetectionServiceProvider = Provider<FaceDetectionService>((ref) {
  return FaceDetectionService();
});

final featureExtractionServiceProvider =
    Provider<FeatureExtractionService>((ref) {
  return FeatureExtractionService();
});

final indianAdaptationServiceProvider =
    Provider<IndianAdaptationService>((ref) {
  return IndianAdaptationService();
});

final ageSimulationServiceProvider = Provider<AgeSimulationService>((ref) {
  return AgeSimulationService();
});

/// Utility service providers
final imageServiceProvider = Provider<ImageService>((ref) {
  return ImageService();
});

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final sharingServiceProvider = Provider<SharingService>((ref) {
  return SharingService();
});

final historyServiceProvider = Provider<HistoryService>((ref) {
  return HistoryService();
});

final quizServiceProvider = Provider<QuizService>((ref) {
  return QuizService();
});

/// User profile state
class UserProfileState {
  final UserProfile? profile;
  final bool isLoading;
  final String? error;

  const UserProfileState({
    this.profile,
    this.isLoading = false,
    this.error,
  });

  UserProfileState copyWith({
    UserProfile? profile,
    bool? isLoading,
    String? error,
  }) {
    return UserProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// User profile notifier
class UserProfileNotifier extends StateNotifier<UserProfileState> {
  final HiveService _hiveService;
  static const String _boxName = 'user_profiles';
  static const String _profileKey = 'current_profile';

  UserProfileNotifier(this._hiveService) : super(const UserProfileState()) {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final profileData = _hiveService.retrieve(_boxName, _profileKey);
      if (profileData != null) {
        // Convert Map to UserProfile
        final profile =
            UserProfile.fromMap(Map<String, dynamic>.from(profileData));
        state = state.copyWith(profile: profile, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateProfile(UserProfile profile) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await _hiveService.store(_boxName, _profileKey, profile.toMap());
      state = state.copyWith(profile: profile, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> clearProfile() async {
    try {
      await _hiveService.delete(_boxName, _profileKey);
      state = const UserProfileState();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

/// User profile provider
final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfileState>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return UserProfileNotifier(hiveService);
});

/// Baby generation state
class BabyGenerationState {
  final List<BabyResult> results;
  final bool isGenerating;
  final double progress;
  final String? error;
  final BabyResult? currentResult;

  const BabyGenerationState({
    this.results = const [],
    this.isGenerating = false,
    this.progress = 0.0,
    this.error,
    this.currentResult,
  });

  BabyGenerationState copyWith({
    List<BabyResult>? results,
    bool? isGenerating,
    double? progress,
    String? error,
    BabyResult? currentResult,
  }) {
    return BabyGenerationState(
      results: results ?? this.results,
      isGenerating: isGenerating ?? this.isGenerating,
      progress: progress ?? this.progress,
      error: error ?? this.error,
      currentResult: currentResult ?? this.currentResult,
    );
  }
}

/// Baby generation notifier
class BabyGenerationNotifier extends StateNotifier<BabyGenerationState> {
  final HiveService _hiveService;
  static const String _boxName = 'baby_results';

  BabyGenerationNotifier(this._hiveService)
      : super(const BabyGenerationState()) {
    _loadResults();
  }

  Future<void> _loadResults() async {
    try {
      final resultsData = _hiveService.getAll(_boxName);
      final results = resultsData.values
          .map((data) => BabyResult.fromMap(Map<String, dynamic>.from(data)))
          .toList();
      state = state.copyWith(results: results);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> startGeneration({
    required String maleImagePath,
    required String femaleImagePath,
    double alphaBlend = 0.5,
    String style = 'realistic',
    int ageMonths = 6,
  }) async {
    try {
      state = state.copyWith(isGenerating: true, progress: 0.0, error: null);

      // Convert image paths to File objects
      final malePhoto = File(maleImagePath);
      final femalePhoto = File(femaleImagePath);

      // Call the correct method with proper parameters
      final result = await AdvancedAIBabyService.generateBabyWithBlend(
        malePhoto: malePhoto,
        femalePhoto: femalePhoto,
        maleName: 'Male Parent',
        femaleName: 'Female Parent',
        alpha: alphaBlend,
        indianRegion: 'North India',
        ageGroup: _getAgeGroup(ageMonths),
        gender: 'mixed',
        adaptationStrength: 0.8,
      );

      // Convert AdvancedBabyResult to BabyResult for compatibility
      final babyResult = BabyResult(
        id: 'baby_${DateTime.now().millisecondsSinceEpoch}',
        babyImagePath: result.babyImagePath,
        maleMatchPercentage: (alphaBlend * 100).round(),
        femaleMatchPercentage: ((1 - alphaBlend) * 100).round(),
        createdAt: DateTime.now(),
        isProcessing: false,
      );

      // Save to Hive
      await _hiveService.store(_boxName, babyResult.id, babyResult.toMap());

      // Update state
      final updatedResults = [...state.results, babyResult];
      state = state.copyWith(
        results: updatedResults,
        isGenerating: false,
        progress: 1.0,
        currentResult: babyResult,
      );
    } catch (e) {
      state = state.copyWith(
        isGenerating: false,
        error: e.toString(),
      );
    }
  }

  String _getAgeGroup(int ageMonths) {
    if (ageMonths <= 6) return 'newborn';
    if (ageMonths <= 12) return 'infant';
    if (ageMonths <= 24) return 'toddler';
    return 'child';
  }

  Future<void> deleteResult(String resultId) async {
    try {
      await _hiveService.delete(_boxName, resultId);
      final updatedResults =
          state.results.where((r) => r.id != resultId).toList();
      state = state.copyWith(results: updatedResults);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Baby generation provider
final babyGenerationProvider =
    StateNotifierProvider<BabyGenerationNotifier, BabyGenerationState>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return BabyGenerationNotifier(hiveService);
});

/// App settings state
class AppSettingsState {
  final bool isDarkMode;
  final String language;
  final bool notificationsEnabled;
  final bool analyticsEnabled;
  final double alphaBlendDefault;
  final String defaultStyle;
  final int defaultAgeMonths;

  const AppSettingsState({
    this.isDarkMode = false,
    this.language = 'en',
    this.notificationsEnabled = true,
    this.analyticsEnabled = true,
    this.alphaBlendDefault = 0.5,
    this.defaultStyle = 'realistic',
    this.defaultAgeMonths = 6,
  });

  AppSettingsState copyWith({
    bool? isDarkMode,
    String? language,
    bool? notificationsEnabled,
    bool? analyticsEnabled,
    double? alphaBlendDefault,
    String? defaultStyle,
    int? defaultAgeMonths,
  }) {
    return AppSettingsState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      language: language ?? this.language,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
      alphaBlendDefault: alphaBlendDefault ?? this.alphaBlendDefault,
      defaultStyle: defaultStyle ?? this.defaultStyle,
      defaultAgeMonths: defaultAgeMonths ?? this.defaultAgeMonths,
    );
  }
}

/// App settings notifier
class AppSettingsNotifier extends StateNotifier<AppSettingsState> {
  final HiveService _hiveService;
  static const String _boxName = 'app_settings';

  AppSettingsNotifier(this._hiveService) : super(const AppSettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settingsData = _hiveService.getAll(_boxName);
      if (settingsData.isNotEmpty) {
        state = AppSettingsState(
          isDarkMode: settingsData['isDarkMode'] ?? false,
          language: settingsData['language'] ?? 'en',
          notificationsEnabled: settingsData['notificationsEnabled'] ?? true,
          analyticsEnabled: settingsData['analyticsEnabled'] ?? true,
          alphaBlendDefault: settingsData['alphaBlendDefault'] ?? 0.5,
          defaultStyle: settingsData['defaultStyle'] ?? 'realistic',
          defaultAgeMonths: settingsData['defaultAgeMonths'] ?? 6,
        );
      }
    } catch (e) {
      // Failed to load settings: $e
    }
  }

  Future<void> _saveSettings() async {
    try {
      await _hiveService.storeBatch(_boxName, {
        'isDarkMode': state.isDarkMode,
        'language': state.language,
        'notificationsEnabled': state.notificationsEnabled,
        'analyticsEnabled': state.analyticsEnabled,
        'alphaBlendDefault': state.alphaBlendDefault,
        'defaultStyle': state.defaultStyle,
        'defaultAgeMonths': state.defaultAgeMonths,
      });
    } catch (e) {
      // Failed to save settings: $e
    }
  }

  Future<void> updateDarkMode(bool isDarkMode) async {
    state = state.copyWith(isDarkMode: isDarkMode);
    await _saveSettings();
  }

  Future<void> updateLanguage(String language) async {
    state = state.copyWith(language: language);
    await _saveSettings();
  }

  Future<void> updateNotifications(bool enabled) async {
    state = state.copyWith(notificationsEnabled: enabled);
    await _saveSettings();
  }

  Future<void> updateAnalytics(bool enabled) async {
    state = state.copyWith(analyticsEnabled: enabled);
    await _saveSettings();
  }

  Future<void> updateAlphaBlendDefault(double alphaBlend) async {
    state = state.copyWith(alphaBlendDefault: alphaBlend);
    await _saveSettings();
  }

  Future<void> updateDefaultStyle(String style) async {
    state = state.copyWith(defaultStyle: style);
    await _saveSettings();
  }

  Future<void> updateDefaultAge(int ageMonths) async {
    state = state.copyWith(defaultAgeMonths: ageMonths);
    await _saveSettings();
  }
}

/// App settings provider
final appSettingsProvider =
    StateNotifierProvider<AppSettingsNotifier, AppSettingsState>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return AppSettingsNotifier(hiveService);
});

/// Analytics state
class AnalyticsState {
  final Map<String, dynamic> events;
  final bool isEnabled;
  final String? error;

  const AnalyticsState({
    this.events = const {},
    this.isEnabled = true,
    this.error,
  });

  AnalyticsState copyWith({
    Map<String, dynamic>? events,
    bool? isEnabled,
    String? error,
  }) {
    return AnalyticsState(
      events: events ?? this.events,
      isEnabled: isEnabled ?? this.isEnabled,
      error: error ?? this.error,
    );
  }
}

/// Analytics notifier
class AnalyticsNotifier extends StateNotifier<AnalyticsState> {
  final AnalyticsService _analyticsService;
  final HiveService _hiveService;
  static const String _boxName = 'analytics_events';

  AnalyticsNotifier(this._analyticsService, this._hiveService)
      : super(const AnalyticsState()) {
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      final eventsData = _hiveService.getAll(_boxName);
      state = state.copyWith(events: eventsData);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> trackEvent(
      String eventName, Map<String, dynamic> parameters) async {
    if (!state.isEnabled) return;

    try {
      final event = {
        'name': eventName,
        'parameters': parameters,
        'timestamp': DateTime.now().toIso8601String(),
      };

      await _hiveService.store(_boxName,
          '${eventName}_${DateTime.now().millisecondsSinceEpoch}', event);

      final updatedEvents = Map<String, dynamic>.from(state.events);
      updatedEvents['${eventName}_${DateTime.now().millisecondsSinceEpoch}'] =
          event;

      state = state.copyWith(events: updatedEvents);

      // Send to analytics service
      await _analyticsService.trackCustomEvent(
        eventName: eventName,
        parameters: parameters,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> setEnabled(bool enabled) async {
    state = state.copyWith(isEnabled: enabled);
  }
}

/// Analytics provider
final analyticsProvider =
    StateNotifierProvider<AnalyticsNotifier, AnalyticsState>((ref) {
  final analyticsService = ref.watch(analyticsServiceProvider);
  final hiveService = ref.watch(hiveServiceProvider);
  return AnalyticsNotifier(analyticsService, hiveService);
});

/// Current user ID provider
final currentUserIdProvider = Provider<String>((ref) {
  // Get user ID from login state
  final loginState = ref.watch(loginProvider);
  return loginState.user?.id ?? 'anonymous_user';
});

/// Current couple ID provider
final currentCoupleIdProvider = Provider<String>((ref) {
  // Get couple ID from user profile
  final userProfile = ref.watch(userProfileProvider);
  return userProfile.profile?.id ?? 'anonymous_couple';
});

/// App theme provider
final appThemeProvider = Provider<bool>((ref) {
  final settings = ref.watch(appSettingsProvider);
  return settings.isDarkMode;
});

/// Language provider
final languageProvider = Provider<String>((ref) {
  final settings = ref.watch(appSettingsProvider);
  return settings.language;
});

/// Notifications enabled provider
final notificationsEnabledProvider = Provider<bool>((ref) {
  final settings = ref.watch(appSettingsProvider);
  return settings.notificationsEnabled;
});

/// Analytics enabled provider
final analyticsEnabledProvider = Provider<bool>((ref) {
  final settings = ref.watch(appSettingsProvider);
  return settings.analyticsEnabled;
});

/// Default alpha blend provider
final defaultAlphaBlendProvider = Provider<double>((ref) {
  final settings = ref.watch(appSettingsProvider);
  return settings.alphaBlendDefault;
});

/// Default style provider
final defaultStyleProvider = Provider<String>((ref) {
  final settings = ref.watch(appSettingsProvider);
  return settings.defaultStyle;
});

/// Default age provider
final defaultAgeProvider = Provider<int>((ref) {
  final settings = ref.watch(appSettingsProvider);
  return settings.defaultAgeMonths;
});
