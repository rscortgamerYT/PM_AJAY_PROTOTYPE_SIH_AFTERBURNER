import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Utility class for handling gestures in mobile and tablet interfaces
class GestureUtils {
  GestureUtils._();

  /// Minimum scale for pinch zoom
  static const double minScale = 0.5;
  
  /// Maximum scale for pinch zoom
  static const double maxScale = 4.0;
  
  /// Threshold for detecting swipe gestures (in pixels)
  static const double swipeThreshold = 50.0;
  
  /// Velocity threshold for swipe detection (pixels per second)
  static const double swipeVelocityThreshold = 300.0;
  
  /// Determines swipe direction based on drag details
  static SwipeDirection? detectSwipeDirection(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond;
    final dx = velocity.dx.abs();
    final dy = velocity.dy.abs();
    
    if (dx < swipeVelocityThreshold && dy < swipeVelocityThreshold) {
      return null;
    }
    
    if (dx > dy) {
      return velocity.dx > 0 ? SwipeDirection.right : SwipeDirection.left;
    } else {
      return velocity.dy > 0 ? SwipeDirection.down : SwipeDirection.up;
    }
  }
  
  /// Clamps scale value between min and max
  static double clampScale(double scale) {
    return scale.clamp(minScale, maxScale);
  }
  
  /// Calculates focal point for zoom
  static Offset calculateFocalPoint(
    Offset localFocalPoint,
    Size size,
    double scale,
    Offset translation,
  ) {
    final scaledSize = size * scale;
    final maxTranslation = Offset(
      (scaledSize.width - size.width) / 2,
      (scaledSize.height - size.height) / 2,
    );
    
    return Offset(
      translation.dx.clamp(-maxTranslation.dx, maxTranslation.dx),
      translation.dy.clamp(-maxTranslation.dy, maxTranslation.dy),
    );
  }
}

/// Swipe direction enum
enum SwipeDirection {
  left,
  right,
  up,
  down,
}

/// Widget that provides swipe gesture detection
class SwipeDetector extends StatelessWidget {
  final Widget child;
  final Function(SwipeDirection)? onSwipe;
  final Function()? onTap;
  final Function()? onDoubleTap;
  final Function()? onLongPress;
  final double sensitivity;

  const SwipeDetector({
    Key? key,
    required this.child,
    this.onSwipe,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.sensitivity = 1.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      onLongPress: onLongPress,
      onHorizontalDragEnd: (details) {
        final direction = GestureUtils.detectSwipeDirection(details);
        if (direction != null && 
            (direction == SwipeDirection.left || direction == SwipeDirection.right)) {
          onSwipe?.call(direction);
        }
      },
      onVerticalDragEnd: (details) {
        final direction = GestureUtils.detectSwipeDirection(details);
        if (direction != null && 
            (direction == SwipeDirection.up || direction == SwipeDirection.down)) {
          onSwipe?.call(direction);
        }
      },
      child: child,
    );
  }
}

/// Widget that provides pinch-to-zoom functionality
class PinchZoomWidget extends StatefulWidget {
  final Widget child;
  final double minScale;
  final double maxScale;
  final bool enablePan;
  final Function(double)? onScaleChanged;
  final Function(Offset)? onTranslationChanged;

  const PinchZoomWidget({
    Key? key,
    required this.child,
    this.minScale = 0.5,
    this.maxScale = 4.0,
    this.enablePan = true,
    this.onScaleChanged,
    this.onTranslationChanged,
  }) : super(key: key);

  @override
  State<PinchZoomWidget> createState() => _PinchZoomWidgetState();
}

class _PinchZoomWidgetState extends State<PinchZoomWidget> {
  double _scale = 1.0;
  double _previousScale = 1.0;
  Offset _translation = Offset.zero;
  Offset _previousTranslation = Offset.zero;
  Offset? _focalPoint;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: (details) {
        _previousScale = _scale;
        _previousTranslation = _translation;
        _focalPoint = details.localFocalPoint;
      },
      onScaleUpdate: (details) {
        setState(() {
          // Update scale
          _scale = (_previousScale * details.scale).clamp(widget.minScale, widget.maxScale);
          widget.onScaleChanged?.call(_scale);
          
          // Update translation if panning is enabled and scale > 1
          if (widget.enablePan && _scale > 1.0) {
            final delta = details.focalPoint - (_focalPoint ?? Offset.zero);
            _translation = _previousTranslation + delta;
            widget.onTranslationChanged?.call(_translation);
          }
        });
      },
      onScaleEnd: (details) {
        _focalPoint = null;
      },
      onDoubleTap: () {
        setState(() {
          if (_scale > 1.0) {
            _scale = 1.0;
            _translation = Offset.zero;
          } else {
            _scale = 2.0;
          }
          widget.onScaleChanged?.call(_scale);
          widget.onTranslationChanged?.call(_translation);
        });
      },
      child: Transform(
        transform: Matrix4.identity()
          ..translate(_translation.dx, _translation.dy)
          ..scale(_scale),
        alignment: Alignment.center,
        child: widget.child,
      ),
    );
  }
}

