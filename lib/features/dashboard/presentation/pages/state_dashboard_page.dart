import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/models/project_model.dart';
import '../../../../core/models/agency_model.dart';
import '../../../maps/widgets/interactive_map_widget.dart';
import '../widgets/agency_capacity_optimizer_widget.dart';
import '../widgets/fund_allocation_simulator_widget.dart';
import '../widgets/district_capacity_planner_widget.dart';
import '../widgets/component_timeline_synchronizer_widget.dart';
import '../widgets/agency_performance_comparator_widget.dart';
import '../../../communication/presentation/pages/communication_hub_page.dart';
import '../../../review_approval/presentation/widgets/state_review_panel_widget.dart';
import '../../../../core/widgets/calendar_widget.dart';
import '../../../../core/theme/app_design_system.dart';
import '../../../../core/widgets/dashboard_components.dart';
import '../../../../core/widgets/event_calendar_widget.dart';
import '../../../../core/widgets/notification_panel_widget.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../../../core/widgets/dashboard_switcher_widget.dart';
import '../../../fund_flow/widgets/dual_entry_reconciliation_widget.dart';
import '../widgets/enhanced_planning_dashboard_widget.dart';
import '../../../../core/utils/page_transitions.dart';

class StateDashboardPage extends ConsumerStatefulWidget {
  const StateDashboardPage({super.key});

  @override
  ConsumerState<StateDashboardPage> createState() => _StateDashboardPageState();
}

