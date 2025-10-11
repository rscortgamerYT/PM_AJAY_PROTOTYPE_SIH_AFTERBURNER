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
      title: 'Agency Project Assignment Request',
      description: 'Request for project assignment in Adarsh Gram component',
      rationale: 'Expanding PM-AJAY implementation in Maharashtra districts',
      component: ProjectComponent.adarshGram,
      stateId: 'state_001',
      districtId: 'dist_001',
      submittedBy: 'agency_mh_001',
      submittedAt: DateTime.now().subtract(const Duration(days: 3)),
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      supportingDocuments: [
        RequestDocument(
          id: 'doc_001',
          name: 'Agency_Registration_Certificate.pdf',
          url: 'https://example.com/docs/reg_cert.pdf',
          type: 'application/pdf',
          size: 245678,
          uploadedAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
        RequestDocument(
          id: 'doc_002',
          name: 'GST_Certificate.pdf',
          url: 'https://example.com/docs/gst_cert.pdf',
          type: 'application/pdf',
          size: 156789,
          uploadedAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
        RequestDocument(
          id: 'doc_003',
          name: 'Capacity_Assessment_Report.pdf',
          url: 'https://example.com/docs/capacity.pdf',
          type: 'application/pdf',
          size: 567890,
          uploadedAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
      ],
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
      title: 'Agency Project Assignment Request',
      description: 'Request for project assignment in Hostel component',
      rationale: 'Coordinating PM-AJAY Hostel construction in Karnataka',
      component: ProjectComponent.hostel,
      stateId: 'state_002',
      districtId: 'dist_002',
      submittedBy: 'agency_ka_001',
      submittedAt: DateTime.now().subtract(const Duration(days: 1)),
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      supportingDocuments: [
        RequestDocument(
          id: 'doc_004',
          name: 'Board_Resolution.pdf',
          url: 'https://example.com/docs/resolution.pdf',
          type: 'application/pdf',
          size: 345678,
          uploadedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        RequestDocument(
          id: 'doc_005',
          name: 'Financial_Statements_2024.pdf',
          url: 'https://example.com/docs/financials.pdf',
          type: 'application/pdf',
          size: 789012,
          uploadedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ],
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
            child: const Icon(Icons.approval, color: Colors.white, size: 32),
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
                  'Review and approve Agency requests with document verification',
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
                  _buildSectionTitle('Request Information'),
                  _buildDetailRow('Request ID', request.id),
                  _buildDetailRow('Agency Name', request.agencyName),
                  _buildDetailRow('Component', request.component?.displayName ?? 'N/A'),
                  _buildDetailRow('Priority', request.priority.displayName.toUpperCase()),
                  _buildDetailRow('Submitted', _formatDate(request.submittedAt)),
                  const SizedBox(height: 24),
                  
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
                  const SizedBox(height: 24),
                  
                  _buildSectionTitle('Supporting Documents'),
                  _buildDocumentsList(request),
                  const SizedBox(height: 24),
                  
                  _buildSectionTitle('Review Actions'),
                  if (request.status == RequestStatus.pending || request.status == RequestStatus.infoRequested)
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _handleApprove(request),
                                icon: const Icon(Icons.check_circle),
                                label: const Text('E-sign & Approve'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.all(16),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _handleReject(request),
                                icon: const Icon(Icons.cancel),
                                label: const Text('Reject'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.all(16),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => _handleRequestInfo(request),
                            icon: const Icon(Icons.info_outline),
                            label: const Text('Request More Information'),
                            style: OutlinedButton.styleFrom(
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

  Widget _buildDocumentsList(RequestModel request) {
    final documents = request.supportingDocuments ?? [];
    
    if (documents.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.grey),
            SizedBox(width: 12),
            Text('No documents attached', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
    
    return Column(
      children: documents.map((doc) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade50,
              child: const Icon(Icons.description, color: Colors.blue),
            ),
            title: Text(doc.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${(doc.size / 1024).toStringAsFixed(2)} KB • ${doc.type}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility),
                  onPressed: () => _viewDocument(doc),
                  tooltip: 'View Document',
                ),
                IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: () => _downloadDocument(doc),
                  tooltip: 'Download Document',
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _viewDocument(RequestDocument doc) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening ${doc.name}...')),
    );
  }

  void _downloadDocument(RequestDocument doc) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Downloading ${doc.name}...')),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _handleApprove(RequestModel request) {
    showDialog(
      context: context,
      builder: (context) => _ESignApprovalDialog(request: request),
    );
  }

  void _handleReject(RequestModel request) {
    final reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to reject the request from ${request.agencyName}?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Rejection Reason',
                hintText: 'Provide reason for rejection...',
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

  void _handleRequestInfo(RequestModel request) {
    final questionController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Additional Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Request additional information from ${request.agencyName}:'),
            const SizedBox(height: 16),
            TextField(
              controller: questionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Information Required',
                hintText: 'Specify what information is needed...',
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
                  const SnackBar(content: Text('Please specify information required')),
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
                'Review and approve Agency requests for project assignments. Verify all supporting documents before approval.',
              ),
              SizedBox(height: 16),
              Text(
                'Features',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text('• Filter requests by component, status, and priority'),
              Text('• View detailed agency profiles and capacity'),
              Text('• Review and verify supporting documents'),
              Text('• Approve requests with e-signature'),
              Text('• Reject with mandatory reason'),
              Text('• Request additional information from agencies'),
              Text('• Full audit trail and notifications'),
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

class _ESignApprovalDialog extends StatefulWidget {
  final RequestModel request;

  const _ESignApprovalDialog({required this.request});

  @override
  State<_ESignApprovalDialog> createState() => _ESignApprovalDialogState();
}

class _ESignApprovalDialogState extends State<_ESignApprovalDialog> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.verified_user, color: Colors.green),
          SizedBox(width: 8),
          Text('E-Sign Approval'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Approve request from ${widget.request.agencyName}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text('Enter OTP sent to your registered mobile number:'),
          const SizedBox(height: 12),
          TextField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: const InputDecoration(
              labelText: 'OTP',
              hintText: 'Enter 6-digit OTP',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.lock),
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
          onPressed: _isLoading ? null : _handleESignApproval,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Approve'),
        ),
      ],
    );
  }

  Future<void> _handleESignApproval() async {
    if (_otpController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid 6-digit OTP')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Simulate e-sign process
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Request approved: ${widget.request.agencyName}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }
}