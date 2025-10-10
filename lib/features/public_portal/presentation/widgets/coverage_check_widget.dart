import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/models/project_model.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../maps/widgets/interactive_map_widget.dart';

/// Coverage Check Widget
/// 
/// Allows users to verify if their village/locality falls under PM-AJAY projects
class CoverageCheckWidget extends ConsumerStatefulWidget {
  const CoverageCheckWidget({super.key});

  @override
  ConsumerState<CoverageCheckWidget> createState() => _CoverageCheckWidgetState();
}

class _CoverageCheckWidgetState extends ConsumerState<CoverageCheckWidget> {
  final TextEditingController _pincodeController = TextEditingController();
  LatLng? _selectedLocation;
  List<ProjectModel> _nearbyProjects = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _pincodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primaryIndigo, AppTheme.secondaryBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Check PM-AJAY Coverage',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Verify if your village or locality is covered under any PM-AJAY project',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),

        // Search Section
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter Your Location',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // PIN Code Input
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _pincodeController,
                      decoration: InputDecoration(
                        labelText: 'PIN Code',
                        hintText: 'Enter 6-digit PIN code',
                        prefixIcon: const Icon(Icons.location_on),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _isSearching ? null : _searchByPincode,
                    icon: _isSearching
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.search),
                    label: const Text('Search'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              const Center(
                child: Text(
                  'OR',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Map Selection
              const Text(
                'Drop a Pin on the Map',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              
              Container(
                height: 400,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      InteractiveMapWidget(
                        projects: _nearbyProjects,
                        agencies: const [],
                        initialCenter: _selectedLocation ?? const LatLng(20.5937, 78.9629),
                        initialZoom: 5.0,
                        onProjectTap: (projectId) {
                          final project = _nearbyProjects.firstWhere((p) => p.id == projectId);
                          _showProjectDetails(project);
                        },
                      ),
                      Positioned(
                        top: 16,
                        right: 16,
                        child: FloatingActionButton.small(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Drop a Pin'),
                                content: const Text('Tap anywhere on the map to check coverage at that location.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          },
                          tooltip: 'Help',
                          child: const Icon(Icons.help_outline),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Results Section
        if (_nearbyProjects.isNotEmpty)
          Expanded(
            child: _buildResultsSection(),
          ),
      ],
    );
  }

  Widget _buildResultsSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          top: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Projects Found: ${_nearbyProjects.length}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _downloadCoverageCertificate,
                icon: const Icon(Icons.download),
                label: const Text('Download Certificate'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          Expanded(
            child: ListView.builder(
              itemCount: _nearbyProjects.length,
              itemBuilder: (context, index) {
                final project = _nearbyProjects[index];
                return _buildProjectCard(project);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard(ProjectModel project) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    project.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(project.status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    project.status.value,
                    style: TextStyle(
                      color: _getStatusColor(project.status),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Text(
              project.description ?? 'No description available',
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),
            
            const SizedBox(height: 16),
            
            _buildInfoRow(Icons.category, 'Component', project.component.value),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.people, 'Beneficiaries', '${project.beneficiariesCount} people'),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.currency_rupee, 'Budget', '₹${(project.allocatedBudget ?? 0).toStringAsFixed(2)} Lakhs'),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.timeline, 'Progress', '${project.completionPercentage.toStringAsFixed(1)}%'),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showProjectDetails(project),
                    icon: const Icon(Icons.info_outline),
                    label: const Text('View Details'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showContactInfo(project),
                    icon: const Icon(Icons.phone),
                    label: const Text('Contact'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.neutralGray),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppTheme.neutralGray,
          ),
        ),
        Text(value),
      ],
    );
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

  void _onMapTap(LatLng location) {
    setState(() {
      _selectedLocation = location;
      _isSearching = true;
    });
    
    _searchNearbyProjects(location);
  }

  Future<void> _searchByPincode() async {
    if (_pincodeController.text.length != 6) {
      _showErrorDialog('Please enter a valid 6-digit PIN code');
      return;
    }

    setState(() => _isSearching = true);

    // Mock: Convert PIN code to coordinates
    // In production, use geocoding API
    final mockLocation = const LatLng(28.6139, 77.2090);
    
    await _searchNearbyProjects(mockLocation);
  }

  Future<void> _searchNearbyProjects(LatLng location) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // Mock data - in production, fetch from Supabase
    final mockProjects = [
      ProjectModel(
        id: '1',
        name: 'Adarsh Gram Development - Village A',
        description: 'Comprehensive village development including infrastructure, sanitation, and education facilities',
        status: ProjectStatus.inProgress,
        component: ProjectComponent.adarshGram,
        location: location,
        completionPercentage: 65.5,
        allocatedBudget: 150.0,
        beneficiariesCount: 250,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ProjectModel(
        id: '2',
        name: 'Hostel Construction Project',
        description: 'Building hostel facilities for tribal students with modern amenities',
        status: ProjectStatus.completed,
        component: ProjectComponent.hostel,
        location: LatLng(location.latitude + 0.01, location.longitude + 0.01),
        completionPercentage: 100.0,
        allocatedBudget: 200.0,
        beneficiariesCount: 150,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    setState(() {
      _nearbyProjects = mockProjects;
      _isSearching = false;
    });
  }

  void _showProjectDetails(ProjectModel project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(project.name),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(project.description ?? 'No description available'),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              _buildDetailRow('Status', project.status.value),
              _buildDetailRow('Component', project.component.value),
              _buildDetailRow('Progress', '${project.completionPercentage.toStringAsFixed(1)}%'),
              _buildDetailRow('Budget', '₹${(project.allocatedBudget ?? 0).toStringAsFixed(2)} Lakhs'),
              _buildDetailRow('Beneficiaries', '${project.beneficiariesCount} people'),
              _buildDetailRow('Created', '${project.createdAt.day}/${project.createdAt.month}/${project.createdAt.year}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _showContactInfo(ProjectModel project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'For queries related to this project, please contact:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Project', project.name),
            _buildDetailRow('Agency', 'Delhi Development Agency'),
            _buildDetailRow('Phone', '+91-11-12345678'),
            _buildDetailRow('Email', 'contact@pmajay.gov.in'),
            _buildDetailRow('Office Hours', 'Mon-Fri, 9 AM - 5 PM'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to complaint submission
            },
            icon: const Icon(Icons.report_problem),
            label: const Text('Report Issue'),
          ),
        ],
      ),
    );
  }

  void _downloadCoverageCertificate() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Generating Coverage Certificate PDF...'),
        duration: Duration(seconds: 2),
      ),
    );
    
    // In production, generate PDF with:
    // - User location coordinates
    // - List of nearby projects
    // - Project details
    // - Coverage map
    // - Official seal and signature
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}