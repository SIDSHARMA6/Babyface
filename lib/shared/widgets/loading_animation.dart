import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math' as math;
import '../../core/theme/app_theme.dart';
import '../../core/theme/baby_font.dart';

/// Loading animation types
enum LoadingType {
  circular,
  footprints,
  hearts,
  bouncing,
}

/// Baby-themed loading animation widget with multiple animation types
class LoadingAnimation extends StatefulWidget {
  final double size;
  final Color? color;
  final String? text;
  final LoadingType type;

  const LoadingAnimation({
    super.key,
    this.size = 50,
    this.color,
    this.text,
    this.type = LoadingType.circular,
  });

  @override
  State<LoadingAnimation> createState() => _LoadingAnimationState();
}

class _LoadingAnimationState extends State<LoadingAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppTheme.primaryPink;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: widget.size.w,
          height: widget.size.w,
          child: _buildAnimationByType(color),
        ),
        if (widget.text != null) ...[
          SizedBox(height: 12.h),
          Text(
            widget.text!,
            style: BabyFont.bodySmall.copyWith(
              color: color,
              fontWeight: BabyFont.medium,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildAnimationByType(Color color) {
    switch (widget.type) {
      case LoadingType.circular:
        return _buildCircularAnimation(color);
      case LoadingType.footprints:
        return _buildFootprintsAnimation(color);
      case LoadingType.hearts:
        return _buildHeartsAnimation(color);
      case LoadingType.bouncing:
        return _buildBouncingAnimation(color);
    }
  }

  Widget _buildCircularAnimation(Color color) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CircularProgressIndicator(
          value: _animation.value,
          strokeWidth: 3.w,
          valueColor: AlwaysStoppedAnimation<Color>(color),
          backgroundColor: color.withValues(alpha: 0.2),
        );
      },
    );
  }

  Widget _buildFootprintsAnimation(Color color) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(3, (index) {
            final delay = index * 0.3;
            final animationValue = (_animation.value + delay) % 1.0;
            final opacity = (animationValue < 0.5)
                ? animationValue * 2
                : (1 - animationValue) * 2;

            return Opacity(
              opacity: opacity.clamp(0.0, 1.0),
              child: Icon(
                Icons.pets_rounded,
                size: widget.size * 0.3,
                color: color,
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildHeartsAnimation(Color color) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: List.generate(4, (index) {
            final angle = (index * 90.0) + (_animation.value * 360);
            final radians = angle * (3.14159 / 180);
            final radius = widget.size * 0.3;

            return Transform.translate(
              offset: Offset(
                radius * 0.5 * math.cos(radians),
                radius * 0.5 * math.sin(radians),
              ),
              child: Icon(
                Icons.favorite_rounded,
                size: widget.size * 0.2,
                color: color.withValues(alpha: 0.7),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildBouncingAnimation(Color color) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final bounceValue = math.sin(_animation.value * 2 * 3.14159);

        return Transform.translate(
          offset: Offset(0, bounceValue * 10),
          child: Icon(
            Icons.child_care_rounded,
            size: widget.size * 0.6,
            color: color,
          ),
        );
      },
    );
  }
}
