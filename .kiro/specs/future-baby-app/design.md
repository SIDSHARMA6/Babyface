# Design Document - Future Baby App

## Overview

The Future Baby app is designed as a high-performance, emotionally engaging Flutter application that combines AI-powered baby face generation with social features. The architecture prioritizes lightweight operations, ANR-free performance (<1 second response time), offline-first data management, responsive UI across all devices, and viral growth mechanics. The design emphasizes cute, playful aesthetics with baby-themed fonts and colors to create an emotional connection with couples and Gen Z users.

### Key Design Principles

1. **Performance First**: All heavy operations in background isolates, <1s UI response
2. **Offline-First**: Local Hive storage with Firebase sync, works without internet
3. **Responsive Design**: Adaptive layouts for phones, tablets, and different screen sizes
4. **Emotional UX**: Baby-themed animations, cute error messages, celebration effects
5. **Viral Growth**: One-tap sharing, referral systems, social media integration
6. **Privacy & Security**: Encrypted storage, auto-delete policies, GDPR compliance

## Architecture

### High-Level Architecture

```
┌─────────────────────────┐
│     Flutter App         │
│   (UI Layer)           │
└───────────┬────────────┘
            │
┌───────────▼────────────┐
│   State Management     │
│   (Riverpod)          │
└───────────┬────────────┘
            │
┌───────────▼────────────┐
│   Repository Layer     │
│   (Business Logic)     │
└───────────┬────────────┘
            │
┌───────────▼────────────┐
│   Service Layer        │
│   (Data & External)    │
└───────────┬────────────┘
            │
┌───────────▼────────────┐
│   Infrastructure       │
│   (Hive + Firebase)    │
└────────────────────────┘
```

### Core Components

1. **UI Layer**: Flutter widgets with baby-themed styling
2. **State Management**: Riverpod with small StateNotifier classes
3. **Repository Pattern**: Clean separation of business logic
4. **Service Layer**: Image processing, AI calls, storage operations
5. **Infrastructure**: Local (Hive) and cloud (Firebase) data persistence

### Technology Stack

- **Frontend**: Flutter 3.x with Material Design 3
- **State Management**: Riverpod for dependency injection and state
- **Local Storage**: Hive for offline-first data persistence
- **Cloud Backend**: Firebase (Auth, Firestore, Storage, Functions)
- **Image Processing**: Flutter isolates with image compression libraries
- **AI Integration**: REST API calls to cloud-based AI services
- **Monitoring**: Firebase Performance, Crashlytics, Sentry
- **Responsive UI**: MediaQuery, LayoutBuilder, flutter_screenutil
- **Fonts**: Custom baby-themed fonts (Baloo 2, Fredoka One)
- **Animations**: Lottie animations, custom morphing effects
- **Sharing**: share_plus, social media SDKs

## Components and Interfaces

### 1. UI Components

#### Theme System
```dart
class AppTheme {
  static const Color primary = Color(0xFFFF6B81); // cute pink
  static const Color secondary = Color(0xFF6BCBFF); // soft blue
  static const Color accent = Color(0xFFFFE066); // yellow spark
  static const Color scaffoldBackground = Color(0xFFFFFCF7);
  
  static ThemeData lightTheme = ThemeData(
    primaryColor: primary,
    scaffoldBackgroundColor: scaffoldBackground,
    textTheme: TextTheme(
      headline1: TextStyle(fontFamily: 'BabyFont', fontSize: 32),
      // ... other text styles
    ),
  );
}
```

#### Core Screens
1. **Splash Screen**: Brand animation with auto-navigation (2-3s)
2. **Onboarding**: 3-4 swipeable intro screens with skip option
3. **Dashboard**: Main hub with couple avatars and baby generation
4. **Profile Screen**: Individual partner profile management with sync status
5. **History Screen**: Grid view of generated baby results with lazy loading
6. **Quiz Screen**: Interactive couple games and baby name generation
7. **Settings Screen**: Privacy controls, premium features, data management

#### Screen Responsiveness Strategy
- **Phone (< 600dp)**: Single column layout, bottom navigation
- **Tablet (> 600dp)**: Two-column layout where appropriate, side navigation
- **Large Screens**: Maximum content width with centered layout
- **Orientation**: Adaptive layouts for portrait/landscape modes

