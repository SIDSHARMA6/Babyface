import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_theme.dart';

/// Animated hearts background widget for romantic screens
class AnimatedHearts extends StatefulWidget {
  const AnimatedHearts({super.key});

  @override
  State<AnimatedHearts> createState() => _AnimatedHeartsState();
}

class _AnimatedHeartsState extends State<AnimatedHearts>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  late List<Animation<double>> _opacityAnimations;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _controllers = List.generate(8, (index) {
      return AnimationController(
        duration: Duration(
          milliseconds: 2000 + (index * 200),
        ),
        vsync: this,
      );
    });

    _animations = _controllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ));
    }).toList();

    _opacityAnimations = _controllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 0.3,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ));
    }).toList();

    // Start animations with delays
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 300), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(8, (index) {
        return Positioned(
          left: (index % 4) * 100.w,
          top: (index ~/ 4) * 200.h,
          child: AnimatedBuilder(
            animation: _animations[index],
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                  0,
                  -20 * _animations[index].value,
                ),
                child: Opacity(
                  opacity: _opacityAnimations[index].value,
                  child: Icon(
                    Icons.favorite,
                    color: index % 2 == 0 
                        ? AppTheme.primaryPink.withOpacity(0.3)
                        : AppTheme.primaryBlue.withOpacity(0.3),
                    size: 20.w + (5 * _animations[index].value),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
