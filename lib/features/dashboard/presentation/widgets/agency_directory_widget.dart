import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/models/agency_model.dart';
import '../../../../core/theme/app_theme.dart';

/// Agency Directory Widget
/// 
/// Comprehensive registry of all implementing agencies with search,
/// filtering, performance metrics, and contact information.
class AgencyDirectoryWidget extends ConsumerStatefulWidget {
  const AgencyDirectoryWidget({super.key});

  @override
  ConsumerState<AgencyDirectoryWidget> createState() => _AgencyDirectoryWidgetState();
}

class _AgencyDirectoryWidgetState extends ConsumerState<AgencyDirectoryWidget> {
  final TextEditingController _searchController = TextEditingController();
  AgencyType? _selectedType;
  String _sortBy = 'name';
  
  // Mock agencies - replace with Supabase data
  final List<AgencyModel> _allAgencies = [
    AgencyModel(
      id: 'agency_001',
      name: 'Delhi Infrastructure Development Agency',
      type: AgencyType.implementingAgency,
      location: const LatLng(28.6139, 77.2090),
      address: 'Connaught Place, New Delhi - 110001',
      contactPerson: 'Rajesh Kumar',
      phone: '+91-11-23456789',
      email: 'rajesh.kumar@dida.gov.in',
      performanceRating: 4.5,
      capacityScore: 85,
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
      updatedAt: DateTime.now(),
      metadata: {
        'team_size': 45,
        'projects_completed': 28,
        'current_workload': 12,
        'established_year': 2015,
        'specialization': 'Urban Infrastructure',
      },
    ),
    AgencyModel(
      id: 'agency_002',
      name: 'Mumbai Urban Development Corporation',
      type: AgencyType.nodalAgency,
      location: const LatLng(19.0760, 72.8777),
      address: 'Bandra Kurla Complex, Mumbai - 400051',
      contactPerson: 'Priya Sharma',
      phone: '+91-22-24567890',
      email: 'priya.sharma@mudc.gov.in',
      performanceRating: 4.8,
      capacityScore: 92,
      createdAt: DateTime.now().subtract(const Duration(days: 450)),
      updatedAt: DateTime.now(),
      metadata: {
        'team_size': 78,
        'projects_completed': 42,
        'current_workload': 18,
        'established_year': 2012,
        'specialization': 'Metropolitan Development',
      },
    ),
    AgencyModel(
      id: 'agency_003',
      name: 'Karnataka Rural Development Authority',
      type: AgencyType.implementingAgency,
      location: const LatLng(12.9716, 77.5946),
      address: 'Vidhana Soudha, Bangalore - 560001',
      contactPerson: 'Anand Reddy',
      phone: '+91-80-22345678',
      email: 'anand.reddy@krda.gov.in',
      performanceRating: 4.2,
      capacityScore: 78,
      createdAt: DateTime.now().subtract(const Duration(days: 300)),
      updatedAt: DateTime.now(),
      metadata: {
        'team_size': 34,
        'projects_completed': 19,
        'current_workload': 8,
        'established_year': 2016,
        'specialization': 'Rural Infrastructure',
      },
    ),
    AgencyModel(
      id: 'agency_004',
      name: 'Tamil Nadu Social Welfare Board',
      type: AgencyType.technicalAgency,
      location: const LatLng(13.0827, 80.2707),
      address: 'Anna Salai, Chennai - 600002',
      contactPerson: 'Lakshmi Venkatesh',
      phone: '+91-44-28765432',
      email: 'lakshmi.v@tnswb.gov.in',
      performanceRating: 4.6,
      capacityScore: 88,
      createdAt: DateTime.now().subtract(const Duration(days: 420)),
      updatedAt: DateTime.now(),
      metadata: {
        'team_size': 52,
        'projects_completed': 31,
        'current_workload': 14,
        'established_year': 2013,
        'specialization': 'Community Development',
      },
    ),
    AgencyModel(
      id: 'agency_005',
      name: 'Gujarat Infrastructure Authority',
      type: AgencyType.implementingAgency,
      location: const LatLng(23.0225, 72.5714),
      address: 'Gandhinagar, Gujarat - 382010',
      contactPerson: 'Vijay Patel',
      phone: '+91-79-23456789',
      email: 'vijay.patel@gia.gov.in',
      performanceRating: 4.4,
      capacityScore: 82,
      createdAt: DateTime.now().subtract(const Duration(days: 380)),
      updatedAt: DateTime.now(),
      metadata: {
        'team_size': 41,
        'projects_completed': 24,
        'current_workload': 10,
        'established_year': 2014,
        'specialization': 'Industrial Infrastructure',
      },
    ),
  ];

