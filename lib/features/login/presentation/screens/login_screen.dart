import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';
import '../../../../shared/providers/login_provider.dart';
import '../../../app/presentation/screens/main_navigation_screen.dart';

/// Clean Login Screen with your desired flow
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _partnerNameController = TextEditingController();
  final TextEditingController _bondNameController = TextEditingController();

  String? _selectedGender;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _partnerNameController.dispose();
    _bondNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginProvider);

    // Navigate to main screen when complete
    ref.listen<LoginState>(loginProvider, (previous, next) {
      if (next.currentStep == LoginStep.complete) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            children: [
              Expanded(
                child: _buildCurrentStep(loginState),
              ),
              if (loginState.isLoading) const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep(LoginState loginState) {
    switch (loginState.currentStep) {
      case LoginStep.login:
        return _buildLoginStep();
      case LoginStep.gender:
        return _buildGenderStep();
      case LoginStep.yourName:
        return _buildYourNameStep();
      case LoginStep.partnerName:
        return _buildPartnerNameStep();
      case LoginStep.bondName:
        return _buildBondNameStep();
      case LoginStep.complete:
        return const SizedBox.shrink();
    }
  }

  Widget _buildLoginStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Logo/Title
        Text(
          '💕 BabyFace',
          style: BabyFont.headingL.copyWith(
            fontSize: 48.sp,
            color: AppTheme.primaryPink,
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          'Welcome to your love journey',
          style: BabyFont.bodyL.copyWith(
            fontSize: 18.sp,
            color: AppTheme.textSecondary,
          ),
        ),
        SizedBox(height: 48.h),

        // Google Sign-In Button
        SizedBox(
          width: double.infinity,
          height: 56.h,
          child: ElevatedButton.icon(
            onPressed: () {
              ref.read(loginProvider.notifier).signInWithGoogle();
            },
            icon: const Icon(Icons.login, color: Colors.white),
            label: Text(
              'Continue with Google',
              style: BabyFont.bodyL.copyWith(
                fontSize: 16.sp,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryPink,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              elevation: 4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'What\'s your gender?',
          style: BabyFont.headingL.copyWith(
            fontSize: 28.sp,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 32.h),

        // Gender options
        _buildGenderOption('Male', '👨'),
        SizedBox(height: 16.h),
        _buildGenderOption('Female', '👩'),
      ],
    );
  }

  Widget _buildGenderOption(String gender, String emoji) {
    final isSelected = _selectedGender == gender;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = gender;
        });
        ref.read(loginProvider.notifier).updateGender(gender);
      },
      child: Container(
        width: double.infinity,
        height: 60.h,
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryPink : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? AppTheme.primaryPink : AppTheme.borderColor,
            width: 2.w,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: TextStyle(fontSize: 24.sp),
            ),
            SizedBox(width: 12.w),
            Text(
              gender,
              style: BabyFont.bodyL.copyWith(
                fontSize: 18.sp,
                color: isSelected ? Colors.white : AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYourNameStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'What\'s your name?',
          style: BabyFont.headingL.copyWith(
            fontSize: 28.sp,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 32.h),

        // First Name
        TextField(
          controller: _firstNameController,
          decoration: InputDecoration(
            labelText: 'First Name',
            hintText: 'Enter your first name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            prefixIcon: const Icon(Icons.person),
          ),
        ),
        SizedBox(height: 16.h),

        // Last Name
        TextField(
          controller: _lastNameController,
          decoration: InputDecoration(
            labelText: 'Last Name',
            hintText: 'Enter your last name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            prefixIcon: const Icon(Icons.person_outline),
          ),
        ),
        SizedBox(height: 32.h),

        // Continue Button
        SizedBox(
          width: double.infinity,
          height: 56.h,
          child: ElevatedButton(
            onPressed: () {
              if (_firstNameController.text.isNotEmpty &&
                  _lastNameController.text.isNotEmpty) {
                ref.read(loginProvider.notifier).updateYourName(
                      _firstNameController.text.trim(),
                      _lastNameController.text.trim(),
                    );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryPink,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            child: Text(
              'Continue',
              style: BabyFont.bodyL.copyWith(
                fontSize: 16.sp,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPartnerNameStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'What\'s your partner\'s name?',
          style: BabyFont.headingL.copyWith(
            fontSize: 28.sp,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 32.h),

        // Partner Name
        TextField(
          controller: _partnerNameController,
          decoration: InputDecoration(
            labelText: 'Partner\'s Name',
            hintText: 'Enter your partner\'s name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            prefixIcon: const Icon(Icons.favorite),
          ),
        ),
        SizedBox(height: 32.h),

        // Continue Button
        SizedBox(
          width: double.infinity,
          height: 56.h,
          child: ElevatedButton(
            onPressed: () {
              if (_partnerNameController.text.isNotEmpty) {
                ref.read(loginProvider.notifier).updatePartnerName(
                      _partnerNameController.text.trim(),
                    );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryPink,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            child: Text(
              'Continue',
              style: BabyFont.bodyL.copyWith(
                fontSize: 16.sp,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBondNameStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'What\'s your bond name?',
          style: BabyFont.headingL.copyWith(
            fontSize: 28.sp,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          '(Optional - you can skip this)',
          style: BabyFont.bodyM.copyWith(
            fontSize: 14.sp,
            color: AppTheme.textSecondary,
          ),
        ),
        SizedBox(height: 32.h),

        // Bond Name
        TextField(
          controller: _bondNameController,
          decoration: InputDecoration(
            labelText: 'Bond Name',
            hintText: 'e.g., "Lovebirds", "Sweethearts"',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            prefixIcon: const Icon(Icons.favorite_border),
          ),
        ),
        SizedBox(height: 24.h),

        // Continue Button
        SizedBox(
          width: double.infinity,
          height: 56.h,
          child: ElevatedButton(
            onPressed: () {
              if (_bondNameController.text.isNotEmpty) {
                ref.read(loginProvider.notifier).updateBondName(
                      _bondNameController.text.trim(),
                    );
              } else {
                ref.read(loginProvider.notifier).skipBondName();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryPink,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            child: Text(
              'Continue',
              style: BabyFont.bodyL.copyWith(
                fontSize: 16.sp,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        SizedBox(height: 16.h),

        // Skip Button
        TextButton(
          onPressed: () {
            ref.read(loginProvider.notifier).skipBondName();
          },
          child: Text(
            'Skip for now',
            style: BabyFont.bodyM.copyWith(
              fontSize: 14.sp,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
