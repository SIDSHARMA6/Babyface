import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'dart:async';

/// Performance optimization service
class PerformanceOptimizationService {
  static final PerformanceOptimizationService _instance =
      PerformanceOptimizationService._internal();
  factory PerformanceOptimizationService() => _instance;
  PerformanceOptimizationService._internal();

  final List<VoidCallback> _frameCallbacks = [];
  final List<VoidCallback> _postFrameCallbacks = [];
  Timer? _performanceTimer;
  int _frameCount = 0;
  double _fps = 60.0;

  /// Get performance optimization service instance
  static PerformanceOptimizationService get instance => _instance;

  /// Initialize performance monitoring
  void initialize() {
    _startPerformanceMonitoring();
  }

  /// Start performance monitoring
  void _startPerformanceMonitoring() {
    _performanceTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      _calculateFPS();
    });
  }

  /// Calculate FPS
  void _calculateFPS() {
    if (_frameCount > 0) {
      _fps = _frameCount.toDouble();
      _frameCount = 0;
    }
  }

  /// Get current FPS
  double get currentFPS => _fps;

  /// Add frame callback
  void addFrameCallback(VoidCallback callback) {
    _frameCallbacks.add(callback);
  }

  /// Remove frame callback
  void removeFrameCallback(VoidCallback callback) {
    _frameCallbacks.remove(callback);
  }

  /// Add post-frame callback
  void addPostFrameCallback(VoidCallback callback) {
    _postFrameCallbacks.add(callback);
  }

  /// Remove post-frame callback
  void removePostFrameCallback(VoidCallback callback) {
    _postFrameCallbacks.remove(callback);
  }

  /// Optimize widget for 60-120fps
  Widget optimizeWidget({
    required Widget child,
    bool enableRepaintBoundary = true,
    bool enableAutomaticKeepAlive = true,
    bool enableRepaintBoundaryForChildren = true,
  }) {
    Widget optimizedChild = child;

    if (enableRepaintBoundary) {
      optimizedChild = RepaintBoundary(
        child: optimizedChild,
      );
    }

    if (enableAutomaticKeepAlive) {
      optimizedChild = AutomaticKeepAlive(
        child: optimizedChild,
      );
    }

    return optimizedChild;
  }

  /// Create optimized list view
  Widget createOptimizedListView({
    required List<Widget> children,
    ScrollController? controller,
    bool shrinkWrap = false,
    bool enableRepaintBoundary = true,
  }) {
    return ListView.builder(
      controller: controller,
      shrinkWrap: shrinkWrap,
      itemCount: children.length,
      itemBuilder: (context, index) {
        final child = children[index];
        return enableRepaintBoundary ? RepaintBoundary(child: child) : child;
      },
    );
  }

  /// Create optimized grid view
  Widget createOptimizedGridView({
    required List<Widget> children,
    required int crossAxisCount,
    ScrollController? controller,
    bool shrinkWrap = false,
    bool enableRepaintBoundary = true,
  }) {
    return GridView.builder(
      controller: controller,
      shrinkWrap: shrinkWrap,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) {
        final child = children[index];
        return enableRepaintBoundary ? RepaintBoundary(child: child) : child;
      },
    );
  }

  /// Create optimized page view
  Widget createOptimizedPageView({
    required List<Widget> children,
    PageController? controller,
    bool enableRepaintBoundary = true,
  }) {
    return PageView.builder(
      controller: controller,
      itemCount: children.length,
      itemBuilder: (context, index) {
        final child = children[index];
        return enableRepaintBoundary ? RepaintBoundary(child: child) : child;
      },
    );
  }

  /// Create optimized custom scroll view
  Widget createOptimizedCustomScrollView({
    required List<Widget> slivers,
    ScrollController? controller,
    bool enableRepaintBoundary = true,
  }) {
    return CustomScrollView(
      controller: controller,
      slivers: slivers, // Don't wrap slivers with RepaintBoundary
    );
  }

  /// Create optimized animated widget
  Widget createOptimizedAnimatedWidget({
    required Widget child,
    required Animation<double> animation,
    bool enableRepaintBoundary = true,
  }) {
    Widget animatedChild = AnimatedBuilder(
      animation: animation,
      builder: (context, widget) => child,
    );

    if (enableRepaintBoundary) {
      animatedChild = RepaintBoundary(child: animatedChild);
    }

    return animatedChild;
  }

  /// Create optimized hero widget
  Widget createOptimizedHeroWidget({
    required String tag,
    required Widget child,
    bool enableRepaintBoundary = true,
  }) {
    Widget heroChild = Hero(
      tag: tag,
      child: child,
    );

    if (enableRepaintBoundary) {
      heroChild = RepaintBoundary(child: heroChild);
    }

    return heroChild;
  }

  /// Create optimized image widget
  Widget createOptimizedImageWidget({
    required String imagePath,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    bool enableRepaintBoundary = true,
  }) {
    Widget imageWidget = Image.asset(
      imagePath,
      width: width,
      height: height,
      fit: fit,
      cacheWidth: width?.toInt(),
      cacheHeight: height?.toInt(),
    );

    if (enableRepaintBoundary) {
      imageWidget = RepaintBoundary(child: imageWidget);
    }

    return imageWidget;
  }

  /// Create optimized network image widget
  Widget createOptimizedNetworkImageWidget({
    required String imageUrl,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    bool enableRepaintBoundary = true,
  }) {
    Widget imageWidget = Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      cacheWidth: width?.toInt(),
      cacheHeight: height?.toInt(),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[300],
          child: Icon(Icons.error),
        );
      },
    );

    if (enableRepaintBoundary) {
      imageWidget = RepaintBoundary(child: imageWidget);
    }

    return imageWidget;
  }

  /// Create optimized text widget
  Widget createOptimizedTextWidget({
    required String text,
    TextStyle? style,
    int? maxLines,
    TextOverflow? overflow,
    bool enableRepaintBoundary = true,
  }) {
    Widget textWidget = Text(
      text,
      style: style,
      maxLines: maxLines,
      overflow: overflow,
    );

    if (enableRepaintBoundary) {
      textWidget = RepaintBoundary(child: textWidget);
    }

    return textWidget;
  }

  /// Create optimized button widget
  Widget createOptimizedButtonWidget({
    required Widget child,
    required VoidCallback? onPressed,
    ButtonStyle? style,
    bool enableRepaintBoundary = true,
  }) {
    Widget buttonWidget = ElevatedButton(
      onPressed: onPressed,
      style: style,
      child: child,
    );

    if (enableRepaintBoundary) {
      buttonWidget = RepaintBoundary(child: buttonWidget);
    }

    return buttonWidget;
  }

  /// Create optimized container widget
  Widget createOptimizedContainerWidget({
    required Widget child,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Decoration? decoration,
    bool enableRepaintBoundary = true,
  }) {
    Widget containerWidget = Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      decoration: decoration,
      child: child,
    );

    if (enableRepaintBoundary) {
      containerWidget = RepaintBoundary(child: containerWidget);
    }

    return containerWidget;
  }

  /// Create optimized card widget
  Widget createOptimizedCardWidget({
    required Widget child,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    Color? color,
    double? elevation,
    bool enableRepaintBoundary = true,
  }) {
    Widget cardWidget = Card(
      margin: margin,
      color: color,
      elevation: elevation,
      child: padding != null
          ? Padding(
              padding: padding,
              child: child,
            )
          : child,
    );

    if (enableRepaintBoundary) {
      cardWidget = RepaintBoundary(child: cardWidget);
    }

    return cardWidget;
  }

  /// Create optimized dialog widget
  Widget createOptimizedDialogWidget({
    required Widget child,
    bool enableRepaintBoundary = true,
  }) {
    Widget dialogWidget = Dialog(
      child: child,
    );

    if (enableRepaintBoundary) {
      dialogWidget = RepaintBoundary(child: dialogWidget);
    }

    return dialogWidget;
  }

  /// Create optimized bottom sheet widget
  Widget createOptimizedBottomSheetWidget({
    required Widget child,
    bool enableRepaintBoundary = true,
  }) {
    Widget bottomSheetWidget = Container(
      child: child,
    );

    if (enableRepaintBoundary) {
      bottomSheetWidget = RepaintBoundary(child: bottomSheetWidget);
    }

    return bottomSheetWidget;
  }

  /// Create optimized snackbar widget
  Widget createOptimizedSnackBarWidget({
    required String message,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
    bool enableRepaintBoundary = true,
  }) {
    Widget snackBarWidget = SnackBar(
      content: Text(message),
      duration: duration,
      action: action,
    );

    if (enableRepaintBoundary) {
      snackBarWidget = RepaintBoundary(child: snackBarWidget);
    }

    return snackBarWidget;
  }

  /// Create optimized loading widget
  Widget createOptimizedLoadingWidget({
    double size = 24.0,
    Color? color,
    bool enableRepaintBoundary = true,
  }) {
    Widget loadingWidget = SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        color: color,
        strokeWidth: 2.0,
      ),
    );

    if (enableRepaintBoundary) {
      loadingWidget = RepaintBoundary(child: loadingWidget);
    }

    return loadingWidget;
  }

  /// Create optimized error widget
  Widget createOptimizedErrorWidget({
    required String message,
    VoidCallback? onRetry,
    bool enableRepaintBoundary = true,
  }) {
    Widget errorWidget = Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48.0,
            color: Colors.red,
          ),
          SizedBox(height: 16.0),
          Text(
            message,
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: onRetry,
              child: Text('Retry'),
            ),
          ],
        ],
      ),
    );

    if (enableRepaintBoundary) {
      errorWidget = RepaintBoundary(child: errorWidget);
    }

    return errorWidget;
  }

  /// Create optimized empty widget
  Widget createOptimizedEmptyWidget({
    required String message,
    IconData? icon,
    bool enableRepaintBoundary = true,
  }) {
    Widget emptyWidget = Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 48.0,
              color: Colors.grey,
            ),
            SizedBox(height: 16.0),
          ],
          Text(
            message,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );

    if (enableRepaintBoundary) {
      emptyWidget = RepaintBoundary(child: emptyWidget);
    }

    return emptyWidget;
  }

  /// Dispose service
  void dispose() {
    _performanceTimer?.cancel();
    _frameCallbacks.clear();
    _postFrameCallbacks.clear();
  }
}

