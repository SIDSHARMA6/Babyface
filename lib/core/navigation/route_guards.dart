import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

/// Route guards for navigation security
/// Follows master plan security standards
class RouteGuards {
  /// Check if user is authenticated
  static bool isAuthenticated() {
    // In a real implementation, this would check:
    // 1. JWT token validity
    // 2. User session status
    // 3. Authentication state

    // For demo purposes, return true
    return true;
  }

  /// Check if user has premium access
  static bool hasPremiumAccess() {
    // In a real implementation, this would check:
    // 1. Subscription status
    // 2. Premium feature access
    // 3. Payment status

    // For demo purposes, return false
    return false;
  }

  /// Check if user has completed onboarding
  static bool hasCompletedOnboarding() {
    // In a real implementation, this would check:
    // 1. Onboarding completion status
    // 2. User preferences setup
    // 3. Profile completion

    // For demo purposes, return true
    return true;
  }

  /// Check if user has verified age
  static bool hasVerifiedAge() {
    // In a real implementation, this would check:
    // 1. Age verification status
    // 2. Parental consent
    // 3. Legal compliance

    // For demo purposes, return true
    return true;
  }

  /// Check if feature is available
  static bool isFeatureAvailable(String featureName) {
    // In a real implementation, this would check:
    // 1. Feature flags
    // 2. A/B testing status
    // 3. Regional availability
    // 4. Maintenance status

    return true;
  }

  /// Check if user can access analytics
  static bool canAccessAnalytics() {
    // In a real implementation, this would check:
    // 1. User role (admin/developer)
    // 2. Permission level
    // 3. Access token

    // For demo purposes, return false
    return false;
  }
}

/// Route guard middleware
class RouteGuardMiddleware {
  /// Authentication guard
  static Widget authGuard(Widget child) {
    return Builder(
      builder: (context) {
        if (!RouteGuards.isAuthenticated()) {
          // Redirect to login or show auth screen
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/onboarding');
          });
          return const _LoadingScreen();
        }
        return child;
      },
    );
  }

  /// Premium access guard
  static Widget premiumGuard(Widget child) {
    return Builder(
      builder: (context) {
        if (!RouteGuards.hasPremiumAccess()) {
          // Show premium upgrade screen
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/premium');
          });
          return const _LoadingScreen();
        }
        return child;
      },
    );
  }

  /// Onboarding guard
  static Widget onboardingGuard(Widget child) {
    return Builder(
      builder: (context) {
        if (!RouteGuards.hasCompletedOnboarding()) {
          // Redirect to onboarding
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/onboarding');
          });
          return const _LoadingScreen();
        }
        return child;
      },
    );
  }

  /// Age verification guard
  static Widget ageVerificationGuard(Widget child) {
    return Builder(
      builder: (context) {
        if (!RouteGuards.hasVerifiedAge()) {
          // Show age verification screen
          return _AgeVerificationScreen();
        }
        return child;
      },
    );
  }

  /// Feature availability guard
  static Widget featureGuard(String featureName, Widget child) {
    return Builder(
      builder: (context) {
        if (!RouteGuards.isFeatureAvailable(featureName)) {
          // Show feature unavailable screen
          return _FeatureUnavailableScreen(featureName: featureName);
        }
        return child;
      },
    );
  }

  /// Analytics access guard
  static Widget analyticsGuard(Widget child) {
    return Builder(
      builder: (context) {
        if (!RouteGuards.canAccessAnalytics()) {
          // Show access denied screen
          return _AccessDeniedScreen();
        }
        return child;
      },
    );
  }
}

/// Loading screen for route guards
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppTheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Loading...',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Age verification screen
class _AgeVerificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Age Verification'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.verified_user,
              size: 64,
              color: AppTheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Age Verification Required',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Please verify your age to continue using the app',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Implement age verification logic
                context.go('/main');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Verify Age'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Feature unavailable screen
class _FeatureUnavailableScreen extends StatelessWidget {
  final String featureName;

  const _FeatureUnavailableScreen({required this.featureName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Feature Unavailable'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.block,
              size: 64,
              color: AppTheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Feature Unavailable',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'The $featureName feature is currently not available',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/main'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Access denied screen
class _AccessDeniedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Access Denied'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock,
              size: 64,
              color: AppTheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Access Denied',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'You do not have permission to access this feature',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/main'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
