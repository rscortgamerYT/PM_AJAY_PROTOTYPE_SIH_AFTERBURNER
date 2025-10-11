import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/models/project_model.dart';
import '../../../core/models/agency_model.dart';
import '../../../core/theme/app_theme.dart';

class InteractiveMapWidget extends StatefulWidget {
  final List<ProjectModel> projects;
  final List<AgencyModel> agencies;
  final LatLng initialCenter;
  final double initialZoom;
  final Function(String projectId)? onProjectTap;
  final Function(String agencyId)? onAgencyTap;
  final bool showProjects;
  final bool showAgencies;
  final List<ProjectStatus>? statusFilter;
  final List<ProjectComponent>? componentFilter;

  const InteractiveMapWidget({
    super.key,
    required this.projects,
    required this.agencies,
    this.initialCenter = const LatLng(20.5937, 78.9629), // India center
    this.initialZoom = 5.0,
    this.onProjectTap,
    this.onAgencyTap,
    this.showProjects = true,
    this.showAgencies = true,
    this.statusFilter,
    this.componentFilter,
  });

  @override
  State<InteractiveMapWidget> createState() => _InteractiveMapWidgetState();
}

class _InteractiveMapWidgetState extends State<InteractiveMapWidget> {
  final MapController _mapController = MapController();
  ProjectModel? _selectedProject;
  AgencyModel? _selectedAgency;

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Color _getStatusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.completed:
        return AppTheme.successGreen;
      case ProjectStatus.inProgress:
        return AppTheme.secondaryBlue;
      case ProjectStatus.onHold:
        return AppTheme.warningOrange;
      case ProjectStatus.planning:
        return Colors.purple;
      case ProjectStatus.review:
        return Colors.amber;
      case ProjectStatus.cancelled:
        return AppTheme.errorRed;
    }
  }

  IconData _getStatusIcon(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.completed:
        return Icons.check_circle;
      case ProjectStatus.inProgress:
        return Icons.access_time;
      case ProjectStatus.onHold:
        return Icons.pause_circle;
      case ProjectStatus.planning:
        return Icons.pending;
      case ProjectStatus.review:
        return Icons.rate_review;
      case ProjectStatus.cancelled:
        return Icons.cancel;
    }
  }

  List<ProjectModel> _getFilteredProjects() {
    var filtered = widget.projects;
    
    if (widget.statusFilter != null && widget.statusFilter!.isNotEmpty) {
      filtered = filtered.where((p) => widget.statusFilter!.contains(p.status)).toList();
    }
    
    if (widget.componentFilter != null && widget.componentFilter!.isNotEmpty) {
      filtered = filtered.where((p) => widget.componentFilter!.contains(p.component)).toList();
    }
    
    return filtered;
  }

  List<Marker> _buildProjectMarkers() {
    if (!widget.showProjects) return [];
    
    final filteredProjects = _getFilteredProjects();
    
    return filteredProjects
        .where((project) => project.location != null)
        .map((project) {
      final isSelected = _selectedProject?.id == project.id;
      final color = _getStatusColor(project.status);
      
      return Marker(
        point: project.location!,
        width: isSelected ? 50 : 36,
        height: isSelected ? 50 : 36,
        alignment: Alignment.center,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _selectedProject = project;
              _selectedAgency = null;
            });
            widget.onProjectTap?.call(project.id);
          },
          child: Container(
            width: isSelected ? 50 : 36,
            height: isSelected ? 50 : 36,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: isSelected ? 2.5 : 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: isSelected ? 8 : 5,
                  spreadRadius: isSelected ? 2 : 1,
                ),
              ],
            ),
            child: Center(
              child: Icon(
                _getStatusIcon(project.status),
                color: Colors.white,
                size: isSelected ? 24 : 18,
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  List<Marker> _buildAgencyMarkers() {
    if (!widget.showAgencies) return [];
    
    return widget.agencies
        .map((agency) {
      final isSelected = _selectedAgency?.id == agency.id;
      
      return Marker(
        point: agency.location,
        width: isSelected ? 44 : 32,
        height: isSelected ? 44 : 32,
        alignment: Alignment.center,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _selectedAgency = agency;
              _selectedProject = null;
            });
            widget.onAgencyTap?.call(agency.id);
          },
          child: Container(
            width: isSelected ? 44 : 32,
            height: isSelected ? 44 : 32,
            decoration: BoxDecoration(
              color: AppTheme.accentTeal,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: isSelected ? 2.5 : 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accentTeal.withOpacity(0.4),
                  blurRadius: isSelected ? 7 : 4,
                  spreadRadius: isSelected ? 1.5 : 0.5,
                ),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.business,
                color: Colors.white,
                size: isSelected ? 22 : 16,
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  List<Polygon> _buildProjectAreas() {
    return _getFilteredProjects()
        .where((project) => project.projectArea != null && project.projectArea!.isNotEmpty)
        .map((project) {
      return Polygon(
        points: project.projectArea!,
        color: _getStatusColor(project.status).withOpacity(0.2),
        borderColor: _getStatusColor(project.status),
        borderStrokeWidth: 2,
        isFilled: true,
      );
    }).toList();
  }

  List<Polygon> _buildAgencyCoverageAreas() {
    if (!widget.showAgencies) return [];
    
    return widget.agencies
        .where((agency) => agency.coverageArea != null && agency.coverageArea!.isNotEmpty)
        .map((agency) {
      return Polygon(
        points: agency.coverageArea!,
        color: AppTheme.accentTeal.withOpacity(0.1),
        borderColor: AppTheme.accentTeal,
        borderStrokeWidth: 1.5,
        isDotted: true,
        isFilled: true,
      );
    }).toList();
  }

  Widget _buildInfoCard() {
    if (_selectedProject != null) {
      return _buildProjectInfoCard(_selectedProject!);
    } else if (_selectedAgency != null) {
      return _buildAgencyInfoCard(_selectedAgency!);
    }
    return const SizedBox.shrink();
  }

  Widget _buildProjectInfoCard(ProjectModel project) {
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: Card(
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getStatusColor(project.status),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getStatusIcon(project.status),
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          project.status.value.toUpperCase(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: _getStatusColor(project.status),
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => _selectedProject = null),
                  ),
                ],
              ),
              if (project.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  project.description!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      'Progress',
                      '${project.completionPercentage.toStringAsFixed(1)}%',
                      Icons.trending_up,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      'Budget',
                      '₹${(project.allocatedBudget ?? 0).toStringAsFixed(2)}L',
                      Icons.account_balance_wallet,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      'Beneficiaries',
                      '${project.beneficiariesCount}',
                      Icons.people,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAgencyInfoCard(AgencyModel agency) {
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: Card(
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.accentTeal,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.business,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          agency.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          agency.type.value.toUpperCase(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.accentTeal,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => _selectedAgency = null),
                  ),
                ],
              ),
              if (agency.address != null) ...[
                const SizedBox(height: 8),
                Text(
                  agency.address!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      'Capacity',
                      '${(agency.capacityScore * 100).toStringAsFixed(0)}%',
                      Icons.speed,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      'Performance',
                      '${(agency.performanceRating * 100).toStringAsFixed(0)}%',
                      Icons.star,
                    ),
                  ),
                  if (agency.phone != null)
                    Expanded(
                      child: _buildInfoItem(
                        'Contact',
                        agency.phone!,
                        Icons.phone,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryIndigo),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: widget.initialCenter,
            initialZoom: widget.initialZoom,
            minZoom: 3.0,
            maxZoom: 18.0,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.pmajay.platform',
            ),
            PolygonLayer(
              polygons: [
                ..._buildAgencyCoverageAreas(),
                ..._buildProjectAreas(),
              ],
            ),
            MarkerLayer(
              markers: [
                ..._buildAgencyMarkers(),
                ..._buildProjectMarkers(),
              ],
            ),
          ],
        ),
        _buildInfoCard(),
      ],
    );
  }
}