/// Error handling service
class ErrorHandlingService {
  static final ErrorHandlingService _instance =
      ErrorHandlingService._internal();
  factory ErrorHandlingService() => _instance;
  ErrorHandlingService._internal();

  final List<ErrorHandler> _errorHandlers = [];
  final List<CrashReporter> _crashReporters = [];

  /// Get error handling service instance
  static ErrorHandlingService get instance => _instance;

  /// Initialize error handling
  void initialize() {
    _setupErrorHandling();
  }

  /// Setup error handling
  void _setupErrorHandling() {
    FlutterError.onError = (FlutterErrorDetails details) {
      _handleFlutterError(details);
    };

    // Note: PlatformDispatcher.onError is not available in all Flutter versions
    // This is a simplified error handling setup
  }

  /// Handle Flutter error
  void _handleFlutterError(FlutterErrorDetails details) {
    developer
        .log('❌ [ErrorHandlingService] Flutter Error: ${details.exception}');
    developer.log('❌ [ErrorHandlingService] Stack Trace: ${details.stack}');

    for (final handler in _errorHandlers) {
      try {
        handler.handleError(
            details.exception, details.stack ?? StackTrace.empty);
      } catch (e) {
        developer.log('❌ [ErrorHandlingService] Error in error handler: $e');
      }
    }
  }

