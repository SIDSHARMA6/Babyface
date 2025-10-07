import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Enhanced adaptive grid widget for responsive layouts
/// Automatically adjusts columns based on screen size and content
class AdaptiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int? crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final double? childAspectRatio;
  final double? maxCrossAxisExtent;
  final ScrollPhysics? physics;

  const AdaptiveGrid({
    super.key,
    required this.children,
    this.crossAxisCount,
    this.crossAxisSpacing = 8.0,
    this.mainAxisSpacing = 8.0,
    this.padding,
    this.shrinkWrap = false,
    this.childAspectRatio,
    this.maxCrossAxisExtent,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Determine responsive columns based on screen size
    int columns;
    if (crossAxisCount != null) {
      columns = crossAxisCount!;
    } else {
      if (screenWidth < 600) {
        columns = 2; // Phone
      } else if (screenWidth < 900) {
        columns = 3; // Tablet
      } else {
        columns = 4; // Desktop
      }
    }

    // Use maxCrossAxisExtent if provided for better responsiveness
    if (maxCrossAxisExtent != null) {
      return GridView.builder(
        shrinkWrap: shrinkWrap,
        padding: padding ?? EdgeInsets.all(8.w),
        physics: physics ?? const BouncingScrollPhysics(),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: maxCrossAxisExtent!,
          crossAxisSpacing: crossAxisSpacing,
          mainAxisSpacing: mainAxisSpacing,
          childAspectRatio: childAspectRatio ?? 1.0,
        ),
        itemCount: children.length,
        itemBuilder: (context, index) => children[index],
      );
    }

    return GridView.builder(
      shrinkWrap: shrinkWrap,
      padding: padding ?? EdgeInsets.all(8.w),
      physics: physics ?? const BouncingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
        childAspectRatio: childAspectRatio ?? 1.0,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}
