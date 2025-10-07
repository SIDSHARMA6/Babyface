import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/performance/performance_tracker.dart';
import '../../core/theme/theme_extensions.dart';

/// Base performance widget class
/// Follows master plan performance standards - Every widget must extend this
abstract class OptimizedWidget extends ConsumerWidget {
  const OptimizedWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PerformanceTracker.wrap(
      name: runtimeType.toString(),
      child: buildOptimized(context, ref),
    );
  }

  /// Build method that must be implemented by subclasses
  Widget buildOptimized(BuildContext context, WidgetRef ref);
}

/// Base performance stateful widget class
abstract class OptimizedStatefulWidget extends ConsumerStatefulWidget {
  const OptimizedStatefulWidget({super.key});

  @override
  OptimizedState createState();
}

/// Base performance state class
abstract class OptimizedState<T extends OptimizedStatefulWidget> extends ConsumerState<T> {
  @override
  Widget build(BuildContext context) {
    return PerformanceTracker.wrap(
      name: widget.runtimeType.toString(),
      child: buildOptimized(context, ref),
    );
  }

  /// Build method that must be implemented by subclasses
  Widget buildOptimized(BuildContext context, WidgetRef ref);
}

/// Optimized container widget
class OptimizedContainer extends OptimizedWidget {
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Decoration? decoration;
  final double? width;
  final double? height;
  final AlignmentGeometry? alignment;

  const OptimizedContainer({
    super.key,
    this.child,
    this.padding,
    this.margin,
    this.decoration,
    this.width,
    this.height,
    this.alignment,
  });

  @override
  Widget buildOptimized(BuildContext context, WidgetRef ref) {
    final theme = context.responsiveTheme;
    
    return Container(
      padding: padding ?? theme.spacing.padding,
      margin: margin ?? theme.spacing.margin,
      decoration: decoration,
      width: width,
      height: height,
      alignment: alignment,
      child: child,
    );
  }
}

/// Optimized text widget
class OptimizedText extends OptimizedWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const OptimizedText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget buildOptimized(BuildContext context, WidgetRef ref) {
    final theme = context.responsiveTheme;
    
    return Text(
      text,
      style: style ?? theme.textStyles.bodyL,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// Optimized button widget
class OptimizedButton extends OptimizedWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final ButtonSize size;
  final Widget? icon;
  final bool isLoading;

  const OptimizedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget buildOptimized(BuildContext context, WidgetRef ref) {
    final theme = context.responsiveTheme;
    
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: _getButtonStyle(theme),
      child: isLoading
          ? SizedBox(
              width: theme.responsive.fontSize(20),
              height: theme.responsive.fontSize(20),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  type == ButtonType.primary ? Colors.white : theme.colors.primary,
                ),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  icon!,
                  SizedBox(width: theme.spacing.small),
                ],
                Text(
                  text,
                  style: _getTextStyle(theme),
                ),
              ],
            ),
    );
  }

  ButtonStyle _getButtonStyle(ResponsiveThemeData theme) {
    final backgroundColor = type == ButtonType.primary
        ? theme.colors.primary
        : theme.colors.secondary;
    
    final padding = size == ButtonSize.small
        ? EdgeInsets.symmetric(
            horizontal: theme.spacing.medium,
            vertical: theme.spacing.small,
          )
        : size == ButtonSize.large
            ? EdgeInsets.symmetric(
                horizontal: theme.spacing.large,
                vertical: theme.spacing.medium,
              )
            : EdgeInsets.symmetric(
                horizontal: theme.spacing.medium,
                vertical: theme.spacing.small,
              );

    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: Colors.white,
      padding: padding,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(theme.responsive.radius(12)),
      ),
      elevation: 2,
    );
  }

  TextStyle _getTextStyle(ResponsiveThemeData theme) {
    return size == ButtonSize.small
        ? theme.textStyles.bodyS
        : size == ButtonSize.large
            ? theme.textStyles.headingS
            : theme.textStyles.bodyM;
  }
}

/// Button type enum
enum ButtonType {
  primary,
  secondary,
  outline,
  ghost,
}

/// Button size enum
enum ButtonSize {
  small,
  medium,
  large,
}
