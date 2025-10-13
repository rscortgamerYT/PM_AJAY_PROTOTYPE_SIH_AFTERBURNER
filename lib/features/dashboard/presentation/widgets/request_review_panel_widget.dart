import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Request Review & Approval Panel Widget
/// 
/// Allows Centre admins to review State requests to launch new scheme components.
/// Features e-sign approval, rejection with comments, and auto-generated sanction orders.
class RequestReviewPanelWidget extends StatefulWidget {
  const RequestReviewPanelWidget({super.key});

  @override
  State<RequestReviewPanelWidget> createState() => _RequestReviewPanelWidgetState();
}

class _RequestReviewPanelWidgetState extends State<RequestReviewPanelWidget> {
  String _filterStatus = 'pending'; // 'pending', 'approved', 'rejected', 'all'
  String _sortBy = 'date'; // 'date', 'priority', 'amount'

  final List<StateRequest> _mockRequests = [
    StateRequest(
      id: 'REQ-2025-001',
      stateName: 'Maharashtra',
      requestType: 'New Component Launch',
      component: 'Adarsh Gram Yojana',
      submittedDate: DateTime.now().subtract(const Duration(days: 2)),
      priority: 'High',
      estimatedAmount: 5000000,
      status: 'pending',
      description: 'Request to launch Adarsh Gram component in 15 districts covering 120 villages',
      documents: ['proposal.pdf', 'budget_estimate.xlsx', 'district_map.pdf'],
    ),
    StateRequest(
      id: 'REQ-2025-002',
      stateName: 'Karnataka',
      requestType: 'Budget Revision',
      component: 'GIA Implementation',
      submittedDate: DateTime.now().subtract(const Duration(days: 5)),
      priority: 'Medium',
      estimatedAmount: 3500000,
      status: 'pending',
      description: 'Request for additional budget allocation due to increased material costs',
      documents: ['revised_budget.xlsx', 'justification.pdf'],
    ),
    StateRequest(
      id: 'REQ-2025-003',
      stateName: 'Tamil Nadu',
      requestType: 'New Component Launch',
      component: 'Hostel Construction',
      submittedDate: DateTime.now().subtract(const Duration(days: 8)),
      priority: 'High',
      estimatedAmount: 8000000,
      status: 'approved',
      description: 'Construction of 25 new hostels in tribal areas',
      documents: ['proposal.pdf', 'site_survey.pdf', 'technical_specs.pdf'],
      approvedBy: 'Centre Admin',
      approvedDate: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  List<StateRequest> get _filteredRequests {
    var requests = _mockRequests.where((r) {
      if (_filterStatus == 'all') return true;
      return r.status == _filterStatus;
    }).toList();

    // Sort
    requests.sort((a, b) {
      switch (_sortBy) {
        case 'priority':
          return _getPriorityValue(b.priority).compareTo(_getPriorityValue(a.priority));
        case 'amount':
          return b.estimatedAmount.compareTo(a.estimatedAmount);
        default:
          return b.submittedDate.compareTo(a.submittedDate);
      }
    });

    return requests;
  }

  int _getPriorityValue(String priority) {
    switch (priority.toLowerCase()) {
      case 'high': return 3;
      case 'medium': return 2;
      case 'low': return 1;
      default: return 0;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high': return AppTheme.errorRed;
      case 'medium': return AppTheme.warningOrange;
      case 'low': return AppTheme.successGreen;
      default: return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved': return AppTheme.successGreen;
      case 'rejected': return AppTheme.errorRed;
      case 'pending': return AppTheme.warningOrange;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black, // Black background as requested
      child: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: _filteredRequests.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredRequests.length,
                    itemBuilder: (context, index) {
                      return _buildRequestCard(_filteredRequests[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black, // Black background
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade800, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'pending', label: Text('Pending')),
                ButtonSegment(value: 'approved', label: Text('Approved')),
                ButtonSegment(value: 'rejected', label: Text('Rejected')),
                ButtonSegment(value: 'all', label: Text('All')),
              ],
              selected: {_filterStatus},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() => _filterStatus = newSelection.first);
              },
            ),
          ),
          const SizedBox(width: 16),
          DropdownButton<String>(
            value: _sortBy,
            items: const [
              DropdownMenuItem(value: 'date', child: Text('Sort by Date')),
              DropdownMenuItem(value: 'priority', child: Text('Sort by Priority')),
              DropdownMenuItem(value: 'amount', child: Text('Sort by Amount')),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _sortBy = value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 64, color: Colors.grey.shade600),
          const SizedBox(height: 16),
          Text(
            'No requests found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey.shade300, // Light text for black background
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Requests matching your filter will appear here',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade400, // Light text for black background
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(StateRequest request) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      color: Colors.grey[900], // Dark grey card background for better contrast
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getPriorityColor(request.priority).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(request.priority),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    request.priority,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    request.id,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // White text for dark background
                        ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(request.status),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    request.status.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 20, color: AppTheme.secondaryBlue),
                    const SizedBox(width: 8),
                    Text(
                      request.stateName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.secondaryBlue,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                _buildInfoRow('Request Type', request.requestType, Icons.category),
                _buildInfoRow('Component', request.component, Icons.layers),
                _buildInfoRow(
                  'Estimated Amount',
                  '₹${(request.estimatedAmount / 100000).toStringAsFixed(2)} Lakhs',
                  Icons.currency_rupee,
                ),
                _buildInfoRow(
                  'Submitted',
                  _formatDate(request.submittedDate),
                  Icons.calendar_today,
                ),
                
                const SizedBox(height: 12),
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade400, // Light text for dark background
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  request.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade300, // Light text for dark background
                  ),
                ),
                
                if (request.documents.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Attachments',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade400, // Lighter for visibility
                        ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: request.documents.map((doc) {
                      return Chip(
                        avatar: const Icon(Icons.attach_file, size: 16, color: Colors.white70),
                        label: Text(doc, style: const TextStyle(color: Colors.white)),
                        backgroundColor: Colors.grey.shade800, // Dark background for chips
                      );
                    }).toList(),
                  ),
                ],

