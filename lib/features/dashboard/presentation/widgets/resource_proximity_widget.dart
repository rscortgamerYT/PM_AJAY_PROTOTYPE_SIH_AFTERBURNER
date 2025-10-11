import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/services/dashboard_analytics_service.dart';
import '../../../../core/theme/app_theme.dart';

/// Resource Proximity Intelligence Widget
/// 
/// Spatial intelligence system for finding and optimizing resources
/// near project locations with cost-distance analysis.
class ResourceProximityWidget extends StatefulWidget {
  final LatLng projectLocation;
  
  const ResourceProximityWidget({
    super.key,
    required this.projectLocation,
  });

  @override
  State<ResourceProximityWidget> createState() => _ResourceProximityWidgetState();
}

class _ResourceProximityWidgetState extends State<ResourceProximityWidget> {
  final MapController _mapController = MapController();
  final DashboardAnalyticsService _analyticsService = DashboardAnalyticsService();
  
  double _searchRadius = 10.0; // km
  final List<String> _selectedResourceTypes = ['suppliers', 'equipment', 'services'];
  Resource? _selectedResource;

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  IconData _getResourceIcon(String type) {
    switch (type) {
      case 'suppliers':
        return Icons.store;
      case 'equipment':
        return Icons.construction;
      case 'services':
        return Icons.engineering;
      case 'materials':
        return Icons.inventory_2;
      default:
        return Icons.location_on;
    }
  }

  Color _getResourceColor(String type) {
    switch (type) {
      case 'suppliers':
        return AppTheme.accentTeal;
      case 'equipment':
        return AppTheme.warningOrange;
      case 'services':
        return AppTheme.secondaryBlue;
      case 'materials':
        return AppTheme.successGreen;
      default:
        return AppTheme.primaryIndigo;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ResourceMapData>(
      future: _analyticsService.getNearbyResources(
        widget.projectLocation,
        _searchRadius,
        _selectedResourceTypes,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: AppTheme.errorRed),
                SizedBox(height: 16),
                Text('Error loading resources'),
              ],
            ),
          );
        }

        final resourceData = snapshot.data;
        if (resourceData == null) {
          return const Center(child: Text('No resource data available'));
        }

        return Column(
          children: [
            // Search and filter controls
            _buildSearchControls(),
            
            // Map with resources
            Expanded(
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: widget.projectLocation,
                      initialZoom: 12.0,
                      minZoom: 10.0,
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
                      
                      // Search radius circle
                      CircleLayer(
                        circles: [
                          CircleMarker(
                            point: widget.projectLocation,
                            radius: _searchRadius * 1000, // Convert to meters
                            useRadiusInMeter: true,
                            color: Colors.blue.withOpacity(0.1),
                            borderColor: Colors.blue,
                            borderStrokeWidth: 1,
                          ),
                        ],
                      ),
                      
                      // Project location marker
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: widget.projectLocation,
                            width: 40,
                            height: 40,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppTheme.primaryIndigo,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(
                                Icons.business,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      // Resource markers
                      MarkerLayer(
                        markers: resourceData.resources.map((resource) {
                          final isSelected = _selectedResource?.id == resource.id;
                          return Marker(
                            point: resource.location,
                            width: isSelected ? 40 : 30,
                            height: isSelected ? 40 : 30,
                            child: GestureDetector(
                              onTap: () {
                                setState(() => _selectedResource = resource);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _getResourceColor(resource.type),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: isSelected ? 3 : 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _getResourceColor(resource.type)
                                          .withOpacity(0.5),
                                      blurRadius: isSelected ? 8 : 4,
                                      spreadRadius: isSelected ? 2 : 1,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  _getResourceIcon(resource.type),
                                  color: Colors.white,
                                  size: isSelected ? 20 : 16,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  
                  // Resource info card
                  if (_selectedResource != null)
                    _buildResourceInfoCard(_selectedResource!),
                ],
              ),
            ),
            
            // Resource list
            _buildResourceList(resourceData.resources),
          ],
        );
      },
    );
  }

  Widget _buildSearchControls() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Search Radius: ${_searchRadius.toStringAsFixed(1)} km',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Slider(
              value: _searchRadius,
              min: 1.0,
              max: 50.0,
              divisions: 49,
              label: '${_searchRadius.toStringAsFixed(1)} km',
              onChanged: (value) {
                setState(() => _searchRadius = value);
              },
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('Suppliers'),
                  selected: _selectedResourceTypes.contains('suppliers'),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedResourceTypes.add('suppliers');
                      } else {
                        _selectedResourceTypes.remove('suppliers');
                      }
                    });
                  },
                ),
                FilterChip(
                  label: const Text('Equipment'),
                  selected: _selectedResourceTypes.contains('equipment'),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedResourceTypes.add('equipment');
                      } else {
                        _selectedResourceTypes.remove('equipment');
                      }
                    });
                  },
                ),
                FilterChip(
                  label: const Text('Services'),
                  selected: _selectedResourceTypes.contains('services'),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedResourceTypes.add('services');
                      } else {
                        _selectedResourceTypes.remove('services');
                      }
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceInfoCard(Resource resource) {
    return Positioned(
      bottom: 200,
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
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getResourceColor(resource.type),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getResourceIcon(resource.type),
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
                          resource.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          resource.type.toUpperCase(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: _getResourceColor(resource.type),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => _selectedResource = null),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Contact vendor
                      },
                      icon: const Icon(Icons.phone),
                      label: const Text('Contact'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Request quote
                      },
                      icon: const Icon(Icons.request_quote),
                      label: const Text('Quote'),
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

  Widget _buildResourceList(List<Resource> resources) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: resources.length,
        itemBuilder: (context, index) {
          final resource = resources[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _getResourceColor(resource.type),
                child: Icon(
                  _getResourceIcon(resource.type),
                  color: Colors.white,
                  size: 20,
                ),
              ),
              title: Text(resource.name),
              subtitle: Text(resource.type),
              trailing: Chip(
                label: Text(resource.available ? 'Available' : 'Unavailable'),
                backgroundColor: resource.available
                    ? AppTheme.successGreen.withOpacity(0.2)
                    : AppTheme.errorRed.withOpacity(0.2),
              ),
              onTap: () {
                setState(() => _selectedResource = resource);
                _mapController.move(resource.location, 15.0);
              },
            ),
          );
        },
      ),
    );
  }
}