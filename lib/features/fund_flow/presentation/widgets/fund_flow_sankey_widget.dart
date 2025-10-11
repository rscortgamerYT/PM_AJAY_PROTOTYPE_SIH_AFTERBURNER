import 'package:flutter/material.dart';
import '../../../../core/models/fund_transaction_model.dart';

/// Sankey node representing an entity in the fund flow
class SankeyNode {
  final String id;
  final String label;
  final FundFlowStage stage;
  final double totalAmount;
  final Color color;
  final int level;

  SankeyNode({
    required this.id,
    required this.label,
    required this.stage,
    required this.totalAmount,
    required this.color,
    required this.level,
  });
}

/// Sankey link representing a fund transfer
class SankeyLink {
  final String sourceId;
  final String targetId;
  final double amount;
  final List<FundTransaction> transactions;
  final Color color;

  SankeyLink({
    required this.sourceId,
    required this.targetId,
    required this.amount,
    required this.transactions,
    required this.color,
  });
}

/// Multi-Stage Fund Flow Dashboard with interactive Sankey diagram
class FundFlowSankeyWidget extends StatefulWidget {
  final List<FundTransaction> transactions;
  final Function(String nodeId)? onNodeClick;
  final Function(SankeyLink link)? onLinkClick;

  const FundFlowSankeyWidget({
    super.key,
    required this.transactions,
    this.onNodeClick,
    this.onLinkClick,
  });

  @override
  State<FundFlowSankeyWidget> createState() => _FundFlowSankeyWidgetState();
}

class _FundFlowSankeyWidgetState extends State<FundFlowSankeyWidget> {
  List<SankeyNode> _nodes = [];
  List<SankeyLink> _links = [];
  String? _hoveredNodeId;
  SankeyLink? _hoveredLink;
  Offset? _tooltipPosition;

  @override
  void initState() {
    super.initState();
    _buildSankeyData();
  }

