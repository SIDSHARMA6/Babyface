import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';
import '../../../../shared/services/zodiac_compatibility_service.dart';
import '../../../../shared/widgets/toast_service.dart';

/// Zodiac compatibility widget for profile screen
class ZodiacCompatibilityWidget extends StatefulWidget {
  const ZodiacCompatibilityWidget({super.key});

  @override
  State<ZodiacCompatibilityWidget> createState() =>
      _ZodiacCompatibilityWidgetState();
}

class _ZodiacCompatibilityWidgetState extends State<ZodiacCompatibilityWidget> {
  final ZodiacCompatibilityService _zodiacService =
      ZodiacCompatibilityService.instance;
  List<ZodiacSign> _zodiacSigns = [];
  ZodiacCompatibility? _currentCompatibility;
  bool _isLoading = false;
  String? _selectedSign1;
  String? _selectedSign2;

  @override
  void initState() {
    super.initState();
    _loadZodiacData();
  }

  Future<void> _loadZodiacData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final signs = await _zodiacService.getAllZodiacSigns();

      setState(() {
        _zodiacSigns = signs;
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
                  Icons.star,
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
                      'Zodiac Compatibility',
                      style: BabyFont.headingS.copyWith(
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      'Discover your astrological connection',
                      style: BabyFont.bodyS.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _showZodiacSigns,
                icon: Icon(
                  Icons.info_outline,
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
          else if (_zodiacSigns.isEmpty)
            _buildEmptyState()
          else
            _buildZodiacContent(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        Icon(
          Icons.star_border,
          size: 48.w,
          color: AppTheme.textSecondary,
        ),
        SizedBox(height: 12.h),
        Text(
          'Zodiac data not available',
          style: BabyFont.bodyM.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Unable to load zodiac information',
          style: BabyFont.bodyS.copyWith(
            color: AppTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildZodiacContent() {
    return Column(
      children: [
        // Sign selection
        _buildSignSelection(),
        SizedBox(height: 16.h),

        // Compatibility result
        if (_currentCompatibility != null) ...[
          _buildCompatibilityResult(),
          SizedBox(height: 16.h),
        ],

        // Action buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _selectedSign1 != null && _selectedSign2 != null
                    ? _calculateCompatibility
                    : null,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryPink,
                  side: BorderSide(color: AppTheme.primaryPink),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text('Calculate'),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: ElevatedButton(
                onPressed: _showZodiacSigns,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPink,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text('View Signs'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSignSelection() {
    return Column(
      children: [
        // Partner 1 sign selection
        Text(
          'Select Your Zodiac Signs',
          style: BabyFont.bodyM.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 12.h),

        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Text(
                    'Partner 1',
                    style: BabyFont.bodyS.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  SizedBox(
                    width: double.infinity,
                    child: DropdownButtonFormField<String>(
                      value: _selectedSign1,
                      isExpanded:
                          true, // This is crucial for preventing overflow
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 8.h),
                      ),
                      hint: Text('Select sign'),
                      items: _zodiacSigns
                          .map((sign) => DropdownMenuItem(
                                value: sign.name,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(sign.emoji,
                                        style: TextStyle(fontSize: 16.sp)),
                                    SizedBox(width: 8.w),
                                    Flexible(
                                      child: Text(
                                        sign.name,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSign1 = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                children: [
                  Text(
                    'Partner 2',
                    style: BabyFont.bodyS.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  SizedBox(
                    width: double.infinity,
                    child: DropdownButtonFormField<String>(
                      value: _selectedSign2,
                      isExpanded:
                          true, // This is crucial for preventing overflow
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 8.h),
                      ),
                      hint: Text('Select sign'),
                      items: _zodiacSigns
                          .map((sign) => DropdownMenuItem(
                                value: sign.name,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(sign.emoji,
                                        style: TextStyle(fontSize: 16.sp)),
                                    SizedBox(width: 8.w),
                                    Flexible(
                                      child: Text(
                                        sign.name,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSign2 = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompatibilityResult() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryPink.withValues(alpha: 0.1),
            AppTheme.primaryPink.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          // Compatibility score
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${_currentCompatibility!.compatibilityScore}%',
                style: BabyFont.headingL.copyWith(
                  color: AppTheme.primaryPink,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                _currentCompatibility!.compatibilityLevel,
                style: BabyFont.bodyM.copyWith(
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),

          // Description
          Text(
            _currentCompatibility!.description,
            style: BabyFont.bodyS.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12.h),

          // Quick stats
          Row(
            children: [
              Expanded(
                child: _buildQuickStat(
                  'Strengths',
                  '${_currentCompatibility!.strengths.length}',
                  Icons.thumb_up,
                ),
              ),
              Container(
                width: 1.w,
                height: 30.h,
                color: AppTheme.textSecondary.withValues(alpha: 0.2),
              ),
              Expanded(
                child: _buildQuickStat(
                  'Challenges',
                  '${_currentCompatibility!.challenges.length}',
                  Icons.warning,
                ),
              ),
              Container(
                width: 1.w,
                height: 30.h,
                color: AppTheme.textSecondary.withValues(alpha: 0.2),
              ),
              Expanded(
                child: _buildQuickStat(
                  'Advice',
                  '${_currentCompatibility!.advice.length}',
                  Icons.lightbulb,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          size: 16.w,
          color: AppTheme.primaryPink,
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: BabyFont.headingS.copyWith(
            color: AppTheme.primaryPink,
          ),
        ),
        Text(
          label,
          style: BabyFont.bodyS.copyWith(
            color: AppTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Future<void> _calculateCompatibility() async {
    if (_selectedSign1 == null || _selectedSign2 == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final compatibility = await _zodiacService.calculateCompatibility(
          _selectedSign1!, _selectedSign2!);

      setState(() {
        _currentCompatibility = compatibility;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ToastService.showError(
          context, 'Failed to calculate compatibility: ${e.toString()}');
    }
  }

  void _showZodiacSigns() {
    showDialog(
      context: context,
      builder: (context) => ZodiacSignsDialog(
        zodiacSigns: _zodiacSigns,
      ),
    );
  }
}

/// Zodiac signs dialog
class ZodiacSignsDialog extends StatelessWidget {
  final List<ZodiacSign> zodiacSigns;

  const ZodiacSignsDialog({
    super.key,
    required this.zodiacSigns,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Zodiac Signs'),
      content: Container(
        width: double.maxFinite,
        height: 400.h,
        child: ListView.builder(
          itemCount: zodiacSigns.length,
          itemBuilder: (context, index) {
            final sign = zodiacSigns[index];
            return Container(
              margin: EdgeInsets.only(bottom: 8.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: AppTheme.textSecondary.withValues(alpha: 0.1),
                ),
              ),
              child: ListTile(
                leading: Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: Color(int.parse(sign.color.replaceAll('#', '0xFF')))
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Center(
                    child: Text(
                      sign.emoji,
                      style: TextStyle(fontSize: 20.sp),
                    ),
                  ),
                ),
                title: Text(sign.name),
                subtitle: Text(sign.description),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      sign.element,
                      style: BabyFont.bodyS.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    Text(
                      sign.quality,
                      style: BabyFont.bodyS.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  _showSignDetails(context, sign);
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

  void _showSignDetails(BuildContext context, ZodiacSign sign) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(sign.emoji, style: TextStyle(fontSize: 24.sp)),
            SizedBox(width: 8.w),
            Text(sign.name),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sign.description,
                style: BabyFont.bodyM.copyWith(
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: 16.h),
              _buildDetailRow('Symbol', sign.symbol),
              _buildDetailRow('Element', sign.element),
              _buildDetailRow('Quality', sign.quality),
              _buildDetailRow('Ruling Planet', sign.rulingPlanet),
              _buildDetailRow('Date Range',
                  '${sign.dateRange[0]}/${sign.dateRange[1]} - ${sign.dateRange[2]}/${sign.dateRange[3]}'),
              SizedBox(height: 16.h),
              Text(
                'Traits',
                style: BabyFont.bodyM.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: sign.traits
                    .map((trait) => Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryPink.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            trait,
                            style: BabyFont.bodyS.copyWith(
                              color: AppTheme.primaryPink,
                            ),
                          ),
                        ))
                    .toList(),
              ),
              SizedBox(height: 16.h),
              Text(
                'Compatible Signs',
                style: BabyFont.bodyM.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: sign.compatibleSigns
                    .map((compatibleSign) => Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryPink.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            compatibleSign,
                            style: BabyFont.bodyS.copyWith(
                              color: AppTheme.primaryPink,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: BabyFont.bodyS.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          Text(
            value,
            style: BabyFont.bodyS.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
