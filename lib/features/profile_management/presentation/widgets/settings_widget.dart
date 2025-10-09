import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';
import '../../../../shared/widgets/toast_service.dart';

/// Optimized settings widget with toggle switches
class SettingsWidget extends StatefulWidget {
  const SettingsWidget({super.key});

  @override
  State<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: 15.h),
          _buildSettingsList(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Settings ⚙️',
          style: BabyFont.headingM.copyWith(
            fontSize: 20.sp,
            color: AppTheme.textPrimary,
            fontWeight: BabyFont.bold,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Customize your experience',
          style: BabyFont.bodyS.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsList() {
    return Column(
      children: [
        _buildSettingCard(
          'Notifications',
          'Manage your notification preferences',
          Icons.notifications_rounded,
          AppTheme.primaryBlue,
          _notificationsEnabled,
          (value) => _updateNotifications(value),
        ),
        _buildSettingCard(
          'Dark Mode',
          'Switch between light and dark themes',
          Icons.dark_mode_rounded,
          AppTheme.accentYellow,
          _darkModeEnabled,
          (value) => _updateDarkMode(value),
        ),
        _buildSettingCard(
          'Privacy',
          'Control your data and privacy settings',
          Icons.privacy_tip_rounded,
          AppTheme.primaryPink,
          false,
          (value) => _showPrivacyInfo(),
        ),
        _buildSettingCard(
          'Share App',
          'Invite friends to try Future Baby',
          Icons.share_rounded,
          AppTheme.primaryBlue,
          false,
          (value) => _showShareInfo(),
        ),
        _buildSettingCard(
          'Support',
          'Get help and contact support',
          Icons.help_rounded,
          Colors.grey,
          false,
          (value) => _showSupportInfo(),
        ),
      ],
    );
  }

  Widget _buildSettingCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildIconContainer(icon, color),
          SizedBox(width: 12.w),
          _buildTextContent(title, subtitle),
          _buildSwitch(color, value, onChanged),
        ],
      ),
    );
  }

  Widget _buildIconContainer(IconData icon, Color color) {
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 20.w),
    );
  }

  Widget _buildTextContent(String title, String subtitle) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: BabyFont.titleMedium.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: BabyFont.semiBold,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            subtitle,
            style: BabyFont.bodySmall.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitch(Color color, bool value, Function(bool) onChanged) {
    return Switch(
      value: value,
      onChanged: onChanged,
      activeColor: color,
    );
  }

  void _updateNotifications(bool value) {
    setState(() {
      _notificationsEnabled = value;
    });
    ToastService.showInfo(
      context,
      'Notifications ${value ? 'enabled' : 'disabled'}! 🔔',
    );
  }

  void _updateDarkMode(bool value) {
    setState(() {
      _darkModeEnabled = value;
    });
    ToastService.showInfo(
      context,
      'Dark mode ${value ? 'enabled' : 'disabled'}! 🌙',
    );
  }

  void _showPrivacyInfo() {
    ToastService.showInfo(context, 'Privacy settings coming soon! 🔒');
  }

  void _showShareInfo() {
    ToastService.showCelebration(context, 'Sharing app with friends! 📱');
  }

  void _showSupportInfo() {
    ToastService.showInfo(context, 'Support coming soon! 🆘');
  }
}

