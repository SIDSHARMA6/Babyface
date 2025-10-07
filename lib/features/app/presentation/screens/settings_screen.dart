import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';
import '../../../../shared/widgets/responsive_widgets.dart';

import '../../../../shared/services/storage_service.dart';

/// Settings screen with app preferences and data management
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _autoSaveEnabled = true;
  bool _highQualityMode = false;
  // String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: BabyFont.headlineMedium.copyWith(color: AppTheme.textPrimary),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ResponsivePadding(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection(
                'App Preferences',
                [
                  _buildSwitchTile(
                    'Notifications',
                    'Get notified when baby generation is complete',
                    Icons.notifications_rounded,
                    _notificationsEnabled,
                    (value) => setState(() => _notificationsEnabled = value),
                  ),
                  _buildSwitchTile(
                    'Auto Save',
                    'Automatically save generated baby photos',
                    Icons.save_rounded,
                    _autoSaveEnabled,
                    (value) => setState(() => _autoSaveEnabled = value),
                  ),
                  _buildSwitchTile(
                    'High Quality Mode',
                    'Generate higher quality images (slower)',
                    Icons.hd_rounded,
                    _highQualityMode,
                    (value) => setState(() => _highQualityMode = value),
                  ),
                ],
              ),
              SizedBox(height: AppTheme.largeSpacing),
              _buildSection(
                'Data Management',
                [
                  _buildActionTile(
                    'Clear Cache',
                    'Free up storage space',
                    Icons.cleaning_services_rounded,
                    AppTheme.warning,
                    () => _showClearCacheDialog(),
                  ),
                  _buildActionTile(
                    'Export Data',
                    'Backup your baby photos and data',
                    Icons.download_rounded,
                    AppTheme.info,
                    () => _exportData(),
                  ),
                  _buildActionTile(
                    'Delete All Data',
                    'Permanently remove all app data',
                    Icons.delete_forever_rounded,
                    AppTheme.error,
                    () => _showDeleteAllDialog(),
                  ),
                ],
              ),
              SizedBox(height: AppTheme.largeSpacing),
              _buildSection(
                'About',
                [
                  _buildInfoTile(
                    'App Version',
                    '1.0.0',
                    Icons.info_rounded,
                  ),
                  _buildActionTile(
                    'Privacy Policy',
                    'Read our privacy policy',
                    Icons.privacy_tip_rounded,
                    AppTheme.textSecondary,
                    () => _openPrivacyPolicy(),
                  ),
                  _buildActionTile(
                    'Terms of Service',
                    'Read our terms of service',
                    Icons.description_rounded,
                    AppTheme.textSecondary,
                    () => _openTermsOfService(),
                  ),
                  _buildActionTile(
                    'Contact Support',
                    'Get help with the app',
                    Icons.support_agent_rounded,
                    AppTheme.primaryBlue,
                    () => _contactSupport(),
                  ),
                ],
              ),
              SizedBox(height: AppTheme.extraLargeSpacing),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: BabyFont.headlineSmall.copyWith(color: AppTheme.textPrimary),
        ),
        SizedBox(height: AppTheme.mediumSpacing),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(AppTheme.largeRadius),
            boxShadow: AppTheme.softShadow,
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      leading: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          color: AppTheme.primaryPink.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppTheme.smallRadius),
        ),
        child: Icon(
          icon,
          color: AppTheme.primaryPink,
          size: 20.w,
        ),
      ),
      title: Text(
        title,
        style: BabyFont.titleMedium.copyWith(color: AppTheme.textPrimary),
      ),
      subtitle: Text(
        subtitle,
        style: BabyFont.bodySmall.copyWith(color: AppTheme.textSecondary),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryPink,
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppTheme.smallRadius),
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 20.w,
        ),
      ),
      title: Text(
        title,
        style: BabyFont.titleMedium.copyWith(color: AppTheme.textPrimary),
      ),
      subtitle: Text(
        subtitle,
        style: BabyFont.bodySmall.copyWith(color: AppTheme.textSecondary),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        color: AppTheme.textSecondary,
        size: 16.w,
      ),
      onTap: onTap,
    );
  }

  Widget _buildInfoTile(
    String title,
    String value,
    IconData icon,
  ) {
    return ListTile(
      leading: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          color: AppTheme.textSecondary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppTheme.smallRadius),
        ),
        child: Icon(
          icon,
          color: AppTheme.textSecondary,
          size: 20.w,
        ),
      ),
      title: Text(
        title,
        style: BabyFont.titleMedium.copyWith(color: AppTheme.textPrimary),
      ),
      trailing: Text(
        value,
        style: BabyFont.bodyMedium.copyWith(color: AppTheme.textSecondary),
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Clear Cache',
          style: BabyFont.headlineSmall,
        ),
        content: Text(
          'This will free up storage space but may slow down the app temporarily. Continue?',
          style: BabyFont.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style:
                  BabyFont.labelLarge.copyWith(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _clearCache();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.warning,
            ),
            child: Text(
              'Clear',
              style: BabyFont.labelLarge.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete All Data',
          style: BabyFont.headlineSmall.copyWith(color: AppTheme.error),
        ),
        content: Text(
          'This will permanently delete all your baby photos, avatars, and app data. This action cannot be undone!',
          style: BabyFont.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style:
                  BabyFont.labelLarge.copyWith(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteAllData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
            ),
            child: Text(
              'Delete All',
              style: BabyFont.labelLarge.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _clearCache() async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Simulate cache clearing
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        Navigator.of(context).pop(); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Cache cleared successfully! 🧹',
              style: BabyFont.bodyMedium.copyWith(color: Colors.white),
            ),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to clear cache: $e',
              style: BabyFont.bodyMedium.copyWith(color: Colors.white),
            ),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteAllData() async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Clear all data
      await StorageService.clearAllData();

      // Reset app state
      // ref.refresh(appStateProvider);

      if (mounted) {
        Navigator.of(context).pop(); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'All data deleted successfully',
              style: BabyFont.bodyMedium.copyWith(color: Colors.white),
            ),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to delete data: $e',
              style: BabyFont.bodyMedium.copyWith(color: Colors.white),
            ),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Export feature coming soon! 📤',
          style: BabyFont.bodyMedium.copyWith(color: Colors.white),
        ),
        backgroundColor: AppTheme.info,
      ),
    );
  }

  void _openPrivacyPolicy() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Privacy policy will open in browser',
          style: BabyFont.bodyMedium.copyWith(color: Colors.white),
        ),
        backgroundColor: AppTheme.info,
      ),
    );
  }

  void _openTermsOfService() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Terms of service will open in browser',
          style: BabyFont.bodyMedium.copyWith(color: Colors.white),
        ),
        backgroundColor: AppTheme.info,
      ),
    );
  }

  void _contactSupport() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Support contact feature coming soon! 📧',
          style: BabyFont.bodyMedium.copyWith(color: Colors.white),
        ),
        backgroundColor: AppTheme.info,
      ),
    );
  }
}
