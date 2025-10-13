import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/request_model.dart';
import '../../../evidence/widgets/tamper_evident_evidence_widget.dart';

class CentreReviewPanelWidget extends ConsumerStatefulWidget {
  const CentreReviewPanelWidget({super.key});

  @override
  ConsumerState<CentreReviewPanelWidget> createState() => _CentreReviewPanelWidgetState();
}

class _CentreReviewPanelWidgetState extends ConsumerState<CentreReviewPanelWidget> {
  final TextEditingController _searchController = TextEditingController();
  ProjectComponent _selectedComponentFilter = ProjectComponent.all;
  RequestStatus _selectedStatusFilter = RequestStatus.pending;
  final RequestPriority _selectedPriorityFilter = RequestPriority.medium;
  RequestModel? _selectedRequest;
  
  // Mock data - to be replaced with Supabase queries
  final List<RequestModel> _mockRequests = [
    RequestModel(
      id: 'req_001',
      agencyId: 'agency_001',
      agencyName: 'Maharashtra State Nodal Agency',
      type: RequestType.fundAllocation,
      title: 'Maharashtra State Participation Request',
      description: 'Request for state participation in PM-AJAY scheme implementation',
      rationale: 'To implement comprehensive rural development across Maharashtra',
      stateId: 'state_001',
      stateName: 'Maharashtra',
      component: ProjectComponent.adarshGram,
      proposedFundAllocation: 50000000.0,
      proposedProjects: 25,
      targetDistricts: ['Mumbai', 'Pune', 'Nagpur'],
      proposedStartDate: DateTime.now().add(const Duration(days: 30)),
      proposedEndDate: DateTime.now().add(const Duration(days: 395)),
      kpis: {
        'villages_covered': 100,
        'beneficiaries_target': 5000,
        'employment_generation': 1200,
      },
      status: RequestStatus.pending,
      priority: RequestPriority.high,
      submittedBy: 'user_mh_001',
      submittedAt: DateTime.now().subtract(const Duration(days: 2)),
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    RequestModel(
      id: 'req_002',
      agencyId: 'agency_002',
      agencyName: 'Karnataka State Nodal Agency',
      type: RequestType.fundAllocation,
      title: 'Karnataka State Participation Request',
      description: 'Request for state participation in PM-AJAY GIA component',
      rationale: 'To support SC/ST institutions across Karnataka',
      stateId: 'state_002',
      stateName: 'Karnataka',
      component: ProjectComponent.gia,
      proposedFundAllocation: 35000000.0,
      proposedProjects: 18,
      targetDistricts: ['Bengaluru', 'Mysuru', 'Mangaluru'],
      proposedStartDate: DateTime.now().add(const Duration(days: 45)),
      proposedEndDate: DateTime.now().add(const Duration(days: 410)),
      kpis: {
        'institutions_supported': 50,
        'beneficiaries_target': 3500,
        'skill_training_hours': 10000,
      },
      status: RequestStatus.pending,
      priority: RequestPriority.medium,
      submittedBy: 'user_ka_001',
      submittedAt: DateTime.now().subtract(const Duration(days: 1)),
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  List<RequestModel> get _filteredRequests {
    return _mockRequests.where((request) {
      final matchesSearch = _searchController.text.isEmpty ||
          (request.stateName?.toLowerCase().contains(_searchController.text.toLowerCase()) ?? false);
      final matchesComponent = _selectedComponentFilter == ProjectComponent.all ||
          request.component == _selectedComponentFilter;
      final matchesStatus = request.status == _selectedStatusFilter;
      final matchesPriority = request.priority == _selectedPriorityFilter;
      
      return matchesSearch && matchesComponent && matchesStatus && matchesPriority;
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
            Colors.blue.shade50,
            Colors.indigo.shade50,
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
          colors: [Colors.blue.shade700, Colors.indigo.shade700],
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
                  'Centre Review & Approval Panel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Review and approve State participation requests for PM-AJAY schemes',
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
                hintText: 'Search by state name...',
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
              initialValue: _selectedComponentFilter,
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
              initialValue: _selectedStatusFilter,
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
                  child: Text(status.displayName.toUpperCase()),
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
              // Export functionality
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Requests Queue (${filteredRequests.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (filteredRequests.length > 1)
                  TextButton.icon(
                    onPressed: () {
                      // Bulk actions
                      _showBulkActionsDialog(context);
                    },
                    icon: const Icon(Icons.checklist),
                    label: const Text('Bulk Actions'),
                  ),
              ],
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
                            color: isSelected ? Colors.blue.shade50 : null,
                            border: Border(
                              left: BorderSide(
                                color: isSelected ? Colors.blue : Colors.transparent,
                                width: 4,
                              ),
                              bottom: BorderSide(color: Colors.grey.shade200),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      request.stateName ?? 'Unknown State',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  _buildPriorityBadge(request.priority),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.category, size: 14, color: Colors.grey.shade600),
                                  const SizedBox(width: 4),
                                  Text(
                                    request.component?.displayName ?? 'Unknown',
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                  ),
                                  const SizedBox(width: 16),
                                  Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatDate(request.submittedAt),
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  _buildStatusBadge(request.status),
                                  const Spacer(),
                                  Text(
                                    '₹${_formatAmount(request.proposedFundAllocation ?? 0.0)}',
                                    style: TextStyle(
                                      color: Colors.green.shade700,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
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
                        request.stateName ?? 'Unknown State',
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
                    'State Profile',
                    Icons.location_city,
                    [
                      _buildDetailRow('State ID', request.stateId ?? 'N/A'),
                      _buildDetailRow('Submitted By', request.submittedBy ?? 'N/A'),
                      _buildDetailRow('Submission Date', _formatDate(request.submittedAt)),
                      _buildDetailRow('Priority', request.priority.displayName.toUpperCase()),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildDetailSection(
                    'Scheme Parameters',
                    Icons.fact_check,
                    [
                      _buildDetailRow('Component', request.component?.displayName ?? 'N/A'),
                      _buildDetailRow('Fund Allocation', '₹${_formatAmount(request.proposedFundAllocation ?? 0.0)}'),
                      _buildDetailRow('Projects', '${request.proposedProjects ?? 0}'),
                      _buildDetailRow('Districts', request.targetDistricts?.join(', ') ?? 'N/A'),
                      _buildDetailRow('Start Date', request.proposedStartDate != null ? _formatDate(request.proposedStartDate!) : 'N/A'),
                      _buildDetailRow('End Date', request.proposedEndDate != null ? _formatDate(request.proposedEndDate!) : 'N/A'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildDetailSection(
                    'Key Performance Indicators',
                    Icons.trending_up,
                    (request.kpis?.entries ?? <MapEntry<String, dynamic>>[]).map((entry) {
                      return _buildDetailRow(
                        entry.key.replaceAll('_', ' ').toUpperCase(),
                        '${entry.value}',
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  _buildDetailSection(
                    'Supporting Documents',
                    Icons.attach_file,
                    (request.supportingDocuments?.isEmpty ?? true)
                        ? [const Text('No documents attached', style: TextStyle(color: Colors.grey))]
                        : (request.supportingDocuments ?? []).map((doc) {
                            return ListTile(
                              leading: const Icon(Icons.description, color: Colors.blue),
                              title: Text(doc.name),
                              subtitle: Text('${(doc.size / 1024).toStringAsFixed(2)} KB'),
                              trailing: IconButton(
                                icon: const Icon(Icons.download),
                                onPressed: () {
                                  // Download document
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Downloading ${doc.name}...')),
                                  );
                                },
                              ),
                            );
                          }).toList(),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildDetailSection(
                    'Evidence Review & Watermarking',
                    Icons.security,
                    [
                      SizedBox(
                        height: 400,
                        child: TamperEvidentEvidenceWidget(
                          projectId: request.id,
                          uploaderName: request.stateName ?? 'Centre Review',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (request.reviewComments != null) ...[
                    _buildDetailSection(
                      'Review Comments',
                      Icons.comment,
                      [Text(request.reviewComments!)],
                    ),
                    const SizedBox(height: 24),
                  ],
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
            Icon(icon, size: 20, color: Colors.blue.shade700),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
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
              label: const Text('Approve'),
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
      case RequestStatus.moreInfoRequired:
        color = Colors.amber;
        text = 'MORE INFO REQUIRED';
        break;
      case RequestStatus.cancelled:
        color = Colors.grey;
        text = 'CANCELLED';
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

  Widget _buildPriorityBadge(RequestPriority priority) {
    Color color;
    IconData icon;
    
    switch (priority) {
      case RequestPriority.low:
        color = Colors.grey;
        icon = Icons.arrow_downward;
        break;
      case RequestPriority.medium:
        color = Colors.blue;
        icon = Icons.remove;
        break;
      case RequestPriority.high:
        color = Colors.orange;
        icon = Icons.arrow_upward;
        break;
      case RequestPriority.urgent:
        color = Colors.red;
        icon = Icons.priority_high;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(icon, size: 16, color: color),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatAmount(double amount) {
    if (amount >= 10000000) {
      return '${(amount / 10000000).toStringAsFixed(2)} Cr';
    } else if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(2)} L';
    } else {
      return amount.toStringAsFixed(2);
    }
  }

  void _handleApprove(BuildContext context, RequestModel request) {
    showDialog(
      context: context,
      builder: (context) => _ESignApprovalDialog(request: request),
    );
  }

  void _handleReject(BuildContext context, RequestModel request) {
    final reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Request'),
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
              
              // Update request status and send notification
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Request rejected: ${request.stateName}'),
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
            const Text('Specify the information needed from the State:'),
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
              
              // Create sub-ticket in Communication Hub
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Information request sent to ${request.stateName}'),
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

  void _showBulkActionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bulk Actions'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.check_circle, color: Colors.green),
              title: Text('Bulk Approve'),
            ),
            ListTile(
              leading: Icon(Icons.cancel, color: Colors.red),
              title: Text('Bulk Reject'),
            ),
          ],
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

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: Colors.blue),
            SizedBox(width: 8),
            Text('Centre Review Panel Help'),
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
                'Review and approve or reject State requests to participate in PM-AJAY schemes, ensuring compliance with national norms.',
              ),
              SizedBox(height: 16),
              Text(
                'Features',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text('• Filter requests by component, status, and priority'),
              Text('• View detailed state profiles and scheme parameters'),
              Text('• Approve requests with e-signature'),
              Text('• Reject with mandatory reason'),
              Text('• Request additional information via sub-tickets'),
              Text('• Bulk actions for multiple requests'),
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
            'Approve request from ${widget.request.stateName ?? 'Unknown State'} for ${widget.request.component?.displayName ?? 'Unknown'}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            'Amount: ₹${((widget.request.proposedFundAllocation ?? 0.0) / 10000000).toStringAsFixed(2)} Cr',
            style: TextStyle(color: Colors.green.shade700),
          ),
          const SizedBox(height: 24),
          const Text('Enter OTP to authenticate:'),
          const SizedBox(height: 8),
          TextField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: const InputDecoration(
              hintText: 'Enter 6-digit OTP',
              border: OutlineInputBorder(),
              counterText: '',
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('OTP sent to your registered mobile')),
              );
            },
            child: const Text('Resend OTP'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleApproval,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Approve'),
        ),
      ],
    );
  }

  void _handleApproval() {
    if (_otpController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid 6-digit OTP')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Simulate e-sign process
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Request approved: ${widget.request.stateName}'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }
}