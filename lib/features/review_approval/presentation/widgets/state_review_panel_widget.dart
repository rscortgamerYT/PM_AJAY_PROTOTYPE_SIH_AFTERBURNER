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
      agencyName: 'Maharashtra Rural Development Agency',
      agencyType: 'implementing_agency',
      stateId: 'state_001',
      districtId: 'dist_001',
      requestedComponent: ProjectComponent.adarshaGram,
      legalStatus: 'Registered Society',
      gstNumber: 'GST27XXXXX',
      registrationNumber: 'REG/MH/2020/12345',
      staffingLevel: 45,
      capacityRating: 7.8,
      geographicCoverage: ['Mumbai', 'Thane', 'Raigad'],
      pastPerformance: {
        'projects_completed': 12,
        'avg_completion_rate': 0.89,
        'quality_score': 8.2,
      },
      status: RequestStatus.pending,
      priority: RequestPriority.high,
      submittedBy: 'agency_mh_001',
      submittedAt: DateTime.now().subtract(const Duration(days: 3)),
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    RequestModel(
      id: 'aor_002',
      agencyName: 'Karnataka Social Welfare Board',
      agencyType: 'nodal_agency',
      stateId: 'state_002',
      districtId: 'dist_002',
      requestedComponent: ProjectComponent.hostel,
      legalStatus: 'Government Board',
      gstNumber: 'GST29XXXXX',
      registrationNumber: 'REG/KA/2019/67890',
      staffingLevel: 60,
      capacityRating: 8.5,
      geographicCoverage: ['Bengaluru', 'Mysuru', 'Hubli'],
      pastPerformance: {
        'projects_completed': 18,
        'avg_completion_rate': 0.92,
        'quality_score': 8.7,
      },
      status: RequestStatus.pending,
      priority: RequestPriority.medium,
      submittedBy: 'agency_ka_001',
      submittedAt: DateTime.now().subtract(const Duration(days: 1)),
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  List<RequestModel> get _filteredRequests {
    return _mockRequests.where((request) {
      final matchesSearch = _searchController.text.isEmpty ||
          request.agencyName.toLowerCase().contains(_searchController.text.toLowerCase());
      final matchesComponent = _selectedComponentFilter == ProjectComponent.all ||
          request.requestedComponent == _selectedComponentFilter;
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
                    child: _buildDetailPane(),
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
        gradient: LinearGradient(
          colors: [Colors.green.shade700, Colors.teal.shade700],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.business, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'State Review & Approval Panel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Review and onboard Agency requests for PM-AJAY project execution',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: () => _showHelpDialog(context),
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
            flex: 2,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by agency name...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<ProjectComponent>(
              value: _selectedComponentFilter,
              decoration: InputDecoration(
                labelText: 'Component',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
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
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<RequestStatus>(
              value: _selectedStatusFilter,
              decoration: InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              items: RequestStatus.values.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status.value.replaceAll('_', ' ').toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedStatusFilter = value);
                }
              },
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Export functionality coming soon')),
              );
            },
            icon: const Icon(Icons.download),
            label: const Text('Export'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsList() {
    final filteredRequests = _filteredRequests;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Agency Onboarding Queue (${filteredRequests.length})',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: filteredRequests.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No requests match your filters',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredRequests.length,
                    itemBuilder: (context, index) {
                      final request = filteredRequests[index];
                      final isSelected = _selectedRequest?.id == request.id;
                      
                      return InkWell(
                        onTap: () => setState(() => _selectedRequest = request),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.green.shade50 : null,
                            border: Border(
                              left: BorderSide(
                                color: isSelected ? Colors.green : Colors.transparent,
                                width: 4,
                              ),
                              bottom: BorderSide(color: Colors.grey.shade200),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                request.agencyName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.category, size: 14, color: Colors.grey.shade600),
                                  const SizedBox(width: 4),
                                  Text(
                                    request.requestedComponent.displayName,
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                  ),
                                  const SizedBox(width: 16),
                                  Icon(Icons.star, size: 14, color: Colors.amber.shade700),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${request.capacityRating.toStringAsFixed(1)}/10',
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  _buildStatusBadge(request.status),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${request.staffingLevel} Staff',
                                      style: TextStyle(
                                        color: Colors.blue.shade700,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
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

  Widget _buildDetailPane() {
    if (_selectedRequest == null) return const SizedBox.shrink();
    
    final request = _selectedRequest!;
    
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 16, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
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
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Request ID: ${request.id}',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(request.status),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailSection(
                    'Agency Profile',
                    Icons.business,
                    [
                      _buildDetailRow('Agency Type', request.agencyType.replaceAll('_', ' ').toUpperCase()),
                      _buildDetailRow('Legal Status', request.legalStatus),
                      _buildDetailRow('GST Number', request.gstNumber),
                      _buildDetailRow('Registration', request.registrationNumber),
                      _buildDetailRow('Submitted By', request.submittedBy),
                      _buildDetailRow('Submission Date', _formatDate(request.submittedAt)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildDetailSection(
                    'Operational Capacity',
                    Icons.analytics,
                    [
                      _buildDetailRow('Staffing Level', '${request.staffingLevel} employees'),
                      _buildDetailRow('Capacity Rating', '${request.capacityRating.toStringAsFixed(1)}/10'),
                      _buildDetailRow('Geographic Coverage', request.geographicCoverage.join(', ')),
                      _buildDetailRow('Component', request.requestedComponent.displayName),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildDetailSection(
                    'Past Performance',
                    Icons.trending_up,
                    request.pastPerformance.entries.map((entry) {
                      return _buildDetailRow(
                        entry.key.replaceAll('_', ' ').toUpperCase(),
                        entry.value is double 
                            ? (entry.value as double).toStringAsFixed(2)
                            : '${entry.value}',
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  if (request.capacityGapIdentified) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.warning_amber, color: Colors.orange.shade700),
                              const SizedBox(width: 8),
                              Text(
                                'Capacity Gap Identified',
                                style: TextStyle(
                                  color: Colors.orange.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          if (request.capacityGapSuggestions != null) ...[
                            const SizedBox(height: 8),
                            Text(request.capacityGapSuggestions!),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  _buildDetailSection(
                    'Compliance Documents',
                    Icons.attach_file,
                    request.complianceDocuments.isEmpty
                        ? [const Text('No documents attached', style: TextStyle(color: Colors.grey))]
                        : request.complianceDocuments.map((doc) {
                            return ListTile(
                              leading: const Icon(Icons.description, color: Colors.green),
                              title: Text(doc.fileName),
                              subtitle: Text('${(doc.fileSize / 1024).toStringAsFixed(2)} KB'),
                              trailing: IconButton(
                                icon: const Icon(Icons.download),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Downloading ${doc.fileName}...')),
                                  );
                                },
                              ),
                            );
                          }).toList(),
                  ),
                ],
              ),
            ),
          ),
          _buildApprovalControls(request),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.green.shade700),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApprovalControls(RequestModel request) {
    if (request.status != RequestStatus.pending && 
        request.status != RequestStatus.infoRequested) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _handleApprove(context, request),
              icon: const Icon(Icons.check_circle),
              label: const Text('Approve & Onboard'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _handleReject(context, request),
              icon: const Icon(Icons.cancel),
              label: const Text('Reject'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _handleRequestInfo(context, request),
              icon: const Icon(Icons.info_outline),
              label: const Text('Request Info'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(RequestStatus status) {
    Color color;
    String text;
    
    switch (status) {
      case RequestStatus.pending:
        color = Colors.orange;
        text = 'PENDING';
        break;
      case RequestStatus.underReview:
        color = Colors.blue;
        text = 'UNDER REVIEW';
        break;
      case RequestStatus.infoRequested:
        color = Colors.purple;
        text = 'INFO REQUESTED';
        break;
      case RequestStatus.approved:
        color = Colors.green;
        text = 'APPROVED';
        break;
      case RequestStatus.rejected:
        color = Colors.red;
        text = 'REJECTED';
        break;
      case RequestStatus.expired:
        color = Colors.grey;
        text = 'EXPIRED';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _handleApprove(BuildContext context, RequestModel request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Approve Agency Onboarding'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Approve onboarding for ${request.agencyName}?',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('This will:'),
            const Text('• Generate digital onboarding certificate'),
            const Text('• Create agency user account'),
            const Text('• Assign initial work order template'),
            const Text('• Send notification to agency'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Agency approved: ${request.agencyName}'),
                  backgroundColor: Colors.green,
                ),
              );
              setState(() => _selectedRequest = null);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Approve & Onboard'),
          ),
        ],
      ),
    );
  }

  void _handleReject(BuildContext context, RequestModel request) {
    final reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Onboarding Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Please provide a reason for rejection:'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Enter rejection reason...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Rejection reason is required')),
                );
                return;
              }
              
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Request rejected: ${request.agencyName}'),
                  backgroundColor: Colors.red,
                ),
              );
              setState(() => _selectedRequest = null);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _handleRequestInfo(BuildContext context, RequestModel request) {
    final questionController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Additional Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Specify the information needed from the Agency:'),
            const SizedBox(height: 16),
            TextField(
              controller: questionController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Enter your questions...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (questionController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter your questions')),
                );
                return;
              }
              
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Information request sent to ${request.agencyName}'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            child: const Text('Send Request'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: Colors.green),
            SizedBox(width: 8),
            Text('State Review Panel Help'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Purpose',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'Review and onboard Agency requests for executing PM-AJAY components within your jurisdiction.',
              ),
              SizedBox(height: 16),
              Text(
                'Features',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text('• Filter requests by component and status'),
              Text('• View agency profiles and capacity ratings'),
              Text('• Assess past performance metrics'),
              Text('• Identify capacity gaps with AI suggestions'),
              Text('• Approve with automatic certificate generation'),
              Text('• Create agency user accounts'),
              Text('• Request additional clarifications'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}