/// Interactive map widget with gesture controls
class InteractiveGestureMap extends StatefulWidget {
  final Widget child;
  final double initialScale;
  final double minScale;
  final double maxScale;
  final bool enableRotation;
  final Function(double)? onScaleChanged;
  final Function(double)? onRotationChanged;

  const InteractiveGestureMap({
    Key? key,
    required this.child,
    this.initialScale = 1.0,
    this.minScale = 0.5,
    this.maxScale = 4.0,
    this.enableRotation = false,
    this.onScaleChanged,
    this.onRotationChanged,
  }) : super(key: key);

  @override
  State<InteractiveGestureMap> createState() => _InteractiveGestureMapState();
}

class _InteractiveGestureMapState extends State<InteractiveGestureMap>
    with SingleTickerProviderStateMixin {
  late TransformationController _controller;
  late AnimationController _animationController;
  Animation<Matrix4>? _animation;

  double _currentScale = 1.0;
  double _currentRotation = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = TransformationController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _currentScale = widget.initialScale;
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleDoubleTap() {
    final newScale = _currentScale == 1.0 ? 2.0 : 1.0;
    final targetMatrix = Matrix4.identity()..scale(newScale);
    
    _animation = Matrix4Tween(
      begin: _controller.value,
      end: targetMatrix,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _animationController.forward(from: 0).then((_) {
      _currentScale = newScale;
      widget.onScaleChanged?.call(_currentScale);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: _handleDoubleTap,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          if (_animation != null) {
            _controller.value = _animation!.value;
          }
          return InteractiveViewer(
            transformationController: _controller,
            minScale: widget.minScale,
            maxScale: widget.maxScale,
            onInteractionUpdate: (details) {
              _currentScale = details.scale;
              widget.onScaleChanged?.call(_currentScale);
              
              if (widget.enableRotation) {
                _currentRotation = details.rotation;
                widget.onRotationChanged?.call(_currentRotation);
              }
            },
            child: widget.child,
          );
        },
        child: widget.child,
      ),
    );
  }
}

/// Draggable sheet with gesture controls
class GestureDraggableSheet extends StatefulWidget {
  final Widget child;
  final double initialChildSize;
  final double minChildSize;
  final double maxChildSize;
  final bool snap;
  final List<double>? snapSizes;
  final Function(double)? onDragUpdate;

  const GestureDraggableSheet({
    Key? key,
    required this.child,
    this.initialChildSize = 0.5,
    this.minChildSize = 0.25,
    this.maxChildSize = 1.0,
    this.snap = true,
    this.snapSizes,
    this.onDragUpdate,
  }) : super(key: key);

  @override
  State<GestureDraggableSheet> createState() => _GestureDraggableSheetState();
}

class _GestureDraggableSheetState extends State<GestureDraggableSheet> {
  final DraggableScrollableController _controller = DraggableScrollableController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: _controller,
      initialChildSize: widget.initialChildSize,
      minChildSize: widget.minChildSize,
      maxChildSize: widget.maxChildSize,
      snap: widget.snap,
      snapSizes: widget.snapSizes,
      builder: (context, scrollController) {
        return NotificationListener<DraggableScrollableNotification>(
          onNotification: (notification) {
            widget.onDragUpdate?.call(notification.extent);
            return true;
          },
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: widget.child,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Swipeable card widget
class SwipeableCard extends StatefulWidget {
  final Widget child;
  final Function()? onSwipeLeft;
  final Function()? onSwipeRight;
  final Function()? onSwipeUp;
  final Function()? onSwipeDown;
  final double threshold;

  const SwipeableCard({
    Key? key,
    required this.child,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.onSwipeUp,
    this.onSwipeDown,
    this.threshold = 100.0,
  }) : super(key: key);

  @override
  State<SwipeableCard> createState() => _SwipeableCardState();
}

class _SwipeableCardState extends State<SwipeableCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;
  Offset _dragOffset = Offset.zero;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDragStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
    });
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta;
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
    });

    final dx = _dragOffset.dx.abs();
    final dy = _dragOffset.dy.abs();

    if (dx > widget.threshold) {
      if (_dragOffset.dx > 0) {
        widget.onSwipeRight?.call();
      } else {
        widget.onSwipeLeft?.call();
      }
    } else if (dy > widget.threshold) {
      if (_dragOffset.dy > 0) {
        widget.onSwipeDown?.call();
      } else {
        widget.onSwipeUp?.call();
      }
    }

    // Animate back to center
    _animation = Tween<Offset>(
      begin: _dragOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward(from: 0).then((_) {
      setState(() {
        _dragOffset = Offset.zero;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _handleDragStart,
      onPanUpdate: _handleDragUpdate,
      onPanEnd: _handleDragEnd,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final offset = _isDragging ? _dragOffset : _animation.value;
          return Transform.translate(
            offset: offset,
            child: Transform.rotate(
              angle: offset.dx * 0.001,
              child: child,
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}