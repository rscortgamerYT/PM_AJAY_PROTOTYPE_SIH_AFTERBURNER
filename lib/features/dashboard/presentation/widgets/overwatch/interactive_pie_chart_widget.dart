import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../../core/theme/app_design_system.dart';

/// Interactive pie chart segment data
class PieChartSegment {
  final String label;
  final double value;
  final Color color;
  final int count;

  PieChartSegment({
    required this.label,
    required this.value,
    required this.color,
    required this.count,
  });
}

/// Interactive pie chart widget with hover and click functionality
class InteractivePieChartWidget extends StatefulWidget {
  final List<PieChartSegment> segments;
  final Function(PieChartSegment)? onSegmentTap;

  const InteractivePieChartWidget({
    super.key,
    required this.segments,
    this.onSegmentTap,
  });

  @override
  State<InteractivePieChartWidget> createState() => _InteractivePieChartWidgetState();
}

class _InteractivePieChartWidgetState extends State<InteractivePieChartWidget>
    with SingleTickerProviderStateMixin {
  int? _hoveredIndex;
  int? _selectedIndex;
  late AnimationController _animationController;
  late List<Animation<double>> _scaleAnimations;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimations = List.generate(
      widget.segments.length,
      (index) => Tween<double>(begin: 1.0, end: 1.1).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeOutCubic,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleHover(int? index) {
    setState(() {
      _hoveredIndex = index;
      if (index != null) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _handleTap(int index) {
    setState(() {
      _selectedIndex = _selectedIndex == index ? null : index;
    });
    if (widget.onSegmentTap != null && _selectedIndex != null) {
      widget.onSegmentTap!(widget.segments[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Center(
            child: AspectRatio(
              aspectRatio: 1.0,
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _InteractivePieChartPainter(
                      segments: widget.segments,
                      hoveredIndex: _hoveredIndex,
                      selectedIndex: _selectedIndex,
                      scaleAnimations: _scaleAnimations,
                    ),
                    child: GestureDetector(
                      onTapDown: (details) {
                        final RenderBox box = context.findRenderObject() as RenderBox;
                        final localPosition = box.globalToLocal(details.globalPosition);
                        final index = _getSegmentIndex(localPosition, box.size);
                        if (index != null) {
                          _handleTap(index);
                        }
                      },
                      child: MouseRegion(
                        onHover: (event) {
                          final RenderBox box = context.findRenderObject() as RenderBox;
                          final localPosition = box.globalToLocal(event.position);
                          final index = _getSegmentIndex(localPosition, box.size);
                          _handleHover(index);
                        },
                        onExit: (_) => _handleHover(null),
                        child: Container(color: Colors.transparent),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 1,
          child: _buildLegendWithDetails(),
        ),
      ],
    );
  }

  int? _getSegmentIndex(Offset position, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final dx = position.dx - center.dx;
    final dy = position.dy - center.dy;
    final distance = math.sqrt(dx * dx + dy * dy);
    final radius = (size.width < size.height ? size.width : size.height) * 0.35;
    final innerRadius = radius * 0.5;

    if (distance < innerRadius || distance > radius) {
      return null;
    }

    var angle = math.atan2(dy, dx);
    angle = (angle + math.pi / 2) % (2 * math.pi);
    if (angle < 0) angle += 2 * math.pi;

    double startAngle = 0;
    for (int i = 0; i < widget.segments.length; i++) {
      final sweepAngle = widget.segments[i].value * 2 * math.pi;
      if (angle >= startAngle && angle < startAngle + sweepAngle) {
        return i;
      }
      startAngle += sweepAngle;
    }

    return null;
  }

  Widget _buildLegendWithDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: widget.segments.asMap().entries.map((entry) {
        final index = entry.key;
        final segment = entry.value;
        final isHovered = _hoveredIndex == index;
        final isSelected = _selectedIndex == index;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: (isHovered || isSelected)
                ? segment.color.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: AppDesignSystem.radiusSmall,
            border: Border.all(
              color: (isHovered || isSelected)
                  ? segment.color
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isHovered || isSelected ? 16 : 12,
                height: isHovered || isSelected ? 16 : 12,
                decoration: BoxDecoration(
                  color: segment.color,
                  shape: BoxShape.circle,
                  boxShadow: (isHovered || isSelected)
                      ? [
                          BoxShadow(
                            color: segment.color.withOpacity(0.5),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      segment.label,
                      style: AppDesignSystem.labelMedium.copyWith(
                        fontWeight: (isHovered || isSelected)
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (isHovered || isSelected) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Count: ${segment.count}',
                        style: AppDesignSystem.labelSmall.copyWith(
                          color: AppDesignSystem.neutral600,
                        ),
                      ),
                      Text(
                        'Percentage: ${(segment.value * 100).toStringAsFixed(1)}%',
                        style: AppDesignSystem.labelSmall.copyWith(
                          color: segment.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _InteractivePieChartPainter extends CustomPainter {
  final List<PieChartSegment> segments;
  final int? hoveredIndex;
  final int? selectedIndex;
  final List<Animation<double>> scaleAnimations;

  _InteractivePieChartPainter({
    required this.segments,
    this.hoveredIndex,
    this.selectedIndex,
    required this.scaleAnimations,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = (size.width < size.height ? size.width : size.height) * 0.35;
    
    double startAngle = -math.pi / 2;
    
    for (int i = 0; i < segments.length; i++) {
      final segment = segments[i];
      final sweepAngle = segment.value * 2 * math.pi;
      final isHighlighted = hoveredIndex == i || selectedIndex == i;
      final radius = isHighlighted
          ? baseRadius * scaleAnimations[i].value
          : baseRadius;
      
      final paint = Paint()
        ..color = segment.color
        ..style = PaintingStyle.fill;
      
      if (isHighlighted) {
        paint.color = segment.color;
        final shadowPaint = Paint()
          ..color = segment.color.withOpacity(0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius + 4),
          startAngle,
          sweepAngle,
          true,
          shadowPaint,
        );
      }
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
      
      if (isHighlighted) {
        final midAngle = startAngle + sweepAngle / 2;
        final labelRadius = radius + 20;
        final labelX = center.dx + labelRadius * math.cos(midAngle);
        final labelY = center.dy + labelRadius * math.sin(midAngle);
        
        final textPainter = TextPainter(
          text: TextSpan(
            text: '${(segment.value * 100).toStringAsFixed(1)}%',
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(labelX - textPainter.width / 2, labelY - textPainter.height / 2),
        );
      }
      
      startAngle += sweepAngle;
    }
    
    final innerRadius = baseRadius * 0.5;
    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, innerRadius, centerPaint);
    
    if (selectedIndex != null) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: segments[selectedIndex!].count.toString(),
          style: TextStyle(
            color: segments[selectedIndex!].color,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}