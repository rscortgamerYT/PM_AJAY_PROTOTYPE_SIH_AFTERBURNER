import 'package:flutter/material.dart';

/// Utility class for creating reusable animations throughout the app
class AnimationUtils {
  AnimationUtils._();

  /// Creates a pulsing animation controller
  static AnimationController createPulseController(
    TickerProvider vsync, {
    Duration duration = const Duration(milliseconds: 1500),
    double lowerBound = 0.0,
    double upperBound = 1.0,
  }) {
    return AnimationController(
      vsync: vsync,
      duration: duration,
      lowerBound: lowerBound,
      upperBound: upperBound,
    )..repeat(reverse: true);
  }

  /// Creates a scale pulse animation
  static Animation<double> createScalePulse(
    AnimationController controller, {
    double minScale = 0.95,
    double maxScale = 1.05,
    Curve curve = Curves.easeInOut,
  }) {
    return Tween<double>(begin: minScale, end: maxScale).animate(
      CurvedAnimation(parent: controller, curve: curve),
    );
  }

  /// Creates an opacity pulse animation
  static Animation<double> createOpacityPulse(
    AnimationController controller, {
    double minOpacity = 0.3,
    double maxOpacity = 1.0,
    Curve curve = Curves.easeInOut,
  }) {
    return Tween<double>(begin: minOpacity, end: maxOpacity).animate(
      CurvedAnimation(parent: controller, curve: curve),
    );
  }

  /// Creates a ripple animation for map pins
  static Animation<double> createRipple(
    AnimationController controller, {
    double startRadius = 0.0,
    double endRadius = 50.0,
    Curve curve = Curves.easeOut,
  }) {
    return Tween<double>(begin: startRadius, end: endRadius).animate(
      CurvedAnimation(parent: controller, curve: curve),
    );
  }

  /// Creates a fade-in slide animation
  static List<Animation<double>> createFadeSlide(
    AnimationController controller, {
    Offset beginOffset = const Offset(0, 0.3),
    Offset endOffset = Offset.zero,
  }) {
    return [
      Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
        ),
      ),
      Tween<double>(begin: beginOffset.dy, end: endOffset.dy).animate(
        CurvedAnimation(
          parent: controller,
          curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
        ),
      ),
    ];
  }

  /// Creates a staggered animation for list items
  static Animation<double> createStaggeredAnimation(
    AnimationController controller,
    int index,
    int totalItems, {
    Duration delay = const Duration(milliseconds: 50),
  }) {
    final delayFraction = (index * delay.inMilliseconds) / 
                         (totalItems * delay.inMilliseconds + controller.duration!.inMilliseconds);
    return Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          delayFraction,
          1.0,
          curve: Curves.easeOutCubic,
        ),
      ),
    );
  }
}

/// Widget that provides pulsing animation for map pins
class PulsingMapPin extends StatefulWidget {
  final Widget child;
  final Color color;
  final double size;
  final Duration duration;
  final bool enabled;

  const PulsingMapPin({
    super.key,
    required this.child,
    required this.color,
    this.size = 40.0,
    this.duration = const Duration(milliseconds: 1500),
    this.enabled = true,
  });

  @override
  State<PulsingMapPin> createState() => _PulsingMapPinState();
}

class _PulsingMapPinState extends State<PulsingMapPin>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationUtils.createPulseController(this, duration: widget.duration);
    _scaleAnimation = AnimationUtils.createScalePulse(_controller);
    _opacityAnimation = AnimationUtils.createOpacityPulse(_controller);
    
    if (widget.enabled) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(PulsingMapPin oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.enabled && _controller.isAnimating) {
      _controller.stop();
    }
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
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer ripple
            Transform.scale(
              scale: _scaleAnimation.value * 1.5,
              child: Container(
                width: widget.size * 1.5,
                height: widget.size * 1.5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withOpacity(_opacityAnimation.value * 0.2),
                ),
              ),
            ),
            // Middle ripple
            Transform.scale(
              scale: _scaleAnimation.value * 1.2,
              child: Container(
                width: widget.size * 1.2,
                height: widget.size * 1.2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withOpacity(_opacityAnimation.value * 0.4),
                ),
              ),
            ),
            // Pin itself
            child!,
          ],
        );
      },
      child: widget.child,
    );
  }
}