  List<AgencyModel> get _filteredAgencies {
    var agencies = _allAgencies;
    
    // Filter by search
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      agencies = agencies.where((a) =>
        a.name.toLowerCase().contains(query) ||
        (a.contactPerson?.toLowerCase().contains(query) ?? false) ||
        (a.address?.toLowerCase().contains(query) ?? false)
      ).toList();
    }
    
    // Filter by type
    if (_selectedType != null) {
      agencies = agencies.where((a) => a.type == _selectedType).toList();
    }
    
    // Sort
    switch (_sortBy) {
      case 'name':
        agencies.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'performance':
        agencies.sort((a, b) => b.performanceRating.compareTo(a.performanceRating));
        break;
      case 'capacity':
        agencies.sort((a, b) => b.capacityScore.compareTo(a.capacityScore));
        break;
    }
    
    return agencies;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredAgencies = _filteredAgencies;
    
    return Column(
      children: [
        _buildHeader(),
        const SizedBox(height: 16),
        _buildFilters(),
        const SizedBox(height: 16),
        _buildStats(filteredAgencies),
        const SizedBox(height: 16),
        Expanded(
          child: _buildAgencyGrid(filteredAgencies),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryIndigo, AppTheme.secondaryBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.business, color: Colors.white, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Agency Directory',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Comprehensive registry of ${_allAgencies.length} implementing agencies',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Export functionality coming soon')),
              );
            },
            icon: const Icon(Icons.download, size: 18),
            label: const Text('Export'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.primaryIndigo,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by name, contact person, or location...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() => _searchController.clear());
                    },
                  )
                : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) => setState(() {}),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButtonFormField<AgencyType?>(
            value: _selectedType,
            decoration: InputDecoration(
              labelText: 'Agency Type',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('All Types')),
              ...AgencyType.values.map((type) => DropdownMenuItem(
                value: type,
                child: Text(_getAgencyTypeLabel(type)),
              )),
            ],
            onChanged: (value) => setState(() => _selectedType = value),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _sortBy,
            decoration: InputDecoration(
              labelText: 'Sort By',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'name', child: Text('Name')),
              DropdownMenuItem(value: 'performance', child: Text('Performance')),
              DropdownMenuItem(value: 'capacity', child: Text('Capacity')),
            ],
            onChanged: (value) => setState(() => _sortBy = value!),
          ),
        ),
      ],
    );
  }

  Widget _buildStats(List<AgencyModel> agencies) {
    final avgPerformance = agencies.isEmpty ? 0.0 :
      agencies.fold<double>(0, (sum, a) => sum + a.performanceRating) / agencies.length;
    final avgCapacity = agencies.isEmpty ? 0.0 :
      agencies.fold<double>(0, (sum, a) => sum + a.capacityScore) / agencies.length;
    final totalProjects = agencies.fold<int>(0, (sum, a) => 
      sum + ((a.metadata['projects_completed'] as int?) ?? 0));

    return Row(
      children: [
        _buildStatCard('Total Agencies', agencies.length.toString(), Icons.business, Colors.blue),
        const SizedBox(width: 12),
        _buildStatCard('Avg Performance', '${avgPerformance.toStringAsFixed(1)}/5.0', Icons.star, Colors.amber),
        const SizedBox(width: 12),
        _buildStatCard('Avg Capacity', '${avgCapacity.toStringAsFixed(0)}%', Icons.speed, Colors.green),
        const SizedBox(width: 12),
        _buildStatCard('Projects Completed', totalProjects.toString(), Icons.check_circle, Colors.purple),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgencyGrid(List<AgencyModel> agencies) {
    if (agencies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.business_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No agencies found',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: agencies.length,
      itemBuilder: (context, index) {
        return _buildAgencyCard(agencies[index]);
      },
    );
  }

  Widget _buildAgencyCard(AgencyModel agency) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showAgencyDetails(agency),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryIndigo.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.business,
                      color: AppTheme.primaryIndigo,
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
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getAgencyTypeColor(agency.type).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _getAgencyTypeLabel(agency.type),
                            style: TextStyle(
                              fontSize: 10,
                              color: _getAgencyTypeColor(agency.type),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(Icons.star, size: 16, color: Colors.amber[700]),
                  const SizedBox(width: 4),
                  Text(
                    agency.performanceRating.toStringAsFixed(1),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.speed, size: 16, color: Colors.green[700]),
                  const SizedBox(width: 4),
                  Text(
                    '${agency.capacityScore}%',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Projects: ${agency.metadata['projects_completed']}',
                          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        ),
                        Text(
                          'Team: ${agency.metadata['team_size']}',
                          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.info_outline, size: 20),
                    onPressed: () => _showAgencyDetails(agency),
                    tooltip: 'View Details',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAgencyDetails(AgencyModel agency) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 600,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryIndigo.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.business,
                      color: AppTheme.primaryIndigo,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          agency.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getAgencyTypeColor(agency.type).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _getAgencyTypeLabel(agency.type),
                            style: TextStyle(
                              fontSize: 12,
                              color: _getAgencyTypeColor(agency.type),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 32),
              _buildDetailRow('Contact Person', agency.contactPerson ?? 'N/A', Icons.person),
              _buildDetailRow('Phone', agency.phone ?? 'N/A', Icons.phone),
              _buildDetailRow('Email', agency.email ?? 'N/A', Icons.email),
              _buildDetailRow('Address', agency.address ?? 'N/A', Icons.location_on),
              const Divider(height: 24),
              const Text('Performance Metrics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              _buildMetricBar('Performance Rating', agency.performanceRating / 5.0, Colors.amber),
              _buildMetricBar('Capacity Score', agency.capacityScore / 100.0, Colors.green),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildInfoCard('Team Size', agency.metadata['team_size'].toString())),
                  const SizedBox(width: 12),
                  Expanded(child: _buildInfoCard('Projects Completed', agency.metadata['projects_completed'].toString())),
                  const SizedBox(width: 12),
                  Expanded(child: _buildInfoCard('Current Workload', agency.metadata['current_workload'].toString())),
                ],
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Specialization', agency.metadata['specialization']?.toString() ?? 'N/A', Icons.work),
              _buildDetailRow('Established', agency.metadata['established_year']?.toString() ?? 'N/A', Icons.calendar_today),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricBar(String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 12)),
              Text('${(value * 100).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: Colors.grey[200],
              color: color,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryIndigo.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.primaryIndigo.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryIndigo,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getAgencyTypeLabel(AgencyType type) {
    switch (type) {
      case AgencyType.implementingAgency:
        return 'Implementing';
      case AgencyType.nodalAgency:
        return 'Nodal';
      case AgencyType.technicalAgency:
        return 'Technical';
      case AgencyType.monitoringAgency:
        return 'Monitoring';
    }
  }

  Color _getAgencyTypeColor(AgencyType type) {
    switch (type) {
      case AgencyType.implementingAgency:
        return Colors.blue;
      case AgencyType.nodalAgency:
        return Colors.green;
      case AgencyType.technicalAgency:
        return Colors.orange;
      case AgencyType.monitoringAgency:
        return Colors.purple;
    }
  }
}