                if (request.status == 'approved' || request.status == 'rejected') ...[
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        request.status == 'approved' ? Icons.check_circle : Icons.cancel,
                        size: 20,
                        color: _getStatusColor(request.status),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${request.status.toUpperCase()} by ${request.approvedBy ?? "Unknown"}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade300, // Lighter for visibility
                            ),
                      ),
                      const Spacer(),
                      Text(
                        _formatDate(request.approvedDate ?? DateTime.now()),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade300, // Lighter for visibility
                            ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Actions
          if (request.status == 'pending')
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade900, // Dark background for action buttons
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showRejectDialog(request),
                      icon: const Icon(Icons.close),
                      label: const Text('Reject'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.errorRed,
                        side: const BorderSide(color: AppTheme.errorRed),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () => _showApprovalDialog(request),
                      icon: const Icon(Icons.check),
                      label: const Text('Approve & E-Sign'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.successGreen,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade400),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade400, // Lighter for visibility
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade200, // Light text for dark background
                ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showApprovalDialog(StateRequest request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to approve this request?'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.successGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Request: ${request.id}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('State: ${request.stateName}'),
                  Text('Amount: ₹${(request.estimatedAmount / 100000).toStringAsFixed(2)} Lakhs'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'A sanction order will be auto-generated and sent to the State admin.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _approveRequest(request);
            },
            icon: const Icon(Icons.verified),
            label: const Text('E-Sign & Approve'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successGreen,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(StateRequest request) {
    final commentController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for rejection:'),
            const SizedBox(height: 16),
            TextField(
              controller: commentController,
              decoration: const InputDecoration(
                hintText: 'Enter rejection reason...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
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
              if (commentController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please provide a rejection reason')),
                );
                return;
              }
              Navigator.pop(context);
              _rejectRequest(request, commentController.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _approveRequest(StateRequest request) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Request ${request.id} approved successfully!'),
        backgroundColor: AppTheme.successGreen,
        action: SnackBarAction(
          label: 'View Sanction Order',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
    setState(() {
      request.status = 'approved';
      request.approvedBy = 'Centre Admin';
      request.approvedDate = DateTime.now();
    });
  }

  void _rejectRequest(StateRequest request, String reason) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Request ${request.id} rejected'),
        backgroundColor: AppTheme.errorRed,
      ),
    );
    setState(() {
      request.status = 'rejected';
      request.approvedBy = 'Centre Admin';
      request.approvedDate = DateTime.now();
      request.rejectionReason = reason;
    });
  }
}

/// State Request Model
class StateRequest {
  final String id;
  final String stateName;
  final String requestType;
  final String component;
  final DateTime submittedDate;
  final String priority;
  final double estimatedAmount;
  String status;
  final String description;
  final List<String> documents;
  String? approvedBy;
  DateTime? approvedDate;
  String? rejectionReason;

  StateRequest({
    required this.id,
    required this.stateName,
    required this.requestType,
    required this.component,
    required this.submittedDate,
    required this.priority,
    required this.estimatedAmount,
    required this.status,
    required this.description,
    required this.documents,
    this.approvedBy,
    this.approvedDate,
    this.rejectionReason,
  });
}