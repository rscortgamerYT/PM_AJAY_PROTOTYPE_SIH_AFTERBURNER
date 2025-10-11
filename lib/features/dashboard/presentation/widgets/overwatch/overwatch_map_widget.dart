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
    // Use actual Indian city coordinates for more realistic placement
    final indianCities = [
      const LatLng(28.6139, 77.2090),  // Delhi
      const LatLng(19.0760, 72.8777),  // Mumbai
      const LatLng(13.0827, 80.2707),  // Chennai
      const LatLng(22.5726, 88.3639),  // Kolkata
      const LatLng(12.9716, 77.5946),  // Bangalore
      const LatLng(17.3850, 78.4867),  // Hyderabad
      const LatLng(23.0225, 72.5714),  // Ahmedabad
      const LatLng(18.5204, 73.8567),  // Pune
      const LatLng(26.9124, 75.7873),  // Jaipur
      const LatLng(30.7333, 76.7794),  // Chandigarh
      const LatLng(21.1458, 79.0882),  // Nagpur
      const LatLng(15.2993, 74.1240),  // Goa
      const LatLng(11.0168, 76.9558),  // Coimbatore
      const LatLng(25.5941, 85.1376),  // Patna
      const LatLng(23.3441, 85.3096),  // Ranchi
      const LatLng(26.8467, 80.9462),  // Lucknow
      const LatLng(19.9975, 73.7898),  // Nashik
      const LatLng(21.1702, 72.8311),  // Surat
      const LatLng(20.2961, 85.8245),  // Bhubaneswar
      const LatLng(10.8505, 76.2711),  // Thrissur
    ];
    
    // Extract number from project ID for deterministic location
    final hashCode = projectId.hashCode.abs();
    final cityIndex = hashCode % indianCities.length;
    
    return indianCities[cityIndex];
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