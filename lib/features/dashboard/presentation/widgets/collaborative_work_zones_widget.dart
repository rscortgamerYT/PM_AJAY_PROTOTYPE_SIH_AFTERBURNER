import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/dashboard_analytics_service.dart';
import '../../../../core/theme/app_theme.dart';

/// Collaborative Work Zones Widget
/// 
/// Inter-agency coordination platform showing nearby projects
/// for resource sharing and collaboration opportunities.
class CollaborativeWorkZonesWidget extends ConsumerStatefulWidget {
  final String agencyId;
  final LatLng agencyLocation;
  
  const CollaborativeWorkZonesWidget({
    super.key,
    required this.agencyId,
    required this.agencyLocation,
  });

  @override
  ConsumerState<CollaborativeWorkZonesWidget> createState() => _CollaborativeWorkZonesWidgetState();
}

class _CollaborativeWorkZonesWidgetState extends ConsumerState<CollaborativeWorkZonesWidget> {
  final MapController _mapController = MapController();
  final DashboardAnalyticsService _analyticsService = DashboardAnalyticsService();
  
  CollaborationZone? _selectedZone;
  String _selectedFilter = 'all';
  double _collaborationRadius = 15.0; // km

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Color _getZoneColor(String status) {
    switch (status) {
      case 'active':
        return AppTheme.successGreen;
      case 'pending':
        return AppTheme.warningOrange;
      case 'opportunity':
        return AppTheme.secondaryBlue;
      default:
        return AppTheme.neutralGray;
    }
  }

