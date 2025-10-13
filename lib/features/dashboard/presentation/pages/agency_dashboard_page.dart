import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/models/project_model.dart';
import '../../../../core/models/agency_model.dart';
import '../../../maps/widgets/interactive_map_widget.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/smart_milestone_claims_widget.dart';
import '../widgets/smart_milestone_workflow_widget.dart';
import '../widgets/resource_proximity_map_widget.dart';
import '../widgets/performance_analytics_widget.dart';
import '../../../communication/presentation/pages/communication_hub_page.dart';
import '../../../../core/widgets/calendar_widget.dart';
import '../../../../core/theme/app_design_system.dart';
import '../../../../core/widgets/dashboard_components.dart';
import '../../../../core/widgets/event_calendar_widget.dart';
import '../../../../core/widgets/notification_panel_widget.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../../../core/widgets/dashboard_switcher_widget.dart';
import '../../../../core/utils/page_transitions.dart';

class AgencyDashboardPage extends ConsumerStatefulWidget {
  const AgencyDashboardPage({super.key});

  @override
  ConsumerState<AgencyDashboardPage> createState() => _AgencyDashboardPageState();
}

class _AgencyDashboardPageState extends ConsumerState<AgencyDashboardPage> {
  int _selectedIndex = 0;
  
  // Mock data - will be replaced with actual Supabase data
  final List<ProjectModel> _projects = [];
  final List<AgencyModel> _agencies = [];
  List<NotificationItem> _notifications = [];
  
