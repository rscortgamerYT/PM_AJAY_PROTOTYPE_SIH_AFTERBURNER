import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/request_model.dart';

class StateReviewPanelWidget extends ConsumerStatefulWidget {
  const StateReviewPanelWidget({super.key});

  @override
  ConsumerState<StateReviewPanelWidget> createState() => _StateReviewPanelWidgetState();
}

class _StateReviewPanelWidgetState extends ConsumerState<StateReviewPanelWidget> {
  final TextEditingController _searchController = TextEditingController();
  ProjectComponent _selectedComponentFilter = ProjectComponent.all;
  RequestStatus _selectedStatusFilter = RequestStatus.pending;
  RequestModel? _selectedRequest;
  
  // Mock data - to be replaced with Supabase queries
  final List<RequestModel> _mockRequests = [
    RequestModel(
      id: 'aor_001',
      agencyId: 'agency_mh_001',
      agencyName: 'Maharashtra Rural Development Agency',
      type: RequestType.projectAssignment,
      priority: RequestPriority.high,
      status: RequestStatus.pending,
      title: 'Agency Onboarding Request',
      description: 'Request for onboarding as implementing agency',
      rationale: 'Expanding PM-AJAY implementation in Maharashtra',
      component: ProjectComponent.adarshGram,
      stateId: 'state_001',
      districtId: 'dist_001',
      submittedBy: 'agency_mh_001',
      submittedAt: DateTime.now().subtract(const Duration(days: 3)),
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      metadata: {
        'agencyType': 'implementing_agency',
        'legalStatus': 'Registered Society',
        'gstNumber': 'GST27XXXXX',
        'registrationNumber': 'REG/MH/2020/12345',
        'staffingLevel': 45,
        'capacityRating': 7.8,
        'geographicCoverage': ['Mumbai', 'Thane', 'Raigad'],
      },
    ),
    RequestModel(
      id: 'aor_002',
      agencyId: 'agency_ka_001',
      agencyName: 'Karnataka Social Welfare Board',
      type: RequestType.projectAssignment,
      priority: RequestPriority.medium,
      status: RequestStatus.pending,
      title: 'Agency Onboarding Request',
      description: 'Request for onboarding as nodal agency',
      rationale: 'Coordinating PM-AJAY implementation in Karnataka',
      component: ProjectComponent.hostel,
      stateId: 'state_002',
      districtId: 'dist_002',
      submittedBy: 'agency_ka_001',
      submittedAt: DateTime.now().subtract(const Duration(days: 1)),
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      metadata: {
        'agencyType': 'nodal_agency',
        'legalStatus': 'Government Board',
        'gstNumber': 'GST29XXXXX',
        'registrationNumber': 'REG/KA/2019/67890',
        'staffingLevel': 60,
        'capacityRating': 8.5,
        'geographicCoverage': ['Bengaluru', 'Mysuru', 'Hubli'],
      },
    ),
  ];