  IconData _getZoneIcon(String type) {
    switch (type) {
      case 'resource_sharing':
        return Icons.share;
      case 'joint_procurement':
        return Icons.shopping_cart;
      case 'equipment_rental':
        return Icons.construction;
      case 'workforce_collaboration':
        return Icons.groups;
      default:
        return Icons.handshake;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CollaborationZone>>(
      stream: _analyticsService.getCollaborationZones(
        widget.agencyId,
        _collaborationRadius,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: AppTheme.errorRed),
                const SizedBox(height: 16),
                Text('Error loading collaboration zones: ${snapshot.error}'),
              ],
            ),
          );
        }

        final zones = snapshot.data ?? [];
        final filteredZones = _selectedFilter == 'all'
            ? zones
            : zones.where((z) => z.status == _selectedFilter).toList();

        return Column(
          children: [
            // Filter and controls
            _buildControlPanel(zones),
            
            // Map with collaboration zones
            Expanded(
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: widget.agencyLocation,
                      initialZoom: 11.0,
                      minZoom: 9.0,
                      maxZoom: 16.0,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.all,
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.pmajay.platform',
                      ),
                      
                      // Collaboration radius circle
                      CircleLayer(
                        circles: [
                          CircleMarker(
                            point: widget.agencyLocation,
                            radius: _collaborationRadius * 1000,
                            useRadiusInMeter: true,
                            color: AppTheme.primaryIndigo.withOpacity(0.1),
                            borderColor: AppTheme.primaryIndigo,
                            borderStrokeWidth: 2,
                          ),
                        ],
                      ),
                      
                      // Agency location marker
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: widget.agencyLocation,
                            width: 50,
                            height: 50,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppTheme.primaryIndigo,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryIndigo.withOpacity(0.5),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.business,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      // Collaboration zone markers
                      MarkerLayer(
                        markers: filteredZones.map((zone) {
                          final isSelected = _selectedZone?.id == zone.id;
                          return Marker(
                            point: zone.location,
                            width: isSelected ? 50 : 40,
                            height: isSelected ? 50 : 40,
                            child: GestureDetector(
                              onTap: () {
                                setState(() => _selectedZone = zone);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _getZoneColor(zone.status),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: isSelected ? 3 : 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _getZoneColor(zone.status)
                                          .withOpacity(0.6),
                                      blurRadius: isSelected ? 12 : 6,
                                      spreadRadius: isSelected ? 3 : 1,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  _getZoneIcon(zone.type),
                                  color: Colors.white,
                                  size: isSelected ? 24 : 20,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      
                      // Connection lines to nearby zones
                      PolylineLayer(
                        polylines: filteredZones.map((zone) {
                          return Polyline(
                            points: [widget.agencyLocation, zone.location],
                            color: _getZoneColor(zone.status).withOpacity(0.4),
                            strokeWidth: 2,
                            isDotted: zone.status == 'opportunity',
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  
                  // Selected zone info card
                  if (_selectedZone != null)
                    _buildZoneInfoCard(_selectedZone!),
                    
                  // Legend
                  _buildLegend(),
                ],
              ),
            ),
            
            // Collaboration opportunities list
            _buildOpportunitiesList(filteredZones),
          ],
        );
      },
    );
  }

  Widget _buildControlPanel(List<CollaborationZone> zones) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.handshake, color: AppTheme.primaryIndigo),
                const SizedBox(width: 8),
                Text(
                  'Collaboration Zones',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${zones.length} zones found',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Search Radius: ${_collaborationRadius.toStringAsFixed(1)} km',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Slider(
              value: _collaborationRadius,
              min: 5.0,
              max: 50.0,
              divisions: 45,
              label: '${_collaborationRadius.toStringAsFixed(1)} km',
              onChanged: (value) {
                setState(() => _collaborationRadius = value);
              },
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('All'),
                    selected: _selectedFilter == 'all',
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedFilter = 'all');
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Active'),
                    selected: _selectedFilter == 'active',
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedFilter = 'active');
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Pending'),
                    selected: _selectedFilter == 'pending',
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedFilter = 'pending');
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Opportunities'),
                    selected: _selectedFilter == 'opportunity',
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedFilter = 'opportunity');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoneInfoCard(CollaborationZone zone) {
    return Positioned(
      top: 16,
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
                      color: _getZoneColor(zone.status),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getZoneIcon(zone.type),
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
                          zone.projectName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          zone.agencyName,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => _selectedZone = null),
                  ),
                ],
              ),
              const Divider(height: 24),
              _buildInfoRow(
                Icons.category,
                'Type',
                zone.type.replaceAll('_', ' ').toUpperCase(),
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.access_time,
                'Distance',
                '${zone.distance.toStringAsFixed(1)} km',
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.circle,
                'Status',
                zone.status.toUpperCase(),
              ),
              if (zone.opportunities.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Collaboration Opportunities:',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                ...zone.opportunities.map((opp) => Padding(
                  padding: const EdgeInsets.only(left: 8, top: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, size: 16, color: AppTheme.successGreen),
                      const SizedBox(width: 8),
                      Expanded(child: Text(opp, style: Theme.of(context).textTheme.bodySmall)),
                    ],
                  ),
                )),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Initiate collaboration
                      },
                      icon: const Icon(Icons.handshake),
                      label: const Text('Collaborate'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getZoneColor(zone.status),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // View details
                      },
                      icon: const Icon(Icons.info_outline),
                      label: const Text('Details'),
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.neutralGray),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.neutralGray,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildLegend() {
    return Positioned(
      bottom: 16,
      right: 16,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Legend',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildLegendItem(AppTheme.successGreen, 'Active'),
              _buildLegendItem(AppTheme.warningOrange, 'Pending'),
              _buildLegendItem(AppTheme.secondaryBlue, 'Opportunity'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
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
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildOpportunitiesList(List<CollaborationZone> zones) {
    final opportunities = zones.where((z) => z.opportunities.isNotEmpty).toList();
    
    return Container(
      height: 180,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Collaboration Opportunities (${opportunities.length})',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: opportunities.length,
              itemBuilder: (context, index) {
                final zone = opportunities[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getZoneColor(zone.status),
                      child: Icon(
                        _getZoneIcon(zone.type),
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: Text(zone.projectName),
                    subtitle: Text(
                      '${zone.agencyName} • ${zone.distance.toStringAsFixed(1)} km',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {
                        setState(() => _selectedZone = zone);
                        _mapController.move(zone.location, 14.0);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getZoneColor(zone.status),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      child: const Text('View'),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}