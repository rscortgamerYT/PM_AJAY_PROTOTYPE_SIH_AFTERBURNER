import 'package:flutter/material.dart';
import '../../../models/overwatch_project_model.dart';
import '../../../../../core/theme/app_design_system.dart';

/// Active Projects Timeline Widget - Calendar-style view of projects organized by timeline
class ActiveProjectsTimelineWidget extends StatefulWidget {
  final List<OverwatchProject> projects;
  final Function(OverwatchProject)? onProjectSelect;

  const ActiveProjectsTimelineWidget({
    super.key,
    required this.projects,
    this.onProjectSelect,
  });

  @override
  State<ActiveProjectsTimelineWidget> createState() =>
      _ActiveProjectsTimelineWidgetState();
}

class _ActiveProjectsTimelineWidgetState
    extends State<ActiveProjectsTimelineWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final DateTime _selectedMonth = DateTime.now();
  String _filterStatus = 'All';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<OverwatchProject> get _filteredProjects {
    if (_filterStatus == 'All') return widget.projects;
    return widget.projects
        .where((p) => p.status.label.toLowerCase() == _filterStatus.toLowerCase())
        .toList();
  }

  Map<String, List<OverwatchProject>> _groupProjectsByWeek() {
    final Map<String, List<OverwatchProject>> grouped = {};
    
    for (final project in _filteredProjects) {
      // Parse timeline to get week info
      final weekKey = _getWeekKeyFromTimeline(project.timeline);
      if (!grouped.containsKey(weekKey)) {
        grouped[weekKey] = [];
      }
      grouped[weekKey]!.add(project);
    }
    
    return grouped;
  }

  String _getWeekKeyFromTimeline(String? timeline) {
    if (timeline == null) return 'Unscheduled';
    
    // Extract date info from timeline strings like "Jan 2024 - Mar 2024"
    final parts = timeline.split(' - ');
    if (parts.isEmpty) return 'Unscheduled';
    
    return parts[0]; // Use start date as key
  }

  @override
  Widget build(BuildContext context) {
    final groupedProjects = _groupProjectsByWeek();
    
    return FadeTransition(
      opacity: _animationController,
      child: Container(
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
            _buildFilterChips(),
            const SizedBox(height: 24),
            _buildTimelineView(groupedProjects),
          ],
        ),
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
            const Text(
              'Active Projects Timeline',
              style: AppDesignSystem.headlineMedium,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppDesignSystem.vibrantTeal,
                ),
                const SizedBox(width: 6),
                Text(
                  '${_filteredProjects.length} projects',
                  style: AppDesignSystem.bodySmall.copyWith(
                    color: AppDesignSystem.vibrantTeal,
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppDesignSystem.neutral100,
                borderRadius: AppDesignSystem.radiusSmall,
                border: Border.all(
                  color: AppDesignSystem.neutral300,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.view_timeline,
                    size: 16,
                    color: AppDesignSystem.neutral600,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Timeline View',
                    style: AppDesignSystem.labelSmall.copyWith(
                      color: AppDesignSystem.neutral600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    final statuses = ['All', 'On-Track', 'At-Risk', 'Delayed', 'Completed'];
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: statuses.map((status) {
          final isSelected = _filterStatus == status;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(status),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _filterStatus = status;
                });
              },
              backgroundColor: AppDesignSystem.neutral100,
              selectedColor: AppDesignSystem.vibrantTeal.withOpacity(0.1),
              checkmarkColor: AppDesignSystem.vibrantTeal,
              labelStyle: AppDesignSystem.labelSmall.copyWith(
                color: isSelected
                    ? AppDesignSystem.vibrantTeal
                    : AppDesignSystem.neutral600,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected
                    ? AppDesignSystem.vibrantTeal
                    : AppDesignSystem.neutral300,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTimelineView(Map<String, List<OverwatchProject>> groupedProjects) {
    if (groupedProjects.isEmpty) {
      return _buildEmptyState();
    }

    // Flatten all projects into a single list
    final allProjects = groupedProjects.values.expand((list) => list).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTimelineBar(allProjects),
        const SizedBox(height: 16),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: allProjects.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(right: index < allProjects.length - 1 ? 16 : 0),
                child: _buildProjectCard(allProjects[index]),
              );
            },
          ),
        ),
      ],
    );
  }


  Widget _buildTimelineBar(List<OverwatchProject> projects) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: AppDesignSystem.neutral100,
        borderRadius: AppDesignSystem.radiusSmall,
        border: Border.all(
          color: AppDesignSystem.neutral300,
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: projects.length * 320.0,
          child: Stack(
            children: [
              // Background grid lines
              Positioned.fill(
                child: CustomPaint(
                  painter: _TimelineGridPainter(),
                ),
              ),
              // Project duration bars
              ...projects.asMap().entries.map((entry) {
                final index = entry.key;
                final project = entry.value;
                return Positioned(
                  left: index * 320.0 + 10,
                  top: 8,
                  child: _buildProjectTimelineBar(project, 300),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProjectTimelineBar(OverwatchProject project, double width) {
    return Container(
      width: width,
      height: 44,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            project.status.color.withOpacity(0.7),
            project.status.color,
          ],
        ),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: project.status.color.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Progress indicator overlay
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: width * (project.progress / 100),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          // Project name label
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  project.name,
                  style: AppDesignSystem.labelSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: const Offset(1, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          // Progress percentage badge
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${project.progress.toStringAsFixed(0)}%',
                style: AppDesignSystem.labelSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard(OverwatchProject project) {
    return GestureDetector(
      onTap: () => widget.onProjectSelect?.call(project),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 300),
        builder: (context, value, child) {
          return Transform.scale(
            scale: 0.9 + (0.1 * value),
            child: Opacity(
              opacity: value,
              child: child,
            ),
          );
        },
        child: Container(
          width: 320,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: AppDesignSystem.radiusMedium,
            border: Border.all(
              color: AppDesignSystem.neutral300,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatusIndicator(project.status),
                  _buildRiskIndicator(project.riskLevel),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 18,
                    color: AppDesignSystem.neutral600,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.name,
                          style: AppDesignSystem.titleSmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          project.location ?? project.state,
                          style: AppDesignSystem.bodySmall.copyWith(
                            color: AppDesignSystem.neutral600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 13,
                    color: AppDesignSystem.neutral600,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      project.timeline ?? 'No timeline',
                      style: AppDesignSystem.labelSmall.copyWith(
                        color: AppDesignSystem.neutral600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.business,
                    size: 13,
                    color: AppDesignSystem.neutral600,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      project.responsiblePerson?.name ?? 'No agency assigned',
                      style: AppDesignSystem.labelSmall.copyWith(
                        color: AppDesignSystem.neutral600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress',
                        style: AppDesignSystem.labelSmall.copyWith(
                          color: AppDesignSystem.neutral600,
                        ),
                      ),
                      Text(
                        '${project.progress.toStringAsFixed(0)}%',
                        style: AppDesignSystem.labelSmall.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: project.progress / 100,
                      minHeight: 6,
                      backgroundColor: AppDesignSystem.neutral200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        project.progress > 75
                            ? AppDesignSystem.success
                            : project.progress > 50
                                ? AppDesignSystem.info
                                : project.progress > 25
                                    ? AppDesignSystem.warning
                                    : AppDesignSystem.error,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Allocated',
                        style: AppDesignSystem.labelSmall.copyWith(
                          color: AppDesignSystem.neutral600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '₹${(project.allocatedFunds / 100000).toStringAsFixed(1)}L',
                        style: AppDesignSystem.labelMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Utilized',
                        style: AppDesignSystem.labelSmall.copyWith(
                          color: AppDesignSystem.neutral600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '₹${(project.utilizedFunds / 100000).toStringAsFixed(1)}L',
                        style: AppDesignSystem.labelMedium.copyWith(
                          color: AppDesignSystem.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (project.lastUpdate != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: const BoxDecoration(
                    color: AppDesignSystem.neutral100,
                    borderRadius: AppDesignSystem.radiusSmall,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.update,
                        size: 12,
                        color: AppDesignSystem.neutral500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Updated ${_formatTimeAgo(project.lastUpdate!)}',
                        style: AppDesignSystem.labelSmall.copyWith(
                          color: AppDesignSystem.neutral500,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(OverwatchProjectStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: AppDesignSystem.labelSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskIndicator(RiskLevel riskLevel) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return Container(
          width: 4,
          height: index == 0 ? 8 : index == 1 ? 12 : 16,
          margin: const EdgeInsets.only(right: 2),
          decoration: BoxDecoration(
            color: index < riskLevel.barCount
                ? riskLevel.color
                : AppDesignSystem.neutral300,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.event_busy,
            size: 64,
            color: AppDesignSystem.neutral400,
          ),
          const SizedBox(height: 16),
          Text(
            'No projects found',
            style: AppDesignSystem.titleMedium.copyWith(
              color: AppDesignSystem.neutral600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: AppDesignSystem.bodySmall.copyWith(
              color: AppDesignSystem.neutral500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }
}
/// Custom painter for timeline grid background
class _TimelineGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppDesignSystem.neutral300
      ..strokeWidth = 1;

    // Draw vertical grid lines every 320 pixels (matching card width)
    for (double x = 320; x < size.width; x += 320) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}