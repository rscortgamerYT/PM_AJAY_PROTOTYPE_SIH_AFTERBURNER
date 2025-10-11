import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Component Timeline Synchronizer Widget
/// 
/// Parallel Gantt charts for water/toilet components
/// with drag-to-adjust milestones and AI conflict detection.
class ComponentTimelineSynchronizerWidget extends StatefulWidget {
  final String stateId;
  
  const ComponentTimelineSynchronizerWidget({
    super.key,
    required this.stateId,
  });

  @override
  State<ComponentTimelineSynchronizerWidget> createState() => 
      _ComponentTimelineSynchronizerWidgetState();
}

class _ComponentTimelineSynchronizerWidgetState 
    extends State<ComponentTimelineSynchronizerWidget> {
  
  String _selectedComponent = 'all'; // 'all', 'water', 'toilet'
  bool _showConflicts = true;

  final List<ComponentTimeline> _mockTimelines = [
    ComponentTimeline(
      componentType: 'water',
      componentName: 'Water Supply - Phase 1',
      district: 'Mumbai',
      startDate: DateTime(2025, 1, 1),
      endDate: DateTime(2025, 6, 30),
      milestones: [
        Milestone(
          name: 'Site Survey',
          startDate: DateTime(2025, 1, 1),
          endDate: DateTime(2025, 1, 15),
          status: 'completed',
          progress: 100,
        ),
        Milestone(
          name: 'Design Approval',
          startDate: DateTime(2025, 1, 16),
          endDate: DateTime(2025, 2, 15),
          status: 'completed',
          progress: 100,
        ),
        Milestone(
          name: 'Procurement',
          startDate: DateTime(2025, 2, 16),
          endDate: DateTime(2025, 3, 31),
          status: 'in_progress',
          progress: 60,
        ),
        Milestone(
          name: 'Installation',
          startDate: DateTime(2025, 4, 1),
          endDate: DateTime(2025, 5, 31),
          status: 'pending',
          progress: 0,
        ),
        Milestone(
          name: 'Testing & QA',
          startDate: DateTime(2025, 6, 1),
          endDate: DateTime(2025, 6, 30),
          status: 'pending',
          progress: 0,
        ),
      ],
      conflicts: ['Resource overlap with Toilet Phase 1'],
    ),
    ComponentTimeline(
      componentType: 'toilet',
      componentName: 'Toilet Construction - Phase 1',
      district: 'Mumbai',
      startDate: DateTime(2025, 2, 1),
      endDate: DateTime(2025, 7, 31),
      milestones: [
        Milestone(
          name: 'Site Preparation',
          startDate: DateTime(2025, 2, 1),
          endDate: DateTime(2025, 2, 28),
          status: 'completed',
          progress: 100,
        ),
        Milestone(
          name: 'Foundation Work',
          startDate: DateTime(2025, 3, 1),
          endDate: DateTime(2025, 4, 15),
          status: 'in_progress',
          progress: 75,
        ),
        Milestone(
          name: 'Superstructure',
          startDate: DateTime(2025, 4, 16),
          endDate: DateTime(2025, 6, 15),
          status: 'pending',
          progress: 0,
        ),
        Milestone(
          name: 'Plumbing & Fixtures',
          startDate: DateTime(2025, 6, 16),
          endDate: DateTime(2025, 7, 15),
          status: 'pending',
          progress: 0,
        ),
        Milestone(
          name: 'Final Inspection',
          startDate: DateTime(2025, 7, 16),
          endDate: DateTime(2025, 7, 31),
          status: 'pending',
          progress: 0,
        ),
      ],
      conflicts: ['Resource overlap with Water Supply Phase 1'],
    ),
    ComponentTimeline(
      componentType: 'water',
      componentName: 'Water Supply - Phase 2',
      district: 'Pune',
      startDate: DateTime(2025, 3, 1),
      endDate: DateTime(2025, 8, 31),
      milestones: [
        Milestone(
          name: 'Site Survey',
          startDate: DateTime(2025, 3, 1),
          endDate: DateTime(2025, 3, 15),
          status: 'in_progress',
          progress: 40,
        ),
        Milestone(
          name: 'Design Approval',
          startDate: DateTime(2025, 3, 16),
          endDate: DateTime(2025, 4, 15),
          status: 'pending',
          progress: 0,
        ),
        Milestone(
          name: 'Procurement',
          startDate: DateTime(2025, 4, 16),
          endDate: DateTime(2025, 6, 15),
          status: 'pending',
          progress: 0,
        ),
        Milestone(
          name: 'Installation',
          startDate: DateTime(2025, 6, 16),
          endDate: DateTime(2025, 8, 15),
          status: 'pending',
          progress: 0,
        ),
        Milestone(
          name: 'Testing & QA',
          startDate: DateTime(2025, 8, 16),
          endDate: DateTime(2025, 8, 31),
          status: 'pending',
          progress: 0,
        ),
      ],
      conflicts: [],
    ),
  ];

  List<ComponentTimeline> get _filteredTimelines {
    if (_selectedComponent == 'all') {
      return _mockTimelines;
    }
    return _mockTimelines.where((t) => t.componentType == _selectedComponent).toList();
  }

  Color _getComponentColor(String type) {
    return type == 'water' ? AppTheme.secondaryBlue : AppTheme.accentTeal;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return AppTheme.successGreen;
      case 'in_progress':
        return AppTheme.warningOrange;
      case 'pending':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildFilters(),
        Expanded(
          child: _buildTimelineView(),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.stateOfficerColor, AppTheme.secondaryBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.timeline, size: 40, color: Colors.white),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Component Timeline Synchronizer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Parallel Gantt charts with AI conflict detection',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          _buildStats(),
        ],
      ),
    );
  }

  Widget _buildStats() {
    final totalComponents = _mockTimelines.length;
    final activeComponents = _mockTimelines.where(
      (t) => t.milestones.any((m) => m.status == 'in_progress')
    ).length;
    final conflictsCount = _mockTimelines.where(
      (t) => t.conflicts.isNotEmpty
    ).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildStatItem('Components', totalComponents.toString()),
          const SizedBox(width: 20),
          _buildStatItem('Active', activeComponents.toString()),
          const SizedBox(width: 20),
          _buildStatItem('Conflicts', conflictsCount.toString(), 
            color: conflictsCount > 0 ? AppTheme.errorRed : Colors.white),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, {Color? color}) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color ?? Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                value: 'all',
                label: Text('All Components'),
                icon: Icon(Icons.view_list),
              ),
              ButtonSegment(
                value: 'water',
                label: Text('Water Supply'),
                icon: Icon(Icons.water_drop),
              ),
              ButtonSegment(
                value: 'toilet',
                label: Text('Toilets'),
                icon: Icon(Icons.wc),
              ),
            ],
            selected: {_selectedComponent},
            onSelectionChanged: (Set<String> newSelection) {
              setState(() => _selectedComponent = newSelection.first);
            },
          ),
          const Spacer(),
          FilterChip(
            label: const Text('Show Conflicts'),
            selected: _showConflicts,
            onSelected: (value) {
              setState(() => _showConflicts = value);
            },
            avatar: Icon(
              _showConflicts ? Icons.warning : Icons.warning_outlined,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredTimelines.length,
      itemBuilder: (context, index) {
        return _buildTimelineCard(_filteredTimelines[index]);
      },
    );
  }

  Widget _buildTimelineCard(ComponentTimeline timeline) {
    final componentColor = _getComponentColor(timeline.componentType);
    final hasConflicts = timeline.conflicts.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: componentColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  timeline.componentType == 'water' ? Icons.water_drop : Icons.wc,
                  color: componentColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        timeline.componentName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${timeline.district} • ${_formatDate(timeline.startDate)} - ${_formatDate(timeline.endDate)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (hasConflicts && _showConflicts)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.errorRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.warning, size: 16, color: AppTheme.errorRed),
                        SizedBox(width: 4),
                        Text(
                          'Conflicts',
                          style: TextStyle(
                            color: AppTheme.errorRed,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          
          // Milestones
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: timeline.milestones.map((milestone) {
                return _buildMilestoneRow(milestone, componentColor);
              }).toList(),
            ),
          ),
          
          // Conflicts
          if (hasConflicts && _showConflicts)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.errorRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.errorRed.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.warning, size: 20, color: AppTheme.errorRed),
                      SizedBox(width: 8),
                      Text(
                        'Detected Conflicts',
                        style: TextStyle(
                          color: AppTheme.errorRed,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...timeline.conflicts.map((conflict) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 28, top: 4),
                      child: Text(
                        '• $conflict',
                        style: const TextStyle(
                          color: AppTheme.errorRed,
                          fontSize: 13,
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.auto_fix_high, size: 16),
                      label: const Text('Auto-Resolve'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.errorRed,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMilestoneRow(Milestone milestone, Color componentColor) {
    final statusColor = _getStatusColor(milestone.status);
    final duration = milestone.endDate.difference(milestone.startDate).inDays;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Status indicator
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              
              // Milestone name
              Expanded(
                flex: 2,
                child: Text(
                  milestone.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              
              // Date range
              Expanded(
                flex: 3,
                child: Text(
                  '${_formatDate(milestone.startDate)} - ${_formatDate(milestone.endDate)} ($duration days)',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              
              // Progress
              SizedBox(
                width: 60,
                child: Text(
                  '${milestone.progress}%',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Progress bar
          Row(
            children: [
              const SizedBox(width: 24),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: milestone.progress / 100,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation(componentColor),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Component Timeline Model
class ComponentTimeline {
  final String componentType; // 'water' or 'toilet'
  final String componentName;
  final String district;
  final DateTime startDate;
  final DateTime endDate;
  final List<Milestone> milestones;
  final List<String> conflicts;

  ComponentTimeline({
    required this.componentType,
    required this.componentName,
    required this.district,
    required this.startDate,
    required this.endDate,
    required this.milestones,
    required this.conflicts,
  });
}

/// Milestone Model
class Milestone {
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final String status; // 'completed', 'in_progress', 'pending'
  final int progress;

  Milestone({
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.progress,
  });
}