import 'package:flutter/material.dart';
import '../../core/theme/responsive_utils.dart';

/// A widget that provides responsive padding
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const ResponsivePadding({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? context.responsivePadding,
      child: child,
    );
  }
}

/// A responsive widget builder
class ResponsiveWidget extends StatelessWidget {
  final Widget Function(BuildContext context, bool isMobile, bool isTablet)?
      builder;
  final Widget? phone;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveWidget({
    super.key,
    this.builder,
    this.phone,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    if (builder != null) {
      return builder!(
        context,
        context.isMobile,
        context.isTablet,
      );
    }

    if (context.isMobile && phone != null) {
      return phone!;
    } else if (context.isTablet && tablet != null) {
      return tablet!;
    } else if (context.isDesktop && desktop != null) {
      return desktop!;
    }

    return phone ?? tablet ?? desktop ?? const SizedBox.shrink();
  }
}
