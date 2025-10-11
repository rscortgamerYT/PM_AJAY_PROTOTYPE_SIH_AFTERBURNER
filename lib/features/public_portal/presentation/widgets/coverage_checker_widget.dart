import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_design_system.dart';

// Mock project location data
class ProjectLocation {
  final String id;
  final String name;
  final String state;
  final String district;
  final double latitude;
  final double longitude;
  final String projectType;
  final String status;
  final int beneficiaries;
  final double budget;

  ProjectLocation({
    required this.id,
    required this.name,
    required this.state,
    required this.district,
    required this.latitude,
    required this.longitude,
    required this.projectType,
    required this.status,
    required this.beneficiaries,
    required this.budget,
  });
}

class CoverageCheckerWidget extends ConsumerStatefulWidget {
  const CoverageCheckerWidget({super.key});

  @override
  ConsumerState<CoverageCheckerWidget> createState() => _CoverageCheckerWidgetState();
}

class _CoverageCheckerWidgetState extends ConsumerState<CoverageCheckerWidget> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  ProjectLocation? _selectedProject;
  String _selectedState = 'All States';
  String _selectedProjectType = 'All Types';
  double _mapZoom = 5.0;
  Offset _mapCenter = const Offset(0, 0);
  bool _isDragging = false;
  Offset _dragStart = Offset.zero;

  final List<String> _states = [
    'All States',
    'Uttar Pradesh',
    'Bihar',
    'Madhya Pradesh',
    'Rajasthan',
    'Maharashtra',
    'West Bengal',
    'Tamil Nadu',
    'Karnataka',
  ];

  final List<String> _projectTypes = [
    'All Types',
    'Infrastructure',
    'Education',
    'Healthcare',
    'Water Supply',
    'Sanitation',
    'Roads',
  ];

  // Mock project data
  final List<ProjectLocation> _allProjects = [
    ProjectLocation(
      id: 'UP001',
      name: 'Rural Road Development',
      state: 'Uttar Pradesh',
      district: 'Varanasi',
      latitude: 25.3176,
      longitude: 82.9739,
      projectType: 'Infrastructure',
      status: 'Completed',
      beneficiaries: 15000,
      budget: 5.5,
    ),
    ProjectLocation(
      id: 'BH001',
      name: 'Primary Health Center',
      state: 'Bihar',
      district: 'Patna',
      latitude: 25.5941,
      longitude: 85.1376,
      projectType: 'Healthcare',
      status: 'In Progress',
      beneficiaries: 25000,
      budget: 8.2,
    ),
    ProjectLocation(
      id: 'MP001',
      name: 'School Building Construction',
      state: 'Madhya Pradesh',
      district: 'Bhopal',
      latitude: 23.2599,
      longitude: 77.4126,
      projectType: 'Education',
      status: 'Completed',
      beneficiaries: 5000,
      budget: 3.5,
    ),
    ProjectLocation(
      id: 'RJ001',
      name: 'Water Supply Network',
      state: 'Rajasthan',
      district: 'Jaipur',
      latitude: 26.9124,
      longitude: 75.7873,
      projectType: 'Water Supply',
      status: 'In Progress',
      beneficiaries: 30000,
      budget: 12.0,
    ),
    ProjectLocation(
      id: 'MH001',
      name: 'Sanitation Facilities',
      state: 'Maharashtra',
      district: 'Pune',
      latitude: 18.5204,
      longitude: 73.8567,
      projectType: 'Sanitation',
      status: 'Completed',
      beneficiaries: 20000,
      budget: 6.5,
    ),
    ProjectLocation(
      id: 'WB001',
      name: 'Community Center',
      state: 'West Bengal',
      district: 'Kolkata',
      latitude: 22.5726,
      longitude: 88.3639,
      projectType: 'Infrastructure',
      status: 'Planning',
      beneficiaries: 10000,
      budget: 4.0,
    ),
    ProjectLocation(
      id: 'TN001',
      name: 'Rural Electrification',
      state: 'Tamil Nadu',
      district: 'Chennai',
      latitude: 13.0827,
      longitude: 80.2707,
      projectType: 'Infrastructure',
      status: 'In Progress',
      beneficiaries: 18000,
      budget: 7.8,
    ),
    ProjectLocation(
      id: 'KA001',
      name: 'Agricultural Training Center',
      state: 'Karnataka',
      district: 'Bangalore',
      latitude: 12.9716,
      longitude: 77.5946,
      projectType: 'Education',
      status: 'Completed',
      beneficiaries: 8000,
      budget: 4.2,
    ),
  ];

  List<ProjectLocation> get _filteredProjects {
    return _allProjects.where((project) {
      bool stateMatch = _selectedState == 'All States' || project.state == _selectedState;
      bool typeMatch = _selectedProjectType == 'All Types' || project.projectType == _selectedProjectType;
      bool searchMatch = _searchController.text.isEmpty ||
          project.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          project.district.toLowerCase().contains(_searchController.text.toLowerCase());
      
      return stateMatch && typeMatch && searchMatch;
    }).toList();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return AppDesignSystem.success;
      case 'In Progress':
        return AppDesignSystem.skyBlue;
      case 'Planning':
        return AppDesignSystem.sunsetOrange;
      default:
        return AppDesignSystem.neutral400;
    }
  }

  IconData _getProjectTypeIcon(String type) {
    switch (type) {
      case 'Infrastructure':
        return Icons.construction;
      case 'Education':
        return Icons.school;
      case 'Healthcare':
        return Icons.local_hospital;
      case 'Water Supply':
        return Icons.water_drop;
      case 'Sanitation':
        return Icons.cleaning_services;
      case 'Roads':
        return Icons.route;
      default:
        return Icons.location_on;
    }
  }

  Widget _buildMap() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onPanStart: (details) {
            _isDragging = true;
            _dragStart = details.globalPosition;
          },
          onPanUpdate: (details) {
            if (_isDragging) {
              setState(() {
                _mapCenter = Offset(
                  _mapCenter.dx + (details.globalPosition.dx - _dragStart.dx) / _mapZoom,
                  _mapCenter.dy + (details.globalPosition.dy - _dragStart.dy) / _mapZoom,
                );
                _dragStart = details.globalPosition;
              });
            }
          },
          onPanEnd: (details) {
            _isDragging = false;
          },
          child: Stack(
            children: [
              // Map background
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppDesignSystem.skyBlue.withOpacity(0.1),
                      AppDesignSystem.vibrantTeal.withOpacity(0.1),
                    ],
                  ),
                ),
                child: CustomPaint(
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                  painter: MapGridPainter(),
                ),
              ),
              
              // Project markers
              ..._filteredProjects.map((project) {
                // Convert lat/lng to screen coordinates (simplified)
                double x = ((project.longitude + 180) / 360) * constraints.maxWidth;
                double y = ((90 - project.latitude) / 180) * constraints.maxHeight;
                
                // Apply zoom and pan
                x = (x - constraints.maxWidth / 2) * _mapZoom + constraints.maxWidth / 2 + _mapCenter.dx;
                y = (y - constraints.maxHeight / 2) * _mapZoom + constraints.maxHeight / 2 + _mapCenter.dy;
                
                return Positioned(
                  left: x - 20,
                  top: y - 40,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedProject = project;
                      });
                    },
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Column(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: _getStatusColor(project.status),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: _getStatusColor(project.status).withOpacity(0.4),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                ),
                                child: Icon(
                                  _getProjectTypeIcon(project.projectType),
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              if (_selectedProject?.id == project.id)
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    project.district,
                                    style: AppDesignSystem.labelSmall.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                );
              }),
              
              // Map controls
              Positioned(
                right: 16,
                bottom: 16,
                child: Column(
                  children: [
                    FloatingActionButton.small(
                      onPressed: () {
                        setState(() {
                          _mapZoom = (_mapZoom * 1.2).clamp(1.0, 10.0);
                        });
                      },
                      backgroundColor: Colors.white,
                      child: const Icon(Icons.add, color: AppDesignSystem.deepIndigo),
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton.small(
                      onPressed: () {
                        setState(() {
                          _mapZoom = (_mapZoom / 1.2).clamp(1.0, 10.0);
                        });
                      },
                      backgroundColor: Colors.white,
                      child: const Icon(Icons.remove, color: AppDesignSystem.deepIndigo),
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton.small(
                      onPressed: () {
                        setState(() {
                          _mapZoom = 5.0;
                          _mapCenter = const Offset(0, 0);
                        });
                      },
                      backgroundColor: Colors.white,
                      child: const Icon(Icons.my_location, color: AppDesignSystem.deepIndigo),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProjectDetails() {
    if (_selectedProject == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.touch_app,
                size: 64,
                color: AppDesignSystem.neutral300,
              ),
              const SizedBox(height: 16),
              Text(
                'Tap on a marker to view project details',
                style: AppDesignSystem.bodyLarge.copyWith(
                  color: AppDesignSystem.neutral600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getStatusColor(_selectedProject!.status),
                  _getStatusColor(_selectedProject!.status).withOpacity(0.7),
                ],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getProjectTypeIcon(_selectedProject!.projectType),
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedProject!.name,
                        style: AppDesignSystem.titleLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_selectedProject!.district}, ${_selectedProject!.state}',
                        style: AppDesignSystem.bodyMedium.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _selectedProject = null;
                    });
                  },
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Project ID', _selectedProject!.id),
                  const Divider(height: 24),
                  _buildDetailRow('Project Type', _selectedProject!.projectType),
                  const Divider(height: 24),
                  _buildDetailRow('Status', _selectedProject!.status, 
                    statusColor: _getStatusColor(_selectedProject!.status)),
                  const Divider(height: 24),
                  _buildDetailRow('Budget', '₹${_selectedProject!.budget.toStringAsFixed(2)} Cr'),
                  const Divider(height: 24),
                  _buildDetailRow('Beneficiaries', 
                    '${(_selectedProject!.beneficiaries / 1000).toStringAsFixed(1)}K+'),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // View full details
                      },
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('View Full Details'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? statusColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppDesignSystem.bodyMedium.copyWith(
            color: AppDesignSystem.neutral600,
          ),
        ),
        Row(
          children: [
            if (statusColor != null)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
            Text(
              value,
              style: AppDesignSystem.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDesignSystem.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PM-AJAY Coverage Map',
            style: AppDesignSystem.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Explore PM-AJAY projects across India',
            style: AppDesignSystem.bodyLarge.copyWith(
              color: AppDesignSystem.neutral600,
            ),
          ),
          const SizedBox(height: 24),
          
          // Search and filters
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by location or project name',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) => setState(() {}),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedState,
                  decoration: InputDecoration(
                    labelText: 'State',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: _states.map((state) {
                    return DropdownMenuItem(
                      value: state,
                      child: Text(state),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedState = value!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedProjectType,
                  decoration: InputDecoration(
                    labelText: 'Project Type',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: _projectTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedProjectType = value!;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Map and details
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: _buildMap(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildProjectDetails(),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Legend
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildLegendItem('Completed', AppDesignSystem.success),
                  _buildLegendItem('In Progress', AppDesignSystem.skyBlue),
                  _buildLegendItem('Planning', AppDesignSystem.sunsetOrange),
                  Text(
                    'Total Projects: ${_filteredProjects.length}',
                    style: AppDesignSystem.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppDesignSystem.bodyMedium,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }
}

class MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppDesignSystem.neutral200.withOpacity(0.3)
      ..strokeWidth = 1.0;

    // Draw grid lines
    for (double i = 0; i < size.width; i += 50) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i, size.height),
        paint,
      );
    }

    for (double i = 0; i < size.height; i += 50) {
      canvas.drawLine(
        Offset(0, i),
        Offset(size.width, i),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}