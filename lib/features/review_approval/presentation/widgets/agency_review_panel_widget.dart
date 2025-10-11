import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/request_model.dart';

class AgencyReviewPanelWidget extends ConsumerStatefulWidget {
  const AgencyReviewPanelWidget({super.key});

  @override
  ConsumerState<AgencyReviewPanelWidget> createState() => _AgencyReviewPanelWidgetState();
}

class _AgencyReviewPanelWidgetState extends ConsumerState<AgencyReviewPanelWidget> {
  final TextEditingController _searchController = TextEditingController();
  ProjectComponent _selectedComponentFilter = ProjectComponent.all;
  RequestStatus _selectedStatusFilter = RequestStatus.pending;
  RequestModel? _selectedRequest;
  
  // Mock data - to be replaced with Supabase queries
  final List<RequestModel> _mockRequests = [
    RequestModel(
      id: 'tar_001',
      type: RequestType.projectAssignment,
      title: 'Mumbai Suburban Adarsha Gram Phase 1',
      description: 'Development of 15 model villages with comprehensive infrastructure',
      rationale: 'State-assigned project for rural development',
      projectId: 'proj_001',
      projectName: 'Mumbai Suburban Adarsha Gram Phase 1',
      agencyId: 'agency_001',
      agencyName: 'Maharashtra Rural Development Agency',
      stateId: 'state_001',
      districtId: 'dist_001',
      component: ProjectComponent.adarshGram,
      projectScope: 'Development of 15 model villages with comprehensive infrastructure',
      objectives: [
        'Improve sanitation facilities in 15 villages',
        'Construct community centers and health posts',
        'Provide skill training for 500 youth',
        'Establish water supply systems',
      ],
      taskBreakdown: {
        'infrastructure': ['Roads', 'Water Supply', 'Sanitation'],
        'social': ['Community Centers', 'Health Posts'],
        'training': ['Skill Development', 'Women Empowerment'],
      },
      allocatedFund: 12500000.0,
      paymentMilestones: [
        {'milestone': 'Site Survey & Planning', 'amount': 1250000, 'percentage': 10},
        {'milestone': 'Foundation Work', 'amount': 3750000, 'percentage': 30},
        {'milestone': 'Structural Completion', 'amount': 5000000, 'percentage': 40},
        {'milestone': 'Finishing & Handover', 'amount': 2500000, 'percentage': 20},
      ],
      pfmsTrackingId: 'PFMS/2025/MH/001',
      startDate: DateTime.now().add(const Duration(days: 15)),
      endDate: DateTime.now().add(const Duration(days: 380)),
      resourcePlan: {
        'engineers': 5,
        'supervisors': 10,
        'workers': 150,
        'equipment': ['JCB', 'Concrete Mixer', 'Water Tanker'],
      },
      teamRoles: [
        {'role': 'Project Manager', 'count': 1},
        {'role': 'Site Engineer', 'count': 3},
        {'role': 'Quality Inspector', 'count': 2},
        {'role': 'Community Coordinator', 'count': 2},
      ],
      geoFencedSiteLocation: '19.0760,72.8777',
      estimatedBeneficiaries: 7500,
      status: RequestStatus.pending,
      priority: RequestPriority.high,
      assignedBy: 'state_officer_001',
      assignedAt: DateTime.now().subtract(const Duration(days: 2)),
      slaDeadline: DateTime.now().add(const Duration(days: 5)),
      submittedAt: DateTime.now().subtract(const Duration(days: 2)),
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    RequestModel(
      id: 'tar_002',
      type: RequestType.projectAssignment,
      title: 'Karnataka Hostel Infrastructure Enhancement',
      description: 'Renovation and expansion of 8 SC/ST hostels',
      rationale: 'State-assigned project for hostel infrastructure improvement',
      projectId: 'proj_002',
      projectName: 'Karnataka Hostel Infrastructure Enhancement',
      agencyId: 'agency_002',
      agencyName: 'Karnataka Social Welfare Board',
      stateId: 'state_002',
      districtId: 'dist_002',
      component: ProjectComponent.hostel,
      projectScope: 'Renovation and expansion of 8 SC/ST hostels',
      objectives: [
        'Renovate existing hostel buildings',
        'Expand capacity by 300 beds',
        'Improve safety and security measures',
        'Install modern amenities',
      ],
      taskBreakdown: {
        'civil_work': ['Building Renovation', 'Expansion Construction'],
        'amenities': ['Furniture', 'Electrical', 'Plumbing'],
        'safety': ['Fire Safety', 'CCTV', 'Security Systems'],
      },
      allocatedFund: 8750000.0,
      paymentMilestones: [
        {'milestone': 'Assessment & Design', 'amount': 875000, 'percentage': 10},
        {'milestone': 'Renovation Work', 'amount': 3500000, 'percentage': 40},
        {'milestone': 'Expansion Work', 'amount': 3062500, 'percentage': 35},
        {'milestone': 'Final Inspection', 'amount': 1312500, 'percentage': 15},
      ],
      pfmsTrackingId: 'PFMS/2025/KA/002',
      startDate: DateTime.now().add(const Duration(days: 20)),
      endDate: DateTime.now().add(const Duration(days: 320)),
      resourcePlan: {
        'engineers': 4,
        'supervisors': 6,
        'workers': 100,
        'equipment': ['Scaffolding', 'Power Tools', 'Safety Equipment'],
      },
      teamRoles: [
        {'role': 'Project Coordinator', 'count': 1},
        {'role': 'Civil Engineer', 'count': 2},
        {'role': 'Electrical Engineer', 'count': 1},
        {'role': 'Safety Officer', 'count': 1},
      ],
      geoFencedSiteLocation: '12.9716,77.5946',
      estimatedBeneficiaries: 2400,
      status: RequestStatus.pending,
      priority: RequestPriority.medium,
      assignedBy: 'state_officer_002',
      assignedAt: DateTime.now().subtract(const Duration(hours: 18)),
      slaDeadline: DateTime.now().add(const Duration(days: 7)),
      submittedAt: DateTime.now().subtract(const Duration(hours: 18)),
      createdAt: DateTime.now().subtract(const Duration(hours: 18)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 18)),
    ),
  ];

