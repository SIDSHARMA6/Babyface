import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FloatingTextWidget extends StatefulWidget {
  final String text;
  final TextStyle? textStyle;
  final Color? backgroundColor;
  final double? borderRadius;
  final EdgeInsets? padding;
  final Duration duration;
  final Offset startOffset;
  final Offset endOffset;
  final bool autoStart;
  final VoidCallback? onComplete;

  const FloatingTextWidget({
    super.key,
    required this.text,
    this.textStyle,
    this.backgroundColor,
    this.borderRadius,
    this.padding,
    this.duration = const Duration(milliseconds: 2000),
    this.startOffset = const Offset(0, 50),
    this.endOffset = const Offset(0, -100),
    this.autoStart = true,
    this.onComplete,
  });

  @override
  State<FloatingTextWidget> createState() => _FloatingTextWidgetState();
}

class _FloatingTextWidgetState extends State<FloatingTextWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _positionAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.elasticOut),
      ),
    );

    _positionAnimation = Tween<Offset>(
      begin: widget.startOffset,
      end: widget.endOffset,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOut),
      ),
    );

    if (widget.autoStart) {
      _startAnimation();
    }
  }

  void _startAnimation() {
    _controller.forward().then((_) {
      if (widget.onComplete != null) {
        widget.onComplete!();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: _positionAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                padding: widget.padding ??
                    EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                decoration: BoxDecoration(
                  color: widget.backgroundColor ?? Colors.black87,
                  borderRadius: BorderRadius.circular(
                    widget.borderRadius ?? 20.r,
                  ),
                ),
                child: Text(
                  widget.text,
                  style: widget.textStyle ??
                      TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class FloatingTextOverlay extends StatefulWidget {
  final Widget child;
  final List<String> texts;
  final Duration interval;
  final bool isActive;

  const FloatingTextOverlay({
    super.key,
    required this.child,
    required this.texts,
    this.interval = const Duration(seconds: 3),
    this.isActive = true,
  });

  @override
  State<FloatingTextOverlay> createState() => _FloatingTextOverlayState();
}

class _FloatingTextOverlayState extends State<FloatingTextOverlay>
    with TickerProviderStateMixin {
  late AnimationController _overlayController;
  int _currentTextIndex = 0;

  @override
  void initState() {
    super.initState();
    _overlayController = AnimationController(
      duration: widget.interval,
      vsync: this,
    );

    if (widget.isActive && widget.texts.isNotEmpty) {
      _startFloatingTexts();
    }
  }

  void _startFloatingTexts() {
    _overlayController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _currentTextIndex = (_currentTextIndex + 1) % widget.texts.length;
        });
        _overlayController.reset();
        _overlayController.forward();
      }
    });

    _overlayController.forward();
  }

  @override
  void didUpdateWidget(FloatingTextOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive && widget.texts.isNotEmpty) {
        _startFloatingTexts();
      } else {
        _overlayController.stop();
      }
    }
  }

  @override
  void dispose() {
    _overlayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.isActive && widget.texts.isNotEmpty)
          Positioned(
            top: 100.h,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingTextWidget(
                text: widget.texts[_currentTextIndex],
                autoStart: true,
                onComplete: () {
                  // Text animation completed, will trigger next text
                },
              ),
            ),
          ),
      ],
    );
  }
}
