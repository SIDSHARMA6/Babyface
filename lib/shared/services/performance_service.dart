import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'dart:developer' as developer;

/// Performance monitoring service for smooth UI
class PerformanceService {
  static final PerformanceService _instance = PerformanceService._internal();
  factory PerformanceService() => _instance;
  PerformanceService._internal();

  static PerformanceService get instance => _instance;

  bool _isMonitoring = false;
  int _frameCount = 0;
  int _droppedFrames = 0;
  DateTime? _lastFrameTime;

  /// Start monitoring performance
  void startMonitoring() {
    if (_isMonitoring) return;

    _isMonitoring = true;
    _frameCount = 0;
    _droppedFrames = 0;
    _lastFrameTime = DateTime.now();

    SchedulerBinding.instance.addPersistentFrameCallback(_onFrame);

    developer.log('📊 Performance monitoring started');
  }

  /// Stop monitoring performance
  void stopMonitoring() {
    if (!_isMonitoring) return;

    _isMonitoring = false;
    // Note: removePersistentFrameCallback is not available in all Flutter versions
    // The callback will naturally stop when _isMonitoring is false

    developer.log('📊 Performance monitoring stopped');
  }

  /// Frame callback for monitoring
  void _onFrame(Duration timeStamp) {
    if (!_isMonitoring) return;

    _frameCount++;
    final now = DateTime.now();

    if (_lastFrameTime != null) {
      final frameDuration = now.difference(_lastFrameTime!);

      // Only log significant frame drops (>50ms) to reduce noise
      if (frameDuration.inMilliseconds > 50) {
        _droppedFrames++;

        if (kDebugMode) {
          developer.log(
              '⚠️ Significant frame drop: ${frameDuration.inMilliseconds}ms');
        }
      }
    }

    _lastFrameTime = now;

    // Log performance stats every 200 frames (reduced frequency)
    if (_frameCount % 200 == 0) {
      _logPerformanceStats();
    }
  }

  /// Log performance statistics
  void _logPerformanceStats() {
    final droppedFramePercentage = (_droppedFrames / _frameCount) * 100;

    developer.log('📊 Performance Stats:');
    developer.log('   Frames: $_frameCount');
    developer.log('   Dropped: $_droppedFrames');
    developer
        .log('   Drop Rate: ${droppedFramePercentage.toStringAsFixed(2)}%');

    if (droppedFramePercentage > 5.0) {
      developer.log('⚠️ High frame drop rate detected!');
    }
  }

  /// Get current performance metrics
  Map<String, dynamic> getPerformanceMetrics() {
    final droppedFramePercentage =
        _frameCount > 0 ? (_droppedFrames / _frameCount) * 100 : 0.0;

    return {
      'frameCount': _frameCount,
      'droppedFrames': _droppedFrames,
      'droppedFramePercentage': droppedFramePercentage,
      'isMonitoring': _isMonitoring,
    };
  }

  /// Check if performance is optimal
  bool isPerformanceOptimal() {
    final metrics = getPerformanceMetrics();
    return metrics['droppedFramePercentage'] < 5.0;
  }

  /// Optimize widget build performance
  static Widget optimizeWidget(Widget child, {String? debugLabel}) {
    if (kDebugMode && debugLabel != null) {
      developer.log('🔧 Optimizing widget: $debugLabel');
    }

    return RepaintBoundary(
      child: child,
    );
  }

  /// Create optimized list view
  static Widget createOptimizedListView({
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
    ScrollController? controller,
    bool shrinkWrap = false,
    String? debugLabel,
  }) {
    if (kDebugMode && debugLabel != null) {
      developer.log('🔧 Creating optimized ListView: $debugLabel');
    }

    return ListView.builder(
      controller: controller,
      shrinkWrap: shrinkWrap,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return RepaintBoundary(
          child: itemBuilder(context, index),
        );
      },
    );
  }

  /// Create optimized grid view
  static Widget createOptimizedGridView({
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
    required int crossAxisCount,
    double crossAxisSpacing = 0.0,
    double mainAxisSpacing = 0.0,
    ScrollController? controller,
    bool shrinkWrap = false,
    String? debugLabel,
  }) {
    if (kDebugMode && debugLabel != null) {
      developer.log('🔧 Creating optimized GridView: $debugLabel');
    }

    return GridView.builder(
      controller: controller,
      shrinkWrap: shrinkWrap,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return RepaintBoundary(
          child: itemBuilder(context, index),
        );
      },
    );
  }

  /// Measure widget build time
  static T measureBuildTime<T>(String widgetName, T Function() builder) {
    final stopwatch = Stopwatch()..start();
    final result = builder();
    stopwatch.stop();

    if (kDebugMode) {
      developer
          .log('⏱️ $widgetName built in ${stopwatch.elapsedMilliseconds}ms');
    }

    return result;
  }

  /// Dispose resources
  void dispose() {
    stopMonitoring();
  }
}
