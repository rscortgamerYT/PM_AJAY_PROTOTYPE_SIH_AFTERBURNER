import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_theme.dart';

class SmartMilestoneClaimsWidget extends StatefulWidget {
  const SmartMilestoneClaimsWidget({super.key});

  @override
  State<SmartMilestoneClaimsWidget> createState() => _SmartMilestoneClaimsWidgetState();
}

class _SmartMilestoneClaimsWidgetState extends State<SmartMilestoneClaimsWidget> {
  int _selectedTab = 0;
  final List<String> _tabs = ['Pending Claims', 'Submitted', 'Approved', 'All'];

  // Mock data - will be replaced with Supabase data
  final List<MilestoneClaimData> _claims = [
    MilestoneClaimData(
      'MS001',
      'Village Infrastructure Phase 1',
      'Adarsh Gram Development - Village A',
      ClaimStatus.pending,
      75.0,
      '₹25.5 Cr',
      DateTime.now().subtract(const Duration(days: 2)),
      ['foundation.jpg', 'progress_report.pdf'],
    ),
    MilestoneClaimData(
      'MS002',
      'Student Hostel Construction',
      'Hostel Construction Project',
      ClaimStatus.submitted,
      100.0,
      '₹40.0 Cr',
      DateTime.now().subtract(const Duration(days: 5)),
      ['completion_cert.pdf', 'photos.zip'],
    ),
    MilestoneClaimData(
      'MS003',
      'Road Infrastructure GIA',
      'Village Infrastructure GIA',
      ClaimStatus.approved,
      85.0,
      '₹18.2 Cr',
      DateTime.now().subtract(const Duration(days: 10)),
      ['inspection_report.pdf'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildTabBar(),
        Expanded(
          child: _selectedTab == 0
              ? _buildPendingClaimsView()
              : _buildClaimsListView(),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Smart Milestone Claims',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'AI-powered validation and submission',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
          Row(
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.add, size: 16),
                label: const Text('New Claim'),
                onPressed: () {
                  _showNewClaimDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryIndigo,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () {},
                tooltip: 'Filter',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: List.generate(_tabs.length, (index) {
          final isSelected = _selectedTab == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Text(_tabs[index]),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedTab = index);
              },
              selectedColor: AppTheme.primaryIndigo.withOpacity(0.2),
              checkmarkColor: AppTheme.primaryIndigo,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPendingClaimsView() {
    final pendingClaims = _claims.where((c) => c.status == ClaimStatus.pending).toList();
    
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildQuickStats(),
          _buildAIValidationPanel(),
          _buildPendingClaimsList(pendingClaims),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Pending Review',
              '3',
              Icons.pending_actions,
              AppTheme.warningOrange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Submitted',
              '5',
              Icons.send,
              AppTheme.secondaryBlue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Approved',
              '12',
              Icons.check_circle,
              AppTheme.successGreen,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Total Claims',
              '₹284 Cr',
              Icons.account_balance,
              AppTheme.primaryIndigo,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIValidationPanel() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 2,
        color: AppTheme.primaryIndigo.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.psychology, color: AppTheme.primaryIndigo),
                  const SizedBox(width: 8),
                  Text(
                    'AI Validation Insights',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.successGreen.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, size: 16, color: AppTheme.successGreen),
                        const SizedBox(width: 4),
                        Text(
                          'All Systems Ready',
                          style: TextStyle(
                            color: AppTheme.successGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildValidationItem(
                'Document Completeness',
                'All required documents uploaded',
                Icons.description,
                AppTheme.successGreen,
                100,
              ),
              const SizedBox(height: 12),
              _buildValidationItem(
                'Progress Verification',
                'Physical progress matches reported metrics',
                Icons.verified,
                AppTheme.successGreen,
                95,
              ),
              const SizedBox(height: 12),
              _buildValidationItem(
                'Financial Accuracy',
                'Expenditure within approved limits',
                Icons.attach_money,
                AppTheme.warningOrange,
                85,
              ),
              const SizedBox(height: 12),
              _buildValidationItem(
                'Timeline Compliance',
                'Milestone achieved within scheduled timeframe',
                Icons.schedule,
                AppTheme.successGreen,
                92,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildValidationItem(String title, String description, IconData icon, Color color, int score) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$score%',
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: score / 100,
                backgroundColor: color.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPendingClaimsList(List<MilestoneClaimData> claims) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 2,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ready for Submission',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.send_and_archive, size: 16),
                    label: const Text('Submit All'),
                    onPressed: () {
                      _submitAllClaims(claims);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.successGreen,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: claims.length,
              itemBuilder: (context, index) {
                return _buildClaimCard(claims[index]);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClaimsListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _claims.length,
      itemBuilder: (context, index) {
        return _buildClaimCard(_claims[index]);
      },
    );
  }

  Widget _buildClaimCard(MilestoneClaimData claim) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(claim.status),
          child: Icon(
            _getStatusIcon(claim.status),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          claim.milestoneName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(claim.projectName),
            const SizedBox(height: 4),
            Row(
              children: [
                Chip(
                  label: Text(claim.status.value),
                  backgroundColor: _getStatusColor(claim.status).withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: _getStatusColor(claim.status),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${claim.completionPercentage.toStringAsFixed(0)}% Complete',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailItem('Claim ID', claim.id),
                    ),
                    Expanded(
                      child: _buildDetailItem('Amount', claim.claimAmount),
                    ),
                    Expanded(
                      child: _buildDetailItem('Submitted', _formatDate(claim.submittedDate)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  'Attachments (${claim.attachments.length})',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: claim.attachments.map((attachment) {
                    return Chip(
                      avatar: Icon(
                        _getFileIcon(attachment),
                        size: 16,
                      ),
                      label: Text(
                        attachment,
                        style: const TextStyle(fontSize: 11),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (claim.status == ClaimStatus.pending) ...[
                      TextButton.icon(
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),
                        onPressed: () {},
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.send),
                        label: const Text('Submit'),
                        onPressed: () {
                          _submitClaim(claim);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.successGreen,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                    if (claim.status == ClaimStatus.submitted)
                      TextButton.icon(
                        icon: const Icon(Icons.visibility),
                        label: const Text('Track Status'),
                        onPressed: () {},
                      ),
                    if (claim.status == ClaimStatus.approved)
                      Row(
                        children: [
                          Icon(Icons.check_circle, color: AppTheme.successGreen, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Approved & Released',
                            style: TextStyle(
                              color: AppTheme.successGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(ClaimStatus status) {
    switch (status) {
      case ClaimStatus.pending:
        return AppTheme.warningOrange;
      case ClaimStatus.submitted:
        return AppTheme.secondaryBlue;
      case ClaimStatus.approved:
        return AppTheme.successGreen;
      case ClaimStatus.rejected:
        return AppTheme.errorRed;
    }
  }

  IconData _getStatusIcon(ClaimStatus status) {
    switch (status) {
      case ClaimStatus.pending:
        return Icons.pending_actions;
      case ClaimStatus.submitted:
        return Icons.send;
      case ClaimStatus.approved:
        return Icons.check_circle;
      case ClaimStatus.rejected:
        return Icons.cancel;
    }
  }

  IconData _getFileIcon(String filename) {
    if (filename.endsWith('.pdf')) return Icons.picture_as_pdf;
    if (filename.endsWith('.jpg') || filename.endsWith('.png')) return Icons.image;
    if (filename.endsWith('.zip')) return Icons.folder_zip;
    return Icons.insert_drive_file;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showNewClaimDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening new claim form...')),
    );
  }

  void _submitClaim(MilestoneClaimData claim) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Submitting claim ${claim.id}...')),
    );
  }

  void _submitAllClaims(List<MilestoneClaimData> claims) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Submitting ${claims.length} claims...')),
    );
  }
}

enum ClaimStatus {
  pending('Pending'),
  submitted('Submitted'),
  approved('Approved'),
  rejected('Rejected');

  final String value;
  const ClaimStatus(this.value);
}

class MilestoneClaimData {
  final String id;
  final String milestoneName;
  final String projectName;
  final ClaimStatus status;
  final double completionPercentage;
  final String claimAmount;
  final DateTime submittedDate;
  final List<String> attachments;

  MilestoneClaimData(
    this.id,
    this.milestoneName,
    this.projectName,
    this.status,
    this.completionPercentage,
    this.claimAmount,
    this.submittedDate,
    this.attachments,
  );
}