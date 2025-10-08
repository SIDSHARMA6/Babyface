import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';
import '../../../../shared/services/voice_recording_service.dart';
import '../../../../shared/widgets/toast_service.dart';

/// Voice recording widget for memory journal
/// Follows memory_journey.md specification for voice memories
class VoiceRecordingWidget extends StatefulWidget {
  final String? initialVoicePath;
  final Function(String?) onVoiceRecorded;
  final bool isEnabled;

  const VoiceRecordingWidget({
    super.key,
    this.initialVoicePath,
    required this.onVoiceRecorded,
    this.isEnabled = true,
  });

  @override
  State<VoiceRecordingWidget> createState() => _VoiceRecordingWidgetState();
}

class _VoiceRecordingWidgetState extends State<VoiceRecordingWidget>
    with TickerProviderStateMixin {
  final VoiceRecordingService _voiceService = VoiceRecordingService();

  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;

  String? _currentVoicePath;
  bool _isRecording = false;
  bool _isPlaying = false;
  Duration _recordingDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _currentVoicePath = widget.initialVoicePath;

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _waveController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _voiceService.hasPermission().then((hasPermission) {
      if (!hasPermission && mounted) {
        ToastService.showError(
            context, 'Microphone permission required for voice recording');
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.primaryPink.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppTheme.primaryPink.withValues(alpha: 0.3),
          width: 1.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.mic,
                color: AppTheme.primaryPink,
                size: 20.w,
              ),
              SizedBox(width: 8.w),
              Text(
                'Voice Memory',
                style: BabyFont.bodyM.copyWith(
                  color: AppTheme.primaryPink,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (_currentVoicePath != null) ...[
                IconButton(
                  onPressed: _isPlaying ? _stopPlaying : _playRecording,
                  icon: Icon(
                    _isPlaying ? Icons.stop : Icons.play_arrow,
                    color: AppTheme.primaryPink,
                    size: 20.w,
                  ),
                ),
                IconButton(
                  onPressed: _deleteRecording,
                  icon: Icon(
                    Icons.delete,
                    color: Colors.red,
                    size: 20.w,
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 12.h),
          if (_isRecording) ...[
            _buildRecordingIndicator(),
          ] else if (_currentVoicePath != null) ...[
            _buildPlaybackControls(),
          ] else ...[
            _buildRecordButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildRecordingIndicator() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Row(
          children: [
            Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              'Recording... ${_formatDuration(_recordingDuration)}',
              style: BabyFont.bodyS.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _stopRecording,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: Size(80.w, 32.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              child: Text(
                'Stop',
                style: BabyFont.bodyS.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPlaybackControls() {
    return Row(
      children: [
        Icon(
          Icons.audiotrack,
          color: AppTheme.primaryPink,
          size: 16.w,
        ),
        SizedBox(width: 8.w),
        Text(
          'Voice recorded',
          style: BabyFont.bodyS.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          '10s', // Placeholder duration
          style: BabyFont.bodyS.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildRecordButton() {
    return Row(
      children: [
        Icon(
          Icons.mic_none,
          color: AppTheme.textSecondary,
          size: 16.w,
        ),
        SizedBox(width: 8.w),
        Text(
          'Tap to record a voice memory',
          style: BabyFont.bodyS.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        const Spacer(),
        ElevatedButton(
          onPressed: widget.isEnabled ? _startRecording : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryPink,
            foregroundColor: Colors.white,
            minimumSize: Size(80.w, 32.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
          child: Text(
            'Record',
            style: BabyFont.bodyS.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _startRecording() async {
    if (!widget.isEnabled) return;

    HapticFeedback.lightImpact();

    final success = await _voiceService.startRecording();
    if (success && mounted) {
      setState(() {
        _isRecording = true;
      });

      _pulseController.repeat(reverse: true);
      _waveController.repeat();

      // Start duration timer
      _startDurationTimer();

      ToastService.showBabyMessage(context, 'Recording started! 🎤');
    } else if (mounted) {
      ToastService.showError(context, 'Failed to start recording');
    }
  }

  Future<void> _stopRecording() async {
    HapticFeedback.lightImpact();

    final path = await _voiceService.stopRecording();
    if (mounted) {
      setState(() {
        _isRecording = false;
        _currentVoicePath = path;
      });

      _pulseController.stop();
      _waveController.stop();

      if (path != null) {
        widget.onVoiceRecorded(path);
        ToastService.showBabyMessage(context, 'Voice recorded! 🎵');
      } else {
        ToastService.showError(context, 'Failed to save recording');
      }
    }
  }

  Future<void> _playRecording() async {
    if (_currentVoicePath == null) return;

    HapticFeedback.lightImpact();

    final success = await _voiceService.playRecording(_currentVoicePath!);
    if (success && mounted) {
      setState(() {
        _isPlaying = true;
      });

      ToastService.showBabyMessage(context, 'Playing voice memory! 🔊');
    } else if (mounted) {
      ToastService.showError(context, 'Failed to play recording');
    }
  }

  Future<void> _stopPlaying() async {
    HapticFeedback.lightImpact();

    await _voiceService.stopPlaying();
    if (mounted) {
      setState(() {
        _isPlaying = false;
      });
    }
  }

  Future<void> _deleteRecording() async {
    if (_currentVoicePath == null) return;

    HapticFeedback.lightImpact();

    final success = await _voiceService.deleteRecording(_currentVoicePath!);
    if (success && mounted) {
      setState(() {
        _currentVoicePath = null;
        _isPlaying = false;
      });

      widget.onVoiceRecorded(null);
      ToastService.showBabyMessage(context, 'Voice deleted! 🗑️');
    } else if (mounted) {
      ToastService.showError(context, 'Failed to delete recording');
    }
  }

  void _startDurationTimer() {
    Future.doWhile(() async {
      if (!_isRecording) return false;

      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _recordingDuration =
              Duration(seconds: _recordingDuration.inSeconds + 1);
        });
      }
      return _isRecording;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
