import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../../../maps/widgets/interactive_map_widget.dart';
import '../../../../../core/models/project_model.dart';
import '../../../models/overwatch_project_model.dart';

/// Adapter widget that integrates InteractiveMapWidget with Overwatch data
class OverwatchMapWidget extends StatelessWidget {
  final List<OverwatchProject> overwatchProjects;
  final Function(String projectId)? onProjectSelected;

  const OverwatchMapWidget({
    super.key,
    required this.overwatchProjects,
    this.onProjectSelected,
  });

  /// Convert OverwatchProject to ProjectModel for map display
  List<ProjectModel> _convertToProjectModels() {
    return overwatchProjects.map((op) {
      // Generate a location based on project ID (mock location for demo)
      // In production, this would come from the actual project data
      final location = _generateLocationForProject(op.id);
      
      return ProjectModel(
        id: op.id,
        name: op.name,
        description: 'Allocated: ₹${_formatAmount(op.allocatedFunds)} | Utilized: ₹${_formatAmount(op.utilizedFunds)}',
        status: _convertStatus(op.status),
        component: _convertComponent(op.component),
        allocatedBudget: op.allocatedFunds / 100000, // Convert to lakhs
        utilizedBudget: op.utilizedFunds / 100000,
        completionPercentage: op.progress,
        beneficiariesCount: 0, // Not available in OverwatchProject
        location: location,
        startDate: op.startDate,
        createdAt: op.lastUpdate ?? DateTime.now(),
        updatedAt: op.lastUpdate ?? DateTime.now(),
      );
    }).toList();
  }

  /// Convert OverwatchProject status to ProjectModel status
  ProjectStatus _convertStatus(OverwatchProjectStatus status) {
    switch (status) {
      case OverwatchProjectStatus.active:
        return ProjectStatus.inProgress;
      case OverwatchProjectStatus.completed:
        return ProjectStatus.completed;
      case OverwatchProjectStatus.delayed:
        return ProjectStatus.onHold;
      case OverwatchProjectStatus.flagged:
        return ProjectStatus.cancelled;
    }
  }

  /// Convert ProjectComponentType to ProjectComponent
  ProjectComponent _convertComponent(ProjectComponentType component) {
    switch (component) {
      case ProjectComponentType.adarshGram:
        return ProjectComponent.adarshGram;
      case ProjectComponentType.gia:
        return ProjectComponent.gia;
      case ProjectComponentType.hostel:
        return ProjectComponent.hostel;
    }
  }

  /// Generate mock location based on project ID
  /// In production, replace with actual project coordinates from database
  LatLng _generateLocationForProject(String projectId) {
    // Extract number from project ID for deterministic location
    final hashCode = projectId.hashCode.abs();
    
    // Generate coordinates within India's bounds
    // Latitude: 8°N to 35°N, Longitude: 68°E to 97°E
    final lat = 8.0 + (hashCode % 27);
    final lng = 68.0 + ((hashCode ~/ 27) % 29);
    
    return LatLng(lat, lng);
  }

  String _formatAmount(double amount) {
    if (amount >= 10000000) {
      return '${(amount / 10000000).toStringAsFixed(2)}Cr';
    } else if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(2)}L';
    } else {
      return amount.toStringAsFixed(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectModels = _convertToProjectModels();
    
    if (projectModels.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No projects to display on map',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Projects with location data will appear here',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                  ),
            ),
          ],
        ),
      );
    }

    return InteractiveMapWidget(
      projects: projectModels,
      agencies: const [], // No agency data in Overwatch context
      initialCenter: const LatLng(20.5937, 78.9629), // India center
      initialZoom: 5.0,
      onProjectTap: (projectId) {
        onProjectSelected?.call(projectId);
      },
      showProjects: true,
      showAgencies: false,
    );
  }
}

/// Widget that displays map with filtering controls
class OverwatchMapWithFilters extends StatefulWidget {
  final List<OverwatchProject> projects;
  final Function(String projectId)? onProjectSelected;

  const OverwatchMapWithFilters({
    super.key,
    required this.projects,
    this.onProjectSelected,
  });

  @override
  State<OverwatchMapWithFilters> createState() => _OverwatchMapWithFiltersState();
}

class _OverwatchMapWithFiltersState extends State<OverwatchMapWithFilters> {
  OverwatchProjectStatus? _statusFilter;
  RiskLevel? _riskFilter;

  List<OverwatchProject> _getFilteredProjects() {
    var filtered = widget.projects;

    if (_statusFilter != null) {
      filtered = filtered.where((p) => p.status == _statusFilter).toList();
    }

    if (_riskFilter != null) {
      filtered = filtered.where((p) => p.riskLevel == _riskFilter).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final filteredProjects = _getFilteredProjects();

    return Column(
      children: [
        // Filter controls
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: IntrinsicHeight(
              child: Row(
                children: [
                  SizedBox(
                    width: 200,
                    child: _buildStatusFilter(),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 200,
                    child: _buildRiskFilter(),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _statusFilter = null;
                        _riskFilter = null;
                      });
                    },
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Clear'),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Map
        Expanded(
          child: OverwatchMapWidget(
            overwatchProjects: filteredProjects,
            onProjectSelected: widget.onProjectSelected,
          ),
        ),
        // Stats bar
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildStat(
                  'Total Projects',
                  '${filteredProjects.length}',
                  Icons.location_on,
                  Colors.blue,
                ),
                const SizedBox(width: 16),
                _buildStat(
                  'Active',
                  '${filteredProjects.where((p) => p.status == OverwatchProjectStatus.active).length}',
                  Icons.play_circle,
                  Colors.green,
                ),
                const SizedBox(width: 16),
                _buildStat(
                  'High Risk',
                  '${filteredProjects.where((p) => p.riskLevel == RiskLevel.high).length}',
                  Icons.warning,
                  Colors.red,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusFilter() {
    return DropdownButtonFormField<OverwatchProjectStatus>(
      initialValue: _statusFilter,
      decoration: const InputDecoration(
        labelText: 'Status',
        prefixIcon: Icon(Icons.filter_list),
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: [
        const DropdownMenuItem(value: null, child: Text('All Statuses')),
        ...OverwatchProjectStatus.values.map((status) {
          return DropdownMenuItem(
            value: status,
            child: Text(status.label.toUpperCase()),
          );
        }),
      ],
      onChanged: (value) {
        setState(() {
          _statusFilter = value;
        });
      },
    );
  }

  Widget _buildRiskFilter() {
    return DropdownButtonFormField<RiskLevel>(
      initialValue: _riskFilter,
      decoration: const InputDecoration(
        labelText: 'Risk Level',
        prefixIcon: Icon(Icons.speed),
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: [
        const DropdownMenuItem(value: null, child: Text('All Risk Levels')),
        ...RiskLevel.values.map((risk) {
          return DropdownMenuItem(
            value: risk,
            child: Text(risk.label.toUpperCase()),
          );
        }),
      ],
      onChanged: (value) {
        setState(() {
          _riskFilter = value;
        });
      },
    );
  }

  Widget _buildStat(String label, String value, IconData icon, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}