  List<RequestModel> get _filteredRequests {
    return _mockRequests.where((request) {
      final matchesSearch = _searchController.text.isEmpty ||
          (request.projectName?.toLowerCase().contains(_searchController.text.toLowerCase()) ?? false);
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
            Colors.purple.shade50,
            Colors.deepPurple.shade50,
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
          colors: [Colors.purple.shade700, Colors.deepPurple.shade700],
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
            child: const Icon(Icons.assignment, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Agency Task Assignment Panel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Review and accept or decline project assignments from State',
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
                hintText: 'Search by project name...',
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
              'Task Assignments (${filteredRequests.length})',
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
                          'No assignments match your filters',
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
                      final daysUntilSla = request.slaDeadline?.difference(DateTime.now()).inDays ?? 0;
                      
                      return InkWell(
                        onTap: () => setState(() => _selectedRequest = request),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.purple.shade50 : null,
                            border: Border(
                              left: BorderSide(
                                color: isSelected ? Colors.purple : Colors.transparent,
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
                                      request.projectName ?? 'Unnamed Project',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (daysUntilSla <= 3)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade100,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.alarm, size: 14, color: Colors.red.shade700),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${daysUntilSla}d',
                                            style: TextStyle(
                                              color: Colors.red.shade700,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
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
                                  Icon(Icons.location_on, size: 14, color: Colors.grey.shade600),
                                  const SizedBox(width: 4),
                                  Text(
                                    request.districtId ?? 'Unknown',
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
                                    '₹${_formatAmount(request.allocatedFund ?? 0.0)}',
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
                        request.projectName ?? 'Unnamed Project',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Assignment ID: ${request.id}',
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
                    'Project Brief',
                    Icons.description,
                    [
                      Text(
                        request.projectScope ?? 'No description provided',
                        style: TextStyle(color: Colors.grey.shade800),
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow('Component', request.component?.displayName ?? 'Unknown'),
                      _buildDetailRow('District', request.districtId ?? 'Unknown'),
                      _buildDetailRow('Assigned By', request.assignedBy ?? 'Unknown'),
                      _buildDetailRow('Assignment Date', request.assignedAt != null ? _formatDate(request.assignedAt!) : 'N/A'),
                      if (request.slaDeadline != null)
                        _buildDetailRow(
                          'SLA Deadline',
                          _formatDate(request.slaDeadline!),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildDetailSection(
                    'Objectives',
                    Icons.flag,
                    (request.objectives ?? []).map((objective) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 6),
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: Colors.purple.shade700,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Text(objective)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  _buildDetailSection(
                    'Financials',
                    Icons.currency_rupee,
                    [
                      _buildDetailRow('Total Allocation', '₹${_formatAmount(request.allocatedFund ?? 0.0)}'),
                      _buildDetailRow('PFMS Tracking', request.pfmsTrackingId ?? 'N/A'),
                      const SizedBox(height: 12),
                      const Text(
                        'Payment Milestones',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...(request.paymentMilestones ?? []).map((milestone) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(milestone['milestone'] as String),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '₹${_formatAmount((milestone['amount'] as num).toDouble())}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '${milestone['percentage']}%',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildDetailSection(
                    'Timeline & Resources',
                    Icons.schedule,
                    [
                      _buildDetailRow('Start Date', request.startDate != null ? _formatDate(request.startDate!) : 'N/A'),
                      _buildDetailRow('End Date', request.endDate != null ? _formatDate(request.endDate!) : 'N/A'),
                      _buildDetailRow('Duration', request.startDate != null && request.endDate != null
                        ? '${request.endDate!.difference(request.startDate!).inDays} days'
                        : 'N/A'),
                      _buildDetailRow('Beneficiaries', '${request.estimatedBeneficiaries ?? 0}'),
                      if (request.geoFencedSiteLocation != null)
                        _buildDetailRow('Site Location', request.geoFencedSiteLocation!),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildDetailSection(
                    'Team Composition',
                    Icons.groups,
                    (request.teamRoles ?? []).map((role) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(child: Text(role['role'] as String)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.purple.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${role['count']}',
                                style: TextStyle(
                                  color: Colors.purple.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
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
            Icon(icon, size: 20, color: Colors.purple.shade700),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade700,
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
    if (request.status != RequestStatus.pending) {
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
              onPressed: () => _handleAccept(context, request),
              icon: const Icon(Icons.check_circle),
              label: const Text('Accept Assignment'),
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
              onPressed: () => _handleDecline(context, request),
              icon: const Icon(Icons.cancel),
              label: const Text('Decline'),
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
              onPressed: () => _handleRequestModification(context, request),
              icon: const Icon(Icons.edit),
              label: const Text('Request Changes'),
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
        text = 'ACCEPTED';
        break;
      case RequestStatus.rejected:
        color = Colors.red;
        text = 'DECLINED';
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

  void _handleAccept(BuildContext context, RequestModel request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Accept Task Assignment'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Accept assignment for ${request.projectName}?',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('This will:'),
            const Text('• Generate digital work order'),
            const Text('• Unlock milestone submission workflow'),
            const Text('• Activate PFMS fund tracking'),
            const Text('• Notify State officer'),
            const SizedBox(height: 16),
            Text(
              'Fund: ₹${_formatAmount(request.allocatedFund ?? 0.0)}',
              style: TextStyle(
                color: Colors.green.shade700,
                fontWeight: FontWeight.bold,
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
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Assignment accepted: ${request.projectName}'),
                  backgroundColor: Colors.green,
                ),
              );
              setState(() => _selectedRequest = null);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Accept Assignment'),
          ),
        ],
      ),
    );
  }

  void _handleDecline(BuildContext context, RequestModel request) {
    final reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Decline Task Assignment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Please provide a reason for declining:'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Enter decline reason...',
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
                  const SnackBar(content: Text('Decline reason is required')),
                );
                return;
              }
              
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Assignment declined: ${request.projectName}'),
                  backgroundColor: Colors.red,
                ),
              );
              setState(() => _selectedRequest = null);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Decline'),
          ),
        ],
      ),
    );
  }

  void _handleRequestModification(BuildContext context, RequestModel request) {
    final modificationController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Modifications'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Propose modifications to scope, timeline, or funds:'),
            const SizedBox(height: 16),
            TextField(
              controller: modificationController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Describe proposed changes...',
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
              if (modificationController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please describe the modifications needed')),
                );
                return;
              }
              
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Modification request sent to State: ${request.projectName}'),
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
            Icon(Icons.help_outline, color: Colors.purple),
            SizedBox(width: 8),
            Text('Agency Task Assignment Help'),
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
                'Review and accept or decline project assignments from State officers.',
              ),
              SizedBox(height: 16),
              Text(
                'Features',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text('• View detailed project briefs and task breakdowns'),
              Text('• Review financial allocations and payment milestones'),
              Text('• Check resource requirements and team composition'),
              Text('• Accept assignments with automatic work order generation'),
              Text('• Decline with mandatory reason'),
              Text('• Request modifications to scope, timeline, or funds'),
              Text('• SLA tracking with deadline alerts'),
              SizedBox(height: 16),
              Text(
                'Important',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text('• Respond within SLA deadline to avoid escalation'),
              Text('• Accepted assignments unlock milestone submission'),
              Text('• Work orders are digitally signed and stored'),
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