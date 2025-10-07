import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/theme/baby_font.dart';
import '../../../../core/theme/responsive_utils.dart';
import '../../../../shared/widgets/responsive_widgets.dart';
import '../../../../shared/models/baby_result.dart';
import '../../../../shared/widgets/baby_card.dart';
import '../../../../shared/widgets/responsive_button.dart';
import '../../../../shared/widgets/toast_service.dart';

/// Enhanced baby detail screen with match percentages and sharing
class BabyDetailScreen extends StatefulWidget {
  final BabyResult result;

  const BabyDetailScreen({
    super.key,
    required this.result,
  });

  @override
  State<BabyDetailScreen> createState() => _BabyDetailScreenState();
}

class _BabyDetailScreenState extends State<BabyDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: AppTheme.normalAnimation,
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: AppTheme.slowAnimation,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: AppTheme.smoothCurve,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: AppTheme.bouncyCurve,
    ));
  }

  void _startAnimations() {
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _scaleController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ResponsivePadding(
                child: Column(
                  children: [
                    _buildBabyImage(),
                    SizedBox(height: AppTheme.largeSpacing),
                    _buildMatchPercentages(),
                    SizedBox(height: AppTheme.largeSpacing),
                    _buildBabyInfo(),
                    SizedBox(height: AppTheme.largeSpacing),
                    _buildActionButtons(),
                    SizedBox(height: AppTheme.extraLargeSpacing),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 100.h,
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.backgroundLight,
      foregroundColor: AppTheme.textPrimary,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Your Future Baby ✨',
          style: BabyFont.titleLarge.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: BabyFont.semiBold,
          ),
        ),
        centerTitle: true,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share_rounded),
          onPressed: _shareResult,
          tooltip: 'Share',
        ),
        IconButton(
          icon: const Icon(Icons.download_rounded),
          onPressed: _saveToGallery,
          tooltip: 'Save',
        ),
      ],
    );
  }

  Widget _buildBabyImage() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Hero(
        tag: 'baby_${widget.result.id}',
        child: Container(
          width: context.isMobile
              ? 280.w
              : context.isTablet
                  ? 320.w
                  : 360.w,
          height: context.isMobile
              ? 280.w
              : context.isTablet
                  ? 320.w
                  : 360.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.extraLargeRadius),
            boxShadow: AppTheme.strongShadow,
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryPink.withValues(alpha: 0.1),
                AppTheme.primaryBlue.withValues(alpha: 0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.extraLargeRadius),
            child: widget.result.hasImage
                ? Image.file(
                    File(widget.result.babyImagePath!),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildPlaceholder();
                    },
                  )
                : _buildPlaceholder(),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppTheme.surfaceLight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.child_care_rounded,
            size: 80.w,
            color: AppTheme.primaryPink,
          ),
          SizedBox(height: AppTheme.mediumSpacing),
          Text(
            'Your adorable baby!',
            style: BabyFont.titleMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchPercentages() {
    return Row(
      children: [
        Expanded(
          child: _buildMatchCard(
            'Dad Match',
            widget.result.maleMatchPercentage,
            AppTheme.primaryBlue,
            Icons.man_rounded,
          ),
        ),
        SizedBox(width: AppTheme.mediumSpacing),
        Expanded(
          child: _buildMatchCard(
            'Mom Match',
            widget.result.femaleMatchPercentage,
            AppTheme.primaryPink,
            Icons.woman_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildMatchCard(
      String title, int percentage, Color color, IconData icon) {
    return BabyCard(
      backgroundColor: color.withValues(alpha: 0.1),
      border: Border.all(color: color.withValues(alpha: 0.3), width: 2.w),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 32.w,
          ),
          SizedBox(height: AppTheme.smallSpacing),
          Text(
            '$percentage%',
            style: BabyFont.displaySmall.copyWith(
              color: color,
              fontWeight: BabyFont.extraBold,
            ),
          ),
          Text(
            title,
            style: BabyFont.labelMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBabyInfo() {
    return BabyCard(
      title: 'Baby Details',
      icon: Icons.info_rounded,
      child: Column(
        children: [
          _buildInfoRow('Generated', _formatDate(widget.result.createdAt)),
          SizedBox(height: AppTheme.smallSpacing),
          _buildInfoRow('Baby ID',
              '#${widget.result.id.substring(widget.result.id.length - 8)}'),
          SizedBox(height: AppTheme.smallSpacing),
          _buildInfoRow(
              'Status', widget.result.isProcessing ? 'Processing' : 'Complete'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: BabyFont.bodyMedium.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        Text(
          value,
          style: BabyFont.bodyMedium.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: BabyFont.medium,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return ResponsiveWidget(
      phone: _buildPhoneButtons(),
      tablet: _buildTabletButtons(),
    );
  }

  Widget _buildPhoneButtons() {
    return Column(
      children: [
        ResponsiveButton(
          text: 'Share Your Baby ✨',
          onPressed: _shareResult,
          type: ButtonType.primary,
          size: ButtonSize.large,
          width: double.infinity,
          icon: Icons.share_rounded,
        ),
        SizedBox(height: AppTheme.mediumSpacing),
        Row(
          children: [
            Expanded(
              child: ResponsiveButton(
                text: 'Save',
                onPressed: _saveToGallery,
                type: ButtonType.secondary,
                size: ButtonSize.medium,
                icon: Icons.download_rounded,
              ),
            ),
            SizedBox(width: AppTheme.mediumSpacing),
            Expanded(
              child: ResponsiveButton(
                text: 'Generate New',
                onPressed: _generateNew,
                type: ButtonType.outline,
                size: ButtonSize.medium,
                icon: Icons.refresh_rounded,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabletButtons() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: ResponsiveButton(
            text: 'Share Your Baby ✨',
            onPressed: _shareResult,
            type: ButtonType.primary,
            size: ButtonSize.large,
            icon: Icons.share_rounded,
          ),
        ),
        SizedBox(width: AppTheme.mediumSpacing),
        Expanded(
          child: ResponsiveButton(
            text: 'Save',
            onPressed: _saveToGallery,
            type: ButtonType.secondary,
            size: ButtonSize.large,
            icon: Icons.download_rounded,
          ),
        ),
        SizedBox(width: AppTheme.mediumSpacing),
        Expanded(
          child: ResponsiveButton(
            text: 'New',
            onPressed: _generateNew,
            type: ButtonType.outline,
            size: ButtonSize.large,
            icon: Icons.refresh_rounded,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _shareResult() {
    // TODO: Implement actual sharing
    ToastService.showBabyMessage(
      context,
      'Share feature coming soon! Your baby is too cute to keep secret! 👶✨',
    );
  }

  void _saveToGallery() {
    // TODO: Implement save to gallery
    ToastService.showSuccess(
      context,
      'Baby photo saved to gallery! 📸',
    );
  }

  void _generateNew() {
    Navigator.of(context).pop();
    ToastService.showInfo(
      context,
      'Ready to create another adorable baby! 🍼',
    );
  }
}
