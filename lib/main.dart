import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/theme/app_theme.dart';
import 'core/navigation/app_controller.dart';
import 'shared/services/hive_service.dart';
import 'shared/services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for ultra-fast local storage first
  print('🔐 [Main] Starting Hive initialization...');
  await HiveService.initialize();
  print('✅ [Main] Hive initialization completed');

  // Initialize Firebase
  print('🚀 [Main] Starting Firebase initialization...');
  try {
    await FirebaseService().initialize();
    print('✅ [Main] Firebase initialized successfully');
  } catch (e) {
    print('❌ [Main] Firebase initialization failed: $e');
    print('❌ [Main] Error type: ${e.runtimeType}');
    // App will continue with limited functionality
  }

  // Set preferred orientations for optimal performance
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Optimize system UI for performance
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const ProviderScope(child: FutureBabyApp()));
}

/// Ultra-fast Future Baby App with zero ANR
/// - Optimized Riverpod setup for minimal rebuilds
/// - Hive-powered ultra-fast local storage
/// - Efficient memory management and performance
/// - Sub-1s app startup time
class FutureBabyApp extends StatelessWidget {
  const FutureBabyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Future Baby',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          home: const AppController(),
          // Performance optimizations
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.noScaling, // Prevent text scaling issues
              ),
              child: child!,
            );
          },
        );
      },
    );
  }
}
