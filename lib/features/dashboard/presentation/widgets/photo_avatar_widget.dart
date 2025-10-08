import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';
import '../../../../core/theme/baby_font.dart';

/// Photo avatar widget for male/female photo selection
class PhotoAvatarWidget extends StatelessWidget {
  final String label;
  final File? photo;
  final Color color;
  final VoidCallback onTap;

  const PhotoAvatarWidget({
    super.key,
    required this.label,
    required this.photo,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          // Outer glow ring - responsive sizing
          Container(
            width: 100.w,
            height: 100.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  color.withValues(alpha: 0.2),
                  color.withValues(alpha: 0.05),
                ],
              ),
            ),
            child: Center(
              child: // Main avatar circle
                  Container(
                width: 85.w,
                height: 85.w,
                decoration: BoxDecoration(
                  color: photo != null
                      ? Colors.white
                      : color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: photo != null ? color : color.withValues(alpha: 0.3),
                    width: 2.5.w,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.2),
                      blurRadius: 12.r,
                      offset: Offset(0, 4.h),
                    ),
                  ],
                ),
                child: photo != null
                    ? ClipOval(
                        child: Image.file(
                          photo!,
                          fit: BoxFit.cover,
                          width: 85.w,
                          height: 85.w,
                        ),
                      )
                    : Icon(
                        Icons.add_photo_alternate,
                        color: color.withValues(alpha: 0.6),
                        size: 35.w,
                      ),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: BabyFont.bodyM.copyWith(
              color: color,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