  List<RequestModel> get _filteredRequests {
    return _mockRequests.where((request) {
      final matchesSearch = _searchController.text.isEmpty ||
          request.agencyName.toLowerCase().contains(_searchController.text.toLowerCase());
      final matchesComponent = _selectedComponentFilter == ProjectComponent.all ||
          request.component == _selectedComponentFilter;
      final matchesStatus = request.status == _selectedStatusFilter;
      
      return matchesSearch && matchesComponent && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green.shade50,
            Colors.teal.shade50,
          ],
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          _buildTopBar(),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildRequestsList(),
                ),
                if (_selectedRequest != null)
                  Expanded(
                    flex: 3,
                    child: _buildRequestDetails(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.business, size: 32, color: Colors.green.shade700),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Agency Onboarding Requests',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Review and approve agency participation',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const Spacer(),
          _buildStatCard('Pending', _mockRequests.where((r) => r.status == RequestStatus.pending).length, Colors.amber),
          const SizedBox(width: 16),
          _buildStatCard('Under Review', _mockRequests.where((r) => r.status == RequestStatus.underReview).length, Colors.blue),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by agency name...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(width: 16),
          DropdownButton<ProjectComponent>(
            value: _selectedComponentFilter,
            items: ProjectComponent.values.map((component) {
              return DropdownMenuItem(
                value: component,
                child: Text(component.displayName),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedComponentFilter = value);
              }
            },
          ),
          const SizedBox(width: 16),
          DropdownButton<RequestStatus>(
            value: _selectedStatusFilter,
            items: RequestStatus.values.map((status) {
              return DropdownMenuItem(
                value: status,
                child: Text(status.displayName),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedStatusFilter = value);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsList() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: ListView.separated(
        itemCount: _filteredRequests.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final request = _filteredRequests[index];
          final isSelected = _selectedRequest?.id == request.id;
          final metadata = request.metadata ?? {};
          
          return ListTile(
            selected: isSelected,
            selectedTileColor: Colors.green.shade50,
            onTap: () => setState(() => _selectedRequest = request),
            leading: CircleAvatar(
              backgroundColor: request.priority.color.withOpacity(0.2),
              child: Icon(
                Icons.business,
                color: request.priority.color,
              ),
            ),
            title: Text(
              request.agencyName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(request.component?.displayName ?? 'N/A'),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: request.status.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        request.status.displayName,
                        style: TextStyle(
                          fontSize: 11,
                          color: request.status.color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (metadata['capacityRating'] != null)
                      Row(
                        children: [
                          Icon(Icons.star, size: 14, color: Colors.amber.shade700),
                          const SizedBox(width: 4),
                          Text(
                            '${(metadata['capacityRating'] as num).toStringAsFixed(1)}/10',
                            style: const TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (metadata['staffingLevel'] != null)
                  Text(
                    '${metadata['staffingLevel']} Staff',
                    style: const TextStyle(fontSize: 12),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRequestDetails() {
    if (_selectedRequest == null) return const SizedBox();
    
    final request = _selectedRequest!;
    final metadata = request.metadata ?? {};
    
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade700, Colors.teal.shade600],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.agencyName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        request.component?.displayName ?? 'N/A',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => setState(() => _selectedRequest = null),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Basic Information'),
                  _buildDetailRow('Agency Type', (metadata['agencyType'] as String?)?.replaceAll('_', ' ').toUpperCase() ?? 'N/A'),
                  _buildDetailRow('Legal Status', metadata['legalStatus'] as String? ?? 'N/A'),
                  _buildDetailRow('GST Number', metadata['gstNumber'] as String? ?? 'N/A'),
                  _buildDetailRow('Registration', metadata['registrationNumber'] as String? ?? 'N/A'),
                  _buildDetailRow('Submitted By', request.submittedBy ?? 'N/A'),
                  const SizedBox(height: 24),
                  
                  _buildSectionTitle('Capacity Details'),
                  if (metadata['staffingLevel'] != null)
                    _buildDetailRow('Staffing Level', '${metadata['staffingLevel']} employees'),
                  if (metadata['capacityRating'] != null)
                    _buildDetailRow('Capacity Rating', '${(metadata['capacityRating'] as num).toStringAsFixed(1)}/10'),
                  if (metadata['geographicCoverage'] != null)
                    _buildDetailRow('Geographic Coverage', (metadata['geographicCoverage'] as List).join(', ')),
                  _buildDetailRow('Component', request.component?.displayName ?? 'N/A'),
                  const SizedBox(height: 24),
                  
                  _buildSectionTitle('Actions'),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _handleApprove(request),
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Approve'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _handleReject(request),
                          icon: const Icon(Icons.cancel),
                          label: const Text('Reject'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            padding: const EdgeInsets.all(16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.green.shade900,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _handleApprove(RequestModel request) {
    // TODO: Implement approval logic with e-sign
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Approving ${request.agencyName}...')),
    );
  }

  void _handleReject(RequestModel request) {
    // TODO: Implement rejection logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Rejecting ${request.agencyName}...')),
    );
  }
}