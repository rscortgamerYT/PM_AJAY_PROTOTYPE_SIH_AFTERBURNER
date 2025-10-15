import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/theme/app_theme.dart';

/// Resource Proximity Map Widget
/// 
/// Interactive map showing nearest suppliers, equipment rentals, and contractors
/// with cost/time estimates and direct contact options.
class ResourceProximityMapWidget extends StatefulWidget {
  final String agencyId;
  
  const ResourceProximityMapWidget({
    super.key,
    required this.agencyId,
  });

  @override
  State<ResourceProximityMapWidget> createState() => 
      _ResourceProximityMapWidgetState();
}

class _ResourceProximityMapWidgetState
    extends State<ResourceProximityMapWidget> {
  
  final MapController _mapController = MapController();
  String _selectedCategory = 'all'; // 'all', 'suppliers', 'equipment', 'contractors'
  double _maxDistance = 50.0; // km
  ResourceProvider? _selectedResource;
  
  final LatLng _agencyLocation = const LatLng(19.0760, 72.8777); // Mumbai

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  final List<ResourceProvider> _mockResources = [
    ResourceProvider(
      id: 'res_001',
      name: 'ABC Building Materials',
      category: ResourceCategory.supplier,
      location: const LatLng(19.0850, 72.8900),
      distance: 3.5,
      rating: 4.5,
      contactNumber: '+91 98765 43210',
      email: 'abc@materials.com',
      services: ['Cement', 'Steel', 'Bricks', 'Sand'],
      estimatedCost: 50000,
      deliveryTime: 2,
    ),
    ResourceProvider(
      id: 'res_002',
      name: 'XYZ Equipment Rentals',
      category: ResourceCategory.equipment,
      location: const LatLng(19.0650, 72.8650),
      distance: 2.8,
      rating: 4.7,
      contactNumber: '+91 98765 43211',
      email: 'xyz@equipment.com',
      services: ['JCB', 'Excavator', 'Concrete Mixer', 'Crane'],
      estimatedCost: 15000,
      deliveryTime: 1,
    ),
    ResourceProvider(
      id: 'res_003',
      name: 'PQR Construction Contractors',
      category: ResourceCategory.contractor,
      location: const LatLng(19.0900, 72.8800),
      distance: 4.2,
      rating: 4.3,
      contactNumber: '+91 98765 43212',
      email: 'pqr@contractors.com',
      services: ['Plumbing', 'Electrical', 'Civil Work', 'Painting'],
      estimatedCost: 75000,
      deliveryTime: 3,
    ),
    ResourceProvider(
      id: 'res_004',
      name: 'LMN Hardware Store',
      category: ResourceCategory.supplier,
      location: const LatLng(19.0700, 72.8850),
      distance: 1.5,
      rating: 4.6,
      contactNumber: '+91 98765 43213',
      email: 'lmn@hardware.com',
      services: ['Pipes', 'Fittings', 'Tools', 'Paint'],
      estimatedCost: 25000,
      deliveryTime: 1,
    ),
    ResourceProvider(
      id: 'res_005',
      name: 'RST Heavy Machinery',
      category: ResourceCategory.equipment,
      location: const LatLng(19.1000, 72.9000),
      distance: 8.5,
      rating: 4.8,
      contactNumber: '+91 98765 43214',
      email: 'rst@machinery.com',
      services: ['Bulldozer', 'Road Roller', 'Paver', 'Loader'],
      estimatedCost: 35000,
      deliveryTime: 2,
    ),
    ResourceProvider(
      id: 'res_006',
      name: 'UVW Skilled Labor',
      category: ResourceCategory.contractor,
      location: const LatLng(19.0600, 72.8700),
      distance: 3.0,
      rating: 4.4,
      contactNumber: '+91 98765 43215',
      email: 'uvw@labor.com',
      services: ['Masons', 'Plumbers', 'Electricians', 'Welders'],
      estimatedCost: 45000,
      deliveryTime: 1,
    ),
  ];

  List<ResourceProvider> get _filteredResources {
    var filtered = _mockResources.where((r) => r.distance <= _maxDistance);
    
    if (_selectedCategory != 'all') {
      final category = ResourceCategory.values.firstWhere(
        (c) => c.name == _selectedCategory,
        orElse: () => ResourceCategory.supplier,
      );
      filtered = filtered.where((r) => r.category == category);
    }
    
    return filtered.toList()..sort((a, b) => a.distance.compareTo(b.distance));
  }

  Color _getCategoryColor(ResourceCategory category) {
    switch (category) {
      case ResourceCategory.supplier:
        return AppTheme.secondaryBlue;
      case ResourceCategory.equipment:
        return AppTheme.warningOrange;
      case ResourceCategory.contractor:
        return AppTheme.accentTeal;
    }
  }

  IconData _getCategoryIcon(ResourceCategory category) {
    switch (category) {
      case ResourceCategory.supplier:
        return Icons.store;
      case ResourceCategory.equipment:
        return Icons.construction;
      case ResourceCategory.contractor:
        return Icons.engineering;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildFilters(),
        Expanded(
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildResourceList(),
              ),
              Expanded(
                flex: 3,
                child: _buildMapView(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.agencyUserColor, AppTheme.accentTeal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.map, size: 40, color: Colors.white),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Resource Proximity Map',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Find nearest suppliers, equipment, and contractors',
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            _filteredResources.length.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Resources',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'all',
                      label: Text('All'),
                      icon: Icon(Icons.category),
                    ),
                    ButtonSegment(
                      value: 'suppliers',
                      label: Text('Suppliers'),
                      icon: Icon(Icons.store),
                    ),
                    ButtonSegment(
                      value: 'equipment',
                      label: Text('Equipment'),
                      icon: Icon(Icons.construction),
                    ),
                    ButtonSegment(
                      value: 'contractors',
                      label: Text('Contractors'),
                      icon: Icon(Icons.engineering),
                    ),
                  ],
                  selected: {_selectedCategory},
                  onSelectionChanged: (Set<String> newSelection) {
                    setState(() => _selectedCategory = newSelection.first);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Max Distance:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 12),
              Expanded(
                child: Slider(
                  value: _maxDistance,
                  min: 5,
                  max: 100,
                  divisions: 19,
                  label: '${_maxDistance.toStringAsFixed(0)} km',
                  onChanged: (value) {
                    setState(() => _maxDistance = value);
                  },
                ),
              ),
              SizedBox(
                width: 80,
                child: Text(
                  '${_maxDistance.toStringAsFixed(0)} km',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResourceList() {
    return Container(
      color: Colors.grey.shade50,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredResources.length,
        itemBuilder: (context, index) {
          return _buildResourceCard(_filteredResources[index]);
        },
      ),
    );
  }

  Widget _buildResourceCard(ResourceProvider resource) {
    final categoryColor = _getCategoryColor(resource.category);
    final categoryIcon = _getCategoryIcon(resource.category);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(categoryIcon, color: categoryColor, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        resource.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            '${resource.distance.toStringAsFixed(1)} km away',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: AppTheme.warningOrange),
                    const SizedBox(width: 4),
                    Text(
                      resource.rating.toStringAsFixed(1),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            
            // Services
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: resource.services.map((service) {
                return Chip(
                  label: Text(service),
                  backgroundColor: categoryColor.withOpacity(0.1),
                  labelStyle: const TextStyle(fontSize: 11),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                );
              }).toList(),
            ),
            
            const SizedBox(height: 12),
            
            // Estimates
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Est. Cost',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        _formatCurrency(resource.estimatedCost),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Delivery',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        '${resource.deliveryTime} ${resource.deliveryTime == 1 ? 'day' : 'days'}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Contact Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.phone, size: 16),
                    label: const Text('Call'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.email, size: 16),
                    label: const Text('Email'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.directions, size: 16),
                    label: const Text('Navigate'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: categoryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapView() {
    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          // Interactive Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _agencyLocation,
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
              MarkerLayer(
                markers: [
                  _buildAgencyMarker(),
                  ..._buildResourceMarkers(),
                ],
              ),
            ],
          ),
          
          // Legend
          Positioned(
            top: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Legend',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildLegendItem(Icons.store, 'Suppliers', AppTheme.secondaryBlue),
                    _buildLegendItem(Icons.construction, 'Equipment', AppTheme.warningOrange),
                    _buildLegendItem(Icons.engineering, 'Contractors', AppTheme.accentTeal),
                    const Divider(),
                    _buildLegendItem(Icons.my_location, 'Your Location', AppTheme.errorRed),
                  ],
                ),
              ),
            ),
          ),
          
          // Selected Resource Info Card
          if (_selectedResource != null) _buildResourceInfoCard(),
        ],
      ),
    );
  }

  Marker _buildAgencyMarker() {
    return Marker(
      point: _agencyLocation,
      width: 44,
      height: 44,
      alignment: Alignment.center,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppTheme.errorRed,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: AppTheme.errorRed.withOpacity(0.5),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(
          Icons.my_location,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  List<Marker> _buildResourceMarkers() {
    return _filteredResources.map((resource) {
      final isSelected = _selectedResource?.id == resource.id;
      final categoryColor = _getCategoryColor(resource.category);
      final categoryIcon = _getCategoryIcon(resource.category);

      return Marker(
        point: resource.location,
        width: isSelected ? 50 : 36,
        height: isSelected ? 50 : 36,
        alignment: Alignment.center,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _selectedResource = resource;
            });
          },
          child: Container(
            width: isSelected ? 50 : 36,
            height: isSelected ? 50 : 36,
            decoration: BoxDecoration(
              color: categoryColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: isSelected ? 3 : 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: categoryColor.withOpacity(0.5),
                  blurRadius: isSelected ? 10 : 6,
                  spreadRadius: isSelected ? 2 : 1,
                ),
              ],
            ),
            child: Icon(
              categoryIcon,
              color: Colors.white,
              size: isSelected ? 26 : 20,
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildResourceInfoCard() {
    final resource = _selectedResource!;
    final categoryColor = _getCategoryColor(resource.category);

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
                      color: categoryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getCategoryIcon(resource.category),
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
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 14, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Text(
                              '${resource.distance.toStringAsFixed(1)} km away',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(Icons.star, size: 14, color: AppTheme.warningOrange),
                            const SizedBox(width: 4),
                            Text(
                              resource.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
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
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: resource.services.take(3).map((service) {
                  return Chip(
                    label: Text(service),
                    backgroundColor: categoryColor.withOpacity(0.1),
                    labelStyle: const TextStyle(fontSize: 11),
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Est. Cost',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          _formatCurrency(resource.estimatedCost),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Delivery',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          '${resource.deliveryTime} ${resource.deliveryTime == 1 ? 'day' : 'days'}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.directions, size: 16),
                    label: const Text('Navigate'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: categoryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

  Widget _buildLegendItem(IconData icon, String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(2)} L';
    } else {
      return '₹${amount.toStringAsFixed(0)}';
    }
  }
}

/// Resource Provider Model
class ResourceProvider {
  final String id;
  final String name;
  final ResourceCategory category;
  final LatLng location;
  final double distance;
  final double rating;
  final String contactNumber;
  final String email;
  final List<String> services;
  final double estimatedCost;
  final int deliveryTime;

  ResourceProvider({
    required this.id,
    required this.name,
    required this.category,
    required this.location,
    required this.distance,
    required this.rating,
    required this.contactNumber,
    required this.email,
    required this.services,
    required this.estimatedCost,
    required this.deliveryTime,
  });
}

/// Resource Category Enum
enum ResourceCategory {
  supplier,
  equipment,
  contractor,
}