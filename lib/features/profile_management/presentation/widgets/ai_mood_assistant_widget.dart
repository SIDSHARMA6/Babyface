import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';
import '../../../../shared/services/ai_mood_assistant_service.dart';
import '../../../../shared/services/mood_tracking_service.dart';
import '../../../../shared/widgets/toast_service.dart';

/// AI mood assistant widget for profile screen
class AIMoodAssistantWidget extends StatefulWidget {
  const AIMoodAssistantWidget({super.key});

  @override
  State<AIMoodAssistantWidget> createState() => _AIMoodAssistantWidgetState();
}

class _AIMoodAssistantWidgetState extends State<AIMoodAssistantWidget> {
  final AIMoodAssistantService _aiService = AIMoodAssistantService.instance;
  final MoodTrackingService _moodService = MoodTrackingService.instance;

  MoodAnalysis? _latestAnalysis;
  WeeklyRecap? _latestRecap;
  bool _isLoading = false;
  bool _isGeneratingRecap = false;

  @override
  void initState() {
    super.initState();
    _loadLatestData();
  }

  Future<void> _loadLatestData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final analysis = await _aiService.getLatestMoodAnalysis();
      final recap = await _aiService.getLatestWeeklyRecap();

      setState(() {
        _latestAnalysis = analysis;
        _latestRecap = recap;
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
                  Icons.psychology,
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
                      'AI Mood Assistant',
                      style: BabyFont.headingS.copyWith(
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      'Personalized mood insights & weekly recaps',
                      style: BabyFont.bodyS.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _showAnalysisHistory,
                icon: Icon(
                  Icons.history,
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
          else
            _buildContent(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        // Latest analysis
        if (_latestAnalysis != null) ...[
          _buildLatestAnalysis(),
          SizedBox(height: 16.h),
        ],

        // Weekly recap section
        _buildWeeklyRecapSection(),
        SizedBox(height: 16.h),

        // Action buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _generateNewAnalysis,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryPink,
                  side: BorderSide(color: AppTheme.primaryPink),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text('Analyze Mood'),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: ElevatedButton(
                onPressed: _isGeneratingRecap ? null : _generateWeeklyRecap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPink,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: _isGeneratingRecap
                    ? SizedBox(
                        width: 16.w,
                        height: 16.w,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text('Generate Recap'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLatestAnalysis() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Analysis header
          Row(
            children: [
              Text(
                'Latest Analysis',
                style: BabyFont.bodyM.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppTheme.primaryPink.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  _latestAnalysis!.overallMood.toUpperCase(),
                  style: BabyFont.bodyS.copyWith(
                    color: AppTheme.primaryPink,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),

          // Mood score
          Row(
            children: [
              Text(
                'Mood Score: ',
                style: BabyFont.bodyS.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              Text(
                '${_latestAnalysis!.moodScore.toStringAsFixed(1)}/10',
                style: BabyFont.bodyS.copyWith(
                  color: AppTheme.primaryPink,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),

          // Analysis text
          Text(
            _latestAnalysis!.analysis,
            style: BabyFont.bodyS.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),

          // Quick stats
          Row(
            children: [
              Expanded(
                child: _buildQuickStat(
                  'Emotions',
                  '${_latestAnalysis!.dominantEmotions.length}',
                  Icons.emoji_emotions,
                ),
              ),
              Container(
                width: 1.w,
                height: 30.h,
                color: AppTheme.textSecondary.withValues(alpha: 0.2),
              ),
              Expanded(
                child: _buildQuickStat(
                  'Triggers',
                  '${_latestAnalysis!.moodTriggers.length}',
                  Icons.psychology,
                ),
              ),
              Container(
                width: 1.w,
                height: 30.h,
                color: AppTheme.textSecondary.withValues(alpha: 0.2),
              ),
              Expanded(
                child: _buildQuickStat(
                  'Suggestions',
                  '${_latestAnalysis!.suggestions.length}',
                  Icons.lightbulb,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyRecapSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.primaryPink.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Weekly Recap',
                style: BabyFont.bodyM.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Spacer(),
              if (_latestRecap != null)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryPink.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    _latestRecap!.overallMoodTrend.toUpperCase(),
                    style: BabyFont.bodyS.copyWith(
                      color: AppTheme.primaryPink,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 8.h),
          if (_latestRecap != null) ...[
            // Recap content
            Text(
              _latestRecap!.personalizedMessage,
              style: BabyFont.bodyS.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 12.h),

            // Recap stats
            Row(
              children: [
                Expanded(
                  child: _buildQuickStat(
                    'Avg Score',
                    '${_latestRecap!.averageMoodScore.toStringAsFixed(1)}',
                    Icons.trending_up,
                  ),
                ),
                Container(
                  width: 1.w,
                  height: 30.h,
                  color: AppTheme.textSecondary.withValues(alpha: 0.2),
                ),
                Expanded(
                  child: _buildQuickStat(
                    'Highlights',
                    '${_latestRecap!.moodHighlights.length}',
                    Icons.star,
                  ),
                ),
                Container(
                  width: 1.w,
                  height: 30.h,
                  color: AppTheme.textSecondary.withValues(alpha: 0.2),
                ),
                Expanded(
                  child: _buildQuickStat(
                    'Achievements',
                    '${_latestRecap!.achievements.length}',
                    Icons.emoji_events,
                  ),
                ),
              ],
            ),
          ] else ...[
            Text(
              'No weekly recap available yet. Generate one to get personalized insights about your mood patterns.',
              style: BabyFont.bodyS.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
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

  Future<void> _generateNewAnalysis() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get recent mood entries
      final moodEntries = await _moodService.getAllMoodEntries();
      final recentEntries = moodEntries
          .take(7)
          .map((entry) => entry.toMap())
          .toList(); // Last 7 entries

      // Generate analysis
      final analysis = await _aiService.analyzeMoodData(recentEntries);

      setState(() {
        _latestAnalysis = analysis;
        _isLoading = false;
      });

      ToastService.showSuccess(context, 'Mood analysis generated! 🧠');
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ToastService.showError(
          context, 'Failed to generate analysis: ${e.toString()}');
    }
  }

  Future<void> _generateWeeklyRecap() async {
    setState(() {
      _isGeneratingRecap = true;
    });

    try {
      // Get weekly analyses
      final analyses = await _aiService.getMoodAnalysisHistory();
      final weeklyAnalyses = analyses.take(7).toList(); // Last 7 analyses

      // Generate recap
      final recap = await _aiService.generateWeeklyRecap(weeklyAnalyses);

      setState(() {
        _latestRecap = recap;
        _isGeneratingRecap = false;
      });

      ToastService.showSuccess(context, 'Weekly recap generated! 📊');
    } catch (e) {
      setState(() {
        _isGeneratingRecap = false;
      });
      ToastService.showError(
          context, 'Failed to generate recap: ${e.toString()}');
    }
  }

  void _showAnalysisHistory() {
    showDialog(
      context: context,
      builder: (context) => AnalysisHistoryDialog(),
    );
  }
}

/// Analysis history dialog
class AnalysisHistoryDialog extends StatefulWidget {
  @override
  State<AnalysisHistoryDialog> createState() => _AnalysisHistoryDialogState();
}

class _AnalysisHistoryDialogState extends State<AnalysisHistoryDialog> {
  final AIMoodAssistantService _aiService = AIMoodAssistantService.instance;
  List<MoodAnalysis> _analyses = [];
  List<WeeklyRecap> _recaps = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final analyses = await _aiService.getMoodAnalysisHistory();
      final recaps = await _aiService.getWeeklyRecapHistory();

      setState(() {
        _analyses = analyses;
        _recaps = recaps;
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
    return AlertDialog(
      title: Text('Analysis History'),
      content: Container(
        width: double.maxFinite,
        height: 400.h,
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(color: AppTheme.primaryPink))
            : DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    TabBar(
                      labelColor: AppTheme.primaryPink,
                      unselectedLabelColor: AppTheme.textSecondary,
                      tabs: [
                        Tab(text: 'Analyses'),
                        Tab(text: 'Recaps'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildAnalysesList(),
                          _buildRecapsList(),
                        ],
                      ),
                    ),
                  ],
                ),
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

  Widget _buildAnalysesList() {
    if (_analyses.isEmpty) {
      return Center(
        child: Text(
          'No mood analyses available yet.\nGenerate one to see your emotional insights!',
          textAlign: TextAlign.center,
          style: BabyFont.bodyM.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: _analyses.length,
      itemBuilder: (context, index) {
        final analysis = _analyses[index];
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
                color: AppTheme.primaryPink.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Center(
                child: Text(
                  '${analysis.moodScore.toStringAsFixed(1)}',
                  style: BabyFont.bodyM.copyWith(
                    color: AppTheme.primaryPink,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            title: Text(analysis.overallMood),
            subtitle: Text(analysis.analysis),
            trailing: Text(
              '${analysis.date.day}/${analysis.date.month}',
              style: BabyFont.bodyS.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            onTap: () {
              _showAnalysisDetails(context, analysis);
            },
          ),
        );
      },
    );
  }

  Widget _buildRecapsList() {
    if (_recaps.isEmpty) {
      return Center(
        child: Text(
          'No weekly recaps available yet.\nGenerate one to see your weekly insights!',
          textAlign: TextAlign.center,
          style: BabyFont.bodyM.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: _recaps.length,
      itemBuilder: (context, index) {
        final recap = _recaps[index];
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
                color: AppTheme.primaryPink.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Center(
                child: Text(
                  '${recap.averageMoodScore.toStringAsFixed(1)}',
                  style: BabyFont.bodyM.copyWith(
                    color: AppTheme.primaryPink,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            title: Text(recap.overallMoodTrend),
            subtitle: Text(recap.personalizedMessage),
            trailing: Text(
              '${recap.weekStart.day}/${recap.weekStart.month}',
              style: BabyFont.bodyS.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            onTap: () {
              _showRecapDetails(context, recap);
            },
          ),
        );
      },
    );
  }

  void _showAnalysisDetails(BuildContext context, MoodAnalysis analysis) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Mood Analysis'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                analysis.analysis,
                style: BabyFont.bodyM.copyWith(
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Dominant Emotions',
                style: BabyFont.bodyM.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: analysis.dominantEmotions
                    .map((emotion) => Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryPink.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            emotion,
                            style: BabyFont.bodyS.copyWith(
                              color: AppTheme.primaryPink,
                            ),
                          ),
                        ))
                    .toList(),
              ),
              SizedBox(height: 16.h),
              Text(
                'Suggestions',
                style: BabyFont.bodyM.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              ...analysis.suggestions.map((suggestion) => Padding(
                    padding: EdgeInsets.only(bottom: 4.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('• ',
                            style: BabyFont.bodyS
                                .copyWith(color: AppTheme.primaryPink)),
                        Expanded(
                          child: Text(
                            suggestion,
                            style: BabyFont.bodyS.copyWith(
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
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

  void _showRecapDetails(BuildContext context, WeeklyRecap recap) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Weekly Recap'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                recap.personalizedMessage,
                style: BabyFont.bodyM.copyWith(
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Relationship Insight',
                style: BabyFont.bodyM.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                recap.relationshipInsight,
                style: BabyFont.bodyS.copyWith(
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Recommendations',
                style: BabyFont.bodyM.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              ...recap.recommendations.map((recommendation) => Padding(
                    padding: EdgeInsets.only(bottom: 4.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('• ',
                            style: BabyFont.bodyS
                                .copyWith(color: AppTheme.primaryPink)),
                        Expanded(
                          child: Text(
                            recommendation,
                            style: BabyFont.bodyS.copyWith(
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
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
}
