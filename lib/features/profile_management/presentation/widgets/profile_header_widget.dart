import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';
import '../../../../shared/models/user.dart';

/// Optimized profile header widget with collapsing SliverAppBar
class ProfileHeaderWidget extends StatelessWidget {
  final User? user;
  final String? bondName;
  final String? bondImagePath;
  final int daysTogether;
  final VoidCallback onEditProfile;
  final VoidCallback onShowSettings;

  const ProfileHeaderWidget({
    super.key,
    required this.user,
    required this.bondName,
    required this.bondImagePath,
    required this.daysTogether,
    required this.onEditProfile,
    required this.onShowSettings,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300.h,
      pinned: true,
      stretch: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final shrinkOffset = constraints.maxHeight - kToolbarHeight;
          final t = (1 - (shrinkOffset / 200)).clamp(0.0, 1.0);

          return FlexibleSpaceBar(
            title: Opacity(
              opacity: t,
              child: Text(
                bondName ?? 'Our Profile',
                style: BabyFont.titleMedium.copyWith(
                  color: AppTheme.primaryPink,
                  fontWeight: BabyFont.bold,
                ),
              ),
            ),
            background: _buildBackground(t),
          );
        },
      ),
      actions: [
        IconButton(
          onPressed: onEditProfile,
          icon: Icon(
            Icons.edit_rounded,
            color: AppTheme.primaryPink,
            size: 24.w,
          ),
        ),
        IconButton(
          onPressed: onShowSettings,
          icon: Icon(
            Icons.settings_rounded,
            color: AppTheme.primaryPink,
            size: 24.w,
          ),
        ),
      ],
    );
  }

  Widget _buildBackground(double t) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Background gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryPink.withValues(alpha: 0.1),
                AppTheme.accentYellow.withValues(alpha: 0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        // Profile content that shrinks
        Transform.scale(
          scale: 0.5 + (0.5 * (1 - t)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildProfileImage(),
              SizedBox(height: 16.h),
              _buildBondName(),
              SizedBox(height: 8.h),
              _buildDaysTogether(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileImage() {
    return Hero(
      tag: 'profile_image',
      child: Container(
        width: 120.w,
        height: 120.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppTheme.primaryPink,
            width: 3.w,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryPink.withValues(alpha: 0.3),
              blurRadius: 20.r,
              offset: Offset(0, 8.h),
            ),
          ],
        ),
        child: ClipOval(
          child: bondImagePath != null
              ? Image.file(
                  File(bondImagePath!),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildDefaultImage();
                  },
                )
              : _buildDefaultImage(),
        ),
      ),
    );
  }

  Widget _buildDefaultImage() {
    return Container(
      color: AppTheme.primaryPink.withValues(alpha: 0.1),
      child: Icon(
        Icons.favorite,
        size: 50.w,
        color: AppTheme.primaryPink,
      ),
    );
  }

  Widget _buildBondName() {
    return Text(
      bondName ?? 'Tap to set bond name',
      style: BabyFont.headingM.copyWith(
        color: AppTheme.primaryPink,
        fontWeight: BabyFont.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDaysTogether() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppTheme.accentYellow.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        '$daysTogether Days Together',
        style: BabyFont.bodyS.copyWith(
          color: AppTheme.accentYellow,
          fontWeight: BabyFont.bold,
        ),
      ),
    );
  }
}