  @override
  void didUpdateWidget(FundFlowSankeyWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.transactions != widget.transactions) {
      _buildSankeyData();
    }
  }

  void _buildSankeyData() {
    final Map<String, Map<String, double>> flows = {};
    final Map<String, List<FundTransaction>> linkTransactions = {};
    
    // Aggregate transactions by source and target
    for (final tx in widget.transactions) {
      final key = '${tx.fromEntityId}-${tx.toEntityId}';
      flows[tx.fromEntityId] ??= {};
      flows[tx.fromEntityId]![tx.toEntityId] = 
          (flows[tx.fromEntityId]![tx.toEntityId] ?? 0) + tx.amount;
      
      linkTransactions[key] ??= [];
      linkTransactions[key]!.add(tx);
    }

    // Create nodes
    final Set<String> nodeIds = {};
    final Map<String, SankeyNode> nodeMap = {};
    
    for (final tx in widget.transactions) {
      nodeIds.add(tx.fromEntityId);
      nodeIds.add(tx.toEntityId);
    }

    int index = 0;
    for (final nodeId in nodeIds) {
      final transactions = widget.transactions.where(
        (tx) => tx.fromEntityId == nodeId || tx.toEntityId == nodeId
      ).toList();
      
      if (transactions.isEmpty) continue;
      
      final stage = transactions.first.fromEntityId == nodeId
          ? transactions.first.stage
          : FundFlowStage.values[
              (transactions.first.stage.index + 1).clamp(0, FundFlowStage.values.length - 1)
            ];
      
      final totalAmount = transactions
          .where((tx) => tx.fromEntityId == nodeId)
          .fold<double>(0, (sum, tx) => sum + tx.amount);
      
      final node = SankeyNode(
        id: nodeId,
        label: transactions.first.fromEntityId == nodeId 
            ? transactions.first.fromEntity 
            : transactions.first.toEntity,
        stage: stage,
        totalAmount: totalAmount > 0 ? totalAmount : transactions
            .where((tx) => tx.toEntityId == nodeId)
            .fold<double>(0, (sum, tx) => sum + tx.amount),
        color: _getStageColor(stage),
        level: stage.index,
      );
      
      nodeMap[nodeId] = node;
      index++;
    }

    _nodes = nodeMap.values.toList()..sort((a, b) => a.level.compareTo(b.level));

    // Create links
    _links = [];
    flows.forEach((sourceId, targets) {
      targets.forEach((targetId, amount) {
        final key = '$sourceId-$targetId';
        final source = nodeMap[sourceId];
        final target = nodeMap[targetId];
        
        if (source != null && target != null) {
          _links.add(SankeyLink(
            sourceId: sourceId,
            targetId: targetId,
            amount: amount,
            transactions: linkTransactions[key] ?? [],
            color: source.color.withOpacity(0.6),
          ));
        }
      });
    });

    setState(() {});
  }

  Color _getStageColor(FundFlowStage stage) {
    switch (stage) {
      case FundFlowStage.centreAllocation:
        return Colors.blue;
      case FundFlowStage.stateTransfer:
        return Colors.green;
      case FundFlowStage.agencyDisbursement:
        return Colors.orange;
      case FundFlowStage.projectSpend:
        return Colors.purple;
      case FundFlowStage.beneficiaryPayment:
        return Colors.teal;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildLegend(),
            const SizedBox(height: 24),
            Expanded(
              child: _nodes.isEmpty
                  ? _buildEmptyState()
                  : Stack(
                      children: [
                        _buildSankeyDiagram(),
                        if (_tooltipPosition != null)
                          Positioned(
                            left: _tooltipPosition!.dx,
                            top: _tooltipPosition!.dy,
                            child: _buildTooltip(),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Multi-Stage Fund Flow',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Interactive Sankey Diagram',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        Row(
          children: [
            _buildSummaryChip(
              'Total Flow',
              '₹${_formatAmount(_getTotalFlow())}',
              Colors.blue,
            ),
            const SizedBox(width: 12),
            _buildSummaryChip(
              'Transactions',
              widget.transactions.length.toString(),
              Colors.green,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 24,
      runSpacing: 12,
      children: FundFlowStage.values.map((stage) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: _getStageColor(stage),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              stage.label,
              style: const TextStyle(fontSize: 13),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildSankeyDiagram() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        
        // Calculate node positions
        final levelWidth = width / (FundFlowStage.values.length + 1);
        final Map<String, Offset> nodePositions = {};
        final Map<int, List<SankeyNode>> nodesByLevel = {};
        
        // Group nodes by level
        for (final node in _nodes) {
          nodesByLevel[node.level] ??= [];
          nodesByLevel[node.level]!.add(node);
        }
        
        // Position nodes
        nodesByLevel.forEach((level, nodes) {
          final levelHeight = height / (nodes.length + 1);
          for (int i = 0; i < nodes.length; i++) {
            final node = nodes[i];
            nodePositions[node.id] = Offset(
              levelWidth * (level + 1),
              levelHeight * (i + 1),
            );
          }
        });

        return MouseRegion(
          onHover: (event) {
            setState(() {
              _tooltipPosition = event.localPosition;
            });
          },
          onExit: (event) {
            setState(() {
              _hoveredNodeId = null;
              _hoveredLink = null;
              _tooltipPosition = null;
            });
          },
          child: CustomPaint(
            size: Size(width, height),
            painter: SankeyPainter(
              nodes: _nodes,
              links: _links,
              nodePositions: nodePositions,
              hoveredNodeId: _hoveredNodeId,
              hoveredLink: _hoveredLink,
              onNodeHover: (nodeId) {
                setState(() => _hoveredNodeId = nodeId);
              },
              onLinkHover: (link) {
                setState(() => _hoveredLink = link);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildTooltip() {
    if (_hoveredNodeId != null) {
      final node = _nodes.firstWhere((n) => n.id == _hoveredNodeId);
      return _buildNodeTooltip(node);
    } else if (_hoveredLink != null) {
      return _buildLinkTooltip(_hoveredLink!);
    }
    return const SizedBox.shrink();
  }

  Widget _buildNodeTooltip(SankeyNode node) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: node.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                node.label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Stage: ${node.stage.label}',
            style: const TextStyle(fontSize: 12),
          ),
          Text(
            'Total: ₹${_formatAmount(node.totalAmount)}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkTooltip(SankeyLink link) {
    final source = _nodes.firstWhere((n) => n.id == link.sourceId);
    final target = _nodes.firstWhere((n) => n.id == link.targetId);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${source.label} → ${target.label}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Amount: ₹${_formatAmount(link.amount)}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'Transactions: ${link.transactions.length}',
            style: const TextStyle(fontSize: 12),
          ),
          if (link.transactions.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Latest: ${_formatDate(link.transactions.last.transactionDate)}',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_tree_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No fund flow data available',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  double _getTotalFlow() {
    return widget.transactions.fold<double>(
      0,
      (sum, tx) => sum + tx.amount,
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 10000000) {
      return '${(amount / 10000000).toStringAsFixed(2)}Cr';
    } else if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(2)}L';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(2)}K';
    }
    return amount.toStringAsFixed(2);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Custom painter for Sankey diagram
class SankeyPainter extends CustomPainter {
  final List<SankeyNode> nodes;
  final List<SankeyLink> links;
  final Map<String, Offset> nodePositions;
  final String? hoveredNodeId;
  final SankeyLink? hoveredLink;
  final Function(String)? onNodeHover;
  final Function(SankeyLink)? onLinkHover;

  SankeyPainter({
    required this.nodes,
    required this.links,
    required this.nodePositions,
    this.hoveredNodeId,
    this.hoveredLink,
    this.onNodeHover,
    this.onLinkHover,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw links first (behind nodes)
    for (final link in links) {
      _drawLink(canvas, link);
    }

    // Draw nodes on top
    for (final node in nodes) {
      _drawNode(canvas, node);
    }
  }

  void _drawLink(Canvas canvas, SankeyLink link) {
    final sourcePos = nodePositions[link.sourceId];
    final targetPos = nodePositions[link.targetId];
    
    if (sourcePos == null || targetPos == null) return;

    final isHovered = hoveredLink == link;
    final paint = Paint()
      ..color = isHovered ? link.color.withOpacity(0.9) : link.color
      ..strokeWidth = _calculateLinkWidth(link.amount)
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(sourcePos.dx + 40, sourcePos.dy);
    
    // Create curved path
    final controlPoint1 = Offset(
      sourcePos.dx + (targetPos.dx - sourcePos.dx) / 3,
      sourcePos.dy,
    );
    final controlPoint2 = Offset(
      sourcePos.dx + 2 * (targetPos.dx - sourcePos.dx) / 3,
      targetPos.dy,
    );
    
    path.cubicTo(
      controlPoint1.dx,
      controlPoint1.dy,
      controlPoint2.dx,
      controlPoint2.dy,
      targetPos.dx - 40,
      targetPos.dy,
    );

    canvas.drawPath(path, paint);
  }

  void _drawNode(Canvas canvas, SankeyNode node) {
    final pos = nodePositions[node.id];
    if (pos == null) return;

    final isHovered = hoveredNodeId == node.id;
    final nodeHeight = _calculateNodeHeight(node.totalAmount);
    
    // Draw node rectangle
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: pos,
        width: 80,
        height: nodeHeight,
      ),
      const Radius.circular(8),
    );

    final paint = Paint()
      ..color = isHovered ? node.color : node.color.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(rect, paint);

    // Draw border
    final borderPaint = Paint()
      ..color = node.color.withOpacity(isHovered ? 1.0 : 0.6)
      ..strokeWidth = isHovered ? 3 : 2
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(rect, borderPaint);

    // Draw label
    final textPainter = TextPainter(
      text: TextSpan(
        text: node.label.length > 12 
            ? '${node.label.substring(0, 12)}...' 
            : node.label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        pos.dx - textPainter.width / 2,
        pos.dy - textPainter.height / 2,
      ),
    );
  }

  double _calculateLinkWidth(double amount) {
    // Scale link width based on amount (min 2, max 20)
    return (amount / 1000000).clamp(2.0, 20.0);
  }

  double _calculateNodeHeight(double amount) {
    // Scale node height based on amount (min 40, max 100)
    return (amount / 500000).clamp(40.0, 100.0);
  }

  @override
  bool shouldRepaint(SankeyPainter oldDelegate) {
    return oldDelegate.hoveredNodeId != hoveredNodeId ||
        oldDelegate.hoveredLink != hoveredLink;
  }
}