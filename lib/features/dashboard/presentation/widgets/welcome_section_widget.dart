import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:future_baby/features/engagement_features/presentation/screens/real_baby_name_generator_screen.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';
import '../../../../shared/providers/login_provider.dart';
import '../../../../shared/widgets/romantic_carousel.dart';
import '../../../../shared/models/carousel_item.dart';
import '../../../../shared/services/app_data_service.dart';
import '../../../engagement_features/presentation/screens/memory_journal_screen.dart';
import '../../../anniversary_tracker/presentation/widgets/anniversary_tracker_widget.dart';
import '../../../period_tracker/presentation/screens/period_tracker_screen.dart';

/// Welcome section widget with user greeting and romantic carousel
class WelcomeSectionWidget extends ConsumerWidget {
  final int babiesGenerated;
  final int memoriesCreated;
  final double lovePercentage;
  final Animation<double> heartAnimation;

  const WelcomeSectionWidget({
    super.key,
    required this.babiesGenerated,
    required this.memoriesCreated,
    required this.lovePercentage,
    required this.heartAnimation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginState = ref.watch(loginProvider);
    final user = loginState.user;

    String greeting = 'Welcome Back! 👋';
    String subGreeting = 'Ready to create magic together? ✨💕';
    if (user != null) {
      if (user.bondName != null && user.bondName!.isNotEmpty) {
        greeting = 'Welcome, ${user.bondName}! 💕';
        subGreeting = 'Your love story continues here ✨';
      } else if (user.partnerName != null && user.partnerName!.isNotEmpty) {
        greeting = 'Hello, ${user.partnerName}! 💕';
        subGreeting = 'Ready to create magic together? ✨💕';
      }
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.w),
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
          Row(
            children: [
              AnimatedBuilder(
                animation: heartAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: heartAnimation.value,
                    child: Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryPink.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.favorite,
                        color: AppTheme.primaryPink,
                        size: 20.w,
                      ),
                    ),
                  );
                },
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: BabyFont.headingL.copyWith(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                        letterSpacing: 0.3,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      subGreeting,
                      style: BabyFont.bodyL.copyWith(
                        color: AppTheme.textSecondary,
                        fontSize: 16.sp,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Text(
                          'Our Love Score: ',
                          style: BabyFont.bodyM.copyWith(
                            color: AppTheme.textSecondary,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${lovePercentage.toInt()}%',
                          style: BabyFont.bodyL.copyWith(
                            color: AppTheme.primaryPink,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          _buildRomanticCarousel(context, user),
        ],
      ),
    );
  }

  Widget _buildRomanticCarousel(BuildContext context, user) {
    return _CarouselDataWidget(
      user: user,
      onBabyGeneratorTap: () => _navigateToBabyGenerator(context),
      onMemoryJournalTap: () => _navigateToMemoryJournal(context),
      onAnniversaryTrackerTap: () => _navigateToAnniversaryTracker(context),
      onPeriodTrackerTap: () => _navigateToPeriodTracker(context),
    );
  }

  /// Navigation methods for carousel taps
  void _navigateToBabyGenerator(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BabyNameGeneratorScreen(),
      ),
    );
  }

  void _navigateToMemoryJournal(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MemoryJournalScreen(),
      ),
    );
  }

  void _navigateToAnniversaryTracker(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AnniversaryTrackerWidget(),
      ),
    );
  }

  void _navigateToPeriodTracker(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PeriodTrackerScreen(),
      ),
    );
  }
}

/// Optimized carousel data widget with proper state management
class _CarouselDataWidget extends StatefulWidget {
  final dynamic user;
  final VoidCallback onBabyGeneratorTap;
  final VoidCallback onMemoryJournalTap;
  final VoidCallback onAnniversaryTrackerTap;
  final VoidCallback onPeriodTrackerTap;

  const _CarouselDataWidget({
    required this.user,
    required this.onBabyGeneratorTap,
    required this.onMemoryJournalTap,
    required this.onAnniversaryTrackerTap,
    required this.onPeriodTrackerTap,
  });

  @override
  State<_CarouselDataWidget> createState() => _CarouselDataWidgetState();
}

class _CarouselDataWidgetState extends State<_CarouselDataWidget> {
  Map<String, dynamic>? _cachedData;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await AppDataService.instance.getDashboardCarouselData();
      if (mounted) {
        setState(() {
          _cachedData = data;
          _isLoading = false;
          _hasError = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SizedBox(
        height: 220.h,
        child: Center(
          child: CircularProgressIndicator(
            color: AppTheme.primaryPink,
          ),
        ),
      );
    }

    if (_hasError || _cachedData == null) {
      return SizedBox(
        height: 220.h,
        child: Center(
          child: Text(
            'Unable to load data',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ),
      );
    }

    final data = _cachedData!;
    final nearestEvent = data['nearestEvent'];
    final periodStats = data['periodStats'] ?? {};
    final bondName = data['bondName'] ?? widget.user?.bondName;
    final isPeriodSetUp = periodStats['isSetUp'] ?? false;
    final babyGenerationCount = data['babyGenerationCount'] ?? 0;
    final latestFinalName = data['latestFinalName'];
    final memoryCount = data['memoryCount'] ?? 0;

    // Format anniversary date
    String? anniversaryDate;
    if (nearestEvent != null) {
      final eventDate = DateTime.parse(nearestEvent['date']);
      anniversaryDate =
          '${eventDate.day} ${_getMonthName(eventDate.month)} ${eventDate.year}';
    }

    // Format period date
    String? periodDate;
    if (isPeriodSetUp && periodStats['nextPeriod'] != null) {
      final nextPeriod = DateTime.parse(periodStats['nextPeriod']);
      periodDate =
          '${nextPeriod.day} ${_getMonthName(nextPeriod.month)} ${nextPeriod.year}';
    }

    final carouselItems = CarouselDataProvider.getCarouselItems(
      babyCount: babyGenerationCount,
      latestBabyName: latestFinalName ?? bondName,
      memoryCount: memoryCount,
      anniversaryDate: anniversaryDate,
      periodDate: periodDate,
      periodStats: periodStats,
      nearestEvent: nearestEvent,
      onBabyGeneratorTap: widget.onBabyGeneratorTap,
      onMemoryJournalTap: widget.onMemoryJournalTap,
      onAnniversaryTrackerTap: widget.onAnniversaryTrackerTap,
      onPeriodTrackerTap: widget.onPeriodTrackerTap,
    );

    return SizedBox(
      width: double.infinity,
      child: RomanticCarousel(
        items: carouselItems,
        height: 220,
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }
}
