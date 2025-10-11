import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import '../../../../core/services/dashboard_analytics_service.dart';
import '../../../../core/services/mock_dashboard_data_service.dart';
import '../../../../core/theme/app_theme.dart';

/// Cross-State Collaboration Network Widget
/// 
/// Network graph showing partnerships and resource sharing between
/// agencies across different states with real-time collaboration metrics.
class CollaborationNetworkWidget extends StatefulWidget {
  const CollaborationNetworkWidget({super.key});

  @override
  State<CollaborationNetworkWidget> createState() => _CollaborationNetworkWidgetState();
}

class _CollaborationNetworkWidgetState extends State<CollaborationNetworkWidget>
    with SingleTickerProviderStateMixin {
  final DashboardAnalyticsService _analyticsService = DashboardAnalyticsService();
  late AnimationController _animationController;
  
  String? _selectedStateId;
  bool _showGeographicOverlay = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use mock data for now since backend is not connected
    final networkData = MockDashboardDataService.getMockNetworkData();

    return Stack(
      children: [
        // Main network visualization
        CustomPaint(
          size: Size.infinite,
          painter: NetworkGraphPainter(
            nodes: networkData.states,
            edges: networkData.collaborations,
            selectedNodeId: _selectedStateId,
            animationValue: _animationController.value,
          ),
        ),

        // Controls overlay
        _buildControlsPanel(),

        // Selected state info
        if (_selectedStateId != null)
          _buildStateInfoPanel(
            networkData.states.firstWhere(
              (s) => s.id == _selectedStateId,
            ),
            networkData.collaborations.where(
              (c) => c.fromStateId == _selectedStateId ||
                     c.toStateId == _selectedStateId,
            ).toList(),
          ),
      ],
    );
  }

  Widget _buildControlsPanel() {
    return Positioned(
      top: 16,
      right: 16,
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SizedBox(
            width: 280,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
              Text(
                'Network Controls',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              SwitchListTile(
                title: const Text('Geographic View'),
                subtitle: const Text('Show on map'),
                value: _showGeographicOverlay,
                onChanged: (value) {
                  setState(() => _showGeographicOverlay = value);
                },
                dense: true,
              ),

              const Divider(),

              ListTile(
                leading: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: AppTheme.successGreen,
                    shape: BoxShape.circle,
                  ),
                ),
                title: const Text('Strong Partnership'),
                subtitle: const Text('10+ collaborations'),
                dense: true,
              ),

              ListTile(
                leading: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryBlue.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                ),
                title: const Text('Moderate Partnership'),
                subtitle: const Text('5-9 collaborations'),
                dense: true,
              ),

              ListTile(
                leading: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                ),
                title: const Text('New Partnership'),
                subtitle: const Text('1-4 collaborations'),
                dense: true,
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStateInfoPanel(StateNode state, List<Collaboration> collaborations) {
    final partnerCount = collaborations.length;
    final totalIntensity = collaborations.fold<int>(
      0,
      (sum, c) => sum + c.intensity,
    );

    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: Card(
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: AppTheme.accentTeal,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.hub,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '$partnerCount Active Partnerships',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.accentTeal,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => _selectedStateId = null),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      'Partners',
                      partnerCount.toString(),
                      Icons.people,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMetricCard(
                      'Projects',
                      totalIntensity.toString(),
                      Icons.assignment,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMetricCard(
                      'Resources',
                      '${(totalIntensity * 1.5).toInt()}',
                      Icons.inventory,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryIndigo.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.primaryIndigo.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: AppTheme.primaryIndigo),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryIndigo,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Custom painter for network graph visualization
class NetworkGraphPainter extends CustomPainter {
  final List<StateNode> nodes;
  final List<Collaboration> edges;
  final String? selectedNodeId;
  final double animationValue;

  NetworkGraphPainter({
    required this.nodes,
    required this.edges,
    this.selectedNodeId,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (nodes.isEmpty) return;

    // Calculate node positions in a circular layout
    final positions = _calculateCircularLayout(size);

    // Draw edges first (so they appear behind nodes)
    _drawEdges(canvas, positions);

    // Draw nodes
    _drawNodes(canvas, positions);

    // Draw labels
    _drawLabels(canvas, positions, size);
  }

  Map<String, Offset> _calculateCircularLayout(Size size) {
    final positions = <String, Offset>{};
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = math.min(centerX, centerY) * 0.7;

    for (var i = 0; i < nodes.length; i++) {
      final angle = (2 * math.pi * i) / nodes.length - math.pi / 2;
      final x = centerX + radius * math.cos(angle);
      final y = centerY + radius * math.sin(angle);
      positions[nodes[i].id] = Offset(x, y);
    }

    return positions;
  }

  void _drawEdges(Canvas canvas, Map<String, Offset> positions) {
    for (final edge in edges) {
      final fromPos = positions[edge.fromStateId];
      final toPos = positions[edge.toStateId];

      if (fromPos == null || toPos == null) continue;

      final paint = Paint()
        ..color = _getEdgeColor(edge.intensity)
        ..strokeWidth = _getEdgeWidth(edge.intensity)
        ..style = PaintingStyle.stroke;

      // Animated dashed line effect
      final path = ui.Path()
        ..moveTo(fromPos.dx, fromPos.dy)
        ..lineTo(toPos.dx, toPos.dy);

      canvas.drawPath(path, paint);

      // Draw arrow
      _drawArrow(canvas, fromPos, toPos, paint);
    }
  }

  Color _getEdgeColor(int intensity) {
    if (intensity >= 10) {
      return AppTheme.successGreen;
    } else if (intensity >= 5) {
      return AppTheme.secondaryBlue.withOpacity(0.6);
    } else {
      return Colors.grey.withOpacity(0.4);
    }
  }

  double _getEdgeWidth(int intensity) {
    if (intensity >= 10) {
      return 3.0;
    } else if (intensity >= 5) {
      return 2.0;
    } else {
      return 1.0;
    }
  }

  void _drawArrow(Canvas canvas, Offset from, Offset to, Paint paint) {
    const arrowSize = 10.0;
    final direction = (to - from);
    final angle = math.atan2(direction.dy, direction.dx);

    final arrowPath = ui.Path()
      ..moveTo(to.dx, to.dy)
      ..lineTo(
        to.dx - arrowSize * math.cos(angle - math.pi / 6),
        to.dy - arrowSize * math.sin(angle - math.pi / 6),
      )
      ..lineTo(
        to.dx - arrowSize * math.cos(angle + math.pi / 6),
        to.dy - arrowSize * math.sin(angle + math.pi / 6),
      )
      ..close();

    canvas.drawPath(arrowPath, paint..style = PaintingStyle.fill);
  }

  void _drawNodes(Canvas canvas, Map<String, Offset> positions) {
    for (final node in nodes) {
      final pos = positions[node.id];
      if (pos == null) continue;

      final isSelected = selectedNodeId == node.id;
      final radius = isSelected ? 25.0 : 20.0;

      // Node shadow
      canvas.drawCircle(
        pos,
        radius + 2,
        Paint()
          ..color = Colors.black.withOpacity(0.2)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );

      // Node circle
      canvas.drawCircle(
        pos,
        radius,
        Paint()
          ..color = isSelected ? AppTheme.accentTeal : AppTheme.primaryIndigo
          ..style = PaintingStyle.fill,
      );

      // Node border
      canvas.drawCircle(
        pos,
        radius,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = isSelected ? 3 : 2,
      );

      // Animated pulse effect for selected node
      if (isSelected) {
        final pulseRadius = radius + (10 * animationValue);
        canvas.drawCircle(
          pos,
          pulseRadius,
          Paint()
            ..color = AppTheme.accentTeal.withOpacity(0.3 * (1 - animationValue))
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }
    }
  }

  void _drawLabels(Canvas canvas, Map<String, Offset> positions, Size size) {
    for (final node in nodes) {
      final pos = positions[node.id];
      if (pos == null) continue;

      final textPainter = TextPainter(
        text: TextSpan(
          text: node.name,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      // Position label below node
      final labelPos = Offset(
        pos.dx - textPainter.width / 2,
        pos.dy + 30,
      );

      // Draw label background
      final labelBg = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          labelPos.dx - 4,
          labelPos.dy - 2,
          textPainter.width + 8,
          textPainter.height + 4,
        ),
        const Radius.circular(4),
      );

      canvas.drawRRect(
        labelBg,
        Paint()
          ..color = Colors.white.withOpacity(0.9)
          ..style = PaintingStyle.fill,
      );

      textPainter.paint(canvas, labelPos);
    }
  }

  @override
  bool shouldRepaint(NetworkGraphPainter oldDelegate) {
    return oldDelegate.selectedNodeId != selectedNodeId ||
           oldDelegate.animationValue != animationValue ||
           oldDelegate.nodes != nodes ||
           oldDelegate.edges != edges;
  }
}