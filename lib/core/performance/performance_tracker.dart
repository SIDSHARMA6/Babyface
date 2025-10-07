import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// Performance tracking and frame rate monitoring
/// Follows master plan performance standards
class PerformanceTracker {
  static final PerformanceTracker _instance = PerformanceTracker._internal();
  factory PerformanceTracker() => _instance;
  PerformanceTracker._internal();

  final Map<String, PerformanceMetrics> _metrics = {};
  Timer? _frameTimer;
  int _frameCount = 0;
  static const Duration _frameMonitoringInterval = Duration(seconds: 1);

  /// Start performance monitoring
  void startMonitoring() {
    if (kDebugMode) {
      _startFrameMonitoring();
    }
  }

  /// Stop performance monitoring
  void stopMonitoring() {
    _frameTimer?.cancel();
    _frameTimer = null;
  }

  /// Start frame rate monitoring
  void _startFrameMonitoring() {
    _frameTimer = Timer.periodic(_frameMonitoringInterval, (_) {
      _updateFrameMetrics();
    });

    // Listen to frame callbacks
    SchedulerBinding.instance.addPersistentFrameCallback(_onFrame);
  }

  /// Frame callback handler
  void _onFrame(Duration timeStamp) {
    _frameCount++;
  }

  /// Update frame metrics
  void _updateFrameMetrics() {
    final fps = _frameCount.toDouble();
    _frameCount = 0;

    // Log performance issues
    if (fps < 55.0) {
      // Below 55 FPS indicates performance issues
      developer.log(
        'Performance warning: FPS dropped to ${fps.toStringAsFixed(1)}',
        name: 'PerformanceTracker',
        level: 900, // Warning level
      );
    }
  }

  /// Wrap widget with performance tracking
  static Widget wrap({
    required String name,
    required Widget child,
  }) {
    if (kDebugMode) {
      return _PerformanceWrapper(
        name: name,
        child: child,
      );
    }
    return child;
  }

  /// Track widget build performance
  static void trackBuild(String name, Duration buildTime) {
    if (kDebugMode) {
      final tracker = PerformanceTracker();
      tracker._trackMetric(name, 'build', buildTime.inMicroseconds / 1000.0);
    }
  }

  /// Track method execution time
  static void trackMethod(String name, String method, Duration executionTime) {
    if (kDebugMode) {
      final tracker = PerformanceTracker();
      tracker._trackMetric(name, method, executionTime.inMicroseconds / 1000.0);
    }
  }

  /// Track custom metric
  void _trackMetric(String name, String method, double value) {
    final key = '$name.$method';
    if (!_metrics.containsKey(key)) {
      _metrics[key] = PerformanceMetrics();
    }
    _metrics[key]!.addValue(value);
  }

  /// Get performance metrics for a widget
  PerformanceMetrics? getMetrics(String name, String method) {
    return _metrics['$name.$method'];
  }

  /// Get all performance metrics
  Map<String, PerformanceMetrics> getAllMetrics() {
    return Map.unmodifiable(_metrics);
  }

  /// Clear all metrics
  void clearMetrics() {
    _metrics.clear();
  }
}

/// Performance wrapper widget
class _PerformanceWrapper extends StatefulWidget {
  final String name;
  final Widget child;

  const _PerformanceWrapper({
    required this.name,
    required this.child,
  });

  @override
  State<_PerformanceWrapper> createState() => _PerformanceWrapperState();
}

class _PerformanceWrapperState extends State<_PerformanceWrapper> {
  @override
  Widget build(BuildContext context) {
    final stopwatch = Stopwatch()..start();

    final result = widget.child;

    stopwatch.stop();
    PerformanceTracker.trackBuild(widget.name, stopwatch.elapsed);

    return result;
  }
}

/// Performance metrics data
class PerformanceMetrics {
  final List<double> _values = [];
  static const int _maxValues = 100;

  void addValue(double value) {
    _values.add(value);
    if (_values.length > _maxValues) {
      _values.removeAt(0);
    }
  }

  double get average {
    if (_values.isEmpty) return 0.0;
    return _values.reduce((a, b) => a + b) / _values.length;
  }

  double get min {
    if (_values.isEmpty) return 0.0;
    return _values.reduce((a, b) => a < b ? a : b);
  }

  double get max {
    if (_values.isEmpty) return 0.0;
    return _values.reduce((a, b) => a > b ? a : b);
  }

  int get count => _values.length;

  @override
  String toString() {
    return 'PerformanceMetrics(count: $count, avg: ${average.toStringAsFixed(2)}ms, '
        'min: ${min.toStringAsFixed(2)}ms, max: ${max.toStringAsFixed(2)}ms)';
  }
}
