import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/national_heatmap_widget.dart';
import '../widgets/collaboration_network_widget.dart';
import '../widgets/compliance_scoreboard_widget.dart';
import '../widgets/national_performance_leaderboard_widget.dart';
import '../widgets/predictive_analytics_widget.dart';
import '../widgets/request_review_panel_widget.dart';
import '../widgets/interactive_sankey_widget.dart';
import '../../../communication/presentation/pages/communication_hub_page.dart';
import '../../../../core/widgets/calendar_widget.dart';
import '../../../../core/widgets/dashboard_components.dart';
import '../../../../core/widgets/event_calendar_widget.dart';
import '../../../../core/widgets/notification_panel_widget.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../data/mock_fund_flow_data.dart';
import '../../../../core/widgets/dashboard_switcher_widget.dart';
import '../../../fund_flow/widgets/dual_entry_reconciliation_widget.dart';

class CentreDashboardPage extends ConsumerStatefulWidget {
  const CentreDashboardPage({super.key});

  @override
  ConsumerState<CentreDashboardPage> createState() => _CentreDashboardPageState();
}

class _CentreDashboardPageState extends ConsumerState<CentreDashboardPage> {
  int _selectedIndex = 0;
  List<NotificationItem> _notifications = [];
  
  // Mock KPI data - to be replaced with real data
  final int _totalStates = 28;
  final int _pendingApprovals = 12;
  final double _fundsAllocated = 5000.0; // in Crores
  final int _activeProjects = 342;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    final now = DateTime.now();
    _notifications = [
      NotificationItem(
        id: '1',
        title: 'Budget Approval Pending',
        message: 'Central budget allocation of ₹500Cr requires your approval.',
        type: NotificationType.approval,
        priority: NotificationPriority.high,
        timestamp: now.subtract(const Duration(minutes: 30)),
        actionRoute: '/approvals',
      ),
      NotificationItem(
        id: '2',
        title: 'State Fund Request',
        message: 'Maharashtra has submitted an emergency fund request for disaster relief.',
        type: NotificationType.alert,
        priority: NotificationPriority.high,
        timestamp: now.subtract(const Duration(hours: 1)),
        actionRoute: '/requests',
      ),
      NotificationItem(
        id: '3',
        title: 'Compliance Report Due',
        message: 'Q4 national compliance report deadline is in 2 days.',
        type: NotificationType.deadline,
        priority: NotificationPriority.medium,
        timestamp: now.subtract(const Duration(hours: 3)),
      ),
    ];
  }

  void _showNotificationPanel() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => Dialog(
        alignment: Alignment.topRight,
        insetPadding: EdgeInsets.only(
          top: ResponsiveLayout.valueByDevice(
            context: context,
            mobile: 0,
            mobileWide: 60,
            tablet: 80,
            desktop: 80,
          ),
          right: ResponsiveLayout.valueByDevice(
            context: context,
            mobile: 0,
            mobileWide: 16,
            tablet: 24,
            desktop: 24,
          ),
        ),
        backgroundColor: Colors.transparent,
        child: NotificationPanelWidget(
          notifications: _notifications,
          onNotificationTap: (notification) {
            if (notification.actionRoute != null) {
              Navigator.pop(context);
              // Navigate to action route
            }
          },
          onMarkAsRead: (id) {
            setState(() {
              final index = _notifications.indexWhere((n) => n.id == id);
              if (index != -1) {
                _notifications[index] = NotificationItem(
                  id: _notifications[index].id,
                  title: _notifications[index].title,
                  message: _notifications[index].message,
                  type: _notifications[index].type,
                  priority: _notifications[index].priority,
                  timestamp: _notifications[index].timestamp,
                  isRead: true,
                  actionRoute: _notifications[index].actionRoute,
                );
              }
            });
          },
          onDeleteNotification: (id) {
            setState(() {
              _notifications.removeWhere((n) => n.id == id);
            });
          },
          onClearAll: () {
            setState(() {
              _notifications.clear();
            });
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  List<CalendarEvent> _getSampleEvents() {
    final now = DateTime.now();
    return [
      CalendarEvent(
        id: '1',
        title: 'Budget Review Meeting',
        date: now,
        type: EventType.meeting,
        description: 'Quarterly budget review with finance team',
      ),
      CalendarEvent(
        id: '2',
        title: 'Fund Transfer Deadline',
        date: now.add(const Duration(days: 2)),
        type: EventType.deadline,
        description: 'Final date for Q4 fund transfers',
      ),
      CalendarEvent(
        id: '3',
        title: 'Project Milestone - Phase 2',
        date: now.add(const Duration(days: 5)),
        type: EventType.milestone,
        description: 'Infrastructure development phase 2 completion',
      ),
      CalendarEvent(
        id: '4',
        title: 'Compliance Audit',
        date: now.add(const Duration(days: 7)),
        type: EventType.review,
        description: 'Annual compliance audit scheduled',
      ),
      CalendarEvent(
        id: '5',
        title: 'New Fund Allocation',
        date: now.add(const Duration(days: 10)),
        type: EventType.funds,
        description: 'Allocation of new central funds to states',
      ),
    ];
  }

  Widget _buildNationalHeatmap() {
    return const NationalHeatmapWidget();
  }

  Widget _buildCollaborationNetwork() {
    return const CollaborationNetworkWidget();
  }

  Widget _buildComplianceScoreboard() {
    return const ComplianceScoreboardWidget();
  }

  Widget _buildPerformanceLeaderboard() {
    return const NationalPerformanceLeaderboardWidget();
  }

  Widget _buildFundFlowView() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: ResponsiveLayout.getResponsivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DashboardSectionHeader(
            title: 'Multi-Stage Fund Flow',
            subtitle: 'Real-time tracking of fund movements from Centre to beneficiaries',
            icon: Icons.account_tree,
          ),
          SizedBox(height: ResponsiveLayout.getResponsiveSpacing(context)),
          SizedBox(
            height: ResponsiveLayout.getChartHeight(context),
            child: InteractiveSankeyWidget(
              initialData: MockFundFlowData.generateMockData(),
              onNodeTap: (nodeId) {
                debugPrint('Node tapped: $nodeId');
              },
              onLinkTap: (linkId) {
                debugPrint('Link tapped: $linkId');
              },
            ),
          ),
          SizedBox(height: ResponsiveLayout.getResponsiveSpacing(context) * 2),
          const DashboardSectionHeader(
            title: 'National Fund Tracker - Reconciliation Ledger',
            subtitle: 'Centralized PFMS vs Bank statement reconciliation across all states',
            icon: Icons.account_balance,
          ),
          SizedBox(height: ResponsiveLayout.getResponsiveSpacing(context)),
          SizedBox(
            height: ResponsiveLayout.getChartHeight(context),
            child: const DualEntryReconciliationWidget(
              title: 'National Fund Reconciliation',
              showDetailsPanel: false, // Compact view for dashboard integration
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsView() {
    return const PredictiveAnalyticsWidget();
  }

  Widget _buildCommunicationHub() {
    return const CommunicationHubPage();
  }

  Widget _buildRequestReviewPanel() {
    return const RequestReviewPanelWidget();
  }

  Widget _buildKpiSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
          DashboardKpiCard(
            label: 'States Participating',
            value: '$_totalStates',
            icon: Icons.location_city,
            color: Colors.blue,
            subtitle: 'Active states',
          ),
          DashboardKpiCard(
            label: 'Pending Approvals',
            value: '$_pendingApprovals',
            icon: Icons.pending_actions,
            color: Colors.orange,
            subtitle: 'Requires action',
            onTap: () {
              setState(() => _selectedIndex = 1);
            },
          ),
          DashboardKpiCard(
            label: 'Funds Allocated',
            value: '₹${_fundsAllocated.toStringAsFixed(0)}Cr',
            icon: Icons.account_balance_wallet,
            color: Colors.green,
            subtitle: 'Total disbursed',
          ),
          DashboardKpiCard(
            label: 'Active Projects',
            value: '$_activeProjects',
            icon: Icons.work,
            color: Colors.purple,
            subtitle: 'In progress',
          ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOverviewPage() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildKpiSection(),
          const DashboardSectionHeader(
            title: 'National Overview',
            subtitle: 'Geographic distribution of projects',
            icon: Icons.map,
          ),
          SizedBox(
            height: 600,
            child: _buildNationalHeatmap(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildOverviewPage(),
      _buildRequestReviewPanel(),
      _buildPerformanceLeaderboard(),
      _buildComplianceScoreboard(),
      _buildFundFlowView(),
      _buildCommunicationHub(),
    ];

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade700, Colors.indigo.shade700],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text('Centre Dashboard', style: TextStyle(color: Colors.white)),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                onPressed: _showNotificationPanel,
              ),
              if (_notifications.where((n) => !n.isRead).isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.red, width: 2),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Center(
                      child: Text(
                        '${_notifications.where((n) => !n.isRead).length}',
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          pages[_selectedIndex],
          const EventCalendarWidget(),
          const DashboardSwitcherWidget(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Overview',
          ),
          NavigationDestination(
            icon: Icon(Icons.approval_outlined),
            selectedIcon: Icon(Icons.approval),
            label: 'Approvals',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events),
            label: 'Performance',
          ),
          NavigationDestination(
            icon: Icon(Icons.rule_outlined),
            selectedIcon: Icon(Icons.rule),
            label: 'Compliance',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_outlined),
            selectedIcon: Icon(Icons.account_balance),
            label: 'Funds',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Communication',
          ),
        ],
      ),
    );
  }
}