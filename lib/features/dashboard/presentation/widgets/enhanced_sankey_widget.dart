import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/enhanced_fund_flow_models.dart';
import '../../../../core/theme/app_design_system.dart';

/// Enhanced Interactive Sankey diagram with 5-level drill-down and analytics
class EnhancedSankeyWidget extends ConsumerStatefulWidget {
  final EnhancedSankeyFlowData initialData;
  final Function(String nodeId)? onNodeTap;
  final Function(String linkId)? onLinkTap;

  const EnhancedSankeyWidget({
    super.key,
    required this.initialData,
    this.onNodeTap,
    this.onLinkTap,
  });

  @override
  ConsumerState<EnhancedSankeyWidget> createState() => _EnhancedSankeyWidgetState();
}

class _EnhancedSankeyWidgetState extends ConsumerState<EnhancedSankeyWidget>
    with TickerProviderStateMixin {
  late EnhancedSankeyFlowData _currentData;
  final List<String> _navigationStack = [];
  String? _selectedNodeId;
  String? _hoveredNodeId;
  FundFlowLevel _currentLevel = FundFlowLevel.centre;
  
  // Animation controllers
  late AnimationController _transitionController;
  late AnimationController _flowAnimationController;
  
  // Filter state
  final Set<FlowHealthStatus> _statusFilter = {};
  final double _minRiskFilter = 0.0;
  bool _showAnomaliesOnly = false;
  
  // View mode
  bool _showComparativeView = false;
  String? _compareNodeId;

  @override
  void initState() {
    super.initState();
    _currentData = widget.initialData;
    
    _transitionController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _flowAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _transitionController.dispose();
    _flowAnimationController.dispose();
    super.dispose();
  }

  List<EnhancedFundFlowNode> get _visibleNodes {
    var nodes = _currentData.nodes;
    
    // Filter by current level and parent context
    if (_navigationStack.isNotEmpty) {
      final parentId = _navigationStack.last;
      nodes = _currentData.getChildNodes(parentId);
    } else {
      nodes = nodes.where((n) => n.level == FundFlowLevel.centre).toList();
    }
    
    // Apply status filter
    if (_statusFilter.isNotEmpty) {
      nodes = nodes.where((n) => _statusFilter.contains(n.healthStatus)).toList();
    }
    
    // Apply risk filter
    nodes = nodes.where((n) => n.riskScore >= _minRiskFilter).toList();
    
    // Show anomalies only
    if (_showAnomaliesOnly) {
      nodes = nodes.where((n) => n.hasIssues).toList();
    }
    
    return nodes;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildControlBar(),
        _buildBreadcrumbNavigation(),
        _buildAnalyticsBar(),
        Expanded(
          child: _showComparativeView ? _buildComparativeView() : _buildMainVisualization(),
        ),
        if (_selectedNodeId != null) _buildDetailPanel(),
      ],
    );
  }

  Widget _buildControlBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppDesignSystem.neutral300)),
      ),
      child: Row(
        children: [
          _buildFilterChips(),
          const Spacer(),
          _buildViewModeToggle(),
          const SizedBox(width: 16),
          _buildExportButton(),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Wrap(
      spacing: 8,
      children: [
        FilterChip(
          label: const Text('Anomalies'),
          selected: _showAnomaliesOnly,
          onSelected: (selected) => setState(() => _showAnomaliesOnly = selected),
          avatar: Icon(Icons.warning, size: 16, 
            color: _showAnomaliesOnly ? Colors.white : AppDesignSystem.error),
          selectedColor: AppDesignSystem.error,
        ),
        ...FlowHealthStatus.values.map((status) {
          final isSelected = _statusFilter.contains(status);
          return FilterChip(
            label: Text(status.label),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                if (selected) {
                  _statusFilter.add(status);
                } else {
                  _statusFilter.remove(status);
                }
              });
            },
            avatar: Icon(status.icon, size: 16,
              color: isSelected ? Colors.white : status.color),
            selectedColor: status.color,
          );
        }),
      ],
    );
  }

  Widget _buildViewModeToggle() {
    return SegmentedButton<bool>(
      segments: const [
        ButtonSegment(
          value: false,
          label: Text('Flow View'),
          icon: Icon(Icons.account_tree),
        ),
        ButtonSegment(
          value: true,
          label: Text('Compare'),
          icon: Icon(Icons.compare),
        ),
      ],
      selected: {_showComparativeView},
      onSelectionChanged: (Set<bool> newSelection) {
        setState(() => _showComparativeView = newSelection.first);
      },
    );
  }

  Widget _buildExportButton() {
    return IconButton.filled(
      icon: const Icon(Icons.download),
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exporting flow data...')),
        );
      },
      tooltip: 'Export Flow Data',
    );
  }

  Widget _buildBreadcrumbNavigation() {
    if (_navigationStack.isEmpty) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: AppDesignSystem.neutral100,
        border: Border(bottom: BorderSide(color: AppDesignSystem.neutral300)),
      ),
      child: Row(
        children: [
          TextButton.icon(
            icon: const Icon(Icons.home, size: 16),
            label: const Text('Centre'),
            onPressed: () {
              setState(() {
                _navigationStack.clear();
                _selectedNodeId = null;
                _currentLevel = FundFlowLevel.centre;
              });
            },
          ),
          ..._navigationStack.map((nodeId) {
            final node = _currentData.getNodeById(nodeId);
            if (node == null) return const SizedBox.shrink();
            
            return Row(
              children: [
                const Icon(Icons.chevron_right, size: 16),
                TextButton(
                  onPressed: () {
                    final index = _navigationStack.indexOf(nodeId);
                    setState(() {
                      _navigationStack.removeRange(index + 1, _navigationStack.length);
                      _selectedNodeId = nodeId;
                      _currentLevel = node.level;
                    });
                  },
                  child: Text(node.name),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAnalyticsBar() {
    final analytics = _currentData.analytics;
    
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppDesignSystem.deepIndigo.withOpacity(0.05),
      child: Row(
        children: [
          _buildAnalyticsMetric(
            'Avg Velocity',
            '₹${analytics.averageVelocity.toStringAsFixed(1)}Cr/day',
            Icons.speed,
            AppDesignSystem.vibrantTeal,
          ),
          const SizedBox(width: 24),
          _buildAnalyticsMetric(
            'SLA Compliance',
            '${analytics.slaCompliance['overall']?.toStringAsFixed(1) ?? '0'}%',
            Icons.verified,
            AppDesignSystem.success,
          ),
          const SizedBox(width: 24),
          _buildAnalyticsMetric(
            'Bottlenecks',
            '${analytics.detectedBottlenecks.length}',
            Icons.warning,
            AppDesignSystem.warning,
          ),
          const SizedBox(width: 24),
          _buildAnalyticsMetric(
            'Anomalies',
            '${analytics.leakageAlerts.length}',
            Icons.error,
            AppDesignSystem.error,
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsMetric(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: AppDesignSystem.radiusSmall,
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppDesignSystem.labelSmall),
            Text(value, style: AppDesignSystem.titleMedium.copyWith(color: color)),
          ],
        ),
      ],
    );
  }

  Widget _buildMainVisualization() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _EnhancedSankeyPainter(
            nodes: _visibleNodes,
            links: _currentData.links,
            selectedNodeId: _selectedNodeId,
            hoveredNodeId: _hoveredNodeId,
            flowAnimation: _flowAnimationController,
          ),
        );
      },
    );
  }

  Widget _buildComparativeView() {
    return Row(
      children: [
        Expanded(
          child: _buildMainVisualization(),
        ),
        if (_compareNodeId != null) ...[
          const VerticalDivider(),
          Expanded(
            child: _buildMainVisualization(),
          ),
        ],
      ],
    );
  }

  Widget _buildDetailPanel() {
    final node = _currentData.getNodeById(_selectedNodeId!);
    if (node == null) return const SizedBox.shrink();
    
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: AppDesignSystem.neutral300)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(node.healthStatus.icon, color: node.statusColor),
                    const SizedBox(width: 8),
                    Text(node.name, style: AppDesignSystem.headlineSmall),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(() => _selectedNodeId = null),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Row(
                    children: [
                      _buildDetailMetric('Allocated', '₹${node.allocatedAmount.toStringAsFixed(2)}Cr'),
                      _buildDetailMetric('Utilized', '₹${node.utilizedAmount.toStringAsFixed(2)}Cr'),
                      _buildDetailMetric('In Transit', '₹${node.inTransitAmount.toStringAsFixed(2)}Cr'),
                      _buildDetailMetric('Utilization', '${node.utilizationRate.toStringAsFixed(1)}%'),
                      _buildDetailMetric('Risk Score', node.riskScore.toStringAsFixed(1)),
                      _buildDetailMetric('Delay', '${node.delayDays} days'),
                    ],
                  ),
                ),
                if (node.flags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: node.flags.map((flag) => Chip(
                      label: Text(flag, style: AppDesignSystem.labelSmall),
                      backgroundColor: AppDesignSystem.warning.withOpacity(0.1),
                    )).toList(),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: () {
              if (node.childNodeIds.isNotEmpty) {
                setState(() {
                  _navigationStack.add(node.id);
                  _selectedNodeId = null;
                  _currentLevel = node.level;
                });
              }
            },
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Drill Down'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailMetric(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppDesignSystem.labelSmall),
          const SizedBox(height: 4),
          Text(value, style: AppDesignSystem.titleMedium),
        ],
      ),
    );
  }
}

