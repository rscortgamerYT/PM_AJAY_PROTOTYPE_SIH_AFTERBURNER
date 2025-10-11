import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/services/dashboard_analytics_service.dart';
import '../../../../core/services/mock_dashboard_data_service.dart';
import '../../../../core/theme/app_theme.dart';

/// National Agency Heatmap Widget for Centre Dashboard
/// 
/// Shows real-time performance metrics of all agencies across states
/// with color-coded visualization based on performance scores.
class NationalHeatmapWidget extends StatefulWidget {
  const NationalHeatmapWidget({super.key});

  @override
  State<NationalHeatmapWidget> createState() => _NationalHeatmapWidgetState();
}

class _NationalHeatmapWidgetState extends State<NationalHeatmapWidget> {
  final MapController _mapController = MapController();
  final DashboardAnalyticsService _analyticsService = DashboardAnalyticsService();
  
  String? _selectedStateId;
  StateMetrics? _selectedState;
  
  // Filter options
  String? _componentFilter; // 'adarsh_gram', 'gia', 'hostel'
  String? _metricFilter; // 'performance', 'fund_utilization', 'timeline'

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  /// Get color based on performance score
  /// Green (90-100%): High-performing
  /// Yellow (70-89%): Average-performing  
  /// Orange (50-69%): Below-average
  /// Red (0-49%): Poor-performing
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
    if (score >= 0.9) {
      return 'High Performance';
    } else if (score >= 0.7) {
      return 'Average Performance';
    } else if (score >= 0.5) {
      return 'Below Average';
    } else {
      return 'Poor Performance';
    }
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
                'Performance Legend',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildLegendItem('90-100%', 'High', AppTheme.successGreen),
              _buildLegendItem('70-89%', 'Average', Colors.yellow.shade700),
              _buildLegendItem('50-69%', 'Below Avg', AppTheme.warningOrange),
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
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
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

  Widget _buildFilterPanel() {
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
                'Filters',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              // Component filter
              DropdownButton<String?>(
                value: _componentFilter,
                hint: const Text('All Components'),
                items: const [
                  DropdownMenuItem(value: null, child: Text('All Components')),
                  DropdownMenuItem(value: 'adarsh_gram', child: Text('Adarsh Gram')),
                  DropdownMenuItem(value: 'gia', child: Text('GIA')),
                  DropdownMenuItem(value: 'hostel', child: Text('Hostel')),
                ],
                onChanged: (value) {
                  setState(() => _componentFilter = value);
                },
              ),
              
              const SizedBox(height: 8),
              
              // Metric filter
              DropdownButton<String?>(
                value: _metricFilter,
                hint: const Text('Performance'),
                items: const [
                  DropdownMenuItem(value: 'performance', child: Text('Performance')),
                  DropdownMenuItem(value: 'fund_utilization', child: Text('Fund Utilization')),
                  DropdownMenuItem(value: 'timeline', child: Text('Timeline Adherence')),
                ],
                onChanged: (value) {
                  setState(() => _metricFilter = value ?? 'performance');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStateInfoCard(StateMetrics state) {
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
                      color: _getPerformanceColor(state.performanceScore),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.location_on,
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
                          state.stateName,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _getPerformanceLabel(state.performanceScore),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: _getPerformanceColor(state.performanceScore),
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
                        _selectedStateId = null;
                        _selectedState = null;
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
                      '${(state.performanceScore * 100).toStringAsFixed(1)}%',
                      Icons.star,
                      _getPerformanceColor(state.performanceScore),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMetricCard(
                      'Projects',
                      '${state.completedProjects}/${state.totalProjects}',
                      Icons.assignment_turned_in,
                      AppTheme.secondaryBlue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMetricCard(
                      'Utilization',
                      '${(state.fundUtilization * 100).toStringAsFixed(0)}%',
                      Icons.account_balance_wallet,
                      AppTheme.accentTeal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  // Navigate to district view
                  _mapController.move(state.centerLocation, 8.0);
                },
                icon: const Icon(Icons.zoom_in),
                label: const Text('View District Details'),
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
      child: Column(
        children: [
          Icon(icon, size: 24, color: color),
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
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use mock data for now since backend is not connected
    final stateMetrics = MockDashboardDataService.getMockStateMetrics();

    return Stack(
      children: [
        Builder(
          builder: (context) {

            // Build state markers
            final markers = stateMetrics.map((state) {
              final isSelected = _selectedStateId == state.stateId;
              final color = _getPerformanceColor(state.performanceScore);

              return Marker(
                point: state.centerLocation,
                width: isSelected ? 60 : 40,
                height: isSelected ? 60 : 40,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedStateId = state.stateId;
                      _selectedState = state;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: isSelected ? 3 : 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.5),
                          blurRadius: isSelected ? 12 : 8,
                          spreadRadius: isSelected ? 3 : 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '${(state.performanceScore * 100).toInt()}',
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
            }).toList();

            return FlutterMap(
              mapController: _mapController,
              options: const MapOptions(
                initialCenter: LatLng(20.5937, 78.9629), // India center
                initialZoom: 5.0,
                minZoom: 4.0,
                maxZoom: 18.0,
                interactionOptions: InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.pmajay.platform',
                ),
                MarkerLayer(markers: markers),
              ],
            );
          },
        ),
        
        _buildFilterPanel(),
        _buildLegend(),
        
        if (_selectedState != null)
          _buildStateInfoCard(_selectedState!),
      ],
    );
  }
}