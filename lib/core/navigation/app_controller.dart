import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/app/presentation/screens/splash_screen.dart';
import '../../features/app/presentation/screens/onboarding_screen.dart';
import '../../features/app/presentation/screens/main_navigation_screen.dart';

/// App controller to manage navigation flow
/// Follows theme standardization and ANR prevention
class AppController extends StatefulWidget {
  const AppController({super.key});

  @override
  State<AppController> createState() => _AppControllerState();
}

class _AppControllerState extends State<AppController> {
  bool _isLoading = true;
  bool _isFirstTime = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Show splash screen for minimal time - ultra fast
    await Future.delayed(const Duration(milliseconds: 1500));

    // Check if it's first time user
    await _checkFirstTimeUser();

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkFirstTimeUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // For testing, always clear the onboarding flag to show onboarding
      await prefs.remove('has_seen_onboarding');
      final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;

      if (mounted) {
        setState(() {
          _isFirstTime = !hasSeenOnboarding; // This will always be true now
        });
      }
    } catch (e) {
      // If there's an error, assume first time
      if (mounted) {
        setState(() {
          _isFirstTime = true;
        });
      }
    }
  }

  void _onOnboardingComplete() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_seen_onboarding', true);

      if (mounted) {
        setState(() {
          _isFirstTime = false;
        });
      }
    } catch (e) {
      // Even if saving fails, proceed to main app
      if (mounted) {
        setState(() {
          _isFirstTime = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Debug: build() - _isLoading = $_isLoading, _isFirstTime = $_isFirstTime

    if (_isLoading) {
      return const SplashScreen();
    }

    if (_isFirstTime) {
      return OnboardingScreen(
        onComplete: _onOnboardingComplete,
      );
    }

    return const MainNavigationScreen();
  }
}
