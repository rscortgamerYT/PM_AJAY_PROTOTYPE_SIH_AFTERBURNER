import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/services/dashboard_analytics_service.dart';
import '../../../../core/theme/app_theme.dart';

/// Project Geo-Tracker Widget with Smart Validation
/// 
/// Real-time GPS-enabled project tracking with automatic location
/// validation for milestone submissions.
class ProjectGeoTrackerWidget extends StatefulWidget {
  final String projectId;
  
  const ProjectGeoTrackerWidget({
    super.key,
    required this.projectId,
  });

  @override
  State<ProjectGeoTrackerWidget> createState() => _ProjectGeoTrackerWidgetState();
}

class _ProjectGeoTrackerWidgetState extends State<ProjectGeoTrackerWidget> {
  final MapController _mapController = MapController();
  final DashboardAnalyticsService _analyticsService = DashboardAnalyticsService();
  
  bool _isTracking = false;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _requestLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showError('Location services are disabled.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showError('Location permissions are denied');
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      _showError('Location permissions are permanently denied');
      return;
    }

    _startTracking();
  }

  void _startTracking() {
    setState(() => _isTracking = true);
    
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    ).listen((Position position) {
      setState(() => _currentPosition = position);
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorRed,
      ),
    );
  }

  Future<void> _takeGeotaggedPhoto() async {
    if (_currentPosition == null) {
      _showError('Location not available');
      return;
    }
    
    // TODO: Implement camera capture with location tagging
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Photo capture functionality coming soon')),
    );
  }

  Future<void> _submitMilestone() async {
    if (_currentPosition == null) {
      _showError('Location not available');
      return;
    }
    
    // TODO: Implement milestone submission
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Milestone submission functionality coming soon')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ProjectLocationData>(
      stream: _analyticsService.trackProjectLocation(widget.projectId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final locationData = snapshot.data;
        if (locationData == null) {
          return const Center(child: Text('No location data available'));
        }

        final currentLoc = _currentPosition != null
            ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
            : locationData.currentLocation;

        return Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: locationData.projectCenter,
                initialZoom: 16.0,
                minZoom: 14.0,
                maxZoom: 19.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.pmajay.platform',
                ),
                
                // Project boundary
                if (locationData.projectBoundary.isNotEmpty)
                  PolygonLayer(
                    polygons: [
                      Polygon(
                        points: locationData.projectBoundary,
                        color: Colors.blue.withOpacity(0.3),
                        borderColor: Colors.blue,
                        borderStrokeWidth: 2,
                        isFilled: true,
                      ),
                    ],
                  ),
                
                // Current location marker
                MarkerLayer(
                  markers: [
                    Marker(
                      point: currentLoc,
                      width: 50,
                      height: 50,
                      child: _buildLocationMarker(locationData.isWithinBoundary),
                    ),
                  ],
                ),
              ],
            ),

            // Location status overlay
            Positioned(
              top: 16,
              left: 16,
              child: _buildLocationStatusCard(
                locationData.isWithinBoundary,
                locationData.accuracy,
                locationData.lastUpdate,
              ),
            ),

            // Quick actions
            Positioned(
              bottom: 16,
              right: 16,
              child: Column(
                children: [
                  FloatingActionButton(
                    heroTag: "photo",
                    onPressed: _takeGeotaggedPhoto,
                    backgroundColor: AppTheme.secondaryBlue,
                    child: const Icon(Icons.camera_alt),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton(
                    heroTag: "milestone",
                    onPressed: locationData.isWithinBoundary
                        ? _submitMilestone
                        : null,
                    backgroundColor: locationData.isWithinBoundary
                        ? AppTheme.successGreen
                        : Colors.grey,
                    child: const Icon(Icons.flag),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton(
                    heroTag: "center",
                    onPressed: () {
                      _mapController.move(currentLoc, 17.0);
                    },
                    backgroundColor: AppTheme.primaryIndigo,
                    child: const Icon(Icons.my_location),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLocationMarker(bool isWithinBoundary) {
    return Container(
      decoration: BoxDecoration(
        color: isWithinBoundary ? AppTheme.successGreen : AppTheme.errorRed,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: (isWithinBoundary ? AppTheme.successGreen : AppTheme.errorRed)
                .withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(
        isWithinBoundary ? Icons.check_circle : Icons.warning,
        color: Colors.white,
        size: 30,
      ),
    );
  }

  Widget _buildLocationStatusCard(
    bool isWithinBoundary,
    double accuracy,
    DateTime lastUpdate,
  ) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  isWithinBoundary ? Icons.check_circle : Icons.warning,
                  color: isWithinBoundary ? AppTheme.successGreen : AppTheme.errorRed,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  isWithinBoundary ? 'Inside Project Area' : 'Outside Project Area',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isWithinBoundary ? AppTheme.successGreen : AppTheme.errorRed,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Accuracy: ${accuracy.toStringAsFixed(1)}m',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              'Updated: ${_formatTime(lastUpdate)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (_isTracking)
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppTheme.successGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Live Tracking',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.successGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    
    if (diff.inSeconds < 60) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else {
      return '${diff.inHours}h ago';
    }
  }
}