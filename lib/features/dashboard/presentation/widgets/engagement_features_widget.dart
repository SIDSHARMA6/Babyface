import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';
import '../../../../shared/widgets/toast_service.dart';
import '../../../engagement_features/presentation/screens/real_baby_name_generator_screen.dart';
import '../../../engagement_features/presentation/screens/real_growth_memory_timeline_screen.dart';
import '../../../engagement_features/presentation/screens/real_couple_challenges_bucket_list_screen.dart';
import '../../../engagement_features/presentation/screens/real_anniversary_event_tracker_screen.dart';
import '../../../engagement_features/presentation/screens/simple_love_language_quiz_screen.dart';
import '../../../engagement_features/presentation/screens/simple_future_planning_screen.dart';
import '../../../engagement_features/presentation/screens/simple_couple_bucket_list_screen.dart';
import '../../../engagement_features/presentation/screens/memory_journal_screen.dart';

/// Engagement features widget with grid of love and engagement features
class EngagementFeaturesWidget extends StatelessWidget {
  const EngagementFeaturesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPink.withValues(alpha: 0.1),
            blurRadius: 15.r,
            offset: Offset(0, 5.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Love & Engagement Features 💕',
            style: BabyFont.headingM.copyWith(
              fontSize: 18.sp,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Strengthen your bond with these amazing features',
            style: BabyFont.bodyS.copyWith(
              color: AppTheme.textSecondary,
              fontSize: 12.sp,
            ),
          ),
          SizedBox(height: 15.h),
          _buildFeatureGrid(context),
        ],
      ),
    );
  }

  Widget _buildFeatureGrid(BuildContext context) {
    final features = [
      {
        'title': 'Baby Names',
        'icon': Icons.baby_changing_station,
        'color': AppTheme.primaryBlue,
        'action': () => _navigateToFeature(
            context, const BabyNameGeneratorScreen(), 'Baby Names'),
        'emoji': '👶'
      },
      {
        'title': 'Memory Journal',
        'icon': Icons.book,
        'color': AppTheme.accentYellow,
        'action': () => _navigateToFeature(
            context, const MemoryJournalScreen(), 'Memory Journal'),
        'emoji': '📖'
      },
      {
        'title': 'Couple Challenges',
        'icon': Icons.fitness_center,
        'color': AppTheme.primaryPink,
        'action': () => _navigateToFeature(context,
            const CoupleChallengesBucketListScreen(), 'Couple Challenges'),
        'emoji': '💪'
      },
      {
        'title': 'Growth Timeline',
        'icon': Icons.timeline,
        'color': AppTheme.primaryBlue,
        'action': () => _navigateToFeature(
            context, const GrowthMemoryTimelineScreen(), 'Growth Timeline'),
        'emoji': '📈'
      },
      {
        'title': 'Anniversary Tracker',
        'icon': Icons.calendar_today,
        'color': AppTheme.accentYellow,
        'action': () => _navigateToFeature(context,
            const AnniversaryEventTrackerScreen(), 'Anniversary Tracker'),
        'emoji': '💍'
      },
      {
        'title': 'Love Language Quiz',
        'icon': Icons.psychology,
        'color': AppTheme.primaryPink,
        'action': () => _navigateToFeature(
            context, const LoveLanguageQuizScreen(), 'Love Language Quiz'),
        'emoji': '💝'
      },
      {
        'title': 'Future Planning',
        'icon': Icons.rocket_launch,
        'color': AppTheme.primaryBlue,
        'action': () => _navigateToFeature(
            context, const FuturePlanningScreen(), 'Future Planning'),
        'emoji': '🚀'
      },
      {
        'title': 'Bucket List',
        'icon': Icons.checklist,
        'color': AppTheme.accentYellow,
        'action': () => _navigateToFeature(
            context, const CoupleBucketListScreen(), 'Bucket List'),
        'emoji': '✅'
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 1.0,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features[index];
        return _buildFeatureCard(
          context,
          feature['title'] as String,
          feature['icon'] as IconData,
          feature['color'] as Color,
          feature['emoji'] as String,
          feature['action'] as VoidCallback,
        );
      },
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    String emoji,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              color.withValues(alpha: 0.02),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1.5.w,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.2),
              blurRadius: 20.r,
              offset: Offset(0, 8.h),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withValues(alpha: 0.1),
                    color.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                children: [
                  Text(
                    emoji,
                    style: TextStyle(fontSize: 24.sp),
                  ),
                  SizedBox(height: 6.h),
                  Icon(
                    icon,
                    color: color,
                    size: 22.w,
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              title,
              style: BabyFont.bodyL.copyWith(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
                letterSpacing: 0.3,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToFeature(
      BuildContext context, Widget screen, String featureName) {
    HapticFeedback.lightImpact();
    ToastService.showLove(context, 'Opening $featureName! 💕');
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}
