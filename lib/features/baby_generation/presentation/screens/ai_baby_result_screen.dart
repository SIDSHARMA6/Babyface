import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';
import '../../../../shared/widgets/toast_service.dart';
import '../../../../shared/services/ai_baby_generation_service.dart';

class AIBabyResultScreen extends StatefulWidget {
  final BabyGenerationResult result;
  final String maleName;
  final String femaleName;

  const AIBabyResultScreen({
    super.key,
    required this.result,
    required this.maleName,
    required this.femaleName,
  });

  @override
  State<AIBabyResultScreen> createState() => _AIBabyResultScreenState();
}

class _AIBabyResultScreenState extends State<AIBabyResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _shareResult() {
    HapticFeedback.lightImpact();
    ToastService.showCelebration(context, 'Sharing your beautiful baby! 📤💕');
    // TODO: Implement actual sharing functionality
  }

  void _saveResult() {
    HapticFeedback.mediumImpact();
    ToastService.showLove(context, 'Saved to your baby collection! 💾👶');
    // TODO: Implement actual saving functionality
  }

  void _generateAnother() {
    HapticFeedback.lightImpact();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Your AI Baby Result 👶',
          style: BabyFont.headingM.copyWith(
            color: AppTheme.primaryPink,
            fontWeight: BabyFont.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _shareResult,
            icon: Icon(
              Icons.share,
              color: AppTheme.primaryPink,
              size: 24.w,
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            children: [
              // Baby Image Section
              _buildBabyImageSection(),

              SizedBox(height: 30.h),

              // Compatibility Score
              _buildCompatibilityScore(),

              SizedBox(height: 20.h),

              // Baby Description
              _buildBabyDescription(),

              SizedBox(height: 20.h),

              // Indian Features
              if (widget.result.indianFeatures != null) _buildIndianFeatures(),

              SizedBox(height: 20.h),

              // Name Suggestions
              if (widget.result.nameSuggestions != null)
                _buildNameSuggestions(),

              SizedBox(height: 20.h),

              // Personality Traits
              if (widget.result.personalityTraits != null)
                _buildPersonalityTraits(),

              SizedBox(height: 30.h),

              // Action Buttons
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBabyImageSection() {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: double.infinity,
            height: 300.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryPink.withValues(alpha: 0.2),
                  blurRadius: 20.r,
                  offset: Offset(0, 10.h),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Baby Image Placeholder
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 200.w,
                        height: 200.w,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryPink.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.primaryPink.withValues(alpha: 0.3),
                            width: 3.w,
                          ),
                        ),
                        child: Icon(
                          Icons.child_care,
                          size: 100.w,
                          color: AppTheme.primaryPink,
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 20.h),
                Text(
                  '${widget.maleName} + ${widget.femaleName}',
                  style: BabyFont.headingM.copyWith(
                    color: AppTheme.textPrimary,
                    fontSize: 18.sp,
                  ),
                ),
                Text(
                  '= Your Beautiful Baby! 👶',
                  style: BabyFont.bodyM.copyWith(
                    color: AppTheme.primaryPink,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompatibilityScore() {
    if (widget.result.compatibilityScore == null) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentYellow.withValues(alpha: 0.1),
            blurRadius: 10.r,
            offset: Offset(0, 5.h),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.favorite,
                color: AppTheme.primaryPink,
                size: 24.w,
              ),
              SizedBox(width: 12.w),
              Text(
                'Love Compatibility Score',
                style: BabyFont.bodyM.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            '${widget.result.compatibilityScore}%',
            style: BabyFont.headingM.copyWith(
              color: AppTheme.primaryPink,
              fontSize: 32.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          LinearProgressIndicator(
            value: widget.result.compatibilityScore! / 100,
            backgroundColor: Colors.grey.withValues(alpha: 0.3),
            valueColor: AlwaysStoppedAnimation(AppTheme.primaryPink),
            minHeight: 8.h,
          ),
          SizedBox(height: 8.h),
          Text(
            'Perfect match! Your baby will inherit the best of both parents! 💕',
            style: BabyFont.bodyS.copyWith(
              color: AppTheme.textSecondary,
              fontSize: 12.sp,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBabyDescription() {
    if (widget.result.babyDescription == null) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.1),
            blurRadius: 10.r,
            offset: Offset(0, 5.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.description,
                color: AppTheme.primaryBlue,
                size: 24.w,
              ),
              SizedBox(width: 12.w),
              Text(
                'Baby Description',
                style: BabyFont.bodyM.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            widget.result.babyDescription!,
            style: BabyFont.bodyM.copyWith(
              color: AppTheme.textSecondary,
              fontSize: 14.sp,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndianFeatures() {
    final features = widget.result.indianFeatures!;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentYellow.withValues(alpha: 0.1),
            blurRadius: 10.r,
            offset: Offset(0, 5.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.face,
                color: AppTheme.accentYellow,
                size: 24.w,
              ),
              SizedBox(width: 12.w),
              Text(
                'Indian Features 🇮🇳',
                style: BabyFont.bodyM.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildFeatureItem('Skin Tone', features.skinTone, Icons.palette),
          _buildFeatureItem('Eye Color', features.eyeColor, Icons.visibility),
          _buildFeatureItem(
              'Hair Color', features.hairColor, Icons.content_cut),
          _buildFeatureItem('Face Shape', features.facialShape, Icons.face),
          _buildFeatureItem('Eye Shape', features.eyeShape, Icons.visibility),
          _buildFeatureItem(
              'Nose Shape', features.noseShape, Icons.face_retouching_natural),
          _buildFeatureItem('Lip Shape', features.lipShape, Icons.face),
          _buildFeatureItem(
              'Cheek Structure', features.cheekStructure, Icons.face_3),
          if (features.characteristics.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Text(
              'Special Characteristics:',
              style: BabyFont.bodyM.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 8.h),
            ...features.characteristics
                .map((char) => Padding(
                      padding: EdgeInsets.only(bottom: 4.h),
                      child: Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: AppTheme.accentYellow,
                            size: 16.w,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            char,
                            style: BabyFont.bodyS.copyWith(
                              color: AppTheme.textSecondary,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    )),
          ],
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.accentYellow, size: 20.w),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: BabyFont.bodyS.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.sp,
                  ),
                ),
                Text(
                  value,
                  style: BabyFont.bodyS.copyWith(
                    color: AppTheme.textSecondary,
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameSuggestions() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPink.withValues(alpha: 0.1),
            blurRadius: 10.r,
            offset: Offset(0, 5.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.baby_changing_station,
                color: AppTheme.primaryPink,
                size: 24.w,
              ),
              SizedBox(width: 12.w),
              Text(
                'Indian Name Suggestions 🇮🇳',
                style: BabyFont.bodyM.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: widget.result.nameSuggestions!.map((name) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppTheme.primaryPink.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: AppTheme.primaryPink.withValues(alpha: 0.3),
                    width: 1.w,
                  ),
                ),
                child: Text(
                  name,
                  style: BabyFont.bodyS.copyWith(
                    color: AppTheme.primaryPink,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.sp,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalityTraits() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.1),
            blurRadius: 10.r,
            offset: Offset(0, 5.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.psychology,
                color: AppTheme.primaryBlue,
                size: 24.w,
              ),
              SizedBox(width: 12.w),
              Text(
                'Personality Traits',
                style: BabyFont.bodyM.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: widget.result.personalityTraits!.map((trait) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                    width: 1.w,
                  ),
                ),
                child: Text(
                  trait,
                  style: BabyFont.bodyS.copyWith(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.sp,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _saveResult,
            icon: Icon(Icons.save, size: 20.w),
            label: Text('Save Result'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.r),
              ),
            ),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _generateAnother,
            icon: Icon(Icons.refresh, size: 20.w),
            label: Text('Generate Another'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryPink,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.r),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
