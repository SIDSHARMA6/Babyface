import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/app/presentation/screens/splash_screen.dart';

/// App controller to manage navigation flow
/// Follows theme standardization and ANR prevention
class AppController extends ConsumerStatefulWidget {
  const AppController({super.key});

  @override
  ConsumerState<AppController> createState() => _AppControllerState();
}

class _AppControllerState extends ConsumerState<AppController> {
  @override
  Widget build(BuildContext context) {
    // The splash screen handles all initialization and navigation
    return const SplashScreen();
  }
}
