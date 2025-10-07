import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/baby_font.dart';
import 'optimized_widget.dart';

/// Error boundary for error handling
/// Follows master plan theme standards and performance requirements
class ErrorBoundary extends OptimizedWidget {
  final Widget child;
  final Widget Function(
      BuildContext context, Object error, StackTrace? stackTrace)? errorBuilder;
  final VoidCallback? onError;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
    this.onError,
  });

  @override
  Widget buildOptimized(BuildContext context, WidgetRef ref) {
    return _ErrorBoundaryWidget(
      errorBuilder: errorBuilder,
      onError: onError,
      child: child,
    );
  }
}

/// Error boundary widget implementation
class _ErrorBoundaryWidget extends StatefulWidget {
  final Widget child;
  final Widget Function(
      BuildContext context, Object error, StackTrace? stackTrace)? errorBuilder;
  final VoidCallback? onError;

  const _ErrorBoundaryWidget({
    required this.child,
    this.errorBuilder,
    this.onError,
  });

  @override
  State<_ErrorBoundaryWidget> createState() => _ErrorBoundaryWidgetState();
}

class _ErrorBoundaryWidgetState extends State<_ErrorBoundaryWidget> {
  Object? _error;
  StackTrace? _stackTrace;

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.errorBuilder?.call(context, _error!, _stackTrace) ??
          _DefaultErrorWidget(
            error: _error!,
            stackTrace: _stackTrace,
            onRetry: _retry,
          );
    }

    return widget.child;
  }

  void _retry() {
    setState(() {
      _error = null;
      _stackTrace = null;
    });
  }

  @override
  void initState() {
    super.initState();
    FlutterError.onError = (FlutterErrorDetails details) {
      setState(() {
        _error = details.exception;
        _stackTrace = details.stack;
      });
      widget.onError?.call();
    };
  }
}

/// Default error widget
class _DefaultErrorWidget extends StatelessWidget {
  final Object error;
  final StackTrace? stackTrace;
  final VoidCallback onRetry;

  const _DefaultErrorWidget({
    required this.error,
    this.stackTrace,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppTheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Oops! Something went wrong',
                style: BabyFont.headingL.copyWith(
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'We encountered an unexpected error. Please try again.',
                style: BabyFont.bodyM.copyWith(
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Try Again'),
              ),
              const SizedBox(height: 16),
              if (stackTrace != null)
                ExpansionTile(
                  title: Text(
                    'Error Details',
                    style: BabyFont.bodyM.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        error.toString(),
                        style: BabyFont.bodyS.copyWith(
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Error boundary provider
final errorBoundaryProvider = Provider<ErrorBoundaryController>((ref) {
  return ErrorBoundaryController();
});

/// Error boundary controller
class ErrorBoundaryController {
  final List<Object> _errors = [];
  final List<StackTrace> _stackTraces = [];

  List<Object> get errors => List.unmodifiable(_errors);
  List<StackTrace> get stackTraces => List.unmodifiable(_stackTraces);

  void addError(Object error, StackTrace stackTrace) {
    _errors.add(error);
    _stackTraces.add(stackTrace);
  }

  void clearErrors() {
    _errors.clear();
    _stackTraces.clear();
  }

  bool get hasErrors => _errors.isNotEmpty;
}

/// Error boundary wrapper for specific widgets
class ErrorBoundaryWrapper extends OptimizedWidget {
  final Widget child;
  final String? errorMessage;
  final VoidCallback? onRetry;

  const ErrorBoundaryWrapper({
    super.key,
    required this.child,
    this.errorMessage,
    this.onRetry,
  });

  @override
  Widget buildOptimized(BuildContext context, WidgetRef ref) {
    return ErrorBoundary(
      errorBuilder: (context, error, stackTrace) {
        return _ErrorWidget(
          error: error,
          errorMessage: errorMessage,
          onRetry: onRetry,
        );
      },
      child: child,
    );
  }
}

/// Error widget for specific errors
class _ErrorWidget extends StatelessWidget {
  final Object error;
  final String? errorMessage;
  final VoidCallback? onRetry;

  const _ErrorWidget({
    required this.error,
    this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  errorMessage ?? 'An error occurred',
                  style: BabyFont.bodyM.copyWith(
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: onRetry,
              child: Text(
                'Retry',
                style: BabyFont.bodyM.copyWith(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Network error boundary
class NetworkErrorBoundary extends OptimizedWidget {
  final Widget child;
  final VoidCallback? onRetry;

  const NetworkErrorBoundary({
    super.key,
    required this.child,
    this.onRetry,
  });

  @override
  Widget buildOptimized(BuildContext context, WidgetRef ref) {
    return ErrorBoundary(
      errorBuilder: (context, error, stackTrace) {
        return _NetworkErrorWidget(
          error: error,
          onRetry: onRetry,
        );
      },
      child: child,
    );
  }
}

/// Network error widget
class _NetworkErrorWidget extends StatelessWidget {
  final Object error;
  final VoidCallback? onRetry;

  const _NetworkErrorWidget({
    required this.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.wifi_off,
                color: Colors.orange,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Network Error',
                  style: BabyFont.bodyM.copyWith(
                    color: Colors.orange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Please check your internet connection and try again.',
            style: BabyFont.bodyS.copyWith(
              color: Colors.orange,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: onRetry,
              child: Text(
                'Retry',
                style: BabyFont.bodyM.copyWith(
                  color: Colors.orange,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
