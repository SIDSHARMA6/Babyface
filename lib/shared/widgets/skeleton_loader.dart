import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
// import '../../core/theme/baby_font.dart';
import 'optimized_widget.dart';

/// Skeleton loader for loading animations
/// Follows master plan theme standards and performance requirements
class SkeletonLoader extends OptimizedWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Color? color;
  final Duration animationDuration;
  final Duration animationDelay;

  const SkeletonLoader({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.color,
    this.animationDuration = const Duration(milliseconds: 1500),
    this.animationDelay = Duration.zero,
  });

  @override
  Widget buildOptimized(BuildContext context, WidgetRef ref) {
    return _SkeletonLoaderWidget(
      width: width,
      height: height,
      borderRadius: borderRadius,
      color: color,
      animationDuration: animationDuration,
      animationDelay: animationDelay,
    );
  }
}

/// Skeleton loader widget implementation
class _SkeletonLoaderWidget extends StatefulWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Color? color;
  final Duration animationDuration;
  final Duration animationDelay;

  const _SkeletonLoaderWidget({
    this.width,
    this.height,
    this.borderRadius,
    this.color,
    required this.animationDuration,
    required this.animationDelay,
  });

  @override
  State<_SkeletonLoaderWidget> createState() => _SkeletonLoaderWidgetState();
}

class _SkeletonLoaderWidgetState extends State<_SkeletonLoaderWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    Future.delayed(widget.animationDelay, () {
      if (mounted) {
        _animationController.repeat();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                widget.color?.withValues(alpha: 0.3) ??
                    AppTheme.primary.withValues(alpha: 0.3),
                widget.color?.withValues(alpha: 0.6) ??
                    AppTheme.primary.withValues(alpha: 0.6),
                widget.color?.withValues(alpha: 0.3) ??
                    AppTheme.primary.withValues(alpha: 0.3),
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ].map((stop) => stop.clamp(0.0, 1.0)).toList(),
            ),
          ),
        );
      },
    );
  }
}

/// Skeleton loader for text
class SkeletonText extends OptimizedWidget {
  final int lines;
  final double? fontSize;
  final double? lineHeight;
  final double? spacing;
  final Color? color;

  const SkeletonText({
    super.key,
    this.lines = 1,
    this.fontSize,
    this.lineHeight,
    this.spacing,
    this.color,
  });

  @override
  Widget buildOptimized(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(lines, (index) {
        final isLastLine = index == lines - 1;
        final lineWidth = isLastLine ? 0.7 : 1.0; // Last line is shorter

        return Container(
          margin: EdgeInsets.only(
            bottom: index < lines - 1 ? (spacing ?? 8) : 0,
          ),
          child: SkeletonLoader(
            width: (fontSize ?? 16) * 8 * lineWidth,
            height: lineHeight ?? fontSize ?? 16,
            color: color,
          ),
        );
      }),
    );
  }
}

/// Skeleton loader for cards
class SkeletonCard extends OptimizedWidget {
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final Color? color;

  const SkeletonCard({
    super.key,
    this.width,
    this.height,
    this.padding,
    this.color,
  });

  @override
  Widget buildOptimized(BuildContext context, WidgetRef ref) {
    return Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonLoader(
            width: double.infinity,
            height: 20,
            color: color,
          ),
          const SizedBox(height: 12),
          SkeletonText(
            lines: 2,
            fontSize: 14,
            color: color,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SkeletonLoader(
                width: 60,
                height: 24,
                borderRadius: BorderRadius.circular(12),
                color: color,
              ),
              const SizedBox(width: 8),
              SkeletonLoader(
                width: 80,
                height: 24,
                borderRadius: BorderRadius.circular(12),
                color: color,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Skeleton loader for list items
class SkeletonListItem extends OptimizedWidget {
  final double? height;
  final Color? color;

  const SkeletonListItem({
    super.key,
    this.height,
    this.color,
  });

  @override
  Widget buildOptimized(BuildContext context, WidgetRef ref) {
    return Container(
      height: height ?? 80,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        children: [
          SkeletonLoader(
            width: 48,
            height: 48,
            borderRadius: BorderRadius.circular(24),
            color: color,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SkeletonLoader(
                  width: double.infinity,
                  height: 16,
                  color: color,
                ),
                const SizedBox(height: 8),
                SkeletonLoader(
                  width: 120,
                  height: 12,
                  color: color,
                ),
              ],
            ),
          ),
          SkeletonLoader(
            width: 24,
            height: 24,
            borderRadius: BorderRadius.circular(12),
            color: color,
          ),
        ],
      ),
    );
  }
}

/// Skeleton loader for images
class SkeletonImage extends OptimizedWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Color? color;

  const SkeletonImage({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.color,
  });

  @override
  Widget buildOptimized(BuildContext context, WidgetRef ref) {
    return SkeletonLoader(
      width: width,
      height: height,
      borderRadius: borderRadius ?? BorderRadius.circular(8),
      color: color,
    );
  }
}

/// Skeleton loader for buttons
class SkeletonButton extends OptimizedWidget {
  final double? width;
  final double? height;
  final Color? color;

  const SkeletonButton({
    super.key,
    this.width,
    this.height,
    this.color,
  });

  @override
  Widget buildOptimized(BuildContext context, WidgetRef ref) {
    return SkeletonLoader(
      width: width ?? 120,
      height: height ?? 40,
      borderRadius: BorderRadius.circular(20),
      color: color,
    );
  }
}
