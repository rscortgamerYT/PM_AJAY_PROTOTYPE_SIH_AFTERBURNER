import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_design_system.dart';

class NewOverwatchDashboardPage extends ConsumerStatefulWidget {
  const NewOverwatchDashboardPage({super.key});

  @override
  ConsumerState<NewOverwatchDashboardPage> createState() =>
      _NewOverwatchDashboardPageState();
}

class _NewOverwatchDashboardPageState
    extends ConsumerState<NewOverwatchDashboardPage> {
  int _selectedIndex = 0;
  double _scanningProgress = 0.0;
  bool _isScanning = false;
  String _selectedProject = 'PMAJAY-MH-045';
  List<String> _selectedClaims = [];
  String _filterCategory = 'ALL';

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
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedProject = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'PMAJAY-MH-045', child: Text('PMAJAY-MH-045')),
              const PopupMenuItem(value: 'PMAJAY-GJ-023', child: Text('PMAJAY-GJ-023')),
              const PopupMenuItem(value: 'PMAJAY-KA-012', child: Text('PMAJAY-KA-012')),
            ],
            child: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_selectedProject, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshAllData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: _buildCurrentPage(),
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
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
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
        gradient: LinearGradient(
          colors: [const Color(0xFF2D3748), const Color(0xFF1A202C)],
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
              style: const TextStyle(fontSize: 14),
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
        color: Color(0xFF2D3748),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Performance Dashboard',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
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
        color: Color(0xFF2D3748),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Activities',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                  style: const TextStyle(fontSize: 11),
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
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.shade400),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Batch Operations',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
        color: Color(0xFF2D3748),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Claims Management',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
        color: isSelected ? Colors.blue.shade50 : Colors.grey.shade50,
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
            icon: Icon(Icons.visibility, size: 16),
            label: Text('Review'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size(80, 30),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      claimId,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
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

  // FUND FLOW PAGE
  Widget _buildFundFlowPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Fund Summary
          _buildFundSummaryRow(),
          const SizedBox(height: 20),
          
          // Interactive Sankey Diagram
          _buildSankeyVisualization(),
          const SizedBox(height: 20),
          
          // Fund Flow Details
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _buildTransactionTable()),
              const SizedBox(width: 16),
              Expanded(flex: 2, child: _buildFundHealthIndicators()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFundSummaryRow() {
    return Row(
      children: [
        Expanded(child: _buildFundSummaryCard('₹2,847Cr', 'Total Allocated', '100%', Colors.blue)),
        const SizedBox(width: 12),
        Expanded(child: _buildFundSummaryCard('₹2,134Cr', 'Utilized', '75%', Colors.green)),
        const SizedBox(width: 12),
        Expanded(child: _buildFundSummaryCard('₹713Cr', 'Remaining', '25%', Colors.orange)),
        const SizedBox(width: 12),
        Expanded(child: _buildFundSummaryCard('₹45Cr', 'Pending Release', '1.6%', Colors.red)),
      ],
    );
  }

  Widget _buildFundSummaryCard(String amount, String label, String percentage, Color color) {
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
            amount,
            style: TextStyle(
              fontSize: 20,
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
          const SizedBox(height: 4),
          Text(
            percentage,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSankeyVisualization() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Multi-Level Fund Flow Visualization',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: [
                // Level 1: Central Government
                Expanded(
                  child: Column(
                    children: [
                      _buildFlowNode('Central\nGovernment\n₹2,847Cr', Colors.blue, isLarge: true),
                      const SizedBox(height: 20),
                      const Text('SOURCE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                
                // Flow Arrow
                const Icon(Icons.arrow_forward, size: 30, color: Colors.grey),
                
                // Level 2: State Distribution
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: _buildFlowNode('Maharashtra\n₹847Cr', Colors.green)),
                          const SizedBox(width: 8),
                          Expanded(child: _buildFlowNode('Gujarat\n₹634Cr', Colors.orange)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: _buildFlowNode('Karnataka\n₹712Cr', Colors.purple)),
                          const SizedBox(width: 8),
                          Expanded(child: _buildFlowNode('Tamil Nadu\n₹654Cr', Colors.red)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text('STATE ALLOCATION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                
                // Flow Arrow
                const Icon(Icons.arrow_forward, size: 30, color: Colors.grey),
                
                // Level 3: Implementation
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: _buildFlowNode('Land\nAcquisition\n₹568Cr', Colors.brown)),
                          const SizedBox(width: 8),
                          Expanded(child: _buildFlowNode('Construction\n₹1,134Cr', Colors.cyan)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: _buildFlowNode('Equipment\n₹432Cr', Colors.indigo)),
                          const SizedBox(width: 8),
                          Expanded(child: _buildFlowNode('Operations\n₹713Cr', Colors.teal)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text('UTILIZATION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlowNode(String text, Color color, {bool isLarge = false}) {
    return Container(
      height: isLarge ? 80 : 60,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: Color(0xFF2D3748),
            fontSize: isLarge ? 12 : 10,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildTransactionTable() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF2D3748),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Transactions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildTransactionItem('TXN-001', 'State → District', '₹50Cr', 'Maharashtra → Pune', 'SUCCESS'),
          _buildTransactionItem('TXN-002', 'District → Agency', '₹25Cr', 'Pune → MRDA', 'PENDING'),
          _buildTransactionItem('TXN-003', 'Agency → Contractor', '₹15Cr', 'MRDA → ABC Constructions', 'SUCCESS'),
          _buildTransactionItem('TXN-004', 'Material Purchase', '₹8Cr', 'XYZ Suppliers', 'PROCESSING'),
          _buildTransactionItem('TXN-005', 'Labor Payment', '₹3Cr', 'Contractor Payroll', 'SUCCESS'),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(String txnId, String type, String amount, String details, String status) {
    Color statusColor;
    switch (status) {
      case 'SUCCESS':
        statusColor = Colors.green;
        break;
      case 'PENDING':
        statusColor = Colors.orange;
        break;
      case 'PROCESSING':
        statusColor = Colors.blue;
        break;
      default:
        statusColor = Colors.red;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: statusColor, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                txnId,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    color: Color(0xFF2D3748),
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            type,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
          ),
          Text(
            details,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
          const SizedBox(height: 4),
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
    );
  }

  Widget _buildFundHealthIndicators() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF2D3748),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fund Health Indicators',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildHealthIndicator('Utilization Rate', 75, Colors.green),
          _buildHealthIndicator('Release Efficiency', 92, Colors.blue),
          _buildHealthIndicator('Compliance Score', 88, Colors.purple),
          _buildHealthIndicator('Delay Risk', 23, Colors.red),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Generate Report'),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthIndicator(String label, int value, Color color) {
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
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
              Text(
                '$value%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: value / 100,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }

  // FRAUD & COMMAND PAGE
  Widget _buildFraudCommandPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Command Center Stats
          Row(
            children: [
              Expanded(child: _buildCommandStat('12', 'Active Investigations', Colors.red)),
              const SizedBox(width: 12),
              Expanded(child: _buildCommandStat('47', 'Under Review', Colors.orange)),
              const SizedBox(width: 12),
              Expanded(child: _buildCommandStat('156', 'Resolved Cases', Colors.green)),
              const SizedBox(width: 12),
              Expanded(child: _buildCommandStat('96%', 'Detection Rate', Colors.blue)),
            ],
          ),
          const SizedBox(height: 20),
          
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AI Fraud Detection
              Expanded(flex: 3, child: _buildAIFraudDetection()),
              const SizedBox(width: 16),
              // Command Operations
              Expanded(flex: 2, child: _buildCommandOperations()),
            ],
          ),
          const SizedBox(height: 20),
          
          // Evidence Analysis
          _buildEvidenceAnalysis(),
        ],
      ),
    );
  }

  Widget _buildCommandStat(String value, String label, Color color) {
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
            style: const TextStyle(fontSize: 12, color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAIFraudDetection() {
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
              Icon(Icons.security, color: Colors.red.shade600),
              const SizedBox(width: 8),
              const Text(
                'AI Fraud Detection Engine',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          ElevatedButton.icon(
            onPressed: _isScanning ? null : _runComprehensiveScan,
            icon: Icon(_isScanning ? Icons.hourglass_empty : Icons.search),
            label: Text(_isScanning ? 'Scanning...' : 'Run Deep Scan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          
          if (_isScanning) _buildScanningProgress(),
          if (!_isScanning) _buildFraudDetectionResults(),
        ],
      ),
    );
  }

  Widget _buildScanningProgress() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF2D3748),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          const Text(
            'AI Deep Analysis in Progress',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _scanningProgress / 100,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.red.shade600),
          ),
          const SizedBox(height: 4),
          Text(
            '${_scanningProgress.toInt()}% Complete',
            style: const TextStyle(fontSize: 12, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            _getScanningPhase(),
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  String _getScanningPhase() {
    if (_scanningProgress < 25) return 'Analyzing image metadata...';
    if (_scanningProgress < 50) return 'Detecting duplicate evidence...';
    if (_scanningProgress < 75) return 'Cross-referencing project data...';
    return 'Generating fraud probability scores...';
  }

  Widget _buildFraudDetectionResults() {
    return Column(
      children: [
        _buildFraudAlert('Critical', 'Duplicate Evidence', 'Same image used in 3 different projects', 94, Colors.red),
        const SizedBox(height: 8),
        _buildFraudAlert('High', 'GPS Manipulation', 'Location coordinates artificially altered', 87, Colors.orange),
        const SizedBox(height: 8),
        _buildFraudAlert('Medium', 'Timeline Inconsistency', 'Progress photos taken on same day', 73, Colors.yellow.shade700),
        const SizedBox(height: 8),
        _buildFraudAlert('Low', 'Quality Variance', 'Unusual image quality patterns detected', 45, Colors.blue),
      ],
    );
  }

  Widget _buildFraudAlert(String severity, String type, String description, int confidence, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  severity.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF2D3748),
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '$confidence%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            type,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          Text(
            description,
            style: const TextStyle(fontSize: 12, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: const Text('Investigate', style: TextStyle(fontSize: 10)),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('Flag', style: TextStyle(fontSize: 10)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommandOperations() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF2D3748), const Color(0xFF1A202C)],
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
              Icon(Icons.settings, color: Colors.blue.shade600),
              const SizedBox(width: 8),
              const Text(
                'Command Operations',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildCommandAction('Emergency Stop', 'Halt all transactions for PMAJAY-MH-045', Icons.stop, Colors.red),
          const SizedBox(height: 8),
          _buildCommandAction('Flag Project', 'Mark project for investigation', Icons.flag, Colors.orange),
          const SizedBox(height: 8),
          _buildCommandAction('Escalate Alert', 'Send to senior authorities', Icons.arrow_upward, Colors.purple),
          const SizedBox(height: 8),
          _buildCommandAction('Generate Report', 'Create investigation summary', Icons.description, Colors.green),
          
          const SizedBox(height: 16),
          const Text(
            'Quick Actions',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Freeze Funds'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Alert Team'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommandAction(String title, String description, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Color(0xFF2D3748),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                Text(
                  description,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.play_arrow, size: 16),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildEvidenceAnalysis() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF2D3748),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Evidence Analysis Dashboard',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(child: _buildEvidenceMetric('2,456', 'Images Analyzed', Colors.blue)),
              const SizedBox(width: 12),
              Expanded(child: _buildEvidenceMetric('143', 'Duplicates Found', Colors.red)),
              const SizedBox(width: 12),
              Expanded(child: _buildEvidenceMetric('89', 'GPS Anomalies', Colors.orange)),
              const SizedBox(width: 12),
              Expanded(child: _buildEvidenceMetric('34', 'Metadata Issues', Colors.purple)),
            ],
          ),
          
          const SizedBox(height: 16),
          const Text(
            'Recent Findings',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          
          _buildEvidenceItem('IMG_2023_001.jpg', 'Used in PMAJAY-MH-045, PMAJAY-GJ-023, PMAJAY-KA-012', 'DUPLICATE', Colors.red),
          _buildEvidenceItem('IMG_2023_087.jpg', 'GPS coordinates: (19.0760, 72.8777) → (28.6139, 77.2090)', 'GPS_TAMPER', Colors.orange),
          _buildEvidenceItem('IMG_2023_156.jpg', 'Timestamp: 2023-03-15 14:30:00 (Created: 2023-02-10)', 'METADATA', Colors.purple),
        ],
      ),
    );
  }

  Widget _buildEvidenceMetric(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEvidenceItem(String filename, String issue, String type, Color color) {
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
          Icon(Icons.image, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  filename,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                Text(
                  issue,
                  style: const TextStyle(fontSize: 10),
                ),
              ],
            ),
          ),
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
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ARCHIVE PAGE
  Widget _buildArchivePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Archive Stats
          Row(
            children: [
              Expanded(child: _buildArchiveStat('1,247', 'Completed Projects', Colors.green)),
              const SizedBox(width: 12),
              Expanded(child: _buildArchiveStat('₹15,480Cr', 'Total Value', Colors.blue)),
              const SizedBox(width: 12),
              Expanded(child: _buildArchiveStat('89%', 'Success Rate', Colors.purple)),
              const SizedBox(width: 12),
              Expanded(child: _buildArchiveStat('4.2/5', 'Avg Quality Score', Colors.orange)),
            ],
          ),
          const SizedBox(height: 20),
          
          // Search and Filters
          _buildArchiveSearchAndFilters(),
          const SizedBox(height: 20),
          
          // Project Archive List
          _buildProjectArchiveList(),
        ],
      ),
    );
  }

  Widget _buildArchiveStat(String value, String label, Color color) {
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
            value,
            style: TextStyle(
              fontSize: 20,
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

  Widget _buildArchiveSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Search & Filter Archive',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          // Search Bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Search by project ID, location, or keywords...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              filled: true,
              fillColor: const Color(0xFF2D2D2D),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Filter Chips
          Wrap(
            spacing: 8,
            children: [
              _buildFilterChip('All Projects', true),
              _buildFilterChip('Completed', false),
              _buildFilterChip('High Quality', false),
              _buildFilterChip('Over Budget', false),
              _buildFilterChip('Under Budget', false),
              _buildFilterChip('2023', false),
              _buildFilterChip('2022', false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {},
      selectedColor: Colors.blue.shade200,
      checkmarkColor: Colors.blue.shade600,
      labelStyle: TextStyle(
        fontSize: 12,
        color: isSelected ? Colors.blue.shade600 : Colors.grey,
      ),
    );
  }

  Widget _buildProjectArchiveList() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF2D3748),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Project Archive',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          _buildArchiveProjectItem(
            'PMAJAY-MH-001',
            'Primary Health Center - Pune',
            'Completed',
            '₹45Cr',
            '2023-12-15',
            '4.8/5',
            Colors.green,
          ),
          _buildArchiveProjectItem(
            'PMAJAY-GJ-002',
            'District Hospital - Ahmedabad',
            'Completed',
            '₹120Cr',
            '2023-11-28',
            '4.6/5',
            Colors.green,
          ),
          _buildArchiveProjectItem(
            'PMAJAY-KA-003',
            'Medical College - Bangalore',
            'Completed',
            '₹280Cr',
            '2023-10-20',
            '4.9/5',
            Colors.green,
          ),
          _buildArchiveProjectItem(
            'PMAJAY-TN-004',
            'Specialty Center - Chennai',
            'Completed',
            '₹95Cr',
            '2023-09-12',
            '4.3/5',
            Colors.green,
          ),
          _buildArchiveProjectItem(
            'PMAJAY-AP-005',
            'Community Health Center - Hyderabad',
            'Completed',
            '₹67Cr',
            '2023-08-30',
            '4.7/5',
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildArchiveProjectItem(
    String projectId,
    String title,
    String status,
    String budget,
    String completedDate,
    String qualityScore,
    Color statusColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      projectId,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
                  title,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      'Completed: $completedDate',
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.star, size: 12, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      qualityScore,
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  budget,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.visibility, size: 16),
                tooltip: 'View Details',
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.download, size: 16),
                tooltip: 'Download Report',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // HELPER METHODS
  void _runComprehensiveScan() async {
    setState(() {
      _isScanning = true;
      _scanningProgress = 0.0;
    });

    for (int i = 0; i <= 100; i += 2) {
      await Future.delayed(const Duration(milliseconds: 50));
      setState(() {
        _scanningProgress = i.toDouble();
      });
    }

    setState(() {
      _isScanning = false;
    });
  }

  void _refreshAllData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Refreshing all dashboard data...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _batchApproveClaims() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Approved ${_selectedClaims.length} claims'),
        duration: const Duration(seconds: 2),
      ),
    );
    setState(() {
      _selectedClaims.clear();
    });
  }

  void _batchRejectClaims() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Rejected ${_selectedClaims.length} claims'),
        duration: const Duration(seconds: 2),
      ),
    );
    setState(() {
      _selectedClaims.clear();
    });
  }

  // Professional Claims Review Modal - Class Methods
  void _showClaimDetailModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1A1A1A),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.95,
            maxHeight: MediaQuery.of(context).size.height * 0.95,
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with responsive title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Professional Claim Review: CLM-001',
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width < 600 ? 16 : 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Responsive content layout
                Expanded(
                  child: MediaQuery.of(context).size.width > 800
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left Panel - Document Evidence
                          Expanded(
                            flex: 2,
                            child: _buildDocumentEvidencePanel(),
                          ),
                          const SizedBox(width: 16),
                          // Right Panel - AI Analysis & Decision
                          Expanded(
                            flex: 1,
                            child: _buildAnalysisDecisionPanel(),
                          ),
                        ],
                      )
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildDocumentEvidencePanel(),
                            const SizedBox(height: 16),
                            _buildAnalysisDecisionPanel(),
                          ],
                        ),
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentEvidencePanel() {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade600),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Document Evidence Review',
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width < 600 ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Geo-tagged Photos Section
                  _buildEvidenceSection(
                    'Geo-Tagged Photos & Videos',
                    Icons.location_on,
                    [
                      _buildPhotoCard('Construction Site - Foundation', '19.0760°N, 72.8777°E', 'Verified ✓'),
                      _buildPhotoCard('Material Delivery', '19.0761°N, 72.8778°E', 'Verified ✓'),
                      _buildVideoCard('Progress Video - Week 12', '19.0759°N, 72.8776°E', 'Verified ✓'),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Financial Receipts Section
                  _buildEvidenceSection(
                    'Financial Receipts & Documentation',
                    Icons.receipt_long,
                    [
                      _buildReceiptCard('Invoice #INV-2024-001', '₹15,00,000', 'Material Purchase', 'Verified ✓'),
                      _buildReceiptCard('Payment Receipt #PAY-455', '₹15,00,000', 'Bank Transfer', 'Verified ✓'),
                      _buildReceiptCard('GST Certificate', 'GST: 18%', 'Tax Documentation', 'Verified ✓'),
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

  Widget _buildAnalysisDecisionPanel() {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade600),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'AI Analysis & Decision Panel',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width < 600 ? 16 : 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            
            // AI Analysis Results
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.verified, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'AI Verification: 98.5% Authentic',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• GPS coordinates verified\n• Timestamps validated\n• Document authenticity confirmed\n• No fraud indicators detected',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Decision Actions
            Text(
              'Professional Decision',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width < 600 ? 14 : 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.check_circle, size: 18),
                    label: const Text('Approve Claim'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.assignment_return, size: 18),
                    label: const Text('Return for Review'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.cancel, size: 18),
                    label: const Text('Reject Claim'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Additional Options
            Text(
              'Additional Actions',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width < 600 ? 14 : 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.security, size: 16),
                label: const Text('Flag for Fraud Investigation'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    // This was causing the duplicate child error - the container was already closed above
  }

  Widget _buildAIAnalysisReport() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade600),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AI Analysis Report',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          
          // AI Analysis Results
          _buildAnalysisCard('Document Authenticity', '98.5%', Colors.green, 'All documents pass verification'),
          _buildAnalysisCard('Location Verification', '96.2%', Colors.green, 'GPS coordinates match site'),
          _buildAnalysisCard('Financial Compliance', '94.8%', Colors.green, 'Amounts and taxes verified'),
          _buildAnalysisCard('Timeline Consistency', '91.3%', Colors.orange, 'Minor date discrepancy detected'),
          
          const SizedBox(height: 20),
          
          // Fraud Check Integration
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade900.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade400),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.security, color: Colors.blue.shade400),
                    const SizedBox(width: 8),
                    const Text(
                      'Fraud Management Check',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '✓ No duplicate evidence detected\n✓ No GPS manipulation found\n✓ Financial patterns normal\n✓ Contractor verification passed',
                  style: TextStyle(fontSize: 12, color: Colors.white),
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
          // Professional Decision Buttons
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _showApprovalConfirmation(context);
                  },
                  icon: const Icon(Icons.verified_user),
                  label: const Text('APPROVE CLAIM'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _showReturnForReviewDialog(context);
                  },
                  icon: const Icon(Icons.assignment_return),
                  label: const Text('RETURN FOR REVIEW'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _showRejectClaimDialog(context);
                  },
                  icon: const Icon(Icons.cancel),
                  label: const Text('REJECT CLAIM'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEvidenceSection(String title, IconData icon, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.blue.shade400, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade400,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...items,
      ],
    );
  }

  Widget _buildPhotoCard(String title, String location, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade400),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.image, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                Text(location, style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
                Text(status, style: const TextStyle(fontSize: 12, color: Colors.green)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoCard(String title, String location, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade400),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.play_circle_filled, color: Colors.blue, size: 30),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                Text(location, style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
                Text(status, style: const TextStyle(fontSize: 12, color: Colors.green)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptCard(String title, String amount, String type, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade400),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.receipt, color: Colors.orange),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                Text(amount, style: const TextStyle(fontSize: 12, color: Colors.blue)),
                Text(type, style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
                Text(status, style: const TextStyle(fontSize: 12, color: Colors.green)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisCard(String title, String percentage, Color color, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
              Text(percentage, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: 4),
          Text(description, style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
        ],
      ),
    );
  }

  void _showApprovalConfirmation(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Claim CLM-001 has been approved and processed'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showReturnForReviewDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Claim CLM-001 returned for additional documentation'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _showRejectClaimDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Claim CLM-001 has been rejected'),
        backgroundColor: Colors.red,
      ),
    );
  }
}