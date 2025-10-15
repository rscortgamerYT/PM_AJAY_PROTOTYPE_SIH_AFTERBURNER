import 'package:flutter/material.dart';
import '../../../../core/models/project_milestone_model.dart';
import '../../../../core/theme/app_design_system.dart';
import '../../../../core/utils/responsive_layout.dart';

class ProjectMilestoneRoadmapWidget extends StatefulWidget {
  final String projectId;
  final List<ProjectMilestone> milestones;
  final VoidCallback? onClaimMilestone;
  final Function(ProjectMilestone)? onMilestoneDetails;

  const ProjectMilestoneRoadmapWidget({
    super.key,
    required this.projectId,
    required this.milestones,
    this.onClaimMilestone,
    this.onMilestoneDetails,
  });

  @override
  State<ProjectMilestoneRoadmapWidget> createState() => _ProjectMilestoneRoadmapWidgetState();
}

class _ProjectMilestoneRoadmapWidgetState extends State<ProjectMilestoneRoadmapWidget> {
  ProjectMilestone? _selectedMilestone;

  @override
  Widget build(BuildContext context) {
    final sortedMilestones = List<ProjectMilestone>.from(widget.milestones)
      ..sort((a, b) => a.sequenceOrder.compareTo(b.sequenceOrder));

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildRoadmapTimeline(sortedMilestones),
            const SizedBox(height: 24),
            _buildMilestonesList(sortedMilestones),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final totalMilestones = widget.milestones.length;
    final completedMilestones = widget.milestones.where((m) => m.isCompleted).length;
    final claimedMilestones = widget.milestones.where((m) => m.isClaimed).length;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Project Roadmap',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                '$completedMilestones of $totalMilestones milestones completed',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        ),
        _buildProgressIndicator(completedMilestones, totalMilestones),
      ],
    );
  }

  Widget _buildProgressIndicator(int completed, int total) {
    final percentage = total > 0 ? (completed / total * 100).round() : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppDesignSystem.deepIndigo.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            '$percentage%',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppDesignSystem.deepIndigo,
            ),
          ),
          Text(
            'Complete',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoadmapTimeline(List<ProjectMilestone> milestones) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildTimelineBar(milestones),
          const SizedBox(height: 16),
          _buildTimelineLegend(),
        ],
      ),
    );
  }

  Widget _buildTimelineBar(List<ProjectMilestone> milestones) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final segmentWidth = constraints.maxWidth / milestones.length;

        return Row(
          children: milestones.asMap().entries.map((entry) {
            final index = entry.key;
            final milestone = entry.value;
            final isLast = index == milestones.length - 1;

            return Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: _buildTimelineSegment(milestone, index),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 40,
                      color: Colors.grey[300],
                    ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildTimelineSegment(ProjectMilestone milestone, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMilestone = milestone;
        });
        widget.onMilestoneDetails?.call(milestone);
      },
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: _getStatusColor(milestone.status).withOpacity(0.2),
          border: Border.all(
            color: _getStatusColor(milestone.status),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            // Completion fill
            if (milestone.isCompleted)
              Container(
                decoration: BoxDecoration(
                  color: _getStatusColor(milestone.status).withOpacity(0.4),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            // Milestone number
            Center(
              child: Text(
                milestone.milestoneNumber,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _getStatusColor(milestone.status),
                ),
              ),
            ),
            // Claim indicator
            if (milestone.isClaimed)
              Positioned(
                top: 4,
                right: 4,
                child: Icon(
                  _getClaimIcon(milestone.claimStatus),
                  size: 14,
                  color: _getClaimStatusColor(milestone.claimStatus),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineLegend() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _buildLegendItem('Completed', MilestoneStatus.completed.color),
        _buildLegendItem('In Progress', MilestoneStatus.inProgress.color),
        _buildLegendItem('Not Started', MilestoneStatus.notStarted.color),
        _buildLegendItem('Delayed', MilestoneStatus.delayed.color),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            border: Border.all(color: color, width: 2),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
        ),
      ],
    );
  }

  Widget _buildMilestonesList(List<ProjectMilestone> milestones) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Milestone Details',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: milestones.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return _buildMilestoneCard(milestones[index]);
          },
        ),
      ],
    );
  }

  Widget _buildMilestoneCard(ProjectMilestone milestone) {
    final isSelected = _selectedMilestone?.id == milestone.id;

    return Container(
      decoration: BoxDecoration(
        color: isSelected ? AppDesignSystem.deepIndigo.withOpacity(0.05) : Colors.white,
        border: Border.all(
          color: isSelected ? AppDesignSystem.deepIndigo : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: _buildMilestoneIcon(milestone),
            title: Text(
              '${milestone.milestoneNumber}: ${milestone.name}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  milestone.description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildStatusChip(milestone.status),
                    const SizedBox(width: 8),
                    _buildClaimStatusChip(milestone.claimStatus),
                  ],
                ),
              ],
            ),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '₹${_formatAmount(milestone.targetAmount)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (milestone.isClaimed)
                  Text(
                    'Claimed: ₹${_formatAmount(milestone.claimedAmount)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
          if (milestone.canBeClaimed)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _handleClaimMilestone(milestone),
                  icon: const Icon(Icons.payment, size: 18),
                  label: const Text('Submit Claim'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppDesignSystem.forestGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
          if (milestone.claimStatus == MilestoneClaimStatus.claimed ||
              milestone.claimStatus == MilestoneClaimStatus.underReview)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _handleViewClaimDetails(milestone),
                  icon: const Icon(Icons.visibility, size: 18),
                  label: const Text('View Claim Details'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppDesignSystem.deepIndigo,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMilestoneIcon(ProjectMilestone milestone) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: _getStatusColor(milestone.status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        _getStatusIcon(milestone.status),
        color: _getStatusColor(milestone.status),
        size: 24,
      ),
    );
  }

  Widget _buildStatusChip(MilestoneStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 11,
          color: _getStatusColor(status),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildClaimStatusChip(MilestoneClaimStatus claimStatus) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getClaimStatusColor(claimStatus).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getClaimIcon(claimStatus),
            size: 12,
            color: _getClaimStatusColor(claimStatus),
          ),
          const SizedBox(width: 4),
          Text(
            claimStatus.label,
            style: TextStyle(
              fontSize: 11,
              color: _getClaimStatusColor(claimStatus),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(MilestoneStatus status) {
    return status.color;
  }

  Color _getClaimStatusColor(MilestoneClaimStatus claimStatus) {
    return claimStatus.color;
  }

  IconData _getStatusIcon(MilestoneStatus status) {
    switch (status) {
      case MilestoneStatus.completed:
        return Icons.check_circle;
      case MilestoneStatus.inProgress:
        return Icons.pending;
      case MilestoneStatus.delayed:
        return Icons.warning;
      case MilestoneStatus.blocked:
        return Icons.block;
      case MilestoneStatus.notStarted:
        return Icons.radio_button_unchecked;
    }
  }

  IconData _getClaimIcon(MilestoneClaimStatus claimStatus) {
    switch (claimStatus) {
      case MilestoneClaimStatus.approved:
        return Icons.check_circle;
      case MilestoneClaimStatus.underReview:
        return Icons.hourglass_empty;
      case MilestoneClaimStatus.claimed:
        return Icons.receipt;
      case MilestoneClaimStatus.rejected:
        return Icons.cancel;
      case MilestoneClaimStatus.notClaimed:
        return Icons.radio_button_unchecked;
    }
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

  void _handleClaimMilestone(ProjectMilestone milestone) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Milestone Claim'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Milestone: ${milestone.name}'),
            const SizedBox(height: 8),
            Text('Amount: ₹${_formatAmount(milestone.targetAmount)}'),
            const SizedBox(height: 16),
            const Text(
              'You will be redirected to the claims submission page to upload required documents and submit your claim.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onClaimMilestone?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppDesignSystem.forestGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('Proceed to Claims'),
          ),
        ],
      ),
    );
  }

  void _handleViewClaimDetails(ProjectMilestone milestone) {
    // Navigate to claims section to view details
    widget.onClaimMilestone?.call();
  }
}