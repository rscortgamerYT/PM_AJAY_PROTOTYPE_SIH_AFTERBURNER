import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/comprehensive_claim_review_dialog.dart';
import '../../../evidence/widgets/tamper_evident_evidence_widget.dart';
import '../../../../core/widgets/dashboard_switcher_widget.dart';

class NewOverwatchDashboardPage extends ConsumerStatefulWidget {
  const NewOverwatchDashboardPage({super.key});

  @override
  ConsumerState<NewOverwatchDashboardPage> createState() =>
      _NewOverwatchDashboardPageState();
}

class _NewOverwatchDashboardPageState
    extends ConsumerState<NewOverwatchDashboardPage> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  final double _scanningProgress = 0.0;
  final bool _isScanning = false;
  String _selectedProject = 'PMAJAY-MH-045';
  final List<String> _selectedClaims = [];
  final String _filterCategory = 'ALL';
  late AnimationController _animationController;
  late Animation<double> _flowAnimation;
  
  // AI Document Verification System
  final List<Map<String, dynamic>> _uploadedDocuments = [];
  bool _isAnalyzing = false;
  
  // Archive System
  final List<Map<String, dynamic>> _archivedProjects = [
    {
      'id': 'PMAJAY-MH-067',
      'name': 'Maharashtra Rural Health Infrastructure Phase 2',
      'status': 'COMPLETED',
      'budget': '₹125 Cr',
      'utilization': '98.2%',
      'completionDate': '2024-08-15',
      'complianceScore': 94.5,
      'beneficiaries': 125000,
    },
    {
      'id': 'PMAJAY-GJ-089',
      'name': 'Gujarat Urban Health Centers Expansion',
      'status': 'COMPLETED',
      'budget': '₹89 Cr',
      'utilization': '95.7%',
      'completionDate': '2024-07-22',
      'complianceScore': 91.8,
      'beneficiaries': 98000,
    },
    {
      'id': 'PMAJAY-KA-056',
      'name': 'Karnataka Telemedicine Network',
      'status': 'TERMINATED',
      'budget': '₹67 Cr',
      'utilization': '45.3%',
      'completionDate': '2024-06-10',
      'complianceScore': 67.2,
      'beneficiaries': 34000,
    },
    {
      'id': 'PMAJAY-UP-134',
      'name': 'Uttar Pradesh Emergency Services Upgrade',
      'status': 'COMPLETED',
      'budget': '₹203 Cr',
      'utilization': '96.8%',
      'completionDate': '2024-09-05',
      'complianceScore': 92.1,
      'beneficiaries': 245000,
    },
  ];
  String _archiveSearchQuery = '';
  String _archiveStatusFilter = 'ALL';

  final List<NavigationDestination> _destinations = [
    const NavigationDestination(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard),
      label: 'Overview',
    ),
    const NavigationDestination(
      icon: Icon(Icons.assignment_outlined),
      selectedIcon: Icon(Icons.assignment),
      label: 'Claims',
    ),
    const NavigationDestination(
      icon: Icon(Icons.account_balance_wallet_outlined),
      selectedIcon: Icon(Icons.account_balance_wallet),
      label: 'Fund Flow',
    ),
    const NavigationDestination(
      icon: Icon(Icons.security_outlined),
      selectedIcon: Icon(Icons.security),
      label: 'Fraud & Command',
    ),
    const NavigationDestination(
      icon: Icon(Icons.archive_outlined),
      selectedIcon: Icon(Icons.archive),
      label: 'Archive',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(); // Make animation continuous
    _flowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A), // Dark background
      appBar: AppBar(
        title: Text(_getPageTitle()),
        backgroundColor: const Color(0xFF2D2D2D),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
            tooltip: 'Notifications',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshAllData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildCurrentPage(),
          const DashboardSwitcherWidget(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: _destinations,
        backgroundColor: const Color(0xFF2D2D2D),
        surfaceTintColor: Colors.white,
        indicatorColor: Colors.blue.shade400,
      ),
    );
  }

  String _getPageTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Overwatch Dashboard - Overview';
      case 1:
        return 'Claims Management';
      case 2:
        return 'Fund Flow Tracker';
      case 3:
        return 'Fraud & Command Center';
      case 4:
        return 'Project Archive';
      default:
        return 'Overwatch Dashboard';
    }
  }

  Widget _buildCurrentPage() {
    switch (_selectedIndex) {
      case 0:
        return _buildOverviewPage();
      case 1:
        return _buildClaimsPage();
      case 2:
        return _buildFundFlowPage();
      case 3:
        return _buildFraudCommandPage();
      case 4:
        return _buildArchivePage();
      default:
        return _buildOverviewPage();
    }
  }

  // OVERVIEW PAGE
  Widget _buildOverviewPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Executive Summary Cards
          _buildExecutiveSummaryRow(),
          const SizedBox(height: 20),
          
          // AI Insights & Alerts
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _buildAIInsightsCard()),
              const SizedBox(width: 16),
              Expanded(flex: 2, child: _buildCriticalAlertsCard()),
            ],
          ),
          const SizedBox(height: 20),
          
          // Performance Dashboard
          _buildPerformanceDashboard(),
          const SizedBox(height: 20),
          
          // Recent Activities
          _buildRecentActivitiesCard(),
        ],
      ),
    );
  }

  Widget _buildExecutiveSummaryRow() {
    return Row(
      children: [
        Expanded(child: _buildSummaryCard('245', 'Active Projects', '↗ +12', Colors.blue)),
        const SizedBox(width: 12),
        Expanded(child: _buildSummaryCard('₹847Cr', 'Total Funds', '↗ +5%', Colors.green)),
        const SizedBox(width: 12),
        Expanded(child: _buildSummaryCard('89%', 'Completion Rate', '↗ +3%', Colors.purple)),
        const SizedBox(width: 12),
        Expanded(child: _buildSummaryCard('23', 'Critical Issues', '↘ -8', Colors.red)),
      ],
    );
  }

  Widget _buildSummaryCard(String value, String label, String trend, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            trend,
            style: TextStyle(
              fontSize: 12,
              color: trend.contains('↗') ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIInsightsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2D3748), Color(0xFF1A202C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.psychology, color: Colors.blue.shade600),
              const SizedBox(width: 8),
              const Text(
                'AI-Powered Insights',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInsightItem('🎯', 'Maharashtra shows 15% better efficiency than national average'),
          _buildInsightItem('⚠️', 'Weather delays predicted for 34 projects in coastal regions'),
          _buildInsightItem('💰', 'Fund utilization optimal in 67% of active projects'),
          _buildInsightItem('🔍', 'Quality compliance improved by 12% this quarter'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('View Detailed Analysis'),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCriticalAlertsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade400),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning, color: Colors.red.shade600),
              const SizedBox(width: 8),
              const Text(
                'Critical Alerts',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildAlertItem('FRAUD', 'Duplicate evidence detected in 3 projects', Colors.red),
          _buildAlertItem('DELAY', 'PMAJAY-GJ-023 behind schedule by 2 weeks', Colors.orange),
          _buildAlertItem('BUDGET', 'Fund overflow risk in Maharashtra region', Colors.yellow.shade700),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => setState(() => _selectedIndex = 3),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Investigate All'),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertItem(String type, String description, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              type,
              style: const TextStyle(
                color: Color(0xFF2D3748),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(fontSize: 12, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceDashboard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D3748),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Performance Dashboard',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildPerformanceMetric('On-Time Delivery', 82, Colors.green)),
              const SizedBox(width: 16),
              Expanded(child: _buildPerformanceMetric('Budget Compliance', 91, Colors.blue)),
              const SizedBox(width: 16),
              Expanded(child: _buildPerformanceMetric('Quality Score', 88, Colors.purple)),
              const SizedBox(width: 16),
              Expanded(child: _buildPerformanceMetric('Fraud Detection', 96, Colors.orange)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetric(String title, int percentage, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                value: percentage / 100,
                strokeWidth: 6,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            Text(
              '$percentage%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentActivitiesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D3748),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Activities',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),
          _buildActivityItem('Project Approved', 'PMAJAY-MH-045 milestone approved', '2 min ago', Colors.green),
          _buildActivityItem('Fund Transfer', '₹50L transferred to contractor', '15 min ago', Colors.blue),
          _buildActivityItem('Risk Alert', 'Weather warning issued for 12 projects', '1 hr ago', Colors.orange),
          _buildActivityItem('Quality Check', 'Inspection completed for PMAJAY-KA-012', '2 hr ago', Colors.purple),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String type, String description, String time, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(6),
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(fontSize: 11, color: Colors.white),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // CLAIMS PAGE
  Widget _buildClaimsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Claims Summary
          Row(
            children: [
              Expanded(child: _buildClaimsSummaryCard('147', 'Pending Claims', Colors.orange)),
              const SizedBox(width: 12),
              Expanded(child: _buildClaimsSummaryCard('89', 'Under Review', Colors.blue)),
              const SizedBox(width: 12),
              Expanded(child: _buildClaimsSummaryCard('234', 'Approved Today', Colors.green)),
              const SizedBox(width: 12),
              Expanded(child: _buildClaimsSummaryCard('12', 'Rejected', Colors.red)),
            ],
          ),
          const SizedBox(height: 20),
          
          // Batch Operations
          _buildBatchOperationsCard(),
          const SizedBox(height: 20),
          
          // Tamper-Evident Evidence Section
          TamperEvidentEvidenceWidget(
            projectId: _selectedProject,
            uploaderName: 'Overwatch Officer',
            onEvidenceUploaded: (evidence) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Evidence uploaded with watermark and EXIF lock'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          
          // Claims List
          _buildClaimsListCard(),
        ],
      ),
    );
  }

  Widget _buildClaimsSummaryCard(String count, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            count,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBatchOperationsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.shade400),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Batch Operations',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _selectedClaims.isEmpty ? null : _batchApproveClaims,
                  icon: const Icon(Icons.verified_user, size: 16),
                  label: Text('Verify & Approve (${_selectedClaims.length})'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _selectedClaims.isEmpty ? null : _batchRejectClaims,
                  icon: const Icon(Icons.cancel, size: 16),
                  label: Text('Return for Review (${_selectedClaims.length})'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.download, size: 16),
                label: const Text('Export'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClaimsListCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade700),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Claims Management',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),
          _buildClaimItem('CLM-001', 'Foundation Work Completion', 'PMAJAY-MH-045', '₹15L', 'PENDING', Colors.orange),
          _buildClaimItem('CLM-002', 'Material Procurement', 'PMAJAY-GJ-023', '₹22L', 'REVIEW', Colors.blue),
          _buildClaimItem('CLM-003', 'Labor Payment', 'PMAJAY-KA-012', '₹8L', 'APPROVED', Colors.green),
          _buildClaimItem('CLM-004', 'Quality Inspection', 'PMAJAY-TN-056', '₹5L', 'RETURNED', Colors.red),
          _buildClaimItem('CLM-005', 'Final Milestone', 'PMAJAY-AP-089', '₹35L', 'PENDING', Colors.orange),
        ],
      ),
    );
  }

  Widget _buildClaimItem(String claimId, String description, String project, String amount, String status, Color statusColor) {
    final isSelected = _selectedClaims.contains(claimId);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected ? Colors.grey.shade800 : Colors.black87,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? Colors.blue.shade300 : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          ElevatedButton.icon(
            onPressed: status == 'PENDING' || status == 'REVIEW' ? () {
              _showClaimDetailModal(context);
            } : null,
            icon: const Icon(Icons.visibility, size: 16),
            label: const Text('Review'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: const Size(80, 30),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      claimId,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        status,
                        style: const TextStyle(
                          color: Color(0xFF2D3748),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      project,
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                    ),
                    const Spacer(),
                    Text(
                      amount,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
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

  // COMPREHENSIVE FUND FLOW PAGE - State-of-the-art implementation
  Widget _buildFundFlowPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project Selection Header
          _buildProjectSelectionHeader(),
          const SizedBox(height: 20),
          
          // Fund Summary Dashboard
          _buildEnhancedFundSummaryRow(),
          const SizedBox(height: 20),
          
          // Comprehensive 2D Animated Fund Flow Visualization
          _buildComprehensiveFundFlowVisualization(),
          const SizedBox(height: 20),
          
          // Fund Flow Details with Evidence Integration
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _buildDetailedFundTrackingTable()),
              const SizedBox(width: 16),
              Expanded(flex: 2, child: _buildAuditControlCenter()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProjectSelectionHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade900, Colors.blue.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_tree, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              const Text(
                'Comprehensive Fund Flow Tracker',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Real-time Sync'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedProject,
                    isExpanded: true,
                    dropdownColor: Colors.blue.shade800,
                    style: const TextStyle(color: Colors.white),
                    underline: Container(),
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                    items: [
                      'PMAJAY-MH-045',
                      'PMAJAY-GJ-023',
                      'PMAJAY-KA-012',
                      'PMAJAY-TN-056',
                      'PMAJAY-AP-089'
                    ].map((project) => DropdownMenuItem(
                      value: project,
                      child: Text(project, style: const TextStyle(color: Colors.white)),
                    )).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedProject = value!;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: const Column(
                    children: [
                      Text('Project Budget', style: TextStyle(color: Colors.white, fontSize: 12)),
                      SizedBox(height: 4),
                      Text('₹847Cr', style: TextStyle(color: Colors.orange, fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green),
                  ),
                  child: const Column(
                    children: [
                      Text('Utilized', style: TextStyle(color: Colors.white, fontSize: 12)),
                      SizedBox(height: 4),
                      Text('₹634Cr', style: TextStyle(color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedFundSummaryRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          SizedBox(
            width: 200,
            child: _buildEnhancedFundSummaryCard('₹847Cr', 'Project Budget', '100%', Colors.blue, Icons.account_balance),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 200,
            child: _buildEnhancedFundSummaryCard('₹634Cr', 'Utilized', '75%', Colors.green, Icons.trending_up),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 200,
            child: _buildEnhancedFundSummaryCard('₹213Cr', 'Remaining', '25%', Colors.orange, Icons.savings),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 200,
            child: _buildEnhancedFundSummaryCard('₹45Cr', 'Under Review', '5%', Colors.red, Icons.flag),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedFundSummaryCard(String amount, String label, String percentage, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black, Colors.grey.shade900],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const Spacer(),
              Text(
                percentage,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            amount,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: double.parse(percentage.replaceAll('%', '')) / 100,
            backgroundColor: Colors.grey.shade800,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }

  Widget _buildComprehensiveFundFlowVisualization() {
    return Container(
      height: 500,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black, Colors.grey.shade900],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.shade300, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timeline, color: Colors.blue.shade300, size: 28),
              const SizedBox(width: 12),
              const Text(
                'Comprehensive Fund Flow Journey',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: AnimatedBuilder(
              animation: _flowAnimation,
              builder: (context, child) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Level 1: Central Government
                      _buildFundFlowStage(
                        'Central\nGovernment',
                        '₹847Cr',
                        'Finance Ministry',
                        'Dr. Rajesh Kumar',
                        ['Budget Approval', 'Release Order'],
                        Colors.blue,
                        true,
                      ),
                      _buildSimpleFlowConnection(),
                      
                      // Level 2: State Government
                      _buildFundFlowStage(
                        'State\nGovernment',
                        '₹847Cr',
                        'Maharashtra Health Dept',
                        'Mrs. Priya Sharma',
                        ['State Allocation', 'Compliance Check'],
                        Colors.green,
                        false,
                      ),
                      _buildSimpleFlowConnection(),
                      
                      // Level 3: Implementation Agency
                      _buildFundFlowStage(
                        'Implementation\nAgency',
                        '₹634Cr',
                        'MRDA Pune Division',
                        'Mr. Amit Patil',
                        ['Project Planning', 'Contractor Selection'],
                        Colors.orange,
                        false,
                      ),
                      
                      // Branching connections to fund utilization
                      _buildBranchingConnections(),
                      
                      // Level 4: Fund Utilization
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildUtilizationNode('Land\nAcquisition', '₹200Cr', 'Mr. Suresh Joshi', Colors.brown),
                          const SizedBox(height: 24),
                          _buildUtilizationNode('Construction\nMaterials', '₹234Cr', 'ABC Suppliers Ltd', Colors.cyan),
                          const SizedBox(height: 24),
                          _buildUtilizationNode('Labor\nPayments', '₹120Cr', 'XYZ Contractors', Colors.purple),
                          const SizedBox(height: 24),
                          _buildUtilizationNode('Equipment\nProcurement', '₹80Cr', 'Tech Solutions Inc', Colors.indigo),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFundFlowStage(String title, String amount, String organization, String responsible, List<String> documents, Color color, bool isSource) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.8), color.withOpacity(0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(isSource ? Icons.account_balance : Icons.business, color: Colors.white, size: 20),
              const Spacer(),
              ElevatedButton(
                onPressed: () => _showFundStageDetails(title, organization, responsible, documents),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: const Size(50, 24),
                ),
                child: const Text('FLAG', style: TextStyle(fontSize: 10)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Flexible(
           child: Text(
             title,
             style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
             textAlign: TextAlign.center,
             maxLines: 2,
             overflow: TextOverflow.ellipsis,
           ),
         ),
         const SizedBox(height: 6),
         Text(
           amount,
           style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
           textAlign: TextAlign.center,
         ),
         const SizedBox(height: 8),
         Flexible(
           child: Container(
             padding: const EdgeInsets.all(6),
             decoration: BoxDecoration(
               color: Colors.black.withOpacity(0.3),
               borderRadius: BorderRadius.circular(6),
             ),
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               mainAxisSize: MainAxisSize.min,
               children: [
                 Text(
                   organization,
                   style: const TextStyle(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.w500),
                   maxLines: 2,
                   overflow: TextOverflow.ellipsis,
                 ),
                 const SizedBox(height: 3),
                 Row(
                   children: [
                     const Icon(Icons.person, color: Colors.white60, size: 12),
                     const SizedBox(width: 3),
                     Expanded(
                       child: Text(
                         responsible,
                         style: const TextStyle(fontSize: 9, color: Colors.white60),
                         maxLines: 1,
                         overflow: TextOverflow.ellipsis,
                       ),
                     ),
                   ],
                 ),
                 const SizedBox(height: 6),
                 Flexible(
                   child: Wrap(
                     spacing: 2,
                     runSpacing: 2,
                     children: documents.map((doc) => Container(
                       padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                       decoration: BoxDecoration(
                         color: Colors.green.withOpacity(0.6),
                         borderRadius: BorderRadius.circular(3),
                       ),
                       child: Text(
                         doc,
                         style: const TextStyle(fontSize: 7, color: Colors.white),
                         maxLines: 1,
                         overflow: TextOverflow.ellipsis,
                       ),
                     )).toList(),
                   ),
                 ),
               ],
             ),
           ),
         ),
        ],
      ),
    );
  }

  Widget _buildSimpleFlowConnection() {
    return SizedBox(
      width: 100,
      height: 60,
      child: Stack(
        children: [
          // Static background connection line
          Positioned(
            top: 28,
            left: 0,
            right: 0,
            child: Container(
              height: 3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.withOpacity(0.4),
                    Colors.blue,
                    Colors.blue.withOpacity(0.4),
                  ],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          // Animated flowing line
          AnimatedBuilder(
            animation: _flowAnimation,
            builder: (context, child) {
              return Positioned(
                left: (_flowAnimation.value * 100) % 100,
                top: 26,
                child: Container(
                  width: 20,
                  height: 7,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.white,
                        Colors.blue.shade300,
                        Colors.white,
                        Colors.transparent,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBranchingConnections() {
    return SizedBox(
      width: 160,
      height: 360,
      child: CustomPaint(
        painter: BranchingFlowPainter(_flowAnimation.value),
        size: const Size(160, 360),
      ),
    );
  }

  Widget _buildFlowConnection() {
    return SizedBox(
      width: 120,
      height: 80,
      child: Stack(
        children: [
          // Static background connection line
          Positioned(
            top: 35,
            left: 0,
            right: 0,
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.green.withOpacity(0.3),
                    Colors.green.withOpacity(0.6),
                    Colors.green.withOpacity(0.3),
                  ],
                ),
              ),
            ),
          ),
          
          // Animated flowing particles
          AnimatedBuilder(
            animation: _flowAnimation,
            builder: (context, child) {
              return Stack(
                children: [
                  // First flowing particle (completed transfer - green)
                  Positioned(
                    left: (_flowAnimation.value * 100) % 120,
                    top: 30,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.6),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Second flowing particle (active usage - yellow)
                  Positioned(
                    left: ((_flowAnimation.value * 80) + 30) % 120,
                    top: 40,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.yellow,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.yellow.withOpacity(0.8),
                            blurRadius: 3,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Third flowing particle (pending - orange)
                  Positioned(
                    left: ((_flowAnimation.value * 90) + 60) % 120,
                    top: 25,
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.7),
                            blurRadius: 2,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          
          // Flow arrow
          Positioned(
            right: 10,
            top: 30,
            child: AnimatedBuilder(
              animation: _flowAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (_flowAnimation.value * 0.1),
                  child: Icon(
                    Icons.arrow_forward,
                    color: Colors.white.withOpacity(0.7 + (_flowAnimation.value * 0.3)),
                    size: 20,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUtilizationNode(String title, String amount, String responsible, Color color) {
    return Container(
      width: 160,
      constraints: const BoxConstraints(maxHeight: 120),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.8), color.withOpacity(0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              ElevatedButton(
                onPressed: () => _showAuditFlag(title, amount, responsible),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(4),
                  minimumSize: const Size(24, 24),
                ),
                child: const Text('🚩', style: TextStyle(fontSize: 8)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 3),
          Flexible(
            child: Text(
              responsible,
              style: const TextStyle(fontSize: 9, color: Colors.white70),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedFundTrackingTable() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black, Colors.grey.shade900],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.list_alt, color: Colors.blue.shade300, size: 24),
              const SizedBox(width: 8),
              const Text(
                'Detailed Fund Tracking & Evidence',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailedTransactionItem('TXN-847-001', 'Central → State Transfer', '₹847Cr', 'Finance Ministry → Maharashtra Health', 'Dr. Rajesh Kumar', 'COMPLETED', Colors.green, ['Budget_Approval.pdf', 'Release_Order.pdf', 'Transfer_Receipt.jpg']),
          _buildDetailedTransactionItem('TXN-634-002', 'State → Agency Allocation', '₹634Cr', 'Maharashtra Health → MRDA Pune', 'Mrs. Priya Sharma', 'COMPLETED', Colors.green, ['State_Sanction.pdf', 'Compliance_Check.mp4']),
          _buildDetailedTransactionItem('TXN-200-003', 'Land Acquisition Payment', '₹200Cr', 'MRDA → Land Acquisition', 'Mr. Suresh Joshi', 'IN_PROGRESS', Colors.orange, ['Land_Survey.pdf', 'Purchase_Agreement.pdf', 'Site_Photos.jpg']),
          _buildDetailedTransactionItem('TXN-234-004', 'Material Procurement', '₹234Cr', 'Agency → ABC Suppliers', 'ABC Suppliers Ltd', 'PENDING_AUDIT', Colors.red, ['Material_Invoice.pdf', 'Quality_Certificate.pdf']),
          _buildDetailedTransactionItem('TXN-120-005', 'Labor Payments', '₹120Cr', 'Contractor → Workers', 'XYZ Contractors', 'FLAGGED', Colors.red, ['Payroll_Records.xlsx', 'Attendance_Report.pdf']),
        ],
      ),
    );
  }

  Widget _buildDetailedTransactionItem(String txnId, String type, String amount, String flow, String responsible, String status, Color statusColor, List<String> evidence) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: statusColor, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      txnId,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      type,
                      style: const TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w500),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              ElevatedButton(
                onPressed: () => _showTransactionAudit(txnId, type, amount, responsible),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  minimumSize: const Size(60, 28),
                ),
                child: const Text('AUDIT', style: TextStyle(fontSize: 9)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            flow,
            style: const TextStyle(fontSize: 13, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.person, color: Colors.blue, size: 16),
              const SizedBox(width: 4),
              Text(
                responsible,
                style: const TextStyle(fontSize: 12, color: Colors.blue),
              ),
              const Spacer(),
              Text(
                amount,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Evidence & Documentation:',
            style: TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: evidence.map((file) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.blue.withOpacity(0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    file.endsWith('.pdf') ? Icons.picture_as_pdf : 
                    file.endsWith('.jpg') || file.endsWith('.png') ? Icons.image :
                    file.endsWith('.mp4') ? Icons.videocam : Icons.description,
                    color: Colors.blue,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    file,
                    style: const TextStyle(fontSize: 10, color: Colors.blue),
                  ),
                ],
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAuditControlCenter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade900, Colors.red.shade700],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.security, color: Colors.white, size: 24),
              SizedBox(width: 8),
              Text(
                'Audit Control Center',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildAuditIndicator('Active Flags', 3, Colors.red),
          _buildAuditIndicator('Pending Reviews', 7, Colors.orange),
          _buildAuditIndicator('Compliance Score', 94, Colors.green),
          _buildAuditIndicator('Risk Assessment', 67, Colors.blue),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _showComprehensiveAuditReport(),
            icon: const Icon(Icons.assessment, size: 18),
            label: const Text('Generate Audit Report'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 40),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () => _initiateForensicAudit(),
            icon: const Icon(Icons.gavel, size: 18),
            label: const Text('Initiate Forensic Audit'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade800,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 40),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recent Audit Actions:',
                  style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('• Material procurement flagged for review', style: TextStyle(fontSize: 10, color: Colors.white70)),
                Text('• Labor payment audit initiated', style: TextStyle(fontSize: 10, color: Colors.white70)),
                Text('• Compliance verification completed', style: TextStyle(fontSize: 10, color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuditIndicator(String label, int value, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
              Text(
                '$value${label.contains('Score') || label.contains('Assessment') ? '%' : ''}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: label.contains('Score') || label.contains('Assessment') ? value / 100 : value / 10,
            backgroundColor: Colors.white24,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }

  // Supporting methods for audit and flag functionality
  void _showFundStageDetails(String title, String organization, String responsible, List<String> documents) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: Text('$title Details', style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Organization: $organization', style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            Text('Responsible: $responsible', style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            const Text('Documents:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ...documents.map((doc) => Text('• $doc', style: const TextStyle(color: Colors.white70))),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _flagForAudit(title);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Flag for Audit'),
          ),
        ],
      ),
    );
  }

  void _showAuditFlag(String title, String amount, String responsible) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: const Text('Flag for Audit', style: TextStyle(color: Colors.white)),
        content: Text(
          'Flag $title ($amount) managed by $responsible for audit review?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _flagForAudit('$title - $amount');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Flag'),
          ),
        ],
      ),
    );
  }

  void _showTransactionAudit(String txnId, String type, String amount, String responsible) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: Text('Audit $txnId', style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: $type', style: const TextStyle(color: Colors.white70)),
            Text('Amount: $amount', style: const TextStyle(color: Colors.white70)),
            Text('Responsible: $responsible', style: const TextStyle(color: Colors.white70)),
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
              _flagForAudit('$txnId - $type');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Request Audit'),
          ),
        ],
      ),
    );
  }

  void _showComprehensiveAuditReport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: const Text('Comprehensive Audit Report', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Generating comprehensive audit report with all fund flow transactions, evidence verification, and compliance assessment...',
          style: TextStyle(color: Colors.white70),
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

  void _initiateForensicAudit() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: const Text('Initiate Forensic Audit', style: TextStyle(color: Colors.white)),
        content: const Text(
          'This will initiate a comprehensive forensic audit involving external auditors and regulatory authorities. Continue?',
          style: TextStyle(color: Colors.white70),
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
                const SnackBar(
                  content: Text('Forensic audit initiated. Authorities notified.'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Initiate'),
          ),
        ],
      ),
    );
  }

  void _flagForAudit(String item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$item has been flagged for audit review'),
        backgroundColor: Colors.orange,
        action: SnackBarAction(
          label: 'View',
          onPressed: () {},
        ),
      ),
    );
  }

  // FRAUD & COMMAND PAGE
  Widget _buildFraudCommandPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AI-Powered Fraud Detection & Command Center',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 20),
          
          // Project Selection Section
          _buildProjectSelection(),
          const SizedBox(height: 24),
          
          // Document Upload Section (only show if project is selected)
          if (_selectedProject.isNotEmpty) ...[
            _buildDocumentUploadSection(),
            const SizedBox(height: 24),
          ],
          
          // Analysis Results
          if (_uploadedDocuments.isNotEmpty) ...[
            _buildAnalysisResultsSection(),
            const SizedBox(height: 24),
          ],
          
          // Real-time Fraud Monitoring
          _buildFraudMonitoringDashboard(),
          const SizedBox(height: 24),
          
          // Command Center Actions
          _buildCommandCenterActions(),
        ],
      ),
    );
  }

  Widget _buildDocumentUploadSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade900.withOpacity(0.3), Colors.purple.shade900.withOpacity(0.3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade300.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.cloud_upload, color: Colors.blue.shade300, size: 28),
              const SizedBox(width: 12),
              const Text(
                'AI Document Verification System',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Upload financial documents, receipts, images, or videos for AI-powered legitimacy analysis',
            style: TextStyle(fontSize: 14, color: Colors.white70),
          ),
          const SizedBox(height: 20),
          
          // Upload Buttons Row
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildUploadButton('Add images of the project for check', Icons.photo_camera, Colors.green),
              _buildUploadButton('Add videos of the project for check', Icons.videocam, Colors.blue),
              _buildUploadButton('Add financial documents of the project for check', Icons.account_balance, Colors.orange),
              _buildUploadButton('Add all the project documents', Icons.folder_open, Colors.purple),
            ],
          ),
          
          if (_uploadedDocuments.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Divider(color: Colors.white30),
            const SizedBox(height: 16),
            
            // Uploaded Files List
            ..._uploadedDocuments.map((doc) => _buildUploadedDocumentItem(doc)),
            
            const SizedBox(height: 20),
            
            // AI Analysis Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isAnalyzing ? null : _runAIAnalysis,
                icon: _isAnalyzing
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.psychology),
                label: Text(_isAnalyzing ? 'Analyzing Documents...' : 'Run AI Analysis'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUploadButton(String label, IconData icon, Color color) {
    return ElevatedButton.icon(
      onPressed: () => _simulateFileUpload(label),
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.2),
        foregroundColor: color,
        side: BorderSide(color: color.withOpacity(0.5)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildUploadedDocumentItem(Map<String, dynamic> doc) {
    Color statusColor = doc['aiVerified'] == null
        ? Colors.grey
        : doc['aiVerified']
            ? Colors.green
            : Colors.red;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(doc['icon'], color: statusColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doc['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                Text('${doc['size']} • ${doc['type']}', style: const TextStyle(color: Colors.white60, fontSize: 12)),
              ],
            ),
          ),
          if (doc['aiVerified'] != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                doc['aiVerified'] ? 'LEGITIMATE' : 'SUSPICIOUS',
                style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${doc['confidence']}%',
              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnalysisResultsSection() {
    var legitimateCount = _uploadedDocuments.where((doc) => doc['aiVerified'] == true).length;
    var suspiciousCount = _uploadedDocuments.where((doc) => doc['aiVerified'] == false).length;
    var totalCount = _uploadedDocuments.where((doc) => doc['aiVerified'] != null).length;
    
    if (totalCount == 0) return Container();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade900.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: Colors.green.shade300, size: 24),
              const SizedBox(width: 12),
              const Text(
                'AI Analysis Results',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildAnalysisStatCard(
                  legitimateCount.toString(),
                  'Legitimate',
                  Colors.green,
                  Icons.verified_user,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAnalysisStatCard(
                  suspiciousCount.toString(),
                  'Suspicious',
                  Colors.red,
                  Icons.warning,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAnalysisStatCard(
                  '${((legitimateCount / totalCount) * 100).toStringAsFixed(1)}%',
                  'Success Rate',
                  Colors.blue,
                  Icons.trending_up,
                ),
              ),
            ],
          ),
          
          if (suspiciousCount > 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.security, color: Colors.red.shade300),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Suspicious documents detected. Recommend manual review and forensic analysis.',
                      style: TextStyle(color: Colors.red.shade300, fontWeight: FontWeight.w500),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _initiateForensicReview(),
                    child: const Text('Review'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnalysisStatCard(String value, String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFraudMonitoringDashboard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.shade900.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade300.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.security, color: Colors.red.shade300, size: 28),
              const SizedBox(width: 12),
              const Text(
                'Real-time Fraud Monitoring',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Fraud Alerts
          _buildFraudAlert('DUPLICATE_INVOICE', 'Duplicate invoice detected across 3 projects', Colors.red, 'HIGH'),
          const SizedBox(height: 8),
          _buildFraudAlert('AMOUNT_MISMATCH', 'Fund transfer amount exceeds approved limit', Colors.orange, 'MEDIUM'),
          const SizedBox(height: 8),
          _buildFraudAlert('TIMING_ANOMALY', 'Unusual transaction timing pattern detected', Colors.yellow.shade700, 'LOW'),
          
          const SizedBox(height: 16),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _generateFraudReport(),
                  icon: const Icon(Icons.report_problem),
                  label: const Text('Generate Report'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _initiateForensicAudit(),
                  icon: const Icon(Icons.gavel),
                  label: const Text('Forensic Audit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade600,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFraudAlert(String type, String description, Color color, String priority) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              priority,
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          IconButton(
            onPressed: () => _investigateAlert(type),
            icon: const Icon(Icons.arrow_forward_ios, size: 16),
            color: Colors.white70,
          ),
        ],
      ),
    );
  }

  Widget _buildCommandCenterActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade900.withOpacity(0.3), Colors.blue.shade900.withOpacity(0.3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.indigo.shade300.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.control_camera, color: Colors.indigo.shade300, size: 28),
              const SizedBox(width: 12),
              const Text(
                'Command Center Actions',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 2.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _buildCommandButton('Freeze Funds', Icons.lock, Colors.red, () => _freezeFunds()),
              _buildCommandButton('Alert Authorities', Icons.report, Colors.orange, () => _alertAuthorities()),
              _buildCommandButton('Block Account', Icons.block, Colors.red.shade700, () => _blockAccount()),
              _buildCommandButton('Evidence Backup', Icons.backup, Colors.blue, () => _backupEvidence()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommandButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.2),
        foregroundColor: color,
        side: BorderSide(color: color.withOpacity(0.5)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildProjectSelection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade900.withOpacity(0.3), Colors.blue.shade900.withOpacity(0.3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.indigo.shade300.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.folder_outlined, color: Colors.indigo.shade300, size: 28),
              const SizedBox(width: 12),
              const Text(
                'Select Project for Analysis',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Choose a project to upload documents for fraud detection analysis',
            style: TextStyle(fontSize: 14, color: Colors.white70),
          ),
          const SizedBox(height: 20),
          
          // Project Selection Dropdown
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedProject.isEmpty ? null : _selectedProject,
                hint: const Text(
                  'Select a project...',
                  style: TextStyle(color: Colors.white70),
                ),
                dropdownColor: Colors.grey.shade800,
                style: const TextStyle(color: Colors.white),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
                items: [
                  'PMAJAY-MH-045 - Maharashtra Rural Health Infrastructure',
                  'PMAJAY-GJ-023 - Gujarat Urban Health Centers',
                  'PMAJAY-KA-012 - Karnataka Telemedicine Network',
                  'PMAJAY-UP-134 - Uttar Pradesh Emergency Services',
                  'PMAJAY-TN-067 - Tamil Nadu Mobile Health Units',
                ].map((project) => DropdownMenuItem<String>(
                  value: project.split(' - ')[0],
                  child: Text(
                    project,
                    style: const TextStyle(color: Colors.white),
                  ),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedProject = value ?? '';
                    _uploadedDocuments.clear(); // Clear previous uploads when switching projects
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ARCHIVE PAGE
  Widget _buildArchivePage() {
    final filteredProjects = _archivedProjects.where((project) {
      final matchesQuery = project['name'].toLowerCase().contains(_archiveSearchQuery.toLowerCase()) ||
                          project['id'].toLowerCase().contains(_archiveSearchQuery.toLowerCase());
      final matchesStatus = _archiveStatusFilter == 'ALL' || project['status'] == _archiveStatusFilter;
      return matchesQuery && matchesStatus;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo.shade800, Colors.purple.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.indigo.shade400, width: 2),
            ),
            child: Row(
              children: [
                const Icon(Icons.archive, color: Colors.white, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Project Archive',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Historical records of ${_archivedProjects.length} completed and terminated projects',
                        style: const TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green, width: 1),
                  ),
                  child: Text(
                    'Total: ${_archivedProjects.length}',
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade900.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade700, width: 1),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            _archiveSearchQuery = value;
                          });
                        },
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search by project name or ID...',
                          hintStyle: const TextStyle(color: Colors.white54),
                          prefixIcon: const Icon(Icons.search, color: Colors.blue),
                          filled: true,
                          fillColor: Colors.grey.shade800,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _archiveStatusFilter,
                        onChanged: (value) {
                          setState(() {
                            _archiveStatusFilter = value!;
                          });
                        },
                        dropdownColor: Colors.grey.shade800,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Filter by Status',
                          labelStyle: const TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.grey.shade800,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'ALL', child: Text('All Status')),
                          DropdownMenuItem(value: 'COMPLETED', child: Text('Completed')),
                          DropdownMenuItem(value: 'TERMINATED', child: Text('Terminated')),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Statistics Row
                Row(
                  children: [
                    _buildArchiveStatCard(
                      'Total Projects',
                      _archivedProjects.length.toString(),
                      Icons.folder_outlined,
                      Colors.blue,
                    ),
                    const SizedBox(width: 12),
                    _buildArchiveStatCard(
                      'Completed',
                      _archivedProjects.where((p) => p['status'] == 'COMPLETED').length.toString(),
                      Icons.check_circle_outline,
                      Colors.green,
                    ),
                    const SizedBox(width: 12),
                    _buildArchiveStatCard(
                      'Terminated',
                      _archivedProjects.where((p) => p['status'] == 'TERMINATED').length.toString(),
                      Icons.cancel_outlined,
                      Colors.red,
                    ),
                    const SizedBox(width: 12),
                    _buildArchiveStatCard(
                      'Total Budget',
                      _calculateTotalBudget(),
                      Icons.currency_rupee,
                      Colors.orange,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Projects Grid
          if (filteredProjects.isEmpty)
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.grey.shade900.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade700, width: 1),
              ),
              child: const Center(
                child: Column(
                  children: [
                    Icon(Icons.search_off, color: Colors.white54, size: 48),
                    SizedBox(height: 16),
                    Text(
                      'No projects found',
                      style: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Try adjusting your search or filter criteria',
                      style: TextStyle(color: Colors.white54, fontSize: 14),
                    ),
                  ],
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: filteredProjects.length,
              itemBuilder: (context, index) {
                final project = filteredProjects[index];
                return _buildArchivedProjectCard(project);
              },
            ),
        ],
      ),
    );
  }
Widget _buildArchiveStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.8), color.withOpacity(0.6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _calculateTotalBudget() {
    double total = 0;
    for (var project in _archivedProjects) {
      String budgetStr = project['budget'].toString().replaceAll(RegExp(r'[₹\s]'), '').replaceAll('Cr', '');
      total += double.tryParse(budgetStr) ?? 0;
    }
    return '₹${total.toStringAsFixed(0)}Cr';
  }

  Widget _buildArchivedProjectCard(Map<String, dynamic> project) {
    final isCompleted = project['status'] == 'COMPLETED';
    final statusColor = isCompleted ? Colors.green : Colors.red;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey.shade900.withOpacity(0.9),
            Colors.grey.shade800.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status
          Row(
            children: [
              Expanded(
                child: Text(
                  project['id'],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor, width: 1),
                ),
                child: Text(
                  project['status'],
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Project name
          Text(
            project['name'],
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 16),
          
          // Budget and utilization
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Budget',
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                    Text(
                      project['budget'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Utilization',
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                    Text(
                      project['utilization'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Completion date and compliance
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.white54, size: 16),
              const SizedBox(width: 4),
              Text(
                project['completionDate'],
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
              const Spacer(),
              Icon(Icons.score, color: Colors.blue.shade300, size: 16),
              const SizedBox(width: 4),
              Text(
                '${project['complianceScore']}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade300,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Beneficiaries and action button
          Row(
            children: [
              Icon(Icons.people, color: Colors.green.shade300, size: 16),
              const SizedBox(width: 4),
              Text(
                '${(project['beneficiaries'] / 1000).toStringAsFixed(0)}K beneficiaries',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green.shade300,
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => _showArchivedProjectDetails(project),
                style: ElevatedButton.styleFrom(
                  backgroundColor: statusColor.withOpacity(0.2),
                  foregroundColor: statusColor,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: const Size(0, 28),
                ),
                child: const Text(
                  'Details',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showArchivedProjectDetails(Map<String, dynamic> project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: Row(
          children: [
            Icon(
              project['status'] == 'COMPLETED' ? Icons.check_circle : Icons.cancel,
              color: project['status'] == 'COMPLETED' ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                project['name'],
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Project ID', project['id']),
              _buildDetailRow('Status', project['status']),
              _buildDetailRow('Budget', project['budget']),
              _buildDetailRow('Utilization', project['utilization']),
              _buildDetailRow('Completion Date', project['completionDate']),
              _buildDetailRow('Compliance Score', '${project['complianceScore']}%'),
              _buildDetailRow('Beneficiaries', project['beneficiaries'].toString()),
              const SizedBox(height: 16),
              const Text(
                'Project Summary:',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                project['status'] == 'COMPLETED' 
                  ? 'This project was successfully completed with all objectives met. Fund utilization and compliance metrics exceeded expected standards.'
                  : 'This project was terminated due to compliance issues or strategic changes. All documentation and fund usage records are maintained for audit purposes.',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Downloaded ${project['id']} archive'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Download Archive'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // UTILITY METHODS
  void _refreshAllData() {
    setState(() {
      // Refresh all data
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data refreshed successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _batchApproveClaims() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Approved ${_selectedClaims.length} claims'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _batchRejectClaims() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Rejected ${_selectedClaims.length} claims for review'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _showClaimDetailModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ComprehensiveClaimReviewDialog(),
    );
  }

  // AI Document Analysis Methods
  void _simulateFileUpload(String type) {
    setState(() {
      _uploadedDocuments.add({
        'name': 'Document_${_uploadedDocuments.length + 1}.pdf',
        'type': type.split(' ')[1],
        'size': '${(1 + (DateTime.now().millisecondsSinceEpoch % 10))} MB',
        'icon': type.contains('Financial') ? Icons.description
              : type.contains('Receipts') ? Icons.receipt_long
              : type.contains('Images') ? Icons.image
              : Icons.videocam,
        'uploadTime': DateTime.now(),
        'aiVerified': null,
        'confidence': null,
      });
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$type uploaded successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _runAIAnalysis() async {
    setState(() {
      _isAnalyzing = true;
    });

    // Simulate AI analysis with realistic delay
    for (int i = 0; i < _uploadedDocuments.length; i++) {
      if (_uploadedDocuments[i]['aiVerified'] == null) {
        await Future.delayed(const Duration(seconds: 2));
        
        setState(() {
          // Simulate AI results with weighted probability toward legitimate
          bool isLegitimate = DateTime.now().millisecondsSinceEpoch % 10 > 2; // 80% legitimate rate
          int confidence = 75 + (DateTime.now().millisecondsSinceEpoch % 20); // 75-95% confidence
          
          _uploadedDocuments[i]['aiVerified'] = isLegitimate;
          _uploadedDocuments[i]['confidence'] = confidence;
        });
      }
    }

    setState(() {
      _isAnalyzing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('AI analysis completed'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Command Center Action Methods
  void _freezeFunds() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: const Text('Emergency Fund Freeze', style: TextStyle(color: Colors.white)),
        content: const Text(
          'This will immediately freeze all fund transactions for the selected project. Continue?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Emergency fund freeze activated'), backgroundColor: Colors.red),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Freeze'),
          ),
        ],
      ),
    );
  }

  void _alertAuthorities() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Alert sent to regulatory authorities and anti-fraud units'),
        backgroundColor: Colors.orange,
      ),
    );
  }
  
  // Custom painter for animated flowing lines in Fund Flow visualization

  void _blockAccount() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Account access blocked pending investigation'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _backupEvidence() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Evidence backup initiated to secure forensic storage'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _generateFraudReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Comprehensive fraud analysis report being generated...'),
        backgroundColor: Colors.purple,
      ),
    );
  }

  void _initiateForensicReview() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: const Text('Initiate Forensic Review', style: TextStyle(color: Colors.white)),
        content: const Text(
          'This will escalate suspicious documents for manual forensic analysis by certified auditors.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Forensic review initiated. Expert auditors notified.'),
                  backgroundColor: Colors.purple,
                ),
              );
            },
            child: const Text('Initiate'),
          ),
        ],
      ),
    );
  }

  void _investigateAlert(String alertType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: Text('Investigating $alertType', style: const TextStyle(color: Colors.white)),
        content: Text(
          'Detailed investigation report for $alertType will be generated with evidence correlation and impact assessment.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$alertType investigation started')),
              );
            },
            child: const Text('Start Investigation'),
          ),
        ],
      ),
    );
  }
}

// Custom painter for branching fund flow connections
class BranchingFlowPainter extends CustomPainter {
  final double animationValue;

  BranchingFlowPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final glowPaint = Paint()
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    // Starting point (from Implementation Agency)
    const startX = 0.0;
    const startY = 200.0; // Center of the container
    
    // End points for each fund category
    const endX = 160.0;
    final endPoints = [
      60.0,   // Land Acquisition
      150.0,  // Construction Materials
      240.0,  // Labor Payments
      320.0,  // Equipment Procurement - reduced to prevent overflow
    ];

    final colors = [
      Colors.brown,     // Land
      Colors.cyan,      // Construction
      Colors.purple,    // Labor
      Colors.indigo,    // Equipment
    ];

    // Draw branching lines to each fund category
    for (int i = 0; i < endPoints.length; i++) {
      final endY = endPoints[i];
      final color = colors[i];
      
      // Create curved path for each branch
      final path = Path();
      path.moveTo(startX, startY);
      
      // Add curve control points for smooth branching
      final controlX = size.width * 0.6;
      final controlY = startY + (endY - startY) * 0.3;
      
      path.quadraticBezierTo(controlX, controlY, endX, endY);
      
      // Draw static background line
      paint.color = color.withOpacity(0.3);
      glowPaint.color = color.withOpacity(0.1);
      canvas.drawPath(path, glowPaint);
      canvas.drawPath(path, paint);
      
      // Draw animated flowing particles along the path
      final pathMetrics = path.computeMetrics().toList();
      if (pathMetrics.isNotEmpty) {
        final pathMetric = pathMetrics.first;
        final pathLength = pathMetric.length;
        
        // Multiple particles per line with different speeds
        for (int j = 0; j < 3; j++) {
          final offset = (j * 0.3 + animationValue) % 1.0;
          final distance = offset * pathLength;
          final tangent = pathMetric.getTangentForOffset(distance);
          
          if (tangent != null) {
            // Draw flowing particle
            final particlePaint = Paint()
              ..color = color
              ..style = PaintingStyle.fill;
              
            final glowParticlePaint = Paint()
              ..color = color.withOpacity(0.8)
              ..style = PaintingStyle.fill
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
            
            canvas.drawCircle(tangent.position, 6, glowParticlePaint);
            canvas.drawCircle(tangent.position, 3, particlePaint);
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant BranchingFlowPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}