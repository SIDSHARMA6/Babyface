import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_extensions.dart';
import 'loading_animation.dart';

// Button types and sizes are defined in theme_extensions.dart

/// Responsive button with baby-themed styling
class ResponsiveButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final ButtonType type;
  final ButtonSize size;
  final IconData? icon;
  final Color? color;
  final Color? textColor;
  final double? width;
  final EdgeInsetsGeometry? padding;

  const ResponsiveButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.icon,
    this.color,
    this.textColor,
    this.width,
    this.padding,
  });

  @override
  State<ResponsiveButton> createState() => _ResponsiveButtonState();
}

class _ResponsiveButtonState extends State<ResponsiveButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = !widget.isEnabled || widget.isLoading;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown:
                isDisabled ? null : (_) => _animationController.forward(),
            onTapUp: isDisabled ? null : (_) => _animationController.reverse(),
            onTapCancel:
                isDisabled ? null : () => _animationController.reverse(),
            child: Container(
              width: widget.width,
              padding: widget.padding ?? EdgeInsets.zero,
              decoration: _getDecoration(isDisabled),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isDisabled ? null : widget.onPressed,
                  borderRadius: BorderRadius.circular(_getBorderRadius()),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: _getVerticalPadding(),
                    ),
                    child: _buildContent(),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    if (widget.isLoading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LoadingAnimation(
            size: _getIconSize(),
            color: _getTextColor(),
          ),
          SizedBox(width: 8.w),
          Text(
            'Loading...',
            style: _getTextStyle(),
          ),
        ],
      );
    }

    if (widget.icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget.icon,
            size: _getIconSize(),
            color: _getTextColor(),
          ),
          SizedBox(width: 8.w),
          Text(
            widget.text,
            style: _getTextStyle(),
          ),
        ],
      );
    }

    return Text(
      widget.text,
      style: _getTextStyle(),
      textAlign: TextAlign.center,
    );
  }

  BoxDecoration _getDecoration(bool isDisabled) {
    Color backgroundColor;
    Color borderColor = Colors.transparent;

    switch (widget.type) {
      case ButtonType.primary:
        backgroundColor = widget.color ?? AppTheme.babyPink;
        break;
      case ButtonType.secondary:
        backgroundColor = Colors.transparent;
        borderColor = widget.color ?? AppTheme.babyBlue;
        break;
      case ButtonType.outline:
        backgroundColor = Colors.transparent;
        borderColor = widget.color ?? AppTheme.babyPink;
        break;
      case ButtonType.ghost:
        backgroundColor =
            (widget.color ?? AppTheme.babyYellow).withValues(alpha: 0.1);
        break;
    }

    if (isDisabled) {
      backgroundColor = backgroundColor.withValues(alpha: 0.5);
      borderColor = borderColor.withValues(alpha: 0.5);
    }

    return BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(_getBorderRadius()),
      border: widget.type == ButtonType.outline ||
              widget.type == ButtonType.secondary
          ? Border.all(color: borderColor, width: 2.w)
          : null,
      boxShadow: widget.type == ButtonType.primary && !isDisabled
          ? [
              BoxShadow(
                color:
                    (widget.color ?? AppTheme.babyPink).withValues(alpha: 0.3),
                blurRadius: 8.r,
                offset: Offset(0, 4.h),
              ),
            ]
          : null,
    );
  }

  TextStyle _getTextStyle() {
    return TextStyle(
      fontSize: _getFontSize(),
      fontWeight: FontWeight.w600,
      color: _getTextColor(),
    );
  }

  Color _getTextColor() {
    if (widget.textColor != null) {
      return widget.textColor!;
    }

    switch (widget.type) {
      case ButtonType.primary:
        return Colors.white;
      case ButtonType.secondary:
      case ButtonType.outline:
        return widget.color ?? AppTheme.babyBlue;
      case ButtonType.ghost:
        return widget.color ?? AppTheme.babyYellow;
    }
  }

  double _getFontSize() {
    switch (widget.size) {
      case ButtonSize.small:
        return 12.sp;
      case ButtonSize.medium:
        return 14.sp;
      case ButtonSize.large:
        return 16.sp;
    }
  }

  double _getVerticalPadding() {
    switch (widget.size) {
      case ButtonSize.small:
        return 8.h;
      case ButtonSize.medium:
        return 12.h;
      case ButtonSize.large:
        return 16.h;
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case ButtonSize.small:
        return 16.w;
      case ButtonSize.medium:
        return 20.w;
      case ButtonSize.large:
        return 24.w;
    }
  }

  double _getBorderRadius() {
    switch (widget.size) {
      case ButtonSize.small:
        return 16.r;
      case ButtonSize.medium:
        return 20.r;
      case ButtonSize.large:
        return 24.r;
    }
  }
}
