import 'package:flutter/material.dart';
import '../../models/overwatch_fund_flow_model.dart';
import '../../models/overwatch_project_model.dart';
import '../../../../core/theme/app_design_system.dart';
import '../../../../core/utils/responsive_layout.dart';

class OverwatchFundFlowSankeyWidget extends StatefulWidget {
  final CompleteFundFlowData fundFlowData;
  final Function(FundFlowNode)? onNodeTap;

  const OverwatchFundFlowSankeyWidget({
    super.key,
    required this.fundFlowData,
    this.onNodeTap,
  });

  @override
  State<OverwatchFundFlowSankeyWidget> createState() =>
      _OverwatchFundFlowSankeyWidgetState();
}

class _OverwatchFundFlowSankeyWidgetState
    extends State<OverwatchFundFlowSankeyWidget> {
  FundFlowNode? _selectedNode;
  int _selectedLevel = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppDesignSystem.radiusLarge,
        border: Border.all(
          color: AppDesignSystem.neutral300,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _buildFlowVisualization(),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 1,
                child: _buildDetailsPanel(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Complete Fund Flow Analysis',
              style: AppDesignSystem.headlineMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Real-time tracking from Centre to specific expenses',
              style: AppDesignSystem.bodySmall.copyWith(
                color: AppDesignSystem.neutral600,
              ),
            ),
          ],
        ),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () {
                // Export functionality
              },
              icon: const Icon(Icons.download, size: 18),
              label: const Text('Export Report'),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: () {
                // Flag functionality
              },
              icon: const Icon(Icons.flag, size: 18),
              label: const Text('Flag Issue'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFlowVisualization() {
    return Container(
      height: 600,
      decoration: BoxDecoration(
        color: AppDesignSystem.neutral100.withValues(alpha: 0.3),
        borderRadius: AppDesignSystem.radiusMedium,
        border: Border.all(
          color: AppDesignSystem.neutral300,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildLevelSelector(),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: _buildFlowDiagram(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelSelector() {
    return Row(
      children: [
        Text(
          'View Level:',
          style: AppDesignSystem.labelMedium,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Wrap(
            spacing: 8,
            children: FundFlowNodeType.values.map((type) {
              return FilterChip(
                label: Text(type.label),
                selected: _selectedLevel == type.level,
                onSelected: (selected) {
                  setState(() {
                    _selectedLevel = type.level;
                  });
                },
                selectedColor: type.color.withValues(alpha: 0.2),
                checkmarkColor: type.color,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildFlowDiagram() {
    final nodesByLevel = <int, List<FundFlowNode>>{};
    for (final node in widget.fundFlowData.nodes) {
      nodesByLevel.putIfAbsent(node.level, () => []).add(node);
    }

    return Column(
      children: [
        for (int level = 0; level <= 5; level++)
          if (nodesByLevel.containsKey(level)) ...[
            _buildLevelRow(level, nodesByLevel[level]!),
            if (level < 5) _buildLevelConnector(),
          ],
      ],
    );
  }

  Widget _buildLevelRow(int level, List<FundFlowNode> nodes) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Level $level: ${FundFlowNodeType.values[level].label}',
            style: AppDesignSystem.labelSmall.copyWith(
              color: AppDesignSystem.neutral600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: nodes.map((node) => _buildNodeCard(node)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelConnector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.arrow_downward,
            size: 24,
            color: AppDesignSystem.neutral400,
          ),
        ],
      ),
    );
  }

  Widget _buildNodeCard(FundFlowNode node) {
    final isSelected = _selectedNode?.id == node.id;
    final nodeType = node.type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedNode = node;
        });
        widget.onNodeTap?.call(node);
      },
      child: Container(
        constraints: const BoxConstraints(maxWidth: 200),
        decoration: BoxDecoration(
          color: nodeType.color.withValues(alpha: isSelected ? 0.3 : 0.1),
          borderRadius: AppDesignSystem.radiusSmall,
          border: Border.all(
            color: isSelected ? nodeType.color : nodeType.color.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              node.name,
              style: AppDesignSystem.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '₹${(node.amount / 100000).toStringAsFixed(1)}L',
              style: AppDesignSystem.labelSmall.copyWith(
                color: AppDesignSystem.neutral600,
              ),
            ),
            if (node.responsiblePerson != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 14,
                    color: AppDesignSystem.neutral600,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      node.responsiblePerson!.name,
                      style: AppDesignSystem.labelSmall.copyWith(
                        color: AppDesignSystem.neutral600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsPanel() {
    return Container(
      height: 600,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppDesignSystem.radiusMedium,
        border: Border.all(
          color: AppDesignSystem.neutral300,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: _selectedNode != null
          ? _buildNodeDetails(_selectedNode!)
          : _buildSummary(),
    );
  }

  Widget _buildNodeDetails(FundFlowNode node) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            node.name,
            style: AppDesignSystem.titleMedium,
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Amount', '₹${(node.amount / 100000).toStringAsFixed(2)} Lakhs'),
          const SizedBox(height: 12),
          _buildDetailRow('Type', node.type.label),
          const SizedBox(height: 12),
          _buildDetailRow('Level', 'Level ${node.level}'),
          if (node.responsiblePerson != null) ...[
            const SizedBox(height: 20),
            Text(
              'Responsible Person',
              style: AppDesignSystem.labelMedium.copyWith(
                color: AppDesignSystem.neutral600,
              ),
            ),
            const SizedBox(height: 12),
            _buildDetailRow('Name', node.responsiblePerson!.name),
            const SizedBox(height: 8),
            _buildDetailRow('Designation', node.responsiblePerson!.designation),
            const SizedBox(height: 8),
            _buildDetailRow('Contact', node.responsiblePerson!.contact),
            const SizedBox(height: 8),
            _buildDetailRow('Employee ID', node.responsiblePerson!.empId),
          ],
          if (node.details != null) ...[
            const SizedBox(height: 20),
            Text(
              'Transaction Details',
              style: AppDesignSystem.labelMedium.copyWith(
                color: AppDesignSystem.neutral600,
              ),
            ),
            const SizedBox(height: 12),
            _buildDetailRow('Transaction ID', node.details!.transactionId),
            const SizedBox(height: 8),
            _buildDetailRow('Date', _formatDate(node.details!.date)),
            const SizedBox(height: 8),
            _buildDetailRow('Bank', node.details!.bankDetails),
            const SizedBox(height: 8),
            _buildDetailRow('Status', node.details!.approvalStatus),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.search, size: 18),
                  label: const Text('Audit'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.flag, size: 18),
                  label: const Text('Flag'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Project Summary',
          style: AppDesignSystem.titleMedium,
        ),
        const SizedBox(height: 20),
        _buildDetailRow(
          'Total Allocated',
          '₹${(widget.fundFlowData.totalAllocated / 100000).toStringAsFixed(1)}L',
        ),
        const SizedBox(height: 12),
        _buildDetailRow(
          'Total Utilized',
          '₹${(widget.fundFlowData.totalUtilized / 100000).toStringAsFixed(1)}L',
          valueColor: AppDesignSystem.success,
        ),
        const SizedBox(height: 12),
        _buildDetailRow(
          'Remaining',
          '₹${((widget.fundFlowData.totalAllocated - widget.fundFlowData.totalUtilized) / 100000).toStringAsFixed(1)}L',
        ),
        const SizedBox(height: 20),
        Text(
          'Flow Statistics',
          style: AppDesignSystem.labelMedium.copyWith(
            color: AppDesignSystem.neutral600,
          ),
        ),
        const SizedBox(height: 12),
        _buildDetailRow('Total Nodes', '${widget.fundFlowData.nodes.length}'),
        const SizedBox(height: 8),
        _buildDetailRow('Total Links', '${widget.fundFlowData.links.length}'),
        const SizedBox(height: 8),
        _buildDetailRow('Flagged Links', '${widget.fundFlowData.flaggedLinks.length}'),
        const SizedBox(height: 8),
        _buildDetailRow('Delayed Links', '${widget.fundFlowData.delayedLinks.length}'),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppDesignSystem.bodySmall.copyWith(
            color: AppDesignSystem.neutral600,
          ),
        ),
        Text(
          value,
          style: AppDesignSystem.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}