  // Mock KPI data
  final Map<String, dynamic> _kpiData = {
    'activeProjects': 3,
    'completionRate': 78.5,
    'pendingClaims': 5,
    'performanceScore': 92.0,
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
        title: 'Milestone Claim Approved',
        message: 'Your claim for Milestone M3 has been approved. ₹10Cr will be disbursed.',
        type: NotificationType.success,
        priority: NotificationPriority.high,
        timestamp: now.subtract(const Duration(minutes: 30)),
      ),
      NotificationItem(
        id: '2',
        title: 'Pending Claims Review',
        message: '5 milestone claims are pending review by state authorities.',
        type: NotificationType.warning,
        priority: NotificationPriority.high,
        timestamp: now.subtract(const Duration(hours: 2)),
      ),
      NotificationItem(
        id: '3',
        title: 'Document Upload Required',
        message: 'Please upload completion certificates for Project ABC Phase 2.',
        type: NotificationType.deadline,
        priority: NotificationPriority.medium,
        timestamp: now.subtract(const Duration(hours: 5)),
        isRead: true,
      ),
      NotificationItem(
        id: '4',
        title: 'Performance Review Scheduled',
        message: 'Quarterly performance review meeting scheduled for next week.',
        type: NotificationType.info,
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

  void _loadMockData() {
    // Mock projects
    _projects.addAll([
      ProjectModel(
        id: '1',
        name: 'Adarsh Gram Development - Village A',
        description: 'Comprehensive village development project',
        status: ProjectStatus.inProgress,
        component: ProjectComponent.adarshGram,
        location: const LatLng(28.6139, 77.2090),
        completionPercentage: 65.5,
        allocatedBudget: 150.0,
        beneficiariesCount: 250,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ProjectModel(
        id: '2',
        name: 'Hostel Construction Project',
        description: 'Building hostel facilities for students',
        status: ProjectStatus.completed,
        component: ProjectComponent.hostel,
        location: const LatLng(28.5355, 77.3910),
        completionPercentage: 100.0,
        allocatedBudget: 200.0,
        beneficiariesCount: 150,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ProjectModel(
        id: '3',
        name: 'Village Infrastructure GIA',
        description: 'Grant-in-Aid for infrastructure development',
        status: ProjectStatus.onHold,
        component: ProjectComponent.gia,
        location: const LatLng(28.7041, 77.1025),
        completionPercentage: 45.0,
        allocatedBudget: 100.0,
        beneficiariesCount: 180,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ]);

    // Mock agencies
    _agencies.addAll([
      AgencyModel(
        id: '1',
        name: 'Delhi Development Agency',
        type: AgencyType.implementingAgency,
        location: const LatLng(28.6139, 77.2090),
        capacityScore: 0.85,
        performanceRating: 0.92,
        phone: '+91-11-12345678',
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
            label: 'Active Projects',
            value: '${_kpiData['activeProjects']}',
            icon: Icons.assignment,
            color: AppDesignSystem.deepIndigo,
            onTap: () {
              setState(() => _selectedIndex = 1);
            },
          ),
          DashboardKpiCard(
            label: 'Completion Rate',
            value: '${(_kpiData['completionRate'] as double).toStringAsFixed(1)}%',
            icon: Icons.trending_up,
            color: AppDesignSystem.forestGreen,
          ),
          DashboardKpiCard(
            label: 'Pending Claims',
            value: '${_kpiData['pendingClaims']}',
            icon: Icons.pending_actions,
            color: AppDesignSystem.sunsetOrange,
            onTap: () {
              setState(() => _selectedIndex = 2);
            },
          ),
          DashboardKpiCard(
            label: 'Performance Score',
            value: '${(_kpiData['performanceScore'] as double).toStringAsFixed(0)}%',
            icon: Icons.star,
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
          ResponsiveLayout.responsiveFlex(
            context: context,
            spacing: ResponsiveLayout.getResponsiveSpacing(context),
            children: [
              Expanded(
                child: DashboardActionButton(
                  label: 'Submit Milestone',
                  icon: Icons.flag,
                  onPressed: () {
                    setState(() => _selectedIndex = 2);
                  },
                ),
              ),
              Expanded(
                child: DashboardActionButton(
                  label: 'View Analytics',
                  icon: Icons.analytics,
                  isOutlined: true,
                  onPressed: () {
                    setState(() => _selectedIndex = 4);
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveLayout.getResponsiveSpacing(context) * 2),
          const DashboardSectionHeader(
            title: 'Project Locations',
            subtitle: 'Geographic distribution of your projects',
          ),
          SizedBox(height: ResponsiveLayout.getResponsiveSpacing(context)),
          SizedBox(
            height: ResponsiveLayout.getMapHeight(context),
            child: _buildMapView(),
          ),
        ],
      ),
    );
  }

  Widget _buildMapView() {
    return InteractiveMapWidget(
      projects: _projects,
      agencies: _agencies,
      initialCenter: const LatLng(28.6139, 77.2090),
      initialZoom: 10.0,
      onProjectTap: (projectId) {
        // Handle project tap
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Project tapped: $projectId')),
        );
      },
      onAgencyTap: (agencyId) {
        // Handle agency tap
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Agency tapped: $agencyId')),
        );
      },
    );
  }

  Widget _buildProjectsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _projects.length,
      itemBuilder: (context, index) {
        final project = _projects[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(project.status),
              child: Icon(
                _getStatusIcon(project.status),
                color: Colors.white,
              ),
            ),
            title: Text(project.name),
            subtitle: Text('${project.completionPercentage.toStringAsFixed(1)}% Complete'),
            trailing: Chip(
              label: Text(project.status.value),
              backgroundColor: _getStatusColor(project.status).withOpacity(0.2),
            ),
            onTap: () {
              // Navigate to project details
            },
          ),
        );
      },
    );
  }

  Widget _buildMilestonesView() {
    return const SmartMilestoneClaimsWidget();
  }

  Widget _buildSmartMilestoneWorkflow() {
    return const SmartMilestoneWorkflowWidget(agencyId: 'mock-agency-id');
  }

  Widget _buildResourceProximityMap() {
    return const ResourceProximityMapWidget(agencyId: 'mock-agency-id');
  }

  Widget _buildPerformanceView() {
    // TODO: Replace with actual agency ID from auth/session
    return const PerformanceAnalyticsWidget(
      agencyId: 'mock-agency-id',
    );
  }

  Widget _buildCommunicationHub() {
    return const CommunicationHubPage();
  }

  List<CalendarEvent> _getSampleEvents() {
    final now = DateTime.now();
    return [
      CalendarEvent(
        id: '1',
        title: 'Project Review Meeting',
        date: now,
        type: EventType.meeting,
        description: 'Review progress on Adarsh Gram project',
      ),
      CalendarEvent(
        id: '2',
        title: 'Milestone Submission Deadline',
        date: now.add(const Duration(days: 2)),
        type: EventType.deadline,
        description: 'Submit milestone claims for Q4',
      ),
      CalendarEvent(
        id: '3',
        title: 'Resource Allocation',
        date: now.add(const Duration(days: 4)),
        type: EventType.funds,
        description: 'Allocate resources for new projects',
      ),
      CalendarEvent(
        id: '4',
        title: 'Performance Review',
        date: now.add(const Duration(days: 6)),
        type: EventType.review,
        description: 'Agency quarterly performance review',
      ),
      CalendarEvent(
        id: '5',
        title: 'Milestone Achieved',
        date: now.add(const Duration(days: 9)),
        type: EventType.milestone,
        description: 'Hostel construction phase completion',
      ),
    ];
  }


  Color _getStatusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.completed:
        return AppTheme.successGreen;
      case ProjectStatus.inProgress:
        return AppTheme.secondaryBlue;
      case ProjectStatus.onHold:
        return AppTheme.warningOrange;
      case ProjectStatus.planning:
        return Colors.purple;
      case ProjectStatus.review:
        return Colors.amber;
      case ProjectStatus.cancelled:
        return AppTheme.errorRed;
    }
  }

  IconData _getStatusIcon(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.completed:
        return Icons.check_circle;
      case ProjectStatus.inProgress:
        return Icons.access_time;
      case ProjectStatus.onHold:
        return Icons.pause_circle;
      case ProjectStatus.planning:
        return Icons.pending;
      case ProjectStatus.review:
        return Icons.rate_review;
      case ProjectStatus.cancelled:
        return Icons.cancel;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildOverviewPage(),
      _buildProjectsList(),
      _buildMilestonesView(),
      _buildResourceProximityMap(),
      _buildPerformanceView(),
      _buildCommunicationHub(),
    ];

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppDesignSystem.royalPurple,
                AppDesignSystem.deepIndigo,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'Agency Dashboard',
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
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () {},
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
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'Projects',
          ),
          NavigationDestination(
            icon: Icon(Icons.flag_outlined),
            selectedIcon: Icon(Icons.flag),
            label: 'Claims',
          ),
          NavigationDestination(
            icon: Icon(Icons.place_outlined),
            selectedIcon: Icon(Icons.place),
            label: 'Resources',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: 'Analytics',
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