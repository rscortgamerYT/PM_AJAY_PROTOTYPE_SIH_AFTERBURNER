import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/fund_flow_models.dart';
import '../../../../core/theme/app_design_system.dart';
import 'dart:math' as math;

/// Interactive Sankey diagram with multi-level drill-down capabilities
class InteractiveSankeyWidget extends ConsumerStatefulWidget {
  final SankeyFlowData initialData;
  final Function(String nodeId)? onNodeTap;
  final Function(String linkId)? onLinkTap;

  const InteractiveSankeyWidget({
    super.key,
    required this.initialData,
    this.onNodeTap,
    this.onLinkTap,
  });

  @override
  ConsumerState<InteractiveSankeyWidget> createState() => _InteractiveSankeyWidgetState();
}

class _InteractiveSankeyWidgetState extends ConsumerState<InteractiveSankeyWidget>
    with TickerProviderStateMixin {
  late SankeyFlowData _currentData;
  final List<FundFlowBreadcrumb> _breadcrumbs = [];
  String? _selectedNodeId;
  String? _selectedLinkId;
  String? _hoveredNodeId;
  String? _hoveredLinkId;
  
  late AnimationController _transitionController;
  late AnimationController _flowAnimationController;
  late Animation<double> _transitionAnimation;
  
  // Filter state
  DateTimeRange? _dateFilter;
  double? _minAmountFilter;
  double? _maxAmountFilter;
  Set<FundFlowStatus> _statusFilter = {};
  String _searchQuery = '';
  
  // Layout calculations
  final Map<String, Rect> _nodePositions = {};
  final Map<String, Path> _linkPaths = {};
  
  @override
  void initState() {
    super.initState();
    _currentData = widget.initialData;
    _initializeAnimations();
    _calculateLayout();
  }

  void _initializeAnimations() {
    _transitionController = AnimationController(
      duration: AppDesignSystem.durationNormal,
      vsync: this,
    );
    
    _transitionAnimation = CurvedAnimation(
      parent: _transitionController,
      curve: AppDesignSystem.curveStandard,
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

  void _calculateLayout() {
    _nodePositions.clear();
    _linkPaths.clear();
    
    // Get nodes by level for current view
    final nodesByLevel = <int, List<FundFlowNode>>{};
    for (var node in _currentData.nodes) {
      nodesByLevel.putIfAbsent(node.level, () => []).add(node);
    }
    
    // Calculate positions for each level
    final levelCount = nodesByLevel.keys.length;
    const double horizontalSpacing = 200.0;
    const double nodeWidth = 150.0;
    const double minNodeHeight = 40.0;
    
    double totalValue = _currentData.nodes.fold(0.0, (sum, node) => sum + node.amount);
    
    for (var level in nodesByLevel.keys) {
      final nodesAtLevel = nodesByLevel[level]!;
      final x = level * horizontalSpacing;
      double y = 50.0;
      
      for (var node in nodesAtLevel) {
        final height = math.max(minNodeHeight, (node.amount / totalValue) * 400);
        _nodePositions[node.id] = Rect.fromLTWH(x, y, nodeWidth, height);
        y += height + 20;
      }
    }
    
    // Calculate link paths
    for (var link in _currentData.links) {
      final sourceBounds = _nodePositions[link.sourceId];
      final targetBounds = _nodePositions[link.targetId];
      
      if (sourceBounds != null && targetBounds != null) {
        _linkPaths[link.id] = _createLinkPath(sourceBounds, targetBounds, link.value, totalValue);
      }
    }
  }

  Path _createLinkPath(Rect source, Rect target, double value, double totalValue) {
    final path = Path();
    final sourceRight = Offset(source.right, source.center.dy);
    final targetLeft = Offset(target.left, target.center.dy);
    final controlPoint1 = Offset(sourceRight.dx + 50, sourceRight.dy);
    final controlPoint2 = Offset(targetLeft.dx - 50, targetLeft.dy);
    
    path.moveTo(sourceRight.dx, sourceRight.dy);
    path.cubicTo(
      controlPoint1.dx, controlPoint1.dy,
      controlPoint2.dx, controlPoint2.dy,
      targetLeft.dx, targetLeft.dy,
    );
    
    return path;
  }

  void _handleNodeTap(String nodeId) {
    setState(() {
      _selectedNodeId = nodeId;
    });
    
    final node = _currentData.nodes.firstWhere((n) => n.id == nodeId);
    
    // Add to breadcrumbs if drilling down
    if (node.level < 5) {
      _breadcrumbs.add(FundFlowBreadcrumb(
        nodeId: nodeId,
        nodeName: node.name,
        level: node.level,
      ));
      
      // Get child nodes and create new data
      _drillDown(nodeId);
    }
    
    widget.onNodeTap?.call(nodeId);
  }

  void _drillDown(String parentId) {
    // This would fetch next level data in production
    // For now, we'll use the existing data structure
    _transitionController.forward(from: 0);
    _calculateLayout();
  }

  void _navigateToBreadcrumb(int index) {
    setState(() {
      _breadcrumbs.removeRange(index + 1, _breadcrumbs.length);
      if (index == -1) {
        // Reset to top level
        _currentData = widget.initialData;
      }
      _calculateLayout();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildBreadcrumbBar(),
        _buildFilterBar(),
        Expanded(
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: _buildSankeyCanvas(),
              ),
              if (_selectedNodeId != null || _selectedLinkId != null)
                Container(
                  width: 400,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: AppDesignSystem.elevation3,
                  ),
                  child: _buildDetailPanel(),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBreadcrumbBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppDesignSystem.neutral300),
        ),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => _navigateToBreadcrumb(-1),
            child: Row(
              children: [
                Icon(Icons.home, size: 20, color: AppDesignSystem.deepIndigo),
                const SizedBox(width: 4),
                Text('Centre', style: AppDesignSystem.labelLarge),
              ],
            ),
          ),
          for (int i = 0; i < _breadcrumbs.length; i++) ...[
            Icon(Icons.chevron_right, size: 20, color: AppDesignSystem.neutral500),
            InkWell(
              onTap: () => _navigateToBreadcrumb(i),
              child: Text(
                _breadcrumbs[i].nodeName,
                style: i == _breadcrumbs.length - 1
                    ? AppDesignSystem.labelLarge.copyWith(
                        color: AppDesignSystem.deepIndigo,
                        fontWeight: FontWeight.bold,
                      )
                    : AppDesignSystem.labelLarge,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppDesignSystem.neutral100,
        border: Border(
          bottom: BorderSide(color: AppDesignSystem.neutral300),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name, PFMS ID, or project...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),
          const SizedBox(width: 16),
          _buildFilterChip('Date Range', Icons.date_range),
          const SizedBox(width: 8),
          _buildFilterChip('Amount', Icons.attach_money),
          const SizedBox(width: 8),
          _buildFilterChip('Status', Icons.flag),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _dateFilter = null;
                _minAmountFilter = null;
                _maxAmountFilter = null;
                _statusFilter.clear();
                _searchQuery = '';
              });
            },
            tooltip: 'Clear Filters',
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      onSelected: (selected) {
        // Show filter dialog
      },
    );
  }

  Widget _buildSankeyCanvas() {
    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 3.0,
      child: CustomPaint(
        painter: SankeyPainter(
          data: _currentData,
          nodePositions: _nodePositions,
          linkPaths: _linkPaths,
          selectedNodeId: _selectedNodeId,
          selectedLinkId: _selectedLinkId,
          hoveredNodeId: _hoveredNodeId,
          hoveredLinkId: _hoveredLinkId,
          flowAnimation: _flowAnimationController,
          transitionAnimation: _transitionAnimation,
        ),
        child: GestureDetector(
          onTapDown: (details) {
            _handleCanvasTap(details.localPosition);
          },
        ),
      ),
    );
  }

  void _handleCanvasTap(Offset position) {
    // Check if tap is on a node
    for (var entry in _nodePositions.entries) {
      if (entry.value.contains(position)) {
        _handleNodeTap(entry.key);
        return;
      }
    }
    
    // Check if tap is on a link (approximate)
    for (var entry in _linkPaths.entries) {
      final path = entry.value;
      if (path.contains(position)) {
        setState(() {
          _selectedLinkId = entry.key;
        });
        widget.onLinkTap?.call(entry.key);
        return;
      }
    }
    
    // Deselect if tapping empty space
    setState(() {
      _selectedNodeId = null;
      _selectedLinkId = null;
    });
  }

  Widget _buildDetailPanel() {
    if (_selectedNodeId != null) {
      return _buildNodeDetailPanel();
    } else if (_selectedLinkId != null) {
      return _buildLinkDetailPanel();
    }
    return const SizedBox.shrink();
  }

  Widget _buildNodeDetailPanel() {
    final node = _currentData.nodes.firstWhere((n) => n.id == _selectedNodeId);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  node.name,
                  style: AppDesignSystem.headlineSmall,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() => _selectedNodeId = null);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Level', _getLevelName(node.level)),
          _buildInfoRow('Allocated', '₹${_formatAmount(node.allocatedAmount ?? node.amount)}'),
          _buildInfoRow('Utilized', '₹${_formatAmount(node.utilizedAmount ?? 0)}'),
          _buildInfoRow('Remaining', '₹${_formatAmount(node.remainingAmount ?? 0)}'),
          _buildInfoRow('Utilization Rate', '${node.utilizationPercentage.toStringAsFixed(1)}%'),
          if (node.responsibleOfficer != null)
            _buildInfoRow('Responsible', node.responsibleOfficer!),
          if (node.contact != null)
            _buildInfoRow('Contact', node.contact!),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: node.utilizationPercentage / 100,
            backgroundColor: AppDesignSystem.neutral200,
            valueColor: AlwaysStoppedAnimation<Color>(
              node.utilizationPercentage > 80
                  ? AppDesignSystem.success
                  : node.utilizationPercentage > 50
                      ? AppDesignSystem.warning
                      : AppDesignSystem.error,
            ),
          ),
          const SizedBox(height: 24),
          if (node.evidenceDocuments.isNotEmpty) ...[
            Text('Evidence Documents', style: AppDesignSystem.titleMedium),
            const SizedBox(height: 8),
            ...node.evidenceDocuments.map((doc) => ListTile(
              leading: const Icon(Icons.file_present),
              title: Text(doc),
              trailing: const Icon(Icons.download),
              dense: true,
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildLinkDetailPanel() {
    final link = _currentData.links.firstWhere((l) => l.id == _selectedLinkId);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Fund Transfer',
                  style: AppDesignSystem.headlineSmall,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() => _selectedLinkId = null);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Amount', '₹${_formatAmount(link.value)}'),
          if (link.pfmsId != null)
            _buildInfoRow('PFMS ID', link.pfmsId!),
          if (link.transferDate != null)
            _buildInfoRow('Transfer Date', _formatDate(link.transferDate!)),
          if (link.processingDays != null)
            _buildInfoRow('Processing Time', '${link.processingDays} days'),
          _buildInfoRow('Status', link.status.displayName),
          if (link.approvedBy != null)
            _buildInfoRow('Approved By', link.approvedBy!),
          if (link.ucStatus != null)
            _buildInfoRow('UC Status', link.ucStatus!),
          const SizedBox(height: 24),
          if (link.auditTrail.isNotEmpty) ...[
            Text('Audit Trail', style: AppDesignSystem.titleMedium),
            const SizedBox(height: 8),
            ...link.auditTrail.map((entry) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(entry.action),
                subtitle: Text('${entry.performedBy}\n${_formatDate(entry.timestamp)}'),
                isThreeLine: true,
                dense: true,
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppDesignSystem.labelLarge),
          Text(
            value,
            style: AppDesignSystem.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  String _getLevelName(int level) {
    switch (level) {
      case 0: return 'Centre';
      case 1: return 'State';
      case 2: return 'Agency';
      case 3: return 'Project';
      case 4: return 'Milestone';
      case 5: return 'Expenditure';
      default: return 'Unknown';
    }
  }

  String _formatAmount(double amount) {
    if (amount >= 10000000) {
      return '${(amount / 10000000).toStringAsFixed(2)} Cr';
    } else if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(2)} L';
    } else {
      return amount.toStringAsFixed(2);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Custom painter for the Sankey diagram
class SankeyPainter extends CustomPainter {
  final SankeyFlowData data;
  final Map<String, Rect> nodePositions;
  final Map<String, Path> linkPaths;
  final String? selectedNodeId;
  final String? selectedLinkId;
  final String? hoveredNodeId;
  final String? hoveredLinkId;
  final Animation<double> flowAnimation;
  final Animation<double> transitionAnimation;

  SankeyPainter({
    required this.data,
    required this.nodePositions,
    required this.linkPaths,
    this.selectedNodeId,
    this.selectedLinkId,
    this.hoveredNodeId,
    this.hoveredLinkId,
    required this.flowAnimation,
    required this.transitionAnimation,
  }) : super(repaint: flowAnimation);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw links first (behind nodes)
    for (var link in data.links) {
      _drawLink(canvas, link);
    }
    
    // Draw nodes
    for (var node in data.nodes) {
      _drawNode(canvas, node);
    }
  }

  void _drawLink(Canvas canvas, FundFlowLink link) {
    final path = linkPaths[link.id];
    if (path == null) return;
    
    final isSelected = link.id == selectedLinkId;
    final isHovered = link.id == hoveredLinkId;
    
    final paint = Paint()
      ..color = link.status.color.withOpacity(isSelected ? 0.8 : 0.3)
      ..strokeWidth = isSelected ? 8 : isHovered ? 6 : 4
      ..style = PaintingStyle.stroke;
    
    canvas.drawPath(path, paint);
    
    // Draw flowing particles for active transfers
    if (link.status == FundFlowStatus.active) {
      _drawFlowingParticles(canvas, path);
    }
  }

  void _drawFlowingParticles(Canvas canvas, Path path) {
    final metrics = path.computeMetrics().first;
    final particleCount = 5;
    
    for (int i = 0; i < particleCount; i++) {
      final progress = (flowAnimation.value + (i / particleCount)) % 1.0;
      final tangent = metrics.getTangentForOffset(metrics.length * progress);
      
      if (tangent != null) {
        final paint = Paint()
          ..color = AppDesignSystem.vibrantTeal
          ..style = PaintingStyle.fill;
        
        canvas.drawCircle(tangent.position, 3, paint);
      }
    }
  }

  void _drawNode(Canvas canvas, FundFlowNode node) {
    final bounds = nodePositions[node.id];
    if (bounds == null) return;
    
    final isSelected = node.id == selectedNodeId;
    final isHovered = node.id == hoveredNodeId;
    
    // Draw node rectangle
    final paint = Paint()
      ..color = node.color
      ..style = PaintingStyle.fill;
    
    final borderPaint = Paint()
      ..color = isSelected
          ? AppDesignSystem.deepIndigo
          : isHovered
              ? AppDesignSystem.vibrantTeal
              : Colors.transparent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    
    final rrect = RRect.fromRectAndRadius(bounds, const Radius.circular(8));
    canvas.drawRRect(rrect, paint);
    canvas.drawRRect(rrect, borderPaint);
    
    // Draw node label
    final textPainter = TextPainter(
      text: TextSpan(
        text: node.name,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 2,
      ellipsis: '...',
    );
    
    textPainter.layout(maxWidth: bounds.width - 16);
    textPainter.paint(
      canvas,
      Offset(bounds.left + 8, bounds.center.dy - textPainter.height / 2),
    );
    
    // Draw status indicator
    if (node.isDelayed) {
      final indicatorPaint = Paint()
        ..color = AppDesignSystem.error
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(bounds.right - 8, bounds.top + 8),
        6,
        indicatorPaint,
      );
    }
  }

  @override
  bool shouldRepaint(SankeyPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.selectedNodeId != selectedNodeId ||
        oldDelegate.selectedLinkId != selectedLinkId ||
        oldDelegate.hoveredNodeId != hoveredNodeId ||
        oldDelegate.hoveredLinkId != hoveredLinkId;
  }
}