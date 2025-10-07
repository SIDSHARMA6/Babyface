import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_theme.dart';

/// Baby-themed card widget
class BabyCard extends StatelessWidget {
  final String? title;
  final IconData? icon;
  final Widget child;
  final Color? backgroundColor;
  final Border? border;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const BabyCard({
    super.key,
    this.title,
    this.icon,
    required this.child,
    this.backgroundColor,
    this.border,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: border,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null || icon != null)
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppTheme.babyPink.withValues(alpha: 0.1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                ),
              ),
              child: Row(
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      color: AppTheme.babyPink,
                      size: 20.w,
                    ),
                    SizedBox(width: 8.w),
                  ],
                  if (title != null)
                    Text(
                      title!,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.babyPink,
                      ),
                    ),
                ],
              ),
            ),
          Padding(
            padding: padding ?? EdgeInsets.all(16.w),
            child: child,
          ),
        ],
      ),
    );
  }
}
