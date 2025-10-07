import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/baby_font.dart';
import 'sharing_modal.dart';

/// Universal sharing button with theme integration
/// Follows zero boilerplate and responsive design principles
class SharingButton extends StatefulWidget {
  final String userId;
  final String imagePath;
  final String contentType;
  final Map<String, dynamic>? metadata;
  final String? customMessage;
  final String? buttonText;
  final IconData? icon;
  final Color? color;
  final bool isCompact;
  final VoidCallback? onPressed;

  const SharingButton({
    super.key,
    required this.userId,
    required this.imagePath,
    required this.contentType,
    this.metadata,
    this.customMessage,
    this.buttonText,
    this.icon,
    this.color,
    this.isCompact = false,
    this.onPressed,
  });

  @override
  State<SharingButton> createState() => _SharingButtonState();
}

class _SharingButtonState extends State<SharingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppTheme.fastAnimation,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: AppTheme.defaultCurve,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: AppTheme.bouncyCurve,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final buttonColor = widget.color ?? AppTheme.primaryPink;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: GestureDetector(
              onTapDown: (_) => _animationController.forward(),
              onTapUp: (_) => _animationController.reverse(),
              onTapCancel: () => _animationController.reverse(),
              onTap: _handleTap,
              child: widget.isCompact
                  ? _buildCompactButton(buttonColor)
                  : _buildFullButton(buttonColor),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFullButton(Color buttonColor) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.mediumSpacing,
        vertical: 12.h,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            buttonColor,
            buttonColor.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.largeRadius),
        boxShadow: [
          BoxShadow(
            color: buttonColor.withValues(alpha: 0.3),
            blurRadius: 8.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            widget.icon ?? Icons.share_rounded,
            color: Colors.white,
            size: 20.w,
          ),
          SizedBox(width: 8.w),
          Text(
            widget.buttonText ?? 'Share',
            style: BabyFont.cuteButton.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactButton(Color buttonColor) {
    return Container(
      width: 44.w,
      height: 44.w,
      decoration: BoxDecoration(
        color: buttonColor,
        shape: BoxShape.circle,
        boxShadow: AppTheme.softShadow,
      ),
      child: Icon(
        widget.icon ?? Icons.share_rounded,
        color: Colors.white,
        size: 20.w,
      ),
    );
  }

  void _handleTap() {
    HapticFeedback.lightImpact();

    // Custom onPressed callback
    widget.onPressed?.call();

    // Show sharing modal
    _showSharingModal();
  }

  void _showSharingModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SharingModal(
        userId: widget.userId,
        imagePath: widget.imagePath,
        contentType: widget.contentType,
        metadata: widget.metadata,
        customMessage: widget.customMessage,
      ),
    );
  }
}
