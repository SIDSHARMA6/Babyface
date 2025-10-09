import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';
import '../../../../shared/services/dynamic_theme_service.dart';
import '../../../../shared/widgets/toast_service.dart';

/// Theme selector widget for profile screen
class ThemeSelectorWidget extends StatefulWidget {
  const ThemeSelectorWidget({super.key});

  @override
  State<ThemeSelectorWidget> createState() => _ThemeSelectorWidgetState();
}

class _ThemeSelectorWidgetState extends State<ThemeSelectorWidget> {
  final DynamicThemeService _themeService = DynamicThemeService.instance;
  List<ThemeConfig> _themes = [];
  ThemeConfig? _currentTheme;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadThemes();
  }

  Future<void> _loadThemes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final themes = await _themeService.getAllThemes();
      final currentTheme = await _themeService.getCurrentTheme();

      setState(() {
        _themes = themes;
        _currentTheme = currentTheme;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPink.withValues(alpha: 0.1),
            blurRadius: 10.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: AppTheme.primaryPink.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.palette,
                  color: AppTheme.primaryPink,
                  size: 20.w,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dynamic Themes',
                      style: BabyFont.headingS.copyWith(
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      'Customize your app appearance',
                      style: BabyFont.bodyS.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _showCreateThemeDialog,
                icon: Icon(
                  Icons.add_circle_outline,
                  color: AppTheme.primaryPink,
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          if (_isLoading)
            Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryPink,
              ),
            )
          else if (_themes.isEmpty)
            _buildEmptyState()
          else
            _buildThemesContent(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        Icon(
          Icons.palette_outlined,
          size: 48.w,
          color: AppTheme.textSecondary,
        ),
        SizedBox(height: 12.h),
        Text(
          'No themes available',
          style: BabyFont.bodyM.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Create your first custom theme!',
          style: BabyFont.bodyS.copyWith(
            color: AppTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16.h),
        ElevatedButton(
          onPressed: _showCreateThemeDialog,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryPink,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          child: Text('Create Theme'),
        ),
      ],
    );
  }

  Widget _buildThemesContent() {
    return Column(
      children: [
        // Current theme
        if (_currentTheme != null) ...[
          _buildCurrentTheme(),
          SizedBox(height: 16.h),
        ],

        // Available themes
        _buildThemesGrid(),
        SizedBox(height: 16.h),

        // Action buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _showCreateThemeDialog,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryPink,
                  side: BorderSide(color: AppTheme.primaryPink),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text('Create Theme'),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: ElevatedButton(
                onPressed: _showThemePreview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPink,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text('Preview'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCurrentTheme() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _currentTheme!.primaryColor.withValues(alpha: 0.1),
            _currentTheme!.primaryColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Text(
            _currentTheme!.emoji,
            style: TextStyle(fontSize: 32.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentTheme!.name,
                  style: BabyFont.headingM.copyWith(
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  _currentTheme!.description,
                  style: BabyFont.bodyS.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: _currentTheme!.primaryColor,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              'Active',
              style: BabyFont.bodyS.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemesGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 1.2,
      ),
      itemCount: _themes.length,
      itemBuilder: (context, index) {
        final theme = _themes[index];
        final isCurrentTheme = _currentTheme?.id == theme.id;

        return GestureDetector(
          onTap: () => _selectTheme(theme),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isCurrentTheme
                    ? theme.primaryColor
                    : AppTheme.textSecondary.withValues(alpha: 0.2),
                width: isCurrentTheme ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.primaryColor.withValues(alpha: 0.1),
                  blurRadius: 8.r,
                  offset: Offset(0, 2.h),
                ),
              ],
            ),
            child: Column(
              children: [
                // Theme preview
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.primaryColor,
                          theme.secondaryColor,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(12.r)),
                    ),
                    child: Center(
                      child: Text(
                        theme.emoji,
                        style: TextStyle(fontSize: 24.sp),
                      ),
                    ),
                  ),
                ),

                // Theme info
                Padding(
                  padding: EdgeInsets.all(8.w),
                  child: Column(
                    children: [
                      Text(
                        theme.name,
                        style: BabyFont.bodyM.copyWith(
                          color: AppTheme.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        theme.description,
                        style: BabyFont.bodyS.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (isCurrentTheme) ...[
                        SizedBox(height: 4.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: theme.primaryColor,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            'Active',
                            style: BabyFont.bodyS.copyWith(
                              color: Colors.white,
                              fontSize: 10.sp,
                            ),
                          ),
                        ),
                      ],
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

  Future<void> _selectTheme(ThemeConfig theme) async {
    try {
      final success = await _themeService.setCurrentTheme(theme);
      if (success && mounted) {
        setState(() {
          _currentTheme = theme;
        });
        ToastService.showSuccess(context, 'Theme applied: ${theme.name} 🎨');
      } else {
        ToastService.showError(context, 'Failed to apply theme');
      }
    } catch (e) {
      ToastService.showError(context, 'Failed to apply theme: ${e.toString()}');
    }
  }

  void _showCreateThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => CreateThemeDialog(
        onThemeCreated: () {
          _loadThemes();
        },
      ),
    );
  }

  void _showThemePreview() {
    showDialog(
      context: context,
      builder: (context) => ThemePreviewDialog(
        themes: _themes,
        currentTheme: _currentTheme,
        onThemeSelected: (theme) {
          _selectTheme(theme);
        },
      ),
    );
  }
}

/// Create theme dialog
class CreateThemeDialog extends StatefulWidget {
  final VoidCallback onThemeCreated;

  const CreateThemeDialog({
    super.key,
    required this.onThemeCreated,
  });

  @override
  State<CreateThemeDialog> createState() => _CreateThemeDialogState();
}

class _CreateThemeDialogState extends State<CreateThemeDialog> {
  final DynamicThemeService _themeService = DynamicThemeService.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  Color _primaryColor = const Color(0xFF6B9D);
  Color _secondaryColor = const Color(0xFF9D6B);
  Color _accentColor = const Color(0xFF6B9D);
  String _selectedEmoji = '🎨';

  final List<String> _emojis = [
    '🎨',
    '💕',
    '🌅',
    '🌊',
    '💜',
    '🌿',
    '✨',
    '🌸',
    '🌈',
    '🦋'
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Create Custom Theme'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Theme name
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Theme Name',
                hintText: 'e.g., "Sunset Dreams"',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // Theme description
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'Describe your theme...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              maxLines: 2,
            ),
            SizedBox(height: 16.h),

            // Emoji selection
            Text(
              'Choose an emoji:',
              style: BabyFont.bodyM.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              children: _emojis
                  .map((emoji) => GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedEmoji = emoji;
                          });
                        },
                        child: Container(
                          width: 40.w,
                          height: 40.w,
                          decoration: BoxDecoration(
                            color: _selectedEmoji == emoji
                                ? AppTheme.primaryPink.withValues(alpha: 0.1)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: _selectedEmoji == emoji
                                  ? AppTheme.primaryPink
                                  : AppTheme.textSecondary
                                      .withValues(alpha: 0.2),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              emoji,
                              style: TextStyle(fontSize: 20.sp),
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
            SizedBox(height: 16.h),

            // Color selection
            Text(
              'Choose colors:',
              style: BabyFont.bodyM.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text('Primary', style: BabyFont.bodyS),
                      SizedBox(height: 4.h),
                      GestureDetector(
                        onTap: () => _selectColor('primary'),
                        child: Container(
                          width: 40.w,
                          height: 40.w,
                          decoration: BoxDecoration(
                            color: _primaryColor,
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                                color: AppTheme.textSecondary
                                    .withValues(alpha: 0.2)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text('Secondary', style: BabyFont.bodyS),
                      SizedBox(height: 4.h),
                      GestureDetector(
                        onTap: () => _selectColor('secondary'),
                        child: Container(
                          width: 40.w,
                          height: 40.w,
                          decoration: BoxDecoration(
                            color: _secondaryColor,
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                                color: AppTheme.textSecondary
                                    .withValues(alpha: 0.2)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text('Accent', style: BabyFont.bodyS),
                      SizedBox(height: 4.h),
                      GestureDetector(
                        onTap: () => _selectColor('accent'),
                        child: Container(
                          width: 40.w,
                          height: 40.w,
                          decoration: BoxDecoration(
                            color: _accentColor,
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                                color: AppTheme.textSecondary
                                    .withValues(alpha: 0.2)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _nameController.text.isNotEmpty ? _createTheme : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryPink,
            foregroundColor: Colors.white,
          ),
          child: Text('Create'),
        ),
      ],
    );
  }

  void _selectColor(String colorType) {
    // TODO: Implement color picker
    // For now, we'll cycle through some predefined colors
    final colors = [
      const Color(0xFF6B9D),
      const Color(0xFFFF6B35),
      const Color(0xFF4ECDC4),
      const Color(0xFF9B59B6),
      const Color(0xFF27AE60),
      const Color(0xFFFFD700),
    ];

    setState(() {
      switch (colorType) {
        case 'primary':
          _primaryColor =
              colors[(colors.indexOf(_primaryColor) + 1) % colors.length];
          break;
        case 'secondary':
          _secondaryColor =
              colors[(colors.indexOf(_secondaryColor) + 1) % colors.length];
          break;
        case 'accent':
          _accentColor =
              colors[(colors.indexOf(_accentColor) + 1) % colors.length];
          break;
      }
    });
  }

  Future<void> _createTheme() async {
    try {
      final theme = ThemeConfig(
        id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text,
        description: _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : 'Custom theme',
        primaryColor: _primaryColor,
        secondaryColor: _secondaryColor,
        accentColor: _accentColor,
        backgroundColor: const Color(0xFFFFFFFF),
        surfaceColor: const Color(0xFFFFFFFF),
        errorColor: const Color(0xFFE53E3E),
        emoji: _selectedEmoji,
        isCustom: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final success = await _themeService.addCustomTheme(theme);
      if (success && mounted) {
        Navigator.pop(context);
        widget.onThemeCreated();
        ToastService.showSuccess(context, 'Custom theme created! 🎨');
      } else {
        ToastService.showError(context, 'Failed to create theme');
      }
    } catch (e) {
      ToastService.showError(
          context, 'Failed to create theme: ${e.toString()}');
    }
  }
}

/// Theme preview dialog
class ThemePreviewDialog extends StatelessWidget {
  final List<ThemeConfig> themes;
  final ThemeConfig? currentTheme;
  final Function(ThemeConfig) onThemeSelected;

  const ThemePreviewDialog({
    super.key,
    required this.themes,
    required this.currentTheme,
    required this.onThemeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Theme Preview'),
      content: Container(
        width: double.maxFinite,
        height: 400.h,
        child: ListView.builder(
          itemCount: themes.length,
          itemBuilder: (context, index) {
            final theme = themes[index];
            final isCurrentTheme = currentTheme?.id == theme.id;

            return Container(
              margin: EdgeInsets.only(bottom: 8.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: isCurrentTheme
                      ? theme.primaryColor
                      : AppTheme.textSecondary.withValues(alpha: 0.2),
                  width: isCurrentTheme ? 2 : 1,
                ),
              ),
              child: ListTile(
                leading: Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [theme.primaryColor, theme.secondaryColor],
                    ),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Center(
                    child: Text(
                      theme.emoji,
                      style: TextStyle(fontSize: 20.sp),
                    ),
                  ),
                ),
                title: Text(theme.name),
                subtitle: Text(theme.description),
                trailing: isCurrentTheme
                    ? Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: theme.primaryColor,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          'Active',
                          style: BabyFont.bodyS.copyWith(
                            color: Colors.white,
                            fontSize: 10.sp,
                          ),
                        ),
                      )
                    : null,
                onTap: () {
                  onThemeSelected(theme);
                  Navigator.pop(context);
                },
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Close'),
        ),
      ],
    );
  }
}