#### Reusable Widgets
- **AvatarWidget**: Circular avatar with upload/edit capabilities, responsive sizing
- **BabyResultCard**: Generated baby display with sharing options, adaptive layout
- **LoadingAnimation**: Cute baby-themed progress indicators (footprints, morphing)
- **ToastMessage**: Friendly error and success notifications with baby emojis
- **PremiumModal**: Upgrade prompts with feature comparisons
- **ResponsiveButton**: Adaptive button sizing based on screen size
- **AdaptiveGrid**: Grid layout that adjusts columns based on screen width
- **SyncIndicator**: Shows online/offline status and sync progress

### 2. State Management Architecture

#### Dashboard State
```dart
class DashboardState {
  final AvatarData? maleAvatar;
  final AvatarData? femaleAvatar;
  final BabyResult? currentResult;
  final bool isProcessing;
  final String? errorMessage;
  
  bool get canGenerate => 
    maleAvatar?.faceDetected == true && 
    femaleAvatar?.faceDetected == true;
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  final AvatarRepository _avatarRepo;
  final BabyGenerationService _babyService;
  
  Future<void> uploadImage(bool isMale, Uint8List imageData) async {
    // Process in isolate, update state immediately with thumbnail
  }
  
  Future<void> generateBaby() async {
    // Enqueue AI processing, show progress
  }
}
```

#### Profile State
```dart
class ProfileState {
  final UserProfile? maleProfile;
  final UserProfile? femaleProfile;
  final bool isSyncing;
  final DateTime? lastSyncTime;
}
```

### 3. Repository Layer

#### Avatar Repository
```dart
abstract class AvatarRepository {
  Future<AvatarData?> getProfileAvatar(bool isMale);
  Future<void> saveProfileAvatar(bool isMale, AvatarData avatar);
  Future<void> saveTempUpload(bool isMale, Uint8List imageData);
  Stream<AvatarData> watchAvatarChanges(bool isMale);
}

class AvatarRepositoryImpl implements AvatarRepository {
  final HiveService _hive;
  final FirebaseStorageService _storage;
  final ImageProcessingService _imageProcessor;
  
  // Implementation with offline-first approach
}
```

#### Baby Generation Repository
```dart
abstract class BabyGenerationRepository {
  Future<BabyResult> generateBaby(AvatarData male, AvatarData female);
  Future<List<BabyResult>> getHistory();
  Future<void> saveResult(BabyResult result);
  Stream<BabyResult> watchGenerationProgress(String taskId);
}
```

### 4. Service Layer

#### Image Processing Service
```dart
class ImageProcessingService {
  Future<Uint8List> compressImage(Uint8List original) async {
    return compute(_compressInIsolate, original);
  }
  
  Future<bool> detectFace(Uint8List imageData) async {
    return compute(_faceDetectionInIsolate, imageData);
  }
  
  Future<List<FaceRegion>> detectMultipleFaces(Uint8List imageData) async {
    return compute(_multipleFaceDetectionInIsolate, imageData);
  }
}

// Isolate functions
Uint8List _compressInIsolate(Uint8List data) {
  final image = img.decodeImage(data);
  final resized = img.copyResize(image!, width: 1024);
  return Uint8List.fromList(img.encodeJpg(resized, quality: 82));
}
```

#### AI Generation Service
```dart
class BabyGenerationService {
  final ApiClient _apiClient;
  final QueueService _queueService;
  
  Future<String> enqueueBabyGeneration(
    String maleImageUrl, 
    String femaleImageUrl
  ) async {
    final response = await _apiClient.post('/generate-baby', {
      'maleImage': maleImageUrl,
      'femaleImage': femaleImageUrl,
      'userId': getCurrentUserId(),
    });
    return response.data['taskId'];
  }
  
  Stream<GenerationProgress> watchProgress(String taskId) {
    return _queueService.watchTask(taskId);
  }
}
```

#### Storage Services
```dart
class HiveService {
  late Box<AvatarData> _avatarBox;
  late Box<BabyResult> _resultBox;
  late Box<UserProfile> _profileBox;
  
  Future<void> init() async {
    await Hive.initFlutter();
    _avatarBox = await Hive.openBox<AvatarData>('avatars');
    _resultBox = await Hive.openBox<BabyResult>('results');
    _profileBox = await Hive.openBox<UserProfile>('profiles');
  }
  
  Future<void> saveAvatar(String key, AvatarData avatar) async {
    await _avatarBox.put(key, avatar);
  }
}

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  Future<String> uploadImage(Uint8List imageData, String path) async {
    final ref = _storage.ref(path);
    final uploadTask = ref.putData(imageData);
    final snapshot = await uploadTask.whenComplete(() {});
    return await snapshot.ref.getDownloadURL();
  }
  
  Future<void> deleteImage(String path) async {
    await _storage.ref(path).delete();
  }
}
```

