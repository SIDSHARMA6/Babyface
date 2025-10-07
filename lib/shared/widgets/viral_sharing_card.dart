import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../core/theme/baby_font.dart';
import 'responsive_widgets.dart';
import '../../core/theme/responsive_utils.dart';
import '../services/sharing_service.dart';
import 'responsive_button.dart';
import 'toast_service.dart';

/// Viral sharing card with referral tracking
/// Follows theme standardization and responsive design
class ViralSharingCard extends StatefulWidget {
  final String userId;
  final int referralCount;
  final int referralRewards;
  final VoidCallback? onRefresh;

  const ViralSharingCard({
    super.key,
    required this.userId,
    this.referralCount = 0,
    this.referralRewards = 0,
    this.onRefresh,
  });

  @override
  State<ViralSharingCard> createState() => _ViralSharingCardState();
}

class _ViralSharingCardState extends State<ViralSharingCard>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _bounceController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _bounceAnimation;

  bool _isSharing = false;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _bounceController = AnimationController(
      duration: AppTheme.normalAnimation,
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: AppTheme.bouncyCurve,
    ));

    _pulseController.repeat(reverse: true);
    _bounceController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bounceAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _bounceAnimation.value,
          child: Container(
            margin: ResponsiveUtils.padding(context),
            padding: AppTheme.cardPadding(context),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.accentYellow.withValues(alpha: 0.1),
                  AppTheme.primaryPink.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppTheme.largeRadius),
              border: Border.all(
                color: AppTheme.accentYellow.withValues(alpha: 0.3),
                width: 1.w,
              ),
              boxShadow: AppTheme.mediumShadow,
            ),
            child: Column(
              children: [
                _buildHeader(),
                SizedBox(height: AppTheme.mediumSpacing),
                _buildStats(),
                SizedBox(height: AppTheme.largeSpacing),
                _buildSharingSection(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 50.w,
                height: 50.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.accentYellow, AppTheme.primaryPink],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: AppTheme.mediumShadow,
                ),
                child: Icon(
                  Icons.share_rounded,
                  color: Colors.white,
                  size: 24.w,
                ),
              ),
            );
          },
        ),
        SizedBox(width: AppTheme.mediumSpacing),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Invite Friends & Earn Rewards!',
                style: BabyFont.titleLarge.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: BabyFont.semiBold,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Share the joy and get 10 points per friend!',
                style: BabyFont.bodySmall.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStats() {
    return ResponsiveWidget(
      phone: _buildPhoneStats(),
      tablet: _buildTabletStats(),
    );
  }

  Widget _buildPhoneStats() {
    return Row(
      children: [
        Expanded(
            child: _buildStatCard('Friends Invited', '${widget.referralCount}',
                Icons.people_rounded, AppTheme.primaryBlue)),
        SizedBox(width: AppTheme.mediumSpacing),
        Expanded(
            child: _buildStatCard('Points Earned', '${widget.referralRewards}',
                Icons.star_rounded, AppTheme.accentYellow)),
      ],
    );
  }

  Widget _buildTabletStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatCard('Friends Invited', '${widget.referralCount}',
            Icons.people_rounded, AppTheme.primaryBlue),
        _buildStatCard('Points Earned', '${widget.referralRewards}',
            Icons.star_rounded, AppTheme.accentYellow),
        _buildStatCard('Rank', '#${_calculateRank()}',
            Icons.emoji_events_rounded, AppTheme.primaryPink),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(AppTheme.mediumSpacing),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 20.w,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: BabyFont.headlineSmall.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: BabyFont.bold,
            ),
          ),
          Text(
            title,
            style: BabyFont.labelSmall.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSharingSection() {
    return Column(
      children: [
        Text(
          'Share with friends and family!',
          style: BabyFont.titleMedium.copyWith(
            color: AppTheme.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppTheme.smallSpacing),
        Text(
          'Every friend who joins earns you 10 points. Use points for premium features!',
          style: BabyFont.bodySmall.copyWith(
            color: AppTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppTheme.mediumSpacing),
        ResponsiveButton(
          text: 'Invite Friends',
          icon: Icons.share_rounded,
          type: ButtonType.primary,
          size: ButtonSize.large,
          width: double.infinity,
          isLoading: _isSharing,
          onPressed: _shareInvitation,
        ),
      ],
    );
  }

  int _calculateRank() {
    // Simple ranking based on referral count
    if (widget.referralCount >= 50) return 1;
    if (widget.referralCount >= 25) return 2;
    if (widget.referralCount >= 10) return 3;
    if (widget.referralCount >= 5) return 4;
    return 5;
  }

  Future<void> _shareInvitation() async {
    if (_isSharing) return;

    setState(() {
      _isSharing = true;
    });

    try {
      await SharingService.shareAppInvitation(
        context: context,
        userId: widget.userId,
        customMessage:
            'Hey! I found this amazing app that shows what your future baby might look like! 👶✨ You have to try it - it\'s so much fun!',
      );

      // Track viral sharing
      await SharingService.trackViralMetrics(
        userId: widget.userId,
        action: 'shared',
        metadata: {
          'source': 'viral_card',
          'referralCount': widget.referralCount,
        },
      );

      // Refresh stats
      widget.onRefresh?.call();

      if (mounted) {
        ToastService.showCelebration(
          context,
          'Invitation shared! 🎉 You\'ll earn 10 points when they join!',
        );
      }
    } catch (e) {
      if (mounted) {
        ToastService.showError(
          context,
          'Failed to share invitation. Please try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }
}
