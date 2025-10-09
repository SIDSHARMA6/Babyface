import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:developer' as developer;
import 'core/theme/app_theme.dart';
import 'core/navigation/app_controller.dart';
import 'shared/services/hive_service.dart';
import 'shared/services/firebase_service.dart';
import 'shared/services/data_sync_service.dart';
import 'features/engagement_features/presentation/screens/add_memory_screen.dart';
import 'features/engagement_features/presentation/screens/memory_journey_preview_screen.dart';
import 'features/engagement_features/presentation/screens/debug_memory_screen.dart';
import 'features/engagement_features/data/models/memory_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for ultra-fast local storage first
  developer.log('🔐 [Main] Starting Hive initialization...');
  await HiveService.initialize();
  developer.log('✅ [Main] Hive initialization completed');

  // Initialize Firebase
  developer.log('🚀 [Main] Starting Firebase initialization...');
  try {
    await FirebaseService().initialize();
    developer.log('✅ [Main] Firebase initialized successfully');

    // Sync data from Firebase after successful initialization
    developer.log('🔄 [Main] Starting data sync from Firebase...');
    try {
      await DataSyncService.instance.syncAllDataFromFirebase();
      developer.log('✅ [Main] Data sync completed successfully');
    } catch (e) {
      developer.log('❌ [Main] Data sync failed: $e');
      // App will continue with local data only
    }
  } catch (e) {
    developer.log('❌ [Main] Firebase initialization failed: $e');
    developer.log('❌ [Main] Error type: ${e.runtimeType}');
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
          routes: {
            '/main/add-memory': (context) => const AddMemoryScreen(),
            '/main/memory-journey-preview': (context) =>
                const MemoryJourneyPreviewScreen(),
            '/debug/memory': (context) => const DebugMemoryScreen(),
            '/main/memory-detail': (context) {
              final memory =
                  ModalRoute.of(context)?.settings.arguments as MemoryModel?;
              if (memory == null) {
                return const Scaffold(
                  body: Center(child: Text('Memory not found')),
                );
              }
              // TODO: Implement proper memory detail screen
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            },
          },
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
