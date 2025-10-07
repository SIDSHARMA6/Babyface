import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/baby_font.dart';

/// Enhanced toast service for showing cute, user-friendly messages
class ToastService {
  static void showBabyMessage(BuildContext context, String message) {
    HapticFeedback.lightImpact();
    _showToast(
      context,
      message,
      AppTheme.primaryPink,
      Icons.child_care_rounded,
      '👶',
    );
  }

  static void showSuccess(BuildContext context, String message) {
    HapticFeedback.lightImpact();
    _showToast(
      context,
      message,
      AppTheme.success,
      Icons.check_circle_rounded,
      '🎉',
    );
  }

  static void showError(BuildContext context, String message) {
    HapticFeedback.lightImpact();
    _showToast(
      context,
      message,
      AppTheme.error,
      Icons.error_rounded,
      '😊',
    );
  }

  static void showWarning(BuildContext context, String message) {
    HapticFeedback.lightImpact();
    _showToast(
      context,
      message,
      AppTheme.warning,
      Icons.warning_rounded,
      '⚠️',
    );
  }

  static void showInfo(BuildContext context, String message) {
    HapticFeedback.lightImpact();
    _showToast(
      context,
      message,
      AppTheme.primaryBlue,
      Icons.info_rounded,
      'ℹ️',
    );
  }

  static void showLove(BuildContext context, String message) {
    HapticFeedback.lightImpact();
    _showToast(
      context,
      message,
      AppTheme.primaryPink,
      Icons.favorite_rounded,
      '💕',
    );
  }

  static void showCelebration(BuildContext context, String message) {
    HapticFeedback.mediumImpact();
    _showToast(
      context,
      message,
      AppTheme.accentYellow,
      Icons.celebration_rounded,
      '🌟',
    );
  }

  static void _showToast(
    BuildContext context,
    String message,
    Color color,
    IconData icon,
    String emoji,
  ) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        color: color,
        icon: icon,
        emoji: emoji,
        onDismiss: () => overlayEntry.remove(),
      ),
    );

    overlay.insert(overlayEntry);

    // Auto dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final Color color;
  final IconData icon;
  final String emoji;
  final VoidCallback onDismiss;

  const _ToastWidget({
    required this.message,
    required this.color,
    required this.icon,
    required this.emoji,
    required this.onDismiss,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16.h,
      left: 16.w,
      right: 16.w,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8.r,
                    offset: Offset(0, 4.h),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Text(
                    widget.emoji,
                    style: TextStyle(fontSize: 20.sp),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: BabyFont.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: BabyFont.medium,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: widget.onDismiss,
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 16.w,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
