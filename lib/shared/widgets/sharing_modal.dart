import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/baby_font.dart';
import 'responsive_widgets.dart';
import '../../core/theme/responsive_utils.dart';
import '../services/sharing_service.dart';
import 'toast_service.dart';

/// Theme-aware sharing modal with ANR prevention
/// Follows universal theme, responsive design, and zero boilerplate principles
class SharingModal extends StatefulWidget {
  final String userId;
  final String imagePath;
  final String contentType;
  final Map<String, dynamic>? metadata;
  final String? customMessage;

  const SharingModal({
    super.key,
    required this.userId,
    required this.imagePath,
    required this.contentType,
    this.metadata,
    this.customMessage,
  });

  @override
  State<SharingModal> createState() => _SharingModalState();
}

class _SharingModalState extends State<SharingModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  bool _isSharing = false;
  String? _generatedLink;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppTheme.normalAnimation,
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 1.0,
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
    _generateSharingLink();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _generateSharingLink() async {
    try {
      final link = await SharingService.generateSharingLink(
        userId: widget.userId,
        contentType: widget.contentType,
        metadata: widget.metadata,
      );

      if (mounted) {
        setState(() {
          _generatedLink = link;
        });
      }
    } catch (e) {
      // Use fallback URL if generation fails
      if (mounted) {
        setState(() {
          _generatedLink = 'https://futurebaby.app';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          color: Colors.black.withValues(alpha: 0.5 * _fadeAnimation.value),
          child: SlideTransition(
            position: Offset(0, _slideAnimation.value)
                .toTween()
                .animate(_animationController),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: _buildModalContent(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModalContent() {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.largeRadius),
        ),
        boxShadow: AppTheme.strongShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(),
          _buildHeader(),
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _buildPreview(),
                  SizedBox(height: AppTheme.largeSpacing),
                  _buildSharingOptions(),
                  SizedBox(height: AppTheme.largeSpacing),
                  _buildLinkSection(),
                  SizedBox(height: AppTheme.extraLargeSpacing),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      width: 40.w,
      height: 4.h,
      margin: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        color: AppTheme.borderLight,
        borderRadius: BorderRadius.circular(2.h),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: ResponsiveUtils.padding(context),
      child: Row(
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
                  'Share Your Result',
                  style: BabyFont.headlineSmall.copyWith(
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  'Spread the joy with friends and family!',
                  style: BabyFont.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _closeModal,
            icon: Icon(
              Icons.close_rounded,
              color: AppTheme.textSecondary,
              size: 24.w,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    return Container(
      margin: ResponsiveUtils.padding(context),
      padding: EdgeInsets.all(AppTheme.mediumSpacing),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
        border: Border.all(color: AppTheme.borderLight),
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.smallRadius),
            child: Image.asset(
              widget.imagePath,
              width: 60.w,
              height: 60.w,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 60.w,
                  height: 60.w,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryPink.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.smallRadius),
                  ),
                  child: Icon(
                    Icons.child_care_rounded,
                    color: AppTheme.primaryPink,
                    size: 30.w,
                  ),
                );
              },
            ),
          ),
          SizedBox(width: AppTheme.mediumSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getPreviewTitle(),
                  style: BabyFont.titleMedium.copyWith(
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  _getPreviewDescription(),
                  style: BabyFont.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSharingOptions() {
    final platforms = SharingService.getAvailablePlatforms();

    return Padding(
      padding: ResponsiveUtils.padding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Share to',
            style: BabyFont.titleMedium.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: AppTheme.mediumSpacing),
          ResponsiveWidget(
            phone: _buildPhoneSharingGrid(platforms),
            tablet: _buildTabletSharingGrid(platforms),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneSharingGrid(List<SharingPlatform> platforms) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children:
          platforms.map((platform) => _buildSharingOption(platform)).toList(),
    );
  }

  Widget _buildTabletSharingGrid(List<SharingPlatform> platforms) {
    return Wrap(
      spacing: AppTheme.mediumSpacing,
      runSpacing: AppTheme.mediumSpacing,
      children:
          platforms.map((platform) => _buildSharingOption(platform)).toList(),
    );
  }

  Widget _buildSharingOption(SharingPlatform platform) {
    return GestureDetector(
      onTap: () => _shareToplatform(platform),
      child: Container(
        width: 70.w,
        padding: EdgeInsets.symmetric(vertical: AppTheme.mediumSpacing),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
          border: Border.all(color: AppTheme.borderLight),
          boxShadow: AppTheme.softShadow,
        ),
        child: Column(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: platform.color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                platform.icon,
                color: platform.color,
                size: 20.w,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              platform.name,
              style: BabyFont.labelSmall.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkSection() {
    return Container(
      margin: ResponsiveUtils.padding(context),
      padding: EdgeInsets.all(AppTheme.mediumSpacing),
      decoration: BoxDecoration(
        color: AppTheme.primaryPink.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
        border: Border.all(
          color: AppTheme.primaryPink.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.link_rounded,
                color: AppTheme.primaryPink,
                size: 20.w,
              ),
              SizedBox(width: 8.w),
              Text(
                'Share Link',
                style: BabyFont.titleSmall.copyWith(
                  color: AppTheme.primaryPink,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.smallSpacing),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.smallRadius),
              border: Border.all(color: AppTheme.borderLight),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _generatedLink ?? 'Generating link...',
                    style: BabyFont.bodySmall.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap: _copyLink,
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryPink.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppTheme.smallRadius),
                    ),
                    child: Icon(
                      Icons.copy_rounded,
                      color: AppTheme.primaryPink,
                      size: 16.w,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getPreviewTitle() {
    switch (widget.contentType) {
      case 'baby_result':
        return 'Future Baby Result';
      case 'quiz_result':
        return 'Quiz Result';
      case 'app_invitation':
        return 'App Invitation';
      default:
        return 'Shared Content';
    }
  }

  String _getPreviewDescription() {
    switch (widget.contentType) {
      case 'baby_result':
        return 'Look at our adorable future baby! 👶✨';
      case 'quiz_result':
        return 'Check out my amazing quiz results! 🎯';
      case 'app_invitation':
        return 'Try this incredible baby prediction app! 🌟';
      default:
        return 'Amazing content to share with everyone!';
    }
  }

  Future<void> _shareToplatform(SharingPlatform platform) async {
    if (_isSharing) return;

    setState(() {
      _isSharing = true;
    });

    try {
      HapticFeedback.lightImpact();

      switch (platform.action) {
        case SharingAction.instagram:
          await SharingService.shareToInstagram(
            context: context,
            userId: widget.userId,
            imagePath: widget.imagePath,
            metadata: widget.metadata,
          );
          break;
        case SharingAction.whatsapp:
          await SharingService.shareToWhatsApp(
            context: context,
            userId: widget.userId,
            imagePath: widget.imagePath,
            metadata: widget.metadata,
          );
          break;
        case SharingAction.general:
          if (widget.contentType == 'baby_result') {
            await SharingService.shareBabyResult(
              context: context,
              imagePath: widget.imagePath,
              userId: widget.userId,
              customMessage: widget.customMessage,
              babyData: widget.metadata,
            );
          } else {
            await SharingService.shareAppInvitation(
              context: context,
              userId: widget.userId,
              customMessage: widget.customMessage,
            );
          }
          break;
        case SharingAction.copy:
          await _copyLink();
          break;
      }

      // Close modal after successful sharing
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _closeModal();
      });
    } catch (e) {
      if (mounted) {
        ToastService.showError(context, 'Sharing failed. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  Future<void> _copyLink() async {
    if (_generatedLink != null) {
      await SharingService.copyToClipboard(
        context: context,
        text: _generatedLink!,
        successMessage: 'Link copied! Share it anywhere! 📋',
      );
    }
  }

  void _closeModal() {
    _animationController.reverse().then((_) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }
}

extension on Offset {
  Tween<Offset> toTween() => Tween<Offset>(begin: this, end: Offset.zero);
}