class _StateDashboardPageState extends ConsumerState<StateDashboardPage> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  final String _stateId = 'state_001'; // Mock state ID
  final List<ProjectModel> _projects = [];
  final List<AgencyModel> _agencies = [];
  List<NotificationItem> _notifications = [];

  // Mock KPI data
  final Map<String, dynamic> _kpiData = {
    'districts': 25,
    'pendingRequests': 8,
    'fundsAllocated': 2500.0,
    'activeAgencies': 42,
  };

  @override
  void initState() {
    super.initState();
    _loadMockData();
    _loadNotifications();
  }

  void _loadNotifications() {
    final now = DateTime.now();
    _notifications = [
      NotificationItem(
        id: '1',
        title: 'Pending Fund Requests',
        message: '8 agencies have submitted fund allocation requests requiring approval.',
        type: NotificationType.approval,
        priority: NotificationPriority.high,
        timestamp: now.subtract(const Duration(hours: 1)),
      ),
      NotificationItem(
        id: '2',
        title: 'District Report Due',
        message: 'District XYZ quarterly report submission deadline is tomorrow.',
        type: NotificationType.deadline,
        priority: NotificationPriority.high,
        timestamp: now.subtract(const Duration(hours: 3)),
      ),
      NotificationItem(
        id: '3',
        title: 'New Agency Registration',
        message: 'Agency ABC has completed registration and awaits verification.',
        type: NotificationType.info,
        priority: NotificationPriority.medium,
        timestamp: now.subtract(const Duration(hours: 6)),
        isRead: true,
      ),
      NotificationItem(
        id: '4',
        title: 'Budget Allocation Approved',
        message: '₹50Cr budget allocation for infrastructure projects has been approved.',
        type: NotificationType.success,
        priority: NotificationPriority.medium,
        timestamp: now.subtract(const Duration(days: 1)),
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
            tablet: 16,
            desktop: 16,
          ),
        ),
        backgroundColor: Colors.transparent,
        child: NotificationPanelWidget(
          notifications: _notifications,
          onNotificationTap: (notification) {
            if (notification.actionRoute != null) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Navigate to: ${notification.actionRoute}'),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
          onMarkAsRead: (id) {
            setState(() {
              final index = _notifications.indexWhere((n) => n.id == id);
              if (index != -1) {
                _notifications[index] = _notifications[index].copyWith(isRead: true);
              }
            });
          },
          onMarkAllAsRead: () {
            setState(() {
              _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
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
        title: 'District Budget Meeting',
        date: now,
        type: EventType.meeting,
        description: 'Monthly district budget review',
      ),
      CalendarEvent(
        id: '2',
        title: 'Project Deadline - Phase 1',
        date: now.add(const Duration(days: 3)),
        type: EventType.deadline,
        description: 'Complete district infrastructure phase 1',
      ),
      CalendarEvent(
        id: '3',
        title: 'State Funds Released',
        date: now.add(const Duration(days: 5)),
        type: EventType.funds,
        description: 'Quarterly state fund allocation',
      ),
      CalendarEvent(
        id: '4',
        title: 'Capacity Planning Review',
        date: now.add(const Duration(days: 8)),
        type: EventType.review,
        description: 'Review district capacity planning',
      ),
    ];
  }

  void _loadMockData() {
    _projects.addAll([
      ProjectModel(
        id: '1',
        name: 'State-Level Development',
        description: 'District-wise project implementation',
        status: ProjectStatus.inProgress,
        component: ProjectComponent.adarshGram,
        location: const LatLng(28.6139, 77.2090),
        completionPercentage: 72.5,
        allocatedBudget: 1000.0,
        beneficiariesCount: 10000,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ]);
  }

  Widget _buildKpiSection() {
    return Padding(
      padding: ResponsiveLayout.getResponsivePadding(context),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return GridView.count(
            crossAxisCount: ResponsiveLayout.getKpiGridColumns(context),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: ResponsiveLayout.getResponsiveSpacing(context),
            crossAxisSpacing: ResponsiveLayout.getResponsiveSpacing(context),
            childAspectRatio: ResponsiveLayout.getKpiAspectRatio(context),
            children: [
          DashboardKpiCard(
            label: 'Districts',
            value: '${_kpiData['districts']}',
            icon: Icons.location_city,
            color: AppDesignSystem.deepIndigo,
          ),
          DashboardKpiCard(
            label: 'Pending Requests',
            value: '${_kpiData['pendingRequests']}',
            icon: Icons.pending_actions,
            color: AppDesignSystem.sunsetOrange,
            onTap: () {
              setState(() => _selectedIndex = 1);
            },
          ),
          DashboardKpiCard(
            label: 'Funds Allocated',
            value: '₹${(_kpiData['fundsAllocated'] as double).toStringAsFixed(1)}Cr',
            icon: Icons.account_balance,
            color: AppDesignSystem.forestGreen,
          ),
          DashboardKpiCard(
            label: 'Active Agencies',
            value: '${_kpiData['activeAgencies']}',
            icon: Icons.business,
            color: AppDesignSystem.vibrantTeal,
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
      padding: ResponsiveLayout.getResponsivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildKpiSection(),
          SizedBox(height: ResponsiveLayout.getResponsiveSpacing(context) * 2),
          const DashboardSectionHeader(
            title: 'District Overview',
            subtitle: 'Geographic distribution of projects and agencies',
          ),
          SizedBox(height: ResponsiveLayout.getResponsiveSpacing(context)),
          SizedBox(
            height: ResponsiveLayout.getMapHeight(context),
            child: _buildDistrictMap(),
          ),
          SizedBox(height: ResponsiveLayout.getResponsiveSpacing(context) * 2),
          const DashboardSectionHeader(
            title: 'Fund Overview - Reconciliation Ledger',
            subtitle: 'State-level PFMS vs Bank statement reconciliation',
          ),
          SizedBox(height: ResponsiveLayout.getResponsiveSpacing(context)),
          SizedBox(
            height: ResponsiveLayout.getChartHeight(context),
            child: const DualEntryReconciliationWidget(
              title: 'State Fund Reconciliation',
              showDetailsPanel: false, // Compact view for dashboard integration
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistrictMap() {
    return InteractiveMapWidget(
      projects: _projects,
      agencies: _agencies,
      initialCenter: const LatLng(28.6139, 77.2090),
      initialZoom: 7.0,
      onProjectTap: (projectId) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Project: $projectId')),
        );
      },
    );
  }

  Widget _buildAgencyOptimizer() {
    return const AgencyCapacityOptimizerWidget();
  }

  Widget _buildFundSimulator() {
    return FundAllocationSimulatorWidget(stateId: _stateId);
  }

  Widget _buildDistrictCapacityPlanner() {
    return DistrictCapacityPlannerWidget(stateId: _stateId);
  }

  Widget _buildComponentTimeline() {
    return ComponentTimelineSynchronizerWidget(stateId: _stateId);
  }

  Widget _buildAgencyComparator() {
    return AgencyPerformanceComparatorWidget(stateId: _stateId);
  }

  Widget _buildCommunicationHub() {
    return const CommunicationHubPage();
  }

  Widget _buildReviewPanel() {
    return const StateReviewPanelWidget();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildOverviewPage(),
      _buildReviewPanel(),
      EnhancedPlanningDashboardWidget(stateId: _stateId),
      _buildFundSimulator(),
      _buildAgencyComparator(),
      _buildCommunicationHub(),
    ];

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppDesignSystem.deepIndigo,
                AppDesignSystem.vibrantTeal,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'State Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
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
                      color: AppDesignSystem.sunsetOrange,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Center(
                      child: Text(
                        '${_notifications.where((n) => !n.isRead).length}',
                        style: const TextStyle(
                          color: Colors.white,
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
          AnimatedIndexedStack(
            index: _selectedIndex,
            children: pages,
          ),
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
            label: 'Requests',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: 'Planning',
          ),
          NavigationDestination(
            icon: Icon(Icons.calculate_outlined),
            selectedIcon: Icon(Icons.calculate),
            label: 'Funds',
          ),
          NavigationDestination(
            icon: Icon(Icons.leaderboard_outlined),
            selectedIcon: Icon(Icons.leaderboard),
            label: 'Performance',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Comms',
          ),
        ],
      ),
    );
  }
}