import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;
import '../../shared/models/user.dart';
import '../../shared/services/google_signin_service.dart';
import '../../shared/services/bond_profile_service.dart';

/// Login state
class LoginState {
  final bool isLoading;
  final User? user;
  final String? error;
  final LoginStep currentStep;

  const LoginState({
    this.isLoading = false,
    this.user,
    this.error,
    this.currentStep = LoginStep.login,
  });

  LoginState copyWith({
    bool? isLoading,
    User? user,
    String? error,
    LoginStep? currentStep,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error ?? this.error,
      currentStep: currentStep ?? this.currentStep,
    );
  }
}

/// Login steps
enum LoginStep {
  login,
  gender,
  yourName,
  partnerName,
  bondName,
  complete,
}

/// Login provider
class LoginProvider extends StateNotifier<LoginState> {
  LoginProvider() : super(const LoginState()) {
    _checkLoginStatus();
  }

  final GoogleSignInService _googleSignInService = GoogleSignInService();

  /// Check initial login status
  Future<void> _checkLoginStatus() async {
    try {
      state = state.copyWith(isLoading: true);

      final user = await _googleSignInService.getCurrentUser();

      if (user != null) {
        state = state.copyWith(
          isLoading: false,
          user: user,
          currentStep: user.isComplete ? LoginStep.complete : LoginStep.gender,
        );
        developer.log('✅ [LoginProvider] User found: ${user.email}');
      } else {
        state = state.copyWith(
          isLoading: false,
          currentStep: LoginStep.login,
        );
        developer.log('🔐 [LoginProvider] No user found');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      developer.log('❌ [LoginProvider] Error checking login status: $e');
    }
  }

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final user = await _googleSignInService.signInWithGoogle();

      if (user != null) {
        state = state.copyWith(
          isLoading: false,
          user: user,
          currentStep: LoginStep.gender,
        );
        developer.log('✅ [LoginProvider] Google Sign-In successful: ${user.email}');
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Google Sign-In failed',
        );
        developer.log('❌ [LoginProvider] Google Sign-In failed');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      developer.log('❌ [LoginProvider] Google Sign-In error: $e');
    }
  }

  /// Update gender
  Future<void> updateGender(String gender) async {
    if (state.user == null) return;

    final updatedUser = state.user!.copyWith(gender: gender);
    await _googleSignInService.updateUser(updatedUser);

    state = state.copyWith(
      user: updatedUser,
      currentStep: LoginStep.yourName,
    );

    developer.log('✅ [LoginProvider] Gender updated: $gender');
  }

  /// Update your name
  Future<void> updateYourName(String firstName, String lastName) async {
    if (state.user == null) return;

    final updatedUser = state.user!.copyWith(
      firstName: firstName,
      lastName: lastName,
    );
    await _googleSignInService.updateUser(updatedUser);

    state = state.copyWith(
      user: updatedUser,
      currentStep: LoginStep.partnerName,
    );

    developer.log('✅ [LoginProvider] Your name updated: $firstName $lastName');
  }

  /// Update partner name
  Future<void> updatePartnerName(String partnerName) async {
    if (state.user == null) return;

    final updatedUser = state.user!.copyWith(partnerName: partnerName);
    await _googleSignInService.updateUser(updatedUser);

    state = state.copyWith(
      user: updatedUser,
      currentStep: LoginStep.bondName,
    );

    developer.log('✅ [LoginProvider] Partner name updated: $partnerName');
  }

  /// Update bond name
  Future<void> updateBondName(String bondName) async {
    if (state.user == null) return;

    final updatedUser = state.user!.copyWith(
      bondName: bondName,
      isComplete: true,
    );
    await _googleSignInService.updateUser(updatedUser);

    // Also save to BondProfileService for profile screen and dashboard
    await BondProfileService.instance.saveBondName(bondName);

    state = state.copyWith(
      user: updatedUser,
      currentStep: LoginStep.complete,
    );

    developer.log('✅ [LoginProvider] Bond name updated: $bondName');
  }

  /// Skip bond name
  Future<void> skipBondName() async {
    if (state.user == null) return;

    final updatedUser = state.user!.copyWith(isComplete: true);
    await _googleSignInService.updateUser(updatedUser);

    // Clear any existing bond name from BondProfileService
    await BondProfileService.instance.saveBondName('');

    state = state.copyWith(
      user: updatedUser,
      currentStep: LoginStep.complete,
    );

    developer.log('✅ [LoginProvider] Bond name skipped');
  }

  /// Sign out
  Future<void> signOut() async {
    await _googleSignInService.signOut();
    state = const LoginState();
    developer.log('✅ [LoginProvider] Sign out successful');
  }
}

/// Login provider instance
final loginProvider = StateNotifierProvider<LoginProvider, LoginState>((ref) {
  return LoginProvider();
});
