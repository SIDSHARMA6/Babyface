import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/baby_font.dart';
import '../models/avatar_data.dart';
import 'loading_animation.dart';

/// Enhanced reusable avatar widget with upload/edit capabilities
/// Supports camera, gallery, face detection, and cute animations
class AvatarWidget extends StatefulWidget {
  final AvatarData? avatarData;
  final String placeholder;
  final VoidCallback? onTap;
  final Function(File)? onImageSelected;
  final Function(String)? onImagePath; // For image path callback
  final double size;
  final bool showUploadIcon;
  final bool isLoading;
  final String? gender; // 'male' or 'female' for styling
  final AvatarData? avatar;
  final bool isMale;
  final VoidCallback? onDelete;
  final bool enableImagePicker; // Enable built-in image picker
  final bool showFaceDetectionStatus; // Show face detection indicator
  final String? errorMessage; // Show error message

  const AvatarWidget({
    super.key,
    this.avatarData,
    required this.placeholder,
    this.onTap,
    this.onImageSelected,
    this.onImagePath,
    this.size = 120,
    this.showUploadIcon = true,
    this.isLoading = false,
    this.gender,
    this.avatar,
    this.isMale = true,
    this.onDelete,
    this.enableImagePicker = false,
    this.showFaceDetectionStatus = false,
    this.errorMessage,
  });

  @override
  State<AvatarWidget> createState() => _AvatarWidgetState();
}

class _AvatarWidgetState extends State<AvatarWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Start pulse animation if loading
    if (widget.isLoading) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _showImageSourceDialog() async {
    HapticFeedback.lightImpact();

    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceLight,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20.r),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40.w,
                  height: 4.h,
                  margin: EdgeInsets.symmetric(vertical: 12.h),
                  decoration: BoxDecoration(
                    color: AppTheme.borderLight,
                    borderRadius: BorderRadius.circular(2.h),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    children: [
                      Text(
                        'Choose Photo Source',
                        style: BabyFont.titleLarge.copyWith(
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Row(
                        children: [
                          Expanded(
                            child: _buildSourceOption(
                              icon: Icons.camera_alt_rounded,
                              label: 'Camera',
                              onTap: () => _pickImage(ImageSource.camera),
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: _buildSourceOption(
                              icon: Icons.photo_library_rounded,
                              label: 'Gallery',
                              onTap: () => _pickImage(ImageSource.gallery),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final color = widget.gender == 'male' || widget.isMale
        ? AppTheme.primaryBlue
        : AppTheme.primaryPink;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
            width: 1.w,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32.w,
              color: color,
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              style: BabyFont.titleSmall.copyWith(
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    Navigator.of(context).pop(); // Close the modal

    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        final file = File(image.path);
        widget.onImageSelected?.call(file);
        widget.onImagePath?.call(image.path);
      }
    } catch (e) {
      // Handle error silently or show toast
      debugPrint('Error picking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatarData = widget.avatarData ?? widget.avatar;
    final hasImage = avatarData?.hasImage == true;
    final color = widget.gender == 'male' || widget.isMale
        ? AppTheme.babyBlue
        : AppTheme.babyPink;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isLoading
              ? _pulseAnimation.value * _scaleAnimation.value
              : _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) => _animationController.forward(),
            onTapUp: (_) => _animationController.reverse(),
            onTapCancel: () => _animationController.reverse(),
            onTap: widget.enableImagePicker
                ? _showImageSourceDialog
                : widget.onTap,
            child: Stack(
              children: [
                Container(
                  width: widget.size.w,
                  height: widget.size.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: color,
                      width: 3.w,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 10.r,
                        offset: Offset(0, 4.h),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: hasImage
                        ? Image.file(
                            File(avatarData!.imagePath!),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPlaceholder(color);
                            },
                          )
                        : _buildPlaceholder(color),
                  ),
                ),

                // Loading overlay
                if (widget.isLoading)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: LoadingAnimation(
                          size: widget.size * 0.3,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                // Upload icon
                if (widget.showUploadIcon && !hasImage && !widget.isLoading)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 32.w,
                      height: 32.w,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2.w,
                        ),
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 16.w,
                      ),
                    ),
                  ),

                // Face detection status
                if (widget.showFaceDetectionStatus &&
                    hasImage &&
                    !widget.isLoading)
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      width: 24.w,
                      height: 24.w,
                      decoration: BoxDecoration(
                        color: avatarData?.faceDetected == true
                            ? AppTheme.success
                            : AppTheme.error,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2.w,
                        ),
                      ),
                      child: Icon(
                        avatarData?.faceDetected == true
                            ? Icons.face_rounded
                            : Icons.face_retouching_off_rounded,
                        color: Colors.white,
                        size: 12.w,
                      ),
                    ),
                  ),

                // Delete button
                if (hasImage && widget.onDelete != null && !widget.isLoading)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: widget.onDelete,
                      child: Container(
                        width: 24.w,
                        height: 24.w,
                        decoration: BoxDecoration(
                          color: AppTheme.error,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2.w,
                          ),
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 12.w,
                        ),
                      ),
                    ),
                  ),

                // Error message
                if (widget.errorMessage != null && !widget.isLoading)
                  Positioned(
                    bottom: -30.h,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.error,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        widget.errorMessage!,
                        style: BabyFont.labelSmall.copyWith(
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder(Color color) {
    return Container(
      color: color.withValues(alpha: 0.1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget.gender == 'male' || widget.isMale
                ? Icons.person
                : Icons.person_outline,
            size: widget.size * 0.4,
            color: color,
          ),
          SizedBox(height: 8.h),
          Text(
            widget.placeholder,
            style: TextStyle(
              fontSize: (widget.size * 0.1).sp,
              color: color,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