## Data Models

### Core Data Models

```dart
@HiveType(typeId: 0)
class AvatarData extends HiveObject {
  @HiveField(0)
  final String? imageUrl;
  
  @HiveField(1)
  final Uint8List? thumbnailData;
  
  @HiveField(2)
  final bool faceDetected;
  
  @HiveField(3)
  final AvatarSource source; // profile, upload, camera
  
  @HiveField(4)
  final DateTime uploadedAt;
  
  @HiveField(5)
  final bool syncPending;
}

@HiveType(typeId: 1)
class BabyResult extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String babyImageUrl;
  
  @HiveField(2)
  final Uint8List? thumbnailData;
  
  @HiveField(3)
  final int maleMatchPercentage;
  
  @HiveField(4)
  final int femaleMatchPercentage;
  
  @HiveField(5)
  final DateTime createdAt;
  
  @HiveField(6)
  final String modelVersion;
  
  @HiveField(7)
  final bool isPremium;
  
  @HiveField(8)
  final bool syncPending;
}

@HiveType(typeId: 2)
class UserProfile extends HiveObject {
  @HiveField(0)
  final String name;
  
  @HiveField(1)
  final DateTime? dateOfBirth;
  
  @HiveField(2)
  final String? profileImageUrl;
  
  @HiveField(3)
  final DateTime lastUpdated;
  
  @HiveField(4)
  final bool syncPending;
}
```

### Quiz Data Models

```dart
@HiveType(typeId: 3)
class QuizResult extends HiveObject {
  @HiveField(0)
  final String quizType; // 'gender_prediction', 'baby_names'
  
  @HiveField(1)
  final Map<String, dynamic> answers;
  
  @HiveField(2)
  final Map<String, dynamic> results;
  
  @HiveField(3)
  final int score;
  
  @HiveField(4)
  final DateTime completedAt;
}
```

## Error Handling

### Error Types and Mapping

```dart
enum AppErrorType {
  networkError,
  faceDetectionFailed,
  multipleFactsDetected,
  imageProcessingFailed,
  generationTimeout,
  storageError,
  syncError,
  subscriptionError,
}

class AppError {
  final AppErrorType type;
  final String message;
  final String? technicalDetails;
  
  String get userFriendlyMessage {
    switch (type) {
      case AppErrorType.faceDetectionFailed:
        return "We couldn't spot a clear face. Try a front-facing photo 🙂";
      case AppErrorType.multipleFactsDetected:
        return "We found multiple faces — tap to choose which one to use";
      case AppErrorType.generationTimeout:
        return "Taking longer than usual — try Lite Mode for instant results";
      case AppErrorType.networkError:
        return "Connection hiccup — we'll retry automatically";
      default:
        return "Something went wrong — tap to try again";
    }
  }
}
```

### Toast Message System

```dart
class ToastService {
  static void showSuccess(String message) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: AppTheme.primary,
      textColor: Colors.white,
      fontSize: 16,
      toastLength: Toast.LENGTH_SHORT,
    );
  }
  
  static void showError(AppError error) {
    Fluttertoast.showToast(
      msg: error.userFriendlyMessage,
      backgroundColor: Colors.orange,
      textColor: Colors.white,
      fontSize: 16,
      toastLength: Toast.LENGTH_LONG,
    );
  }
}
```

## Testing Strategy

### Unit Testing
- **Repository Tests**: Mock Hive and Firebase services
- **Service Tests**: Test image processing, AI calls, and error handling
- **State Management Tests**: Verify StateNotifier behavior and state transitions
- **Utility Tests**: Image compression, face detection, and data validation

### Integration Testing
- **Storage Integration**: Test Hive ↔ Firebase sync mechanisms
- **Image Pipeline**: End-to-end image upload, processing, and storage
- **Generation Flow**: Complete baby generation workflow
- **Offline Scenarios**: Test offline-first behavior and sync recovery

### Widget Testing
- **Screen Tests**: Verify UI behavior and state updates
- **Component Tests**: Test reusable widgets in isolation
- **Navigation Tests**: Verify screen transitions and deep linking
- **Error Handling**: Test error states and toast messages

### Performance Testing
- **ANR Prevention**: Verify no blocking operations on main isolate
- **Memory Usage**: Test image caching and cleanup
- **Network Efficiency**: Verify compression and retry mechanisms
- **Battery Impact**: Monitor background processing and sync frequency