class _EnhancedSankeyPainter extends CustomPainter {
  final List<EnhancedFundFlowNode> nodes;
  final List<EnhancedFundFlowLink> links;
  final String? selectedNodeId;
  final String? hoveredNodeId;
  final Animation<double> flowAnimation;

  _EnhancedSankeyPainter({
    required this.nodes,
    required this.links,
    this.selectedNodeId,
    this.hoveredNodeId,
    required this.flowAnimation,
  }) : super(repaint: flowAnimation);

  @override
  void paint(Canvas canvas, Size size) {
    if (nodes.isEmpty) return;

    const nodeHeight = 60.0;
    const nodeSpacing = 20.0;
    final totalHeight = (nodes.length * nodeHeight) + ((nodes.length - 1) * nodeSpacing);
    final startY = (size.height - totalHeight) / 2;

    // Draw nodes
    for (var i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      final rect = Rect.fromLTWH(
        20,
        startY + (i * (nodeHeight + nodeSpacing)),
        size.width - 40,
        nodeHeight,
      );

      _drawNode(canvas, node, rect);
    }
  }

  void _drawNode(Canvas canvas, EnhancedFundFlowNode node, Rect rect) {
    final paint = Paint()
      ..color = node.statusColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = node.statusColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw node background
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      paint..color = node.statusColor.withOpacity(0.1),
    );

    // Draw node border
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      borderPaint,
    );

    // Draw utilization bar
    final utilizationWidth = (rect.width * node.utilizationRate / 100);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(rect.left, rect.bottom - 4, utilizationWidth, 4),
        const Radius.circular(2),
      ),
      paint..color = node.statusColor,
    );
  }

  @override
  bool shouldRepaint(_EnhancedSankeyPainter oldDelegate) {
    return oldDelegate.nodes != nodes ||
           oldDelegate.links != links ||
           oldDelegate.selectedNodeId != selectedNodeId ||
           oldDelegate.hoveredNodeId != hoveredNodeId;
  }
}