  /// Add error handler
  void addErrorHandler(ErrorHandler handler) {
    _errorHandlers.add(handler);
  }

  /// Remove error handler
  void removeErrorHandler(ErrorHandler handler) {
    _errorHandlers.remove(handler);
  }

  /// Add crash reporter
  void addCrashReporter(CrashReporter reporter) {
    _crashReporters.add(reporter);
  }

  /// Remove crash reporter
  void removeCrashReporter(CrashReporter reporter) {
    _crashReporters.remove(reporter);
  }

  /// Report crash
  void reportCrash(Object error, StackTrace stack) {
    for (final reporter in _crashReporters) {
      try {
        reporter.reportCrash(error, stack);
      } catch (e) {
        developer.log('❌ [ErrorHandlingService] Error in crash reporter: $e');
      }
    }
  }
}

/// Error handler interface
abstract class ErrorHandler {
  void handleError(Object error, StackTrace stack);
}

/// Crash reporter interface
abstract class CrashReporter {
  void reportCrash(Object error, StackTrace stack);
}

/// Offline-first architecture service
class OfflineFirstArchitectureService {
  static final OfflineFirstArchitectureService _instance =
      OfflineFirstArchitectureService._internal();
  factory OfflineFirstArchitectureService() => _instance;
  OfflineFirstArchitectureService._internal();

  final List<SyncableService> _syncableServices = [];
  Timer? _syncTimer;
  bool _isOnline = true;

  /// Get offline-first architecture service instance
  static OfflineFirstArchitectureService get instance => _instance;

  /// Initialize offline-first architecture
  void initialize() {
    _startSyncTimer();
    _monitorConnectivity();
  }

  /// Add syncable service
  void addSyncableService(SyncableService service) {
    _syncableServices.add(service);
  }

  /// Remove syncable service
  void removeSyncableService(SyncableService service) {
    _syncableServices.remove(service);
  }

  /// Start sync timer
  void _startSyncTimer() {
    _syncTimer = Timer.periodic(Duration(minutes: 5), (timer) {
      if (_isOnline) {
        _syncAllServices();
      }
    });
  }

  /// Monitor connectivity
  void _monitorConnectivity() {
    // This would typically use connectivity_plus package
    // For now, we'll simulate connectivity
    _isOnline = true;
  }

  /// Sync all services
  Future<void> _syncAllServices() async {
    for (final service in _syncableServices) {
      try {
        await service.syncWithCloud();
      } catch (e) {
        developer.log(
            '❌ [OfflineFirstArchitectureService] Error syncing service: $e');
      }
    }
  }

  /// Force sync all services
  Future<void> forceSyncAllServices() async {
    await _syncAllServices();
  }

  /// Dispose service
  void dispose() {
    _syncTimer?.cancel();
    _syncableServices.clear();
  }
}

/// Syncable service interface
abstract class SyncableService {
  Future<void> syncWithCloud();
  Future<void> syncFromCloud();
  Future<void> clearLocalData();
}
