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

  @override
  void initState() {
    super.initState();
    _loadMockData();
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

  void _showCalendarBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              boxShadow: AppDesignSystem.elevation4,
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppDesignSystem.neutral400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppDesignSystem.deepIndigo,
                        AppDesignSystem.vibrantTeal,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: Colors.white,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Agency Calendar',
                          style: AppDesignSystem.headlineMedium.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                // Calendar content
                Expanded(
                  child: PMCalendarWidget(
                    events: _getSampleEvents(),
                    onEventTap: (event) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Selected: ${event.title}'),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
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
      _buildMapView(),
      _buildProjectsList(),
      _buildMilestonesView(),
      _buildSmartMilestoneWorkflow(),
      _buildResourceProximityMap(),
      _buildPerformanceView(),
      _buildCommunicationHub(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agency Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: pages[_selectedIndex],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCalendarBottomSheet(context),
        icon: const Icon(Icons.event),
        label: const Text('Schedule'),
        backgroundColor: AppDesignSystem.vibrantTeal,
        elevation: 6,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Map',
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
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome),
            label: 'Workflow',
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
            label: 'Comm',
          ),
        ],
      ),
    );
  }
}