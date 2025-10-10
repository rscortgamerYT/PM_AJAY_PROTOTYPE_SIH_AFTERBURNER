import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/services/dashboard_analytics_service.dart';
import '../../../../core/theme/app_theme.dart';

/// District-wise Performance Map Widget for State Dashboard
/// 
/// Interactive state map showing district-level performance with
/// drill-down capabilities to block and village levels.
class DistrictPerformanceMapWidget extends StatefulWidget {
  final String stateId;
  
  const DistrictPerformanceMapWidget({
    super.key,
    required this.stateId,
  });

  @override
  State<DistrictPerformanceMapWidget> createState() => _DistrictPerformanceMapWidgetState();
}

class _DistrictPerformanceMapWidgetState extends State<DistrictPerformanceMapWidget> {
  final MapController _mapController = MapController();
  final DashboardAnalyticsService _analyticsService = DashboardAnalyticsService();
  
  String? _selectedDistrictId;
  DistrictPerformance? _selectedDistrict;
  
  // Layer toggles
  bool _showFundUtilization = false;
  bool _showProjectCompletion = true;
  bool _showAgencyPerformance = false;

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  /// Get color based on performance score with smooth gradients
  Color _getPerformanceColor(double score) {
    if (score >= 0.9) {
      return AppTheme.successGreen;
    } else if (score >= 0.7) {
      return Colors.yellow.shade700;
    } else if (score >= 0.5) {
      return AppTheme.warningOrange;
    } else {
      return AppTheme.errorRed;
    }
  }

  String _getPerformanceLabel(double score) {
    if (score >= 0.9) return 'Excellent';
    if (score >= 0.7) return 'Good';
    if (score >= 0.5) return 'Fair';
    return 'Needs Improvement';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<StateData>(
      future: _analyticsService.getStateData(widget.stateId),
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
                const Text('Error loading district data'),
                const SizedBox(height: 8),
                Text(
                  snapshot.error.toString(),
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final stateData = snapshot.data;
        if (stateData == null || stateData.districts.isEmpty) {
          return const Center(
            child: Text('No district data available'),
          );
        }

        return Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: stateData.stateCenter,
                initialZoom: 7.0,
                minZoom: 6.0,
                maxZoom: 15.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.pmajay.platform',
                ),
                
                // District boundary polygons
                PolygonLayer(
                  polygons: stateData.districts.map((district) {
                    final isSelected = _selectedDistrictId == district.districtId;
                    final color = _getPerformanceColor(district.performanceScore);
                    
                    return Polygon(
                      points: district.boundaryPoints,
                      color: color.withOpacity(isSelected ? 0.4 : 0.2),
                      borderColor: isSelected ? color : color.withOpacity(0.8),
                      borderStrokeWidth: isSelected ? 3 : 1.5,
                      isFilled: true,
                    );
                  }).toList(),
                ),
                
                // District center markers
                MarkerLayer(
                  markers: stateData.districts.map((district) {
                    final center = _calculatePolygonCenter(district.boundaryPoints);
                    final isSelected = _selectedDistrictId == district.districtId;
                    
                    return Marker(
                      point: center,
                      width: isSelected ? 50 : 40,
                      height: isSelected ? 50 : 40,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedDistrictId = district.districtId;
                            _selectedDistrict = district;
                          });
                          _mapController.move(center, 9.0);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: _getPerformanceColor(district.performanceScore),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: isSelected ? 3 : 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _getPerformanceColor(district.performanceScore)
                                    .withOpacity(0.5),
                                blurRadius: isSelected ? 10 : 6,
                                spreadRadius: isSelected ? 2 : 1,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              '${(district.performanceScore * 100).toInt()}',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: isSelected ? 14 : 11,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                
                // Agency markers
                MarkerLayer(
                  markers: stateData.agencies.map((agency) {
                    return Marker(
                      point: agency.location,
                      width: 30,
                      height: 30,
                      child: GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(agency.name),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.accentTeal,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.business,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            
            // Layer controls
            _buildLayerControls(),
            
            // Legend
            _buildLegend(),
            
            // District info card
            if (_selectedDistrict != null)
              _buildDistrictInfoCard(_selectedDistrict!),
          ],
        );
      },
    );
  }

  Widget _buildLayerControls() {
    return Positioned(
      top: 16,
      left: 16,
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Performance Layers',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              SwitchListTile(
                title: const Text('Project Completion'),
                value: _showProjectCompletion,
                onChanged: (value) {
                  setState(() => _showProjectCompletion = value);
                },
                dense: true,
              ),
              
              SwitchListTile(
                title: const Text('Fund Utilization'),
                value: _showFundUtilization,
                onChanged: (value) {
                  setState(() => _showFundUtilization = value);
                },
                dense: true,
              ),
              
              SwitchListTile(
                title: const Text('Agency Performance'),
                value: _showAgencyPerformance,
                onChanged: (value) {
                  setState(() => _showAgencyPerformance = value);
                },
                dense: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Positioned(
      top: 16,
      right: 16,
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Performance Scale',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildLegendItem('90-100%', 'Excellent', AppTheme.successGreen),
              _buildLegendItem('70-89%', 'Good', Colors.yellow.shade700),
              _buildLegendItem('50-69%', 'Fair', AppTheme.warningOrange),
              _buildLegendItem('0-49%', 'Poor', AppTheme.errorRed),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String range, String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.white, width: 1),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                range,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDistrictInfoCard(DistrictPerformance district) {
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
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getPerformanceColor(district.performanceScore),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.location_city,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          district.districtName,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _getPerformanceLabel(district.performanceScore),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: _getPerformanceColor(district.performanceScore),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _selectedDistrictId = null;
                        _selectedDistrict = null;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      'Score',
                      '${(district.performanceScore * 100).toStringAsFixed(1)}%',
                      Icons.star,
                      _getPerformanceColor(district.performanceScore),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  // Navigate to block view
                },
                icon: const Icon(Icons.zoom_in),
                label: const Text('View Block Details'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 40),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
          ),
        ],
      ),
    );
  }

  /// Calculate center point of a polygon
  LatLng _calculatePolygonCenter(List<LatLng> points) {
    if (points.isEmpty) return const LatLng(0, 0);
    
    double lat = 0;
    double lng = 0;
    
    for (final point in points) {
      lat += point.latitude;
      lng += point.longitude;
    }
    
    return LatLng(lat / points.length, lng / points.length);
  }
}