## UI/UX Flow Design

### Navigation Structure
```
Bottom Navigation:
├── Dashboard (Home)
├── History
├── Quiz Games
└── Profile

Modal Flows:
├── Image Upload (Camera/Gallery)
├── Face Selection (Multiple faces)
├── Premium Upgrade
└── Settings/Privacy
```

### Screen Wireframes

#### Dashboard Screen
```
┌─────────────────────────────────┐
│           Dashboard             │
├─────────────────────────────────┤
│  ┌─────┐    👶    ┌─────┐      │
│  │  👨  │  (empty)  │  👩  │      │
│  │ +📷 │    baby   │ +📷 │      │
│  └─────┘   avatar  └─────┘      │
│                                 │
│     [Generate Baby Face]        │
│                                 │
│  Match: 65% Mom, 35% Dad       │
└─────────────────────────────────┘
```

#### History Screen
```
┌─────────────────────────────────┐
│            History              │
├─────────────────────────────────┤
│  ┌───┐ ┌───┐ ┌───┐             │
│  │👶1│ │👶2│ │👶3│             │
│  └───┘ └───┘ └───┘             │
│  Sep29 Oct01 Oct03             │
│                                 │
│  ┌───┐ ┌───┐ ┌───┐             │
│  │👶4│ │👶5│ │ + │             │
│  └───┘ └───┘ └───┘             │
└─────────────────────────────────┘
```

### Animation and Transitions

#### Loading Animations
- **Baby Footprints**: Walking across screen during processing
- **Morphing Effect**: Parents' faces gradually blend into baby face
- **Progress Indicators**: Cute percentage counters with baby icons
- **Shimmer Effects**: For loading thumbnails and content

#### Success Celebrations
- **Sparkle Effects**: Particle animations around generated baby
- **Gentle Bounces**: Subtle scale animations for completed actions
- **Confetti**: Celebration particles for first-time generation
- **Heart Animations**: Floating hearts for sharing actions

#### Error States
- **Gentle Shake**: Subtle shake for invalid inputs
- **Friendly Icons**: Cute baby faces for different error types
- **Fade Transitions**: Smooth error message appearances
- **Recovery Animations**: Positive feedback when errors are resolved

#### Screen Transitions
- **Slide Animations**: Smooth navigation between screens
- **Fade Effects**: For modal appearances and disappearances
- **Scale Transitions**: For button presses and interactions
- **Custom Page Routes**: Baby-themed transition animations

## Performance Optimizations

### ANR Prevention
1. **Isolate Usage**: All heavy operations in background isolates
2. **Async Operations**: Database writes and network calls are non-blocking
3. **Lazy Loading**: History items loaded on-demand with pagination
4. **Image Optimization**: Thumbnails for lists, full-size on demand
5. **State Management**: Minimal rebuilds with selective consumers

### Memory Management
1. **Image Caching**: LRU cache with size limits
2. **Automatic Cleanup**: Dispose of large objects when not needed
3. **Thumbnail Strategy**: Store small previews locally
4. **Background Processing**: Offload heavy tasks from main thread

### Network Optimization
1. **Image Compression**: Reduce upload sizes by 80%
2. **Retry Logic**: Exponential backoff for failed requests
3. **Offline Support**: Queue operations when offline
4. **CDN Usage**: Serve images from global CDN

### Storage Optimization
1. **Hive Efficiency**: Store only essential data locally
2. **Firebase Sync**: Batch operations and use transactions
3. **Auto-cleanup**: Remove old cached data periodically
4. **Compression**: Compress stored JSON data

## Security Considerations

### Data Protection
1. **Encryption**: All images encrypted in transit and at rest
2. **Signed URLs**: Temporary, secure access to cloud storage
3. **Authentication**: Firebase Auth with secure token management
4. **Privacy Controls**: User-configurable data retention policies

### Content Safety
1. **NSFW Detection**: Server-side content filtering
2. **Age Verification**: Prevent underage usage
3. **Content Moderation**: Filter inappropriate quiz inputs
4. **Abuse Prevention**: Rate limiting and spam detection

## Monitoring and Analytics

### Performance Monitoring
- **Firebase Performance**: Track app startup, screen rendering
- **Crashlytics**: Monitor crashes and ANR events
- **Custom Metrics**: Generation success rate, processing times
- **User Experience**: Track completion rates and drop-offs

### Business Analytics
- **User Engagement**: Daily/weekly active users, session duration
- **Feature Usage**: Most popular features and user flows
- **Conversion Tracking**: Free to premium upgrade rates
- **Viral Metrics**: Share rates and referral attribution

### Error Tracking
- **Sentry Integration**: Detailed error reporting and context
- **Custom Error Events**: Track specific failure scenarios
- **Performance Alerts**: Automated notifications for degradation
- **User Feedback**: In-app feedback collection for issues

## ASO (App Store Optimization) Integration

### App Metadata Design
- **App Name**: "Future Baby: Couple Face Generator"
- **Package Name**: com.anilkumar.futurebaby
- **Keywords**: baby face generator, future baby, couple photo, AI baby predictor
- **Icon Design**: Cute baby face with sparkles and heart elements
- **Screenshots**: Emotional journey from couple upload to baby result

### Viral Growth Features
- **One-Tap Sharing**: Pre-filled captions with app promotion
- **Deep Linking**: Direct links to specific baby results
- **Referral System**: Bonus features for inviting friends
- **Social Challenges**: Weekly contests and trending hashtags
- **Influencer Integration**: Special features for content creators

### Monetization UI Design
- **Freemium Flow**: Clear value proposition for premium features
- **Watermark Design**: Subtle, non-intrusive branding on free results
- **Premium Modals**: Attractive upgrade prompts with feature comparisons
- **Subscription Management**: Easy upgrade/downgrade interfaces

## Implementation Guidelines

### Code Organization
```
lib/
├── core/
│   ├── theme/
│   │   ├── app_theme.dart
│   │   ├── baby_fonts.dart
│   │   └── responsive_utils.dart
│   ├── errors/
│   │   ├── app_error.dart
│   │   └── error_handler.dart
│   └── constants/
│       ├── app_constants.dart
│       └── api_endpoints.dart
├── features/
│   ├── dashboard/
│   ├── profile/
│   ├── history/
│   ├── quiz/
│   └── settings/
├── shared/
│   ├── widgets/
│   ├── services/
│   └── repositories/
└── main.dart
```

### Performance Budgets
- **App Startup**: < 2 seconds to first screen
- **Image Upload**: < 1 second for thumbnail preview
- **Baby Generation**: < 10 seconds end-to-end
- **Screen Navigation**: < 300ms transition time
- **Memory Usage**: < 100MB average, < 200MB peak
- **APK Size**: < 50MB for release build

### Quality Assurance
- **ANR Rate**: < 0.47% (Google Play threshold)
- **Crash Rate**: < 0.1% for stable releases
- **User Rating**: Target 4.5+ stars with positive reviews
- **Retention**: > 30% D7 retention rate
- **Performance Score**: > 90 on Firebase Performance

This comprehensive design provides a solid foundation for building a high-performance, user-friendly Future Baby app that meets all requirements while ensuring scalability, maintainability, and market success.
Overview

The Future Baby app is a high-performance, emotionally engaging Flutter application that combines AI-powered baby face generation with social features. The architecture prioritizes lightweight operations, ANR-free performance, offline-first data management, universal UI scaling, and viral growth mechanics. The design emphasizes cute, playful aesthetics with baby-themed fonts and colors to create an emotional connection with couples and Gen Z users.

Architecture
High-Level Architecture
┌─────────────────────────┐
│     Flutter App         │
│   (UI Layer)           │
└───────────┬────────────┘
            │
┌───────────▼────────────┐
│   State Management     │
│   (Riverpod)          │
└───────────┬────────────┘
            │
┌───────────▼────────────┐
│   Repository Layer     │
│   (Business Logic)     │
└───────────┬────────────┘
            │
┌───────────▼────────────┐
│   Service Layer        │
│   (Data & External)    │
└───────────┬────────────┘
            │
┌───────────▼────────────┐
│   Infrastructure       │
│   (Hive + Firebase)    │
└────────────────────────┘

Core Components

UI Layer: Flutter widgets with responsive, baby-themed styling

State Management: Riverpod with small StateNotifier classes

Repository Pattern: Clean separation of business logic

Service Layer: Image processing, AI calls, storage operations

Infrastructure: Local (Hive) and cloud (Firebase) offline-first persistence

Technology Stack

Frontend: Flutter 3.x with Material Design 3

State Management: Riverpod

Local Storage: Hive

Cloud Backend: Firebase (Auth, Firestore, Storage, Functions)

Image Processing: Flutter isolates with image compression

AI Integration: Cloud AI REST API

Monitoring: Firebase Performance, Crashlytics, Sentry

Components and Interfaces
1. UI Components
Theme System
class AppTheme {
  static const Color primary = Color(0xFFFF6B81); // cute pink
  static const Color secondary = Color(0xFF6BCBFF); // soft blue
  static const Color accent = Color(0xFFFFE066); // yellow spark
  static const Color scaffoldBackground = Color(0xFFFFFCF7);

  static ThemeData lightTheme = ThemeData(
    primaryColor: primary,
    scaffoldBackgroundColor: scaffoldBackground,
    textTheme: TextTheme(
      headline1: TextStyle(fontFamily: 'BabyFont', fontSize: 32),
      bodyText1: TextStyle(fontFamily: 'BabyFont', fontSize: 16),
      button: TextStyle(fontFamily: 'BabyFont', fontSize: 18, fontWeight: FontWeight.w600),
    ),
  );
}

BabyFont System
class BabyFont {
  static TextStyle headingL(BuildContext context) => TextStyle(
    fontSize: UIHelper.responsiveFont(context, 32),
    fontWeight: FontWeight.bold,
  );

  static TextStyle body(BuildContext context) => TextStyle(
    fontSize: UIHelper.responsiveFont(context, 16),
  );

  static TextStyle button(BuildContext context) => TextStyle(
    fontSize: UIHelper.responsiveFont(context, 18),
    fontWeight: FontWeight.w600,
  );
}

class UIHelper {
  static double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
  static double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;

  static bool isTablet(BuildContext context) => screenWidth(context) > 600;

  static double responsiveFont(BuildContext context, double baseSize) {
    double scale = screenWidth(context) / 375; // base width 375px
    return baseSize * scale;
  }
}

2. Core Screens & Responsiveness
Screen	Responsive Behavior
Splash	Logo scales fractionally, loader adjusts width
Onboarding	Swipeable images scale, text scales with font helper
Dashboard	Male/female avatars scale by screen width; baby avatar adjusts proportionally; tablet uses two-column layout
Profile	Profile fields flexible; row → column switch on tablet
History	Grid layout with SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 200); lazy loading thumbnails
Quiz	Cards use AspectRatio or FractionallySizedBox; buttons scale width; text scales
Settings/Privacy	Scrollable layout with adaptive spacing
3. State Management Architecture
class DashboardState {
  final AvatarData? maleAvatar;
  final AvatarData? femaleAvatar;
  final BabyResult? currentResult;
  final bool isProcessing;
  final String? errorMessage;

  bool get canGenerate => 
    maleAvatar?.faceDetected == true && 
    femaleAvatar?.faceDetected == true;
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  final AvatarRepository _avatarRepo;
  final BabyGenerationService _babyService;

  Future<void> uploadImage(bool isMale, Uint8List imageData) async {
    // Process in isolate, update thumbnail immediately
  }

  Future<void> generateBaby() async {
    // AI processing in background queue
  }
}

4. Error Handling & Toasts
class AppError {
  final AppErrorType type;
  final String message;

  String get userFriendlyMessage {
    switch(type) {
      case AppErrorType.faceDetectionFailed:
        return "We couldn't spot a clear face. Try a front-facing photo 🙂";
      case AppErrorType.multipleFacesDetected:
        return "We found multiple faces — tap to choose which one to use";
      case AppErrorType.generationTimeout:
        return "Taking longer than usual — try Lite Mode for instant results";
      case AppErrorType.networkError:
        return "Connection hiccup — we'll retry automatically";
      default:
        return "Something went wrong — tap to try again";
    }
  }
}

class ToastService {
  static void showError(AppError error) {
    Fluttertoast.showToast(
      msg: error.userFriendlyMessage,
      backgroundColor: Colors.orange,
      textColor: Colors.white,
      fontSize: 16,
    );
  }
}

5. Performance & ANR Guidelines

Heavy tasks run in isolates

Async I/O for Hive/Firebase

Lazy loading in history and quizzes

Thumbnails for faster loading

Memory management: LRU caching + dispose large objects

Network: Image compression, retries, offline queue

6. Monitoring & Analytics

Firebase Performance: screen rendering, API latency

Crashlytics: crash & ANR tracking

Custom Metrics: baby generation success, processing times

User Engagement: DAU/WAU, retention, sharing metrics

7. Navigation & Flow
Bottom Navigation:
├── Dashboard (Home)
├── History
├── Quiz Games
└── Profile

Modals:
├── Image Upload
├── Face Selection
├── Premium Upgrade
└── Settings/Privacy


Animations: Baby footprints, morphing parents → baby, sparkle success, gentle shake on errors.