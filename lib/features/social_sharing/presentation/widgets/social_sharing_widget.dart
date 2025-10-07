import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/theme/baby_font.dart';
import '../../../../shared/widgets/responsive_widgets.dart';
import '../../../../core/theme/responsive_utils.dart';
import '../../../../shared/widgets/responsive_button.dart';
import '../../../../shared/widgets/sharing_button.dart';
import '../../../../shared/widgets/viral_sharing_card.dart';
import '../../../../shared/widgets/toast_service.dart';
import '../../../../shared/services/sharing_service.dart';

/// Social sharing widget with viral features
/// Follows theme standardization and ANR prevention
class SocialSharingWidget extends StatefulWidget {
  final String userId;
  final String contentType;
  final String? imagePath;
  final Map<String, dynamic>? metadata;
  final String? customMessage;
  final bool showViralCard;
  final int referralCount;
  final int referralRewards;

  const SocialSharingWidget({
    super.key,
    required this.userId,
    required this.contentType,
    this.imagePath,
    this.metadata,
    this.customMessage,
    this.showViralCard = true,
    this.referralCount = 0,
    this.referralRewards = 0,
  });

  @override
  State<SocialSharingWidget> createState() => _SocialSharingWidgetState();
}

class _SocialSharingWidgetState extends State<SocialSharingWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppTheme.normalAnimation,
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: AppTheme.defaultCurve,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: AppTheme.defaultCurve,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value.clamp(0.0, 1.0),
            child: Column(
              children: [
                if (widget.showViralCard) ...[
                  ViralSharingCard(
                    userId: widget.userId,
                    referralCount: widget.referralCount,
                    referralRewards: widget.referralRewards,
                    onRefresh: _refreshStats,
                  ),
                  SizedBox(height: AppTheme.largeSpacing),
                ],
                _buildQuickSharingSection(),
                SizedBox(height: AppTheme.largeSpacing),
                _buildPlatformSharingSection(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickSharingSection() {
    return Container(
      margin: ResponsiveUtils.padding(context),
      padding: AppTheme.cardPadding(context),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(AppTheme.largeRadius),
        border: Border.all(color: AppTheme.borderLight),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryPink, AppTheme.primaryBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.share_rounded,
                  color: Colors.white,
                  size: 20.w,
                ),
              ),
              SizedBox(width: AppTheme.mediumSpacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Share Your Joy',
                      style: BabyFont.titleLarge.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: BabyFont.semiBold,
                      ),
                    ),
                    Text(
                      'Spread the happiness with friends and family!',
                      style: BabyFont.bodySmall.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.largeSpacing),
          if (widget.imagePath != null)
            SharingButton(
              userId: widget.userId,
              imagePath: widget.imagePath!,
              contentType: widget.contentType,
              metadata: widget.metadata,
              customMessage: widget.customMessage,
              buttonText: 'Share Result',
              icon: Icons.share_rounded,
              onPressed: () => _trackSharingAction('quick_share'),
            )
          else
            ResponsiveButton(
              text: 'Share App',
              icon: Icons.share_rounded,
              type: ButtonType.primary,
              size: ButtonSize.large,
              width: double.infinity,
              onPressed: _shareApp,
            ),
        ],
      ),
    );
  }

  Widget _buildPlatformSharingSection() {
    return Container(
      margin: ResponsiveUtils.padding(context),
      padding: AppTheme.cardPadding(context),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(AppTheme.largeRadius),
        border: Border.all(color: AppTheme.borderLight),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Share to Platforms',
            style: BabyFont.titleMedium.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: BabyFont.semiBold,
            ),
          ),
          SizedBox(height: AppTheme.smallSpacing),
          Text(
            'Choose your favorite platform to share',
            style: BabyFont.bodySmall.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: AppTheme.mediumSpacing),
          ResponsiveWidget(
            phone: _buildPhonePlatforms(),
            tablet: _buildTabletPlatforms(),
          ),
        ],
      ),
    );
  }

  Widget _buildPhonePlatforms() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildPlatformButton(
                'Instagram',
                Icons.camera_alt_rounded,
                const Color(0xFFE4405F),
                () => _shareToInstagram(),
              ),
            ),
            SizedBox(width: AppTheme.mediumSpacing),
            Expanded(
              child: _buildPlatformButton(
                'WhatsApp',
                Icons.chat_rounded,
                const Color(0xFF25D366),
                () => _shareToWhatsApp(),
              ),
            ),
          ],
        ),
        SizedBox(height: AppTheme.mediumSpacing),
        Row(
          children: [
            Expanded(
              child: _buildPlatformButton(
                'Copy Link',
                Icons.link_rounded,
                AppTheme.primaryBlue,
                () => _copyLink(),
              ),
            ),
            SizedBox(width: AppTheme.mediumSpacing),
            Expanded(
              child: _buildPlatformButton(
                'More',
                Icons.more_horiz_rounded,
                AppTheme.textSecondary,
                () => _showMoreOptions(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabletPlatforms() {
    return Wrap(
      spacing: AppTheme.mediumSpacing,
      runSpacing: AppTheme.mediumSpacing,
      children: [
        _buildPlatformButton(
          'Instagram',
          Icons.camera_alt_rounded,
          const Color(0xFFE4405F),
          () => _shareToInstagram(),
        ),
        _buildPlatformButton(
          'WhatsApp',
          Icons.chat_rounded,
          const Color(0xFF25D366),
          () => _shareToWhatsApp(),
        ),
        _buildPlatformButton(
          'Copy Link',
          Icons.link_rounded,
          AppTheme.primaryBlue,
          () => _copyLink(),
        ),
        _buildPlatformButton(
          'More',
          Icons.more_horiz_rounded,
          AppTheme.textSecondary,
          () => _showMoreOptions(),
        ),
      ],
    );
  }

  Widget _buildPlatformButton(
    String name,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppTheme.mediumSpacing),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Container(
              width: 50.w,
              height: 50.w,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 24.w,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              name,
              style: BabyFont.labelMedium.copyWith(
                color: color,
                fontWeight: BabyFont.medium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareApp() async {
    try {
      HapticFeedback.lightImpact();

      await SharingService.shareAppInvitation(
        context: context,
        userId: widget.userId,
        customMessage: widget.customMessage,
      );

      _trackSharingAction('app_invitation');
    } catch (e) {
      if (mounted) {
        ToastService.showError(context, 'Failed to share app');
      }
    }
  }

  Future<void> _shareToInstagram() async {
    if (widget.imagePath == null) {
      ToastService.showError(context, 'No image to share');
      return;
    }

    try {
      HapticFeedback.lightImpact();

      await SharingService.shareToInstagram(
        context: context,
        userId: widget.userId,
        imagePath: widget.imagePath!,
        metadata: widget.metadata,
      );

      _trackSharingAction('instagram');
    } catch (e) {
      if (mounted) {
        ToastService.showError(context, 'Failed to share to Instagram');
      }
    }
  }

  Future<void> _shareToWhatsApp() async {
    if (widget.imagePath == null) {
      ToastService.showError(context, 'No image to share');
      return;
    }

    try {
      HapticFeedback.lightImpact();

      await SharingService.shareToWhatsApp(
        context: context,
        userId: widget.userId,
        imagePath: widget.imagePath!,
        metadata: widget.metadata,
      );

      _trackSharingAction('whatsapp');
    } catch (e) {
      if (mounted) {
        ToastService.showError(context, 'Failed to share to WhatsApp');
      }
    }
  }

  Future<void> _copyLink() async {
    try {
      HapticFeedback.lightImpact();

      final link = await SharingService.generateSharingLink(
        userId: widget.userId,
        contentType: widget.contentType,
        metadata: widget.metadata,
      );

      if (mounted) {
        await SharingService.copyToClipboard(
          context: context,
          text: link,
          successMessage: 'Link copied! Share it anywhere! 📋',
        );
      }

      _trackSharingAction('copy_link');
    } catch (e) {
      if (mounted) {
        ToastService.showError(context, 'Failed to copy link');
      }
    }
  }

  void _showMoreOptions() {
    HapticFeedback.lightImpact();

    if (widget.imagePath != null) {
      // Show sharing modal with more options
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(), // SharingModal would go here
      );
    } else {
      _shareApp();
    }
  }

  void _trackSharingAction(String platform) {
    SharingService.trackViralMetrics(
      userId: widget.userId,
      action: 'shared',
      metadata: {
        'platform': platform,
        'contentType': widget.contentType,
        'source': 'social_widget',
      },
    );
  }

  void _refreshStats() {
    // Refresh viral sharing stats
    // This would typically trigger a parent widget refresh
  }
}
