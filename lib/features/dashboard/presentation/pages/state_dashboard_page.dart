import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/models/project_model.dart';
import '../../../../core/models/agency_model.dart';
import '../../../maps/widgets/interactive_map_widget.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/agency_capacity_optimizer_widget.dart';
import '../widgets/fund_allocation_simulator_widget.dart';
import '../widgets/district_capacity_planner_widget.dart';
import '../widgets/component_timeline_synchronizer_widget.dart';
import '../widgets/agency_performance_comparator_widget.dart';
import '../../../communication/presentation/pages/communication_hub_page.dart';
import '../../../../core/widgets/calendar_widget.dart';
import '../../../../core/theme/app_design_system.dart';

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
  bool _isCalendarExpanded = false;
  late AnimationController _sidebarAnimationController;
  late Animation<double> _sidebarAnimation;

  @override
  void initState() {
    super.initState();
    _loadMockData();
    _sidebarAnimationController = AnimationController(
      vsync: this,
      duration: AppDesignSystem.durationNormal,
    );
    _sidebarAnimation = CurvedAnimation(
      parent: _sidebarAnimationController,
      curve: AppDesignSystem.curveStandard,
    );
  }

  @override
  void dispose() {
    _sidebarAnimationController.dispose();
    super.dispose();
  }

  void _toggleCalendar() {
    setState(() {
      _isCalendarExpanded = !_isCalendarExpanded;
      if (_isCalendarExpanded) {
        _sidebarAnimationController.forward();
      } else {
        _sidebarAnimationController.reverse();
      }
    });
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

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildDistrictMap(),
      _buildDistrictCapacityPlanner(),
      _buildComponentTimeline(),
      _buildFundSimulator(),
      _buildAgencyComparator(),
      _buildAgencyOptimizer(),
      _buildCommunicationHub(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('State Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: AnimatedRotation(
              turns: _isCalendarExpanded ? 0.25 : 0,
              duration: AppDesignSystem.durationNormal,
              child: Icon(
                _isCalendarExpanded ? Icons.calendar_view_day : Icons.calendar_month,
                color: _isCalendarExpanded ? AppDesignSystem.vibrantTeal : null,
              ),
            ),
            onPressed: _toggleCalendar,
            tooltip: _isCalendarExpanded ? 'Collapse Calendar' : 'Expand Calendar',
          ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            child: pages[_selectedIndex],
          ),
          // Collapsible Calendar Sidebar
          AnimatedBuilder(
            animation: _sidebarAnimation,
            builder: (context, child) {
              return Container(
                width: 320 * _sidebarAnimation.value,
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  boxShadow: _sidebarAnimation.value > 0
                      ? AppDesignSystem.elevation4
                      : [],
                  border: Border(
                    left: BorderSide(
                      color: AppDesignSystem.neutral300.withValues(alpha: _sidebarAnimation.value),
                      width: 1,
                    ),
                  ),
                ),
                child: _sidebarAnimation.value > 0.3
                    ? Opacity(
                        opacity: (_sidebarAnimation.value - 0.3) / 0.7,
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppDesignSystem.deepIndigo,
                                    AppDesignSystem.vibrantTeal,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.event_note,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'State Schedule',
                                      style: AppDesignSystem.headlineSmall.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                    ),
                                    onPressed: _toggleCalendar,
                                    tooltip: 'Close Calendar',
                                  ),
                                ],
                              ),
                            ),
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
                      )
                    : const SizedBox.shrink(),
              );
            },
          ),
        ],
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
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: 'Capacity',
          ),
          NavigationDestination(
            icon: Icon(Icons.timeline_outlined),
            selectedIcon: Icon(Icons.timeline),
            label: 'Timeline',
          ),
          NavigationDestination(
            icon: Icon(Icons.calculate_outlined),
            selectedIcon: Icon(Icons.calculate),
            label: 'Simulator',
          ),
          NavigationDestination(
            icon: Icon(Icons.leaderboard_outlined),
            selectedIcon: Icon(Icons.leaderboard),
            label: 'Compare',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outlined),
            selectedIcon: Icon(Icons.people),
            label: 'Agencies',
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