/// Widget that provides animated chart transitions
class AnimatedChartTransition extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final bool animate;

  const AnimatedChartTransition({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 800),
    this.curve = Curves.easeOutCubic,
    this.animate = true,
  });

  @override
  State<AnimatedChartTransition> createState() => _AnimatedChartTransitionState();
}

class _AnimatedChartTransitionState extends State<AnimatedChartTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    final animations = AnimationUtils.createFadeSlide(_controller);
    _fadeAnimation = animations[0];
    _slideAnimation = animations[1];
    
    if (widget.animate) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(AnimatedChartTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !oldWidget.animate) {
      _controller.forward(from: 0.0);
    }
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
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Transform.translate(
            offset: Offset(0, _slideAnimation.value * 50),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// Custom painter for animated chart bars
class AnimatedBarPainter extends CustomPainter {
  final double progress;
  final List<double> values;
  final List<Color> colors;
  final double maxValue;

  AnimatedBarPainter({
    required this.progress,
    required this.values,
    required this.colors,
    required this.maxValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final barWidth = size.width / values.length;
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < values.length; i++) {
      final normalizedValue = (values[i] / maxValue).clamp(0.0, 1.0);
      final animatedHeight = size.height * normalizedValue * progress;
      
      paint.color = colors[i % colors.length];
      
      final rect = Rect.fromLTWH(
        i * barWidth + barWidth * 0.1,
        size.height - animatedHeight,
        barWidth * 0.8,
        animatedHeight,
      );
      
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(AnimatedBarPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.values != values ||
           oldDelegate.colors != colors;
  }
}

/// Custom painter for animated line chart
class AnimatedLinePainter extends CustomPainter {
  final double progress;
  final List<double> values;
  final Color lineColor;
  final Color gradientColor;
  final double maxValue;
  final double strokeWidth;

  AnimatedLinePainter({
    required this.progress,
    required this.values,
    required this.lineColor,
    required this.gradientColor,
    required this.maxValue,
    this.strokeWidth = 3.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    final pointSpacing = size.width / (values.length - 1);
    final points = <Offset>[];

    for (int i = 0; i < values.length; i++) {
      final normalizedValue = (values[i] / maxValue).clamp(0.0, 1.0);
      final x = i * pointSpacing;
      final y = size.height - (size.height * normalizedValue);
      points.add(Offset(x, y));
    }

    // Draw gradient fill
    final gradientPath = Path();
    gradientPath.moveTo(0, size.height);
    for (final point in points) {
      gradientPath.lineTo(point.dx, point.dy);
    }
    gradientPath.lineTo(size.width, size.height);
    gradientPath.close();

    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          gradientColor.withOpacity(0.3),
          gradientColor.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(gradientPath, gradientPaint);

    // Draw animated line
    final linePath = Path();
    final animatedPointCount = (points.length * progress).floor();
    
    if (animatedPointCount > 0) {
      linePath.moveTo(points[0].dx, points[0].dy);
      
      for (int i = 1; i < animatedPointCount; i++) {
        linePath.lineTo(points[i].dx, points[i].dy);
      }
      
      if (animatedPointCount < points.length) {
        final prevPoint = points[animatedPointCount - 1];
        final nextPoint = points[animatedPointCount];
        final fraction = (points.length * progress) - animatedPointCount;
        final interpolatedPoint = Offset(
          prevPoint.dx + (nextPoint.dx - prevPoint.dx) * fraction,
          prevPoint.dy + (nextPoint.dy - prevPoint.dy) * fraction,
        );
        linePath.lineTo(interpolatedPoint.dx, interpolatedPoint.dy);
      }

      final linePaint = Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      canvas.drawPath(linePath, linePaint);

      // Draw animated points
      final pointPaint = Paint()
        ..color = lineColor
        ..style = PaintingStyle.fill;

      for (int i = 0; i < animatedPointCount; i++) {
        canvas.drawCircle(points[i], 4, pointPaint);
      }
    }
  }

  @override
  bool shouldRepaint(AnimatedLinePainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.values != values ||
           oldDelegate.lineColor != lineColor;
  }
}