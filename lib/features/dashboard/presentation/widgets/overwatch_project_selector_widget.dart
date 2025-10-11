import 'package:flutter/material.dart';
import '../../models/overwatch_project_model.dart';
import '../../../../core/theme/app_design_system.dart';
import '../../../../core/utils/responsive_layout.dart';

class OverwatchProjectSelectorWidget extends StatefulWidget {
  final List<OverwatchProject> projects;
  final Function(OverwatchProject) onProjectSelect;
  final OverwatchProject? selectedProject;

  const OverwatchProjectSelectorWidget({
    super.key,
    required this.projects,
    required this.onProjectSelect,
    this.selectedProject,
  });

  @override
  State<OverwatchProjectSelectorWidget> createState() =>
      _OverwatchProjectSelectorWidgetState();
}

class _OverwatchProjectSelectorWidgetState
    extends State<OverwatchProjectSelectorWidget> {
  String _searchTerm = '';
  final ProjectFilterCriteria _filterCriteria = ProjectFilterCriteria();
  bool _showFilters = false;

  List<OverwatchProject> get _filteredProjects {
    return widget.projects.where((project) {
      final criteria = _filterCriteria.copyWith(searchTerm: _searchTerm);
      return criteria.matches(project);
    }).toList();
  }

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
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchAndFilters(),
          const SizedBox(height: 24),
          _buildProjectGrid(),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Search projects by name, agency, or location...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: AppDesignSystem.radiusMedium,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchTerm = value;
              });
            },
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed: () {
            setState(() {
              _showFilters = !_showFilters;
            });
          },
          icon: const Icon(Icons.filter_list, size: 18),
          label: const Text('Filters'),
        ),
      ],
    );
  }

  Widget _buildProjectGrid() {
    final projects = _filteredProjects;

    if (projects.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            children: [
              const Icon(
                Icons.search_off,
                size: 64,
                color: AppDesignSystem.neutral400,
              ),
              const SizedBox(height: 16),
              Text(
                'No projects found',
                style: AppDesignSystem.headlineSmall.copyWith(
                  color: AppDesignSystem.neutral600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try adjusting your search or filters',
                style: AppDesignSystem.bodyMedium.copyWith(
                  color: AppDesignSystem.neutral500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveLayout.valueByDevice(
          context: context,
          mobile: 1,
          mobileWide: 2,
          tablet: 3,
          desktop: 3,
        ),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        return _buildProjectCard(projects[index]);
      },
    );
  }

  Widget _buildProjectCard(OverwatchProject project) {
    final isSelected = widget.selectedProject?.id == project.id;

    return GestureDetector(
      onTap: () => widget.onProjectSelect(project),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: AppDesignSystem.radiusMedium,
          border: Border.all(
            color: isSelected
                ? AppDesignSystem.vibrantTeal
                : AppDesignSystem.neutral300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppDesignSystem.vibrantTeal.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    project.name,
                    style: AppDesignSystem.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                _buildStatusBadge(project.status),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: AppDesignSystem.neutral600,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    project.state,
                    style: AppDesignSystem.bodySmall.copyWith(
                      color: AppDesignSystem.neutral600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Utilized:',
                  style: AppDesignSystem.labelSmall.copyWith(
                    color: AppDesignSystem.neutral600,
                  ),
                ),
                Text(
                  '₹${(project.utilizedFunds / 100000).toStringAsFixed(1)}L / ₹${(project.totalFunds / 100000).toStringAsFixed(1)}L',
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
                value: project.utilizationPercentage / 100,
                minHeight: 8,
                backgroundColor: AppDesignSystem.neutral200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  project.utilizationPercentage > 80
                      ? AppDesignSystem.success
                      : project.utilizationPercentage > 50
                          ? AppDesignSystem.info
                          : AppDesignSystem.warning,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Risk Score:',
                  style: AppDesignSystem.labelSmall.copyWith(
                    color: AppDesignSystem.neutral600,
                  ),
                ),
                Row(
                  children: [
                    _buildRiskIndicator(project.riskLevel),
                    const SizedBox(width: 8),
                    Text(
                      '${project.riskScore.toStringAsFixed(1)}/10',
                      style: AppDesignSystem.labelSmall.copyWith(
                        color: project.riskLevel.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(OverwatchProjectStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.1),
        borderRadius: AppDesignSystem.radiusSmall,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            status.icon,
            size: 12,
            color: status.color,
          ),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: AppDesignSystem.labelSmall.copyWith(
              color: status.color,
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
}

extension on ProjectFilterCriteria {
  ProjectFilterCriteria copyWith({
    String? searchTerm,
    List<OverwatchProjectStatus>? statuses,
    List<ProjectComponentType>? components,
    List<String>? states,
    RiskLevel? minRiskLevel,
    double? minProgress,
    double? maxProgress,
  }) {
    return ProjectFilterCriteria(
      searchTerm: searchTerm ?? this.searchTerm,
      statuses: statuses ?? this.statuses,
      components: components ?? this.components,
      states: states ?? this.states,
      minRiskLevel: minRiskLevel ?? this.minRiskLevel,
      minProgress: minProgress ?? this.minProgress,
      maxProgress: maxProgress ?? this.maxProgress,
    );
  }
}