read the all three files C:\Users\HP\StudioProjects\BabyFace\.kiro\specs\future-baby-app

read the files for optimzations C:\Users\HP\StudioProjects\BabyFace\.kiro\specs\theme-standardization\tasks.md

also read this

C:\Users\HP\StudioProjects\BabyFace\lib\screens\taskbottamfiles



so there is total 7 files 

read all the 7 files 

and make a final consolidated md file

make a perfect plan of complete project 

each classs must follow the C:\Users\HP\StudioProjects\BabyFace\.kiro\specs\theme-standardization\tasks.md



so my motive is that whenever your create class you always remember the theme standard class so that each class must follow the proper optmization rules 

if each classs follow the rule then automatic complete project is optmized 

so make a plan so and task so that each classs must follow rules 






E/flutter ( 6017): [ERROR:flutter/runtime/dart_vm_initializer.cc(40)] Unhandled Exception: A CoupleGoalsProvider was used after being disposed.
E/flutter ( 6017): Once you have called dispose() on a CoupleGoalsProvider, it can no longer be used.
E/flutter ( 6017): #0      ChangeNotifier.debugAssertNotDisposed.<anonymous closure> (package:flutter/src/foundation/change_notifier.dart:183:9)
E/flutter ( 6017): #1      ChangeNotifier.debugAssertNotDisposed (package:flutter/src/foundation/change_notifier.dart:190:6)
E/flutter ( 6017): #2      ChangeNotifier.notifyListeners (package:flutter/src/foundation/change_notifier.dart:416:27)
E/flutter ( 6017): #3      CoupleGoalsProvider._calculateLovePercentage.<anonymous closure> (package:future_baby/features/couple_goals/presentation/providers/couple_goals_provider.dart:172:7)
E/flutter ( 6017): #4      new Future.delayed.<anonymous closure> (dart:async/future.dart:417:42)
E/flutter ( 6017): #5      Timer._createTimer.<anonymous closure> (dart:async-patch/timer_patch.dart:18:15)
E/flutter ( 6017): #6      _Timer._runTimers (dart:isolate-patch/timer_impl.dart:398:19)
E/flutter ( 6017): #7      _Timer._handleMessage (dart:isolate-patch/timer_impl.dart:429:5)
E/flutter ( 6017): #8      _RawReceivePort._handleMessage (dart:isolate-patch/isolate_patch.dart:184:12)
E/flutter ( 6017): 
Restarted application in 3,286ms.
3
E/BLASTBufferQueue( 6017): [SurfaceView[com.anilkumar.futurebaby/com.anilkumar.futurebaby.MainActivity]#1](f:1,a:7) acquireNextBufferLocked: Can't acquire next buffer. Already acquired max frames 7 max:5 + 2
W/WindowOnBackDispatcher( 6017): OnBackInvokedCallback is not enabled for the application.
W/WindowOnBackDispatcher( 6017): Set 'android:enableOnBackInvokedCallback="true"' in the application manifest.
8
E/BLASTBufferQueue( 6017): [SurfaceView[com.anilkumar.futurebaby/com.anilkumar.futurebaby.MainActivity]#1](f:1,a:7) acquireNextBufferLocked: Can't acquire next buffer. Already acquired max frames 7 max:5 + 2
I/ScrollIdentify( 6017): on fling
8
E/BLASTBufferQueue( 6017): [SurfaceView[com.anilkumar.futurebaby/com.anilkumar.futurebaby.MainActivity]#1](f:1,a:7) acquireNextBufferLocked: Can't acquire next buffer. Already acquired max frames 7 max:5 + 2

════════ Exception caught by rendering library ═════════════════════════════════
The following assertion was thrown during layout:
A RenderFlex overflowed by 14 pixels on the bottom.

The relevant error-causing widget was:
    Column Column:file:///C:/Users/HP/StudioProjects/BabyFace/lib/screens/couple_goals_screen.dart:415:14

: To inspect this widget in Flutter DevTools, visit: http://127.0.0.1:9100/#/inspector?uri=http%3A%2F%2F127.0.0.1%3A62202%2FuL6xSwGtWWo%3D%2F&inspectorRef=inspector-0

The overflowing RenderFlex has an orientation of Axis.vertical.
The edge of the RenderFlex that is overflowing has been marked in the rendering with a yellow and black striped pattern. This is usually caused by the contents being too big for the RenderFlex.
Consider applying a flex factor (e.g. using an Expanded widget) to force the children of the RenderFlex to fit within the available space instead of being sized to their natural size.
This is considered an error condition because it indicates that there is content that cannot be seen. If the content is legitimately bigger than the available space, consider clipping it with a ClipRect widget before putting it in the flex, or using a scrollable container rather than a Flex, like a ListView.
The specific RenderFlex in question is: RenderFlex#5551d OVERFLOWING
    parentData: offset=Offset(18.6, 18.6) (can use size)
    constraints: BoxConstraints(w=140.1, h=110.5)
    size: Size(140.1, 110.5)
    direction: vertical
    mainAxisAlignment: center
    mainAxisSize: max
    crossAxisAlignment: center
    verticalDirection: down
    spacing: 0.0
    child 1: RenderParagraph#9c433 relayoutBoundary=up1
        parentData: offset=Offset(48.1, 0.0); flex=null; fit=null (can use size)
        constraints: BoxConstraints(0.0<=w<=140.1, 0.0<=h<=Infinity)
        size: Size(43.9, 53.0)
        textAlign: start
        textDirection: ltr
        softWrap: wrapping at box width
        overflow: clip
        locale: en_US
        maxLines: unlimited
        text: TextSpan
            debugLabel: ((englishLike bodyMedium 2021).merge(((blackMountainView bodyMedium).apply).merge(unknown))).merge(unknown)
            inherit: false
            color: Color(alpha: 1.0000, red: 0.1725, green: 0.1725, blue: 0.1804, colorSpace: ColorSpace.sRGB)
            family: Handcaps
            size: 35.1
            weight: 400
            letterSpacing: 0.3
            baseline: alphabetic
            height: 1.5x
            leadingDistribution: even
            decoration: Color(alpha: 1.0000, red: 0.1725, green: 0.1725, blue: 0.1804, colorSpace: ColorSpace.sRGB) TextDecoration.none
            "🎯"
    child 2: RenderConstrainedBox#65843 relayoutBoundary=up1
        parentData: offset=Offset(70.0, 53.0); flex=null; fit=null (can use size)
        constraints: BoxConstraints(0.0<=w<=140.1, 0.0<=h<=Infinity)
        size: Size(0.0, 9.0)
        additionalConstraints: BoxConstraints(0.0<=w<=Infinity, h=9.0)
    child 3: RenderParagraph#2ac48 relayoutBoundary=up1
        parentData: offset=Offset(35.6, 62.0); flex=null; fit=null (can use size)
        constraints: BoxConstraints(0.0<=w<=140.1, 0.0<=h<=Infinity)
        size: Size(68.8, 18.0)
        textAlign: center
        textDirection: ltr
        softWrap: wrapping at box width
        overflow: clip
        locale: en_US
        maxLines: unlimited
        text: TextSpan
            debugLabel: ((englishLike bodyMedium 2021).merge(((blackMountainView bodyMedium).apply).merge(unknown))).merge(unknown)
            inherit: false
            color: Color(alpha: 1.0000, red: 0.5569, green: 0.5569, blue: 0.5765, colorSpace: ColorSpace.sRGB)
            family: Handcaps
            size: 13.2
            weight: 600
            letterSpacing: 0.3
            baseline: alphabetic
            height: 1.4x
            leadingDistribution: even
            decoration: Color(alpha: 1.0000, red: 0.1725, green: 0.1725, blue: 0.1804, colorSpace: ColorSpace.sRGB) TextDecoration.none
            "Quiz Masters"
    child 4: RenderConstrainedBox#3b3be relayoutBoundary=up1
        parentData: offset=Offset(70.0, 80.0); flex=null; fit=null (can use size)
        constraints: BoxConstraints(0.0<=w<=140.1, 0.0<=h<=Infinity)
        size: Size(0.0, 4.5)
        additionalConstraints: BoxConstraints(0.0<=w<=Infinity, h=4.5)
    child 5: RenderParagraph#54d79 relayoutBoundary=up1
        parentData: offset=Offset(0.0, 84.5); flex=null; fit=null (can use size)
        constraints: BoxConstraints(0.0<=w<=140.1, 0.0<=h<=Infinity)
        size: Size(140.1, 40.0)
        textAlign: center
        textDirection: ltr
        softWrap: wrapping at box width
        overflow: ellipsis
        locale: en_US
        maxLines: 2
        text: TextSpan
            debugLabel: ((englishLike bodyMedium 2021).merge(((blackMountainView bodyMedium).apply).merge(unknown))).merge(unknown)
            inherit: false
            color: Color(alpha: 1.0000, red: 0.5569, green: 0.5569, blue: 0.5765, colorSpace: ColorSpace.sRGB)
            family: Handcaps
            size: 13.2
            weight: 400
            letterSpacing: 0.3
            baseline: alphabetic
            height: 1.5x
            leadingDistribution: even
            decoration: Color(alpha: 1.0000, red: 0.1725, green: 0.1725, blue: 0.1804, colorSpace: ColorSpace.sRGB) TextDecoration.none
            "Complete your first quiz together"
◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤
════════════════════════════════════════════════════════════════════════════════

════════ Exception caught by rendering library ═════════════════════════════════
A RenderFlex overflowed by 14 pixels on the bottom.
The relevant error-causing widget was:
    Column Column:file:///C:/Users/HP/StudioProjects/BabyFace/lib/screens/couple_goals_screen.dart:415:14
════════════════════════════════════════════════════════════════════════════════

════════ Exception caught by rendering library ═════════════════════════════════
A RenderFlex overflowed by 14 pixels on the bottom.
The relevant error-causing widget was:
    Column Column:file:///C:/Users/HP/StudioProjects/BabyFace/lib/screens/couple_goals_screen.dart:415:14
════════════════════════════════════════════════════════════════════════════════

════════ Exception caught by rendering library ═════════════════════════════════
A RenderFlex overflowed by 14 pixels on the bottom.
The relevant error-causing widget was:
    Column Column:file:///C:/Users/HP/StudioProjects/BabyFace/lib/screens/couple_goals_screen.dart:415:14
════════════════════════════════════════════════════════════════════════════════
3
I/ScrollIdentify( 6017): on fling


yes i like it 

the text love quiz adventure and above small 2 hearts 

 i like it 

but there is 2 heart only 

make it perfect pattern add more heart which it looks very nice and beatufliuully 



and make same pattern add in profile,couple goals scren ,history screen ,dashboard ,so that its looks our theme universal theme of the project 

universal patttern ,

so make it seperate class for this widget 

and call it in every 5 class 
# Future Baby - AI Baby Face Generator

A Flutter-based mobile application that allows couples to upload their photos and generate AI-powered predictions of what their future baby might look like. Built with Flutter, Firebase, and Hive for optimal performance and offline-first functionality.

## 🚀 Features

- **AI Baby Generation**: Upload couple photos and see your future baby
- **Offline-First**: Works without internet, syncs when online
- **Responsive Design**: Optimized for phones, tablets, and all screen sizes
- **Baby-Themed UI**: Cute, playful design with baby fonts and colors
- **Performance Optimized**: <1 second response time, ANR-free
- **Social Sharing**: Share results on Instagram, WhatsApp, TikTok
- **Quiz Games**: Fun couple games and baby name generation
- **Premium Features**: HD images, watermark removal, advanced AI

## 🏗️ Architecture

The app follows clean architecture principles with:

- **UI Layer**: Flutter widgets with baby-themed styling
- **State Management**: Riverpod with small StateNotifier classes
- **Repository Pattern**: Clean separation of business logic
- **Service Layer**: Image processing, AI calls, storage operations
- **Infrastructure**: Local (Hive) and cloud (Firebase) data persistence

## 📱 Tech Stack

- **Frontend**: Flutter 3.x with Material Design 3
- **State Management**: Riverpod
- **Local Storage**: Hive (offline-first)
- **Cloud Backend**: Firebase (Auth, Firestore, Storage, Functions)
- **Image Processing**: Flutter isolates with compression
- **AI Integration**: REST API calls to cloud-based AI services
- **Monitoring**: Firebase Performance, Crashlytics, Sentry

## 🛠️ Setup & Installation

### Prerequisites

- Flutter SDK 3.x
- Dart SDK 3.6.1+
- Firebase CLI
- Android Studio / VS Code

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd future-baby-app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   ```bash
   # Install Firebase CLI if not already installed
   npm install -g firebase-tools
   
   # Login to Firebase
   firebase login
   
   # Initialize Firebase project
   firebase init
   ```

4. **Update Firebase configuration**
   - Update `lib/firebase_options.dart` with your Firebase project credentials
   - Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)

5. **Run the app**
   ```bash
   flutter run
   ```

## 🧪 Testing

Run all tests:
```bash
flutter test
```

Run specific test files:
```bash
flutter test test/core/theme/app_theme_test.dart
flutter test test/core/errors/app_error_test.dart
```

## 📁 Project Structure

```
lib/
├── core/
│   ├── theme/          # AppTheme, BabyFont, responsive utils
│   ├── errors/         # Error handling and user messages
│   ├── constants/      # App constants and configurations
│   └── utils/          # Helper functions and utilities
├── features/
│   ├── dashboard/      # Main baby generation screen
│   ├── profile/        # User profile management
│   ├── history/        # Result history and management
│   ├── quiz/           # Games and quizzes
│   └── settings/       # App settings and preferences
├── shared/
│   ├── widgets/        # Reusable UI components
│   ├── services/       # Business logic services
│   ├── repositories/   # Data access layer
│   └── models/         # Data models and DTOs
└── main.dart           # App entry point
```

## 🎨 Design System

### Colors
- **Primary**: #FF6B81 (cute pink)
- **Secondary**: #6BCBFF (soft blue)
- **Accent**: #FFE066 (yellow spark)
- **Background**: #FFFCF7 (soft off-white)

### Typography
- **Font Family**: BabyFont (custom baby-themed fonts)
- **Responsive**: Scales based on screen size
- **Weights**: Regular, Medium, Bold

## 🚀 Performance

- **ANR-Free**: All heavy operations in background isolates
- **Response Time**: <1 second for all user interactions
- **Memory Usage**: <100MB average, <200MB peak
- **Offline Support**: Full functionality without internet
- **Image Optimization**: Intelligent compression and caching

## 📈 ASO (App Store Optimization)

- **App Name**: Future Baby: Couple Face Generator
- **Package**: com.anilkumar.futurebaby
- **Keywords**: baby face generator, future baby, couple photo, AI baby
- **Target Rating**: 4.5+ stars
- **Retention Goal**: >30% D7 retention

## 🔒 Security & Privacy

- **Encryption**: All images encrypted in transit and at rest
- **Auto-Delete**: Configurable data retention policies
- **GDPR Compliant**: Data export and deletion support
- **Privacy First**: Clear privacy controls and settings

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

For support, email support@futurebaby.app or join our Discord community.

---

Made with 💕 